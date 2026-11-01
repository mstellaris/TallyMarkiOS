//
//  TallyStore.swift
//  TallyMarkiOS
//

import Foundation
import OSLog
import SwiftData

/// Owns the SwiftData container shared by the app and the widget extension through the App Group.
nonisolated enum TallyStore {
    static let appGroupID = "group.com.hyperstellarlabs.TallyMarkiOS"

    private static let logger = Logger(subsystem: "com.hyperstellarlabs.TallyMarkiOS", category: "TallyStore")

    /// The persistent container, or an in-memory one if the store couldn't be opened.
    /// Check `loadError` to tell the user their tallies won't be saved.
    static let shared: (container: ModelContainer, loadError: (any Error)?) = {
        do {
            return (try makeContainer(), nil)
        } catch {
            logger.error("Falling back to an in-memory store: \(error)")
            // An in-memory store only fails if the model itself is invalid, which is a programmer error.
            return (try! makeContainer(inMemory: true), error)
        }
    }()

    static var container: ModelContainer { shared.container }

    static func makeContainer(inMemory: Bool = false) throws -> ModelContainer {
        let schema = Schema([DistractionEvent.self])
        let configuration = if inMemory {
            ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else {
            ModelConfiguration(schema: schema, groupContainer: .identifier(appGroupID))
        }
        return try ModelContainer(for: schema, configurations: configuration)
    }

    /// Counts the events logged on the calendar day containing `date`.
    static func counts(on date: Date, in context: ModelContext, calendar: Calendar = .current) throws -> DayCounts {
        let interval = dayInterval(containing: date, calendar: calendar)
        var counts = DayCounts()
        for type in EventType.allCases {
            counts[type] = try context.fetchCount(FetchDescriptor(predicate: predicate(for: type, in: interval)))
        }
        return counts
    }

    /// The most recent event on the calendar day containing `date`.
    static func latestEvent(on date: Date, in context: ModelContext, calendar: Calendar = .current) throws -> DistractionEvent? {
        let interval = dayInterval(containing: date, calendar: calendar)
        let start = interval.start
        let end = interval.end
        var descriptor = FetchDescriptor<DistractionEvent>(
            predicate: #Predicate { $0.timestamp >= start && $0.timestamp < end },
            sortBy: [SortDescriptor(\.timestamp, order: .reverse)]
        )
        descriptor.fetchLimit = 1
        return try context.fetch(descriptor).first
    }

    static func dayInterval(containing date: Date, calendar: Calendar = .current) -> DateInterval {
        calendar.dateInterval(of: .day, for: date)
            ?? DateInterval(start: calendar.startOfDay(for: date), duration: 24 * 60 * 60)
    }

    private static func predicate(for type: EventType, in interval: DateInterval) -> Predicate<DistractionEvent> {
        let start = interval.start
        let end = interval.end
        let rawType = type.rawValue
        return #Predicate { $0.timestamp >= start && $0.timestamp < end && $0.eventType == rawType }
    }
}
