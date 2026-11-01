//
//  HistoryView.swift
//  TallyMarkiOS
//

import Charts
import SwiftData
import SwiftUI

struct HistoryView: View {
    @Query(sort: \DistractionEvent.timestamp, order: .reverse)
    private var events: [DistractionEvent]

    var body: some View {
        let summaries = DaySummary.summaries(for: events)

        List {
            Section("Last 14 Days") {
                HistoryChart(days: DaySummary.recentDays(14, endingOn: .now, from: summaries))
                    .frame(height: 200)
                    .padding(.vertical, 8)
            }

            Section("All Days") {
                if summaries.isEmpty {
                    ContentUnavailableView("No Tallies Yet", systemImage: "chart.bar", description: Text("Logged distractions and resisted moments appear here."))
                } else {
                    ForEach(summaries) { summary in
                        HistoryRow(summary: summary)
                    }
                }
            }
        }
        .navigationTitle("History")
    }
}

private struct HistoryChart: View {
    let days: [DaySummary]

    var body: some View {
        Chart(days) { day in
            ForEach(EventType.allCases, id: \.self) { type in
                BarMark(
                    x: .value("Date", day.date, unit: .day),
                    y: .value("Count", day.counts[type])
                )
                .foregroundStyle(by: .value("Type", String(localized: type.shortTitle)))
                .position(by: .value("Type", String(localized: type.shortTitle)))
            }
        }
        .chartForegroundStyleScale(
            domain: EventType.allCases.map { String(localized: $0.shortTitle) },
            range: EventType.allCases.map(\.color)
        )
        .chartXAxis {
            AxisMarks(values: .stride(by: .day, count: 2)) {
                AxisGridLine()
                AxisValueLabel(format: .dateTime.day().month(.abbreviated))
            }
        }
    }
}

private struct HistoryRow: View {
    let summary: DaySummary

    var body: some View {
        HStack {
            Text(summary.date, format: .dateTime.weekday(.abbreviated).day().month(.abbreviated).year())
            Spacer()
            ForEach(EventType.allCases, id: \.self) { type in
                Label {
                    Text(summary.counts[type], format: .number)
                } icon: {
                    Image(systemName: type.systemImage)
                }
                .foregroundStyle(type.color)
                .accessibilityLabel(Text("\(summary.counts[type]) \(type.title)"))
            }
        }
        .accessibilityElement(children: .combine)
    }
}

#Preview(traits: .sampleTallies) {
    NavigationStack {
        HistoryView()
    }
}
