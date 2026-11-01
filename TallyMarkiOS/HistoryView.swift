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
        // Plot each day as its own category so every day, including today, gets an equal-width column.
        Chart(days) { day in
            ForEach(EventType.allCases, id: \.self) { type in
                BarMark(
                    x: .value("Date", Self.columnLabel(for: day.date)),
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
            // Label every third day counting back from today, so today is always labeled.
            AxisMarks { value in
                if let column = value.as(String.self), labeledColumns.contains(column) {
                    AxisValueLabel()
                }
            }
        }
    }

    private var labeledColumns: [String] {
        stride(from: days.count - 1, through: 0, by: -3).map { Self.columnLabel(for: days[$0].date) }
    }

    /// Unique within the chart's 14-day window.
    private static func columnLabel(for date: Date) -> String {
        date.formatted(.dateTime.month(.abbreviated).day())
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
            }
        }
        // Explicit label: combining children would also pull in the symbols' own traits (e.g. "Selected").
        .accessibilityElement(children: .ignore)
        .accessibilityLabel(Text("\(summary.date, format: .dateTime.weekday(.wide).month(.wide).day()): \(summary.counts.distracted) \(EventType.distracted.title), \(summary.counts.resisted) \(EventType.resisted.title)"))
    }
}

#Preview(traits: .sampleTallies) {
    NavigationStack {
        HistoryView()
    }
}
