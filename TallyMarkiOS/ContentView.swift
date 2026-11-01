//
//  ContentView.swift
//  TallyMarkiOS
//
//  Created by Miltos on 2/2/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(TallyDataManager.self) private var dataManager
    @Environment(\.scenePhase) private var scenePhase
    /// Bumped on each log/undo tap so haptics don't fire for refreshes or the midnight reset.
    @State private var feedback: (tap: Int, feedback: SensoryFeedback) = (0, .increase)

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    if TallyStore.shared.loadError != nil {
                        StoreErrorBanner()
                    }
                    ForEach(EventType.allCases, id: \.self) { type in
                        TallySection(type: type, count: dataManager.today[type]) {
                            withAnimation {
                                dataManager.log(type)
                                feedback = (feedback.tap + 1, .increase)
                            }
                        }
                    }
                    LiveActivityToggle()
                }
                .padding()
            }
            .navigationTitle("Tally Mark")
            .navigationSubtitle(Text(dataManager.day, format: .dateTime.weekday(.wide).month(.wide).day()))
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Undo", systemImage: "arrow.uturn.backward") {
                        withAnimation {
                            dataManager.undoLast()
                            feedback = (feedback.tap + 1, .decrease)
                        }
                    }
                    .disabled(!dataManager.canUndo)
                }
                ToolbarItem(placement: .topBarTrailing) {
                    NavigationLink {
                        HistoryView()
                    } label: {
                        Label("History", systemImage: "clock.arrow.circlepath")
                    }
                }
            }
            .sensoryFeedback(trigger: feedback.tap) { _, _ in feedback.feedback }
            // Reload when returning to the app (it may have been logged to from the Live Activity, or a new
            // day may have started) and at midnight while the app stays open.
            .onChange(of: scenePhase, initial: true) { _, phase in
                if phase == .active {
                    dataManager.refresh()
                }
            }
            .task {
                for await _ in NotificationCenter.default.notifications(named: UIApplication.significantTimeChangeNotification) {
                    dataManager.refresh()
                }
            }
        }
    }
}

private struct TallySection: View {
    let type: EventType
    let count: Int
    let log: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Label {
                    Text(type.title)
                } icon: {
                    Image(systemName: type.systemImage)
                }
                .font(.headline)
                .foregroundStyle(type.color)
                Spacer()
                Text(count, format: .number)
                    .font(.title2.bold())
                    .monospacedDigit()
                    .contentTransition(.numericText(value: Double(count)))
            }
            // Explicit label: combining children would also pull in the symbol's own traits (e.g. "Selected").
            .accessibilityElement(children: .ignore)
            .accessibilityLabel(Text("\(type.title): \(count)"))

            TallyMarksView(count: count)
                .frame(maxWidth: .infinity, minHeight: 44, alignment: .leading)

            Button {
                log()
            } label: {
                Label {
                    Text(type.logTitle)
                } icon: {
                    Image(systemName: "plus")
                }
                .frame(maxWidth: .infinity)
            }
            .buttonStyle(.glassProminent)
            .controlSize(.large)
            .tint(type.color)
        }
        .padding()
        .background(.background.secondary, in: .rect(cornerRadius: 24))
    }
}

private struct LiveActivityToggle: View {
    @Environment(TallyDataManager.self) private var dataManager

    var body: some View {
        Toggle(isOn: Binding(
            get: { dataManager.isLiveActivityActive },
            set: { isOn in
                if isOn {
                    dataManager.startLiveActivity()
                } else {
                    dataManager.endLiveActivity()
                }
            }
        )) {
            Label {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Show on Lock Screen")
                    Text("Log from the Lock Screen and Dynamic Island.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } icon: {
                Image(systemName: "platter.filled.bottom.iphone")
            }
        }
        .padding()
        .background(.background.secondary, in: .rect(cornerRadius: 24))
    }
}

private struct StoreErrorBanner: View {
    var body: some View {
        Label(
            "Tallies can't be saved right now. Anything you log will be lost when the app closes.",
            systemImage: "exclamationmark.triangle.fill"
        )
        .font(.callout)
        .foregroundStyle(.orange)
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.orange.opacity(0.12), in: .rect(cornerRadius: 16))
    }
}

#Preview(traits: .sampleTallies) {
    ContentView()
}
