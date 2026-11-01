//
//  TallyActivityWidget.swift
//  TallyLiveActivity
//

import ActivityKit
import AppIntents
import SwiftUI
import WidgetKit

/// Today's tally on the Lock Screen and in the Dynamic Island, with buttons that log without opening the app.
struct TallyActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TallyActivityAttributes.self) { context in
            TallyActivityLockScreenView(counts: context.state, isStale: context.isStale)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) {
                    TallyCountLabel(type: .distracted, count: context.state.distracted)
                        .padding(.leading, 6)
                }
                DynamicIslandExpandedRegion(.trailing) {
                    TallyCountLabel(type: .resisted, count: context.state.resisted, alignment: .trailing)
                        .padding(.trailing, 6)
                }
                DynamicIslandExpandedRegion(.bottom) {
                    TallyLogButtons()
                }
            } compactLeading: {
                TallyCompactCount(type: .distracted, count: context.state.distracted)
            } compactTrailing: {
                TallyCompactCount(type: .resisted, count: context.state.resisted)
            } minimal: {
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(.tint)
                    .accessibilityLabel("Tally Mark")
            }
            .keylineTint(.green)
        }
    }
}

struct TallyActivityLockScreenView: View {
    let counts: DayCounts
    let isStale: Bool

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                TallyCountLabel(type: .distracted, count: counts.distracted)
                Spacer()
                TallyCountLabel(type: .resisted, count: counts.resisted, alignment: .trailing)
            }
            if isStale {
                Text("New day. Log a tally to start today's count.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            TallyLogButtons()
        }
        .padding()
    }
}

struct TallyCountLabel: View {
    let type: EventType
    let count: Int
    var alignment: HorizontalAlignment = .leading

    var body: some View {
        VStack(alignment: alignment, spacing: 2) {
            Label {
                Text(type.title)
            } icon: {
                Image(systemName: type.systemImage)
            }
            .font(.caption)
            .foregroundStyle(type.color)
            .lineLimit(1)
            .fixedSize()
            Text(count, format: .number)
                .font(.title.bold())
                .contentTransition(.numericText(value: Double(count)))
        }
        .accessibilityElement(children: .combine)
    }
}

struct TallyCompactCount: View {
    let type: EventType
    let count: Int

    var body: some View {
        Text(count, format: .number)
            .foregroundStyle(type.color)
            .contentTransition(.numericText(value: Double(count)))
            .accessibilityLabel(Text("\(count) \(type.title)"))
    }
}

struct TallyLogButtons: View {
    var body: some View {
        HStack {
            ForEach(EventType.allCases, id: \.self) { type in
                Button(intent: LogEventIntent(type: type)) {
                    Label {
                        Text(type.shortTitle)
                    } icon: {
                        Image(systemName: "plus")
                    }
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(type.color)
                .accessibilityLabel(Text(type.logTitle))
            }
        }
    }
}

#Preview("Lock Screen", as: .content, using: TallyActivityAttributes()) {
    TallyActivityWidget()
} contentStates: {
    DayCounts(distracted: 0, resisted: 0)
    DayCounts(distracted: 3, resisted: 7)
}

#Preview("Dynamic Island", as: .dynamicIsland(.expanded), using: TallyActivityAttributes()) {
    TallyActivityWidget()
} contentStates: {
    DayCounts(distracted: 3, resisted: 7)
}
