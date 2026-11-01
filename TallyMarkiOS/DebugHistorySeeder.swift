//
//  DebugHistorySeeder.swift
//  TallyMarkiOS
//

#if DEBUG
import Foundation
import OSLog
import SwiftData

/// Fills the store with a year of past tallies for trying out History. Debug builds only; runs when the app is
/// launched with the `-seedHistory` argument. Today is left untouched, and each run adds another year's worth.
enum DebugHistorySeeder {
    static let launchArgument = "-seedHistory"

    static func seedIfRequested(into container: ModelContainer, days: Int = 365) {
        guard ProcessInfo.processInfo.arguments.contains(launchArgument) else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let context = ModelContext(container)
        var generator = SeededGenerator(seed: 2026)
        var inserted = 0

        for offset in 1...days {
            guard let day = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
            // Older days skew toward more distractions and fewer resisted moments, so the history shows a trend.
            let progress = 1 - Double(offset) / Double(days)
            let isWeekend = calendar.isDateInWeekend(day)
            let distracted = Int.random(in: 2...(isWeekend ? 14 : 10), using: &generator) - Int(progress * 3)
            let resisted = Int.random(in: 0...6, using: &generator) + Int(progress * 5)

            for (type, count) in [(EventType.distracted, max(0, distracted)), (.resisted, max(0, resisted))] {
                for _ in 0..<count {
                    // Spread across waking hours, 7:00–23:00.
                    let seconds = Double(Int.random(in: (7 * 3600)..<(23 * 3600), using: &generator))
                    context.insert(DistractionEvent(type: type, timestamp: day.addingTimeInterval(seconds)))
                    inserted += 1
                }
            }
        }

        do {
            try context.save()
            Logger(subsystem: "com.hyperstellarlabs.TallyMarkiOS", category: "DebugHistorySeeder")
                .info("Seeded \(inserted) events over \(days) days")
        } catch {
            Logger(subsystem: "com.hyperstellarlabs.TallyMarkiOS", category: "DebugHistorySeeder")
                .error("Seeding failed: \(error)")
        }
    }
}

/// SplitMix64, so seeded history is the same on every run.
private struct SeededGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9E37_79B9_7F4A_7C15
        var z = state
        z = (z ^ (z >> 30)) &* 0xBF58_476D_1CE4_E5B9
        z = (z ^ (z >> 27)) &* 0x94D0_49BB_1331_11EB
        return z ^ (z >> 31)
    }
}
#endif
