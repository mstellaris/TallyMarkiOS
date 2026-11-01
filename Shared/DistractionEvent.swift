//
//  DistractionEvent.swift
//  TallyMarkiOS
//

import Foundation
import SwiftData

/// A single logged tally. `eventType` stores `EventType.rawValue` so it can be used in predicates.
@Model
nonisolated final class DistractionEvent {
    var timestamp: Date = Date.now
    var eventType: String = EventType.distracted.rawValue

    init(type: EventType, timestamp: Date = .now) {
        self.timestamp = timestamp
        self.eventType = type.rawValue
    }

    var type: EventType? {
        EventType(rawValue: eventType)
    }
}

/// Distracted / resisted totals for one day.
nonisolated struct DayCounts: Codable, Hashable, Sendable {
    var distracted = 0
    var resisted = 0

    subscript(type: EventType) -> Int {
        get {
            switch type {
            case .distracted: distracted
            case .resisted: resisted
            }
        }
        set {
            switch type {
            case .distracted: distracted = newValue
            case .resisted: resisted = newValue
            }
        }
    }

    var total: Int { distracted + resisted }
}
