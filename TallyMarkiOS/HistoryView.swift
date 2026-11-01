//
//  HistoryView.swift
//  TallyMarkiOS
//

import SwiftUI
import CoreData
import Charts

struct DaySummary: Identifiable {
    let id = UUID()
    let date: Date
    let distractedCount: Int
    let resistedCount: Int
}

struct HistoryView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \DistractionEvent.timestamp, ascending: false)]
    ) private var events: FetchedResults<DistractionEvent>
    
    private var daySummaries: [DaySummary] {
        let calendar = Calendar.current
        let grouped = Dictionary(grouping: events) { event -> Date in
            calendar.startOfDay(for: event.timestamp ?? Date())
        }
        return grouped.map { (date, events) in
            DaySummary(
                date: date,
                distractedCount: events.filter { $0.eventType == "distracted" }.count,
                resistedCount: events.filter { $0.eventType == "resisted" }.count
            )
        }
        .sorted { $0.date > $1.date }
    }
    
    private var chartSummaries: [DaySummary] {
        Array(daySummaries.suffix(14).reversed())
    }
    
    var body: some View {
        List {
            // Chart section
            Section("Last 14 Days") {
                Chart {
                    ForEach(chartSummaries) { summary in
                        BarMark(
                            x: .value("Date", summary.date, unit: .day),
                            y: .value("Count", summary.distractedCount)
                        )
                        .foregroundStyle(.red.opacity(0.7))
                        .position(by: .value("Type", "Distracted"))
                        
                        BarMark(
                            x: .value("Date", summary.date, unit: .day),
                            y: .value("Count", summary.resistedCount)
                        )
                        .foregroundStyle(.green.opacity(0.7))
                        .position(by: .value("Type", "Resisted"))
                    }
                }
                .chartForegroundStyleScale([
                    "Distracted": Color.red.opacity(0.7),
                    "Resisted": Color.green.opacity(0.7)
                ])
                .frame(height: 200)
                .padding(.vertical, 8)
            }
            
            // Day-by-day list
            Section("All Days") {
                if daySummaries.isEmpty {
                    Text("No events recorded yet.")
                        .foregroundStyle(.secondary)
                } else {
                    ForEach(daySummaries) { summary in
                        HStack {
                            Text(summary.date, style: .date)
                            Spacer()
                            Label("\(summary.distractedCount)", systemImage: "xmark.circle")
                                .foregroundStyle(.red)
                            Label("\(summary.resistedCount)", systemImage: "checkmark.circle")
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
        }
        .navigationTitle("History")
    }
}

#Preview {
    NavigationStack {
        HistoryView()
            .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
