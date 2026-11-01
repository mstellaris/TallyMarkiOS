//
//  TodayWidget.swift
//  TallyLiveActivity
//

import AppIntents
import SwiftData
import SwiftUI
import WidgetKit

nonisolated struct TodayEntry: TimelineEntry {
    let date: Date
    let counts: DayCounts
}

/// Reads today's counts from the shared App Group store, and schedules a zeroed entry for midnight.
nonisolated struct TodayProvider: TimelineProvider {
    func placeholder(in context: Context) -> TodayEntry {
        TodayEntry(date: .now, counts: DayCounts(distracted: 2, resisted: 5))
    }

    func getSnapshot(in context: Context, completion: @escaping (TodayEntry) -> Void) {
        completion(context.isPreview ? placeholder(in: context) : entry(for: .now))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<TodayEntry>) -> Void) {
        let now = Date.now
        let midnight = TallyStore.dayInterval(containing: now).end
        let entries = [entry(for: now), TodayEntry(date: midnight, counts: DayCounts())]
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func entry(for date: Date) -> TodayEntry {
        let context = ModelContext(TallyStore.container)
        let counts = (try? TallyStore.counts(on: date, in: context)) ?? DayCounts()
        return TodayEntry(date: date, counts: counts)
    }
}

struct TodayWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "TodayWidget", provider: TodayProvider()) { entry in
            TodayWidgetView(counts: entry.counts)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("Today's Tally")
        .description("See today's distractions and resisted moments, and log new ones.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular, .accessoryInline])
    }
}

struct TodayWidgetView: View {
    @Environment(\.widgetFamily) private var family
    let counts: DayCounts

    var body: some View {
        switch family {
        case .accessoryInline:
            Text("\(counts.distracted) distracted · \(counts.resisted) resisted")
        case .accessoryRectangular:
            VStack(alignment: .leading) {
                Text("Today")
                    .font(.headline)
                ForEach(EventType.allCases, id: \.self) { type in
                    Label {
                        Text("\(counts[type]) \(type.shortTitle)")
                    } icon: {
                        Image(systemName: type.systemImage)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        case .systemMedium:
            VStack(spacing: 12) {
                counters
                TallyLogButtons()
            }
        default:
            VStack(alignment: .leading, spacing: 12) {
                ForEach(EventType.allCases, id: \.self) { type in
                    TallyCountLabel(type: type, count: counts[type])
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
    }

    private var counters: some View {
        HStack {
            TallyCountLabel(type: .distracted, count: counts.distracted)
            Spacer()
            TallyCountLabel(type: .resisted, count: counts.resisted, alignment: .trailing)
        }
    }
}

#Preview("Small", as: .systemSmall) {
    TodayWidget()
} timeline: {
    TodayEntry(date: .now, counts: DayCounts(distracted: 3, resisted: 7))
}

#Preview("Medium", as: .systemMedium) {
    TodayWidget()
} timeline: {
    TodayEntry(date: .now, counts: DayCounts(distracted: 3, resisted: 7))
}

#Preview("Lock Screen", as: .accessoryRectangular) {
    TodayWidget()
} timeline: {
    TodayEntry(date: .now, counts: DayCounts(distracted: 3, resisted: 7))
}
