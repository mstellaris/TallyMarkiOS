//
//  DaySummary.swift
//  TallyMarkiOS
//

import Foundation

/// Totals for one calendar day. Identified by the day's start so list and chart identity is stable.
struct DaySummary: Identifiable, Hashable {
    let date: Date
    var counts: DayCounts

    var id: Date { date }

    /// One summary per day that has events, newest first.
    static func summaries(for events: some Sequence<DistractionEvent>, calendar: Calendar = .current) -> [DaySummary] {
        var countsByDay: [Date: DayCounts] = [:]
        for event in events {
            guard let type = event.type else { continue }
            countsByDay[calendar.startOfDay(for: event.timestamp), default: DayCounts()][type] += 1
        }
        return countsByDay
            .map { DaySummary(date: $0.key, counts: $0.value) }
            .sorted { $0.date > $1.date }
    }

    /// The `dayCount` calendar days ending on `endDate`, oldest first, with empty days filled in.
    static func recentDays(
        _ dayCount: Int,
        endingOn endDate: Date,
        from summaries: [DaySummary],
        calendar: Calendar = .current
    ) -> [DaySummary] {
        let countsByDay = Dictionary(summaries.map { ($0.date, $0.counts) }, uniquingKeysWith: { first, _ in first })
        let lastDay = calendar.startOfDay(for: endDate)
        return (0..<dayCount).reversed().compactMap { offset in
            guard let day = calendar.date(byAdding: .day, value: -offset, to: lastDay) else { return nil }
            let start = calendar.startOfDay(for: day)
            return DaySummary(date: start, counts: countsByDay[start] ?? DayCounts())
        }
    }
}
