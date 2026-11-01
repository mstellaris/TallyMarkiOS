//
//  TallyDataManager.swift
//  TallyMarkiOS
//

import ActivityKit
import Foundation
import OSLog
import SwiftData
import WidgetKit

/// The single owner of today's tally. The app UI and `LogEventIntent` (which runs in the app's
/// process when tapped in the Live Activity or a widget) both go through `shared`.
@Observable
final class TallyDataManager {
    static let shared = TallyDataManager(container: TallyStore.container)

    /// The start of the day `today` counts. Changes at midnight on the next `refresh()`.
    private(set) var day = Date.now
    private(set) var today = DayCounts()
    private(set) var isLiveActivityActive = false

    var canUndo: Bool { today.total > 0 }

    private let context: ModelContext
    private let calendar: Calendar
    private let now: () -> Date
    private let logger = Logger(subsystem: "com.hyperstellarlabs.TallyMarkiOS", category: "TallyDataManager")

    private var activityID: String?
    private var activityObservation: Task<Void, Never>?

    init(container: ModelContainer, calendar: Calendar = .current, now: @escaping () -> Date = { .now }) {
        self.context = container.mainContext
        self.calendar = calendar
        self.now = now
        refresh()
    }

    /// Reloads today's counts. Call when the app becomes active or the day changes, so counts reset at midnight.
    func refresh() {
        let date = now()
        day = calendar.startOfDay(for: date)
        do {
            today = try TallyStore.counts(on: date, in: context, calendar: calendar)
        } catch {
            logger.error("Couldn't load today's counts: \(error)")
        }
        reconnectLiveActivity()
        updateLiveActivity()
    }

    func log(_ type: EventType) {
        context.insert(DistractionEvent(type: type, timestamp: now()))
        saveAndPublish()
    }

    /// Removes the most recent event logged today. Earlier days are never touched.
    func undoLast() {
        do {
            guard let latest = try TallyStore.latestEvent(on: now(), in: context, calendar: calendar) else { return }
            context.delete(latest)
            saveAndPublish()
        } catch {
            logger.error("Couldn't find the event to undo: \(error)")
        }
    }

    private func saveAndPublish() {
        do {
            try context.save()
        } catch {
            logger.error("Couldn't save: \(error)")
            context.rollback()
        }
        refresh()
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Live Activity

    func startLiveActivity() {
        guard !isLiveActivityActive, ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        do {
            let activity = try Activity.request(
                attributes: TallyActivityAttributes(),
                content: activityContent(),
                pushType: nil
            )
            track(activity)
        } catch {
            logger.error("Couldn't start Live Activity: \(error)")
        }
    }

    func endLiveActivity() {
        guard let id = activityID else { return }
        let content = activityContent()
        stopTracking()
        Task {
            await Self.end(activityID: id, with: content)
        }
    }

    private func updateLiveActivity() {
        guard let id = activityID else { return }
        let content = activityContent()
        Task {
            await Self.update(activityID: id, with: content)
        }
    }

    /// Marks the activity stale at midnight so the Lock Screen doesn't present yesterday's tally as today's.
    private func activityContent() -> ActivityContent<DayCounts> {
        ActivityContent(state: today, staleDate: TallyStore.dayInterval(containing: now(), calendar: calendar).end)
    }

    /// Picks up an activity that's still running from a previous launch.
    private func reconnectLiveActivity() {
        guard activityID == nil,
              let running = Activity<TallyActivityAttributes>.activities.first(where: { $0.activityState == .active || $0.activityState == .stale })
        else { return }
        track(running)
    }

    private func track(_ activity: Activity<TallyActivityAttributes>) {
        activityID = activity.id
        isLiveActivityActive = true
        activityObservation?.cancel()
        // Notice when the person dismisses the activity from the Lock Screen or the system ends it.
        activityObservation = Task { [weak self] in
            for await state in activity.activityStateUpdates where state == .ended || state == .dismissed {
                self?.stopTracking()
                return
            }
        }
    }

    private func stopTracking() {
        activityObservation?.cancel()
        activityObservation = nil
        activityID = nil
        isLiveActivityActive = false
    }

    // `Activity` isn't Sendable, so look it up by ID off the main actor instead of passing it across.
    @concurrent
    private nonisolated static func update(activityID: String, with content: ActivityContent<DayCounts>) async {
        guard let activity = Activity<TallyActivityAttributes>.activities.first(where: { $0.id == activityID }) else { return }
        await activity.update(content)
    }

    @concurrent
    private nonisolated static func end(activityID: String, with content: ActivityContent<DayCounts>) async {
        guard let activity = Activity<TallyActivityAttributes>.activities.first(where: { $0.id == activityID }) else { return }
        await activity.end(content, dismissalPolicy: .default)
    }
}
