//
//  LogEventIntent.swift
//  TallyMarkiOS
//

import AppIntents

/// Logs a tally without opening the app. Because it's a `LiveActivityIntent`, the system runs it in the
/// app's process, so it updates the same `TallyDataManager` the app UI observes.
struct LogEventIntent: LiveActivityIntent {
    static let title: LocalizedStringResource = "Log Tally"
    static let description = IntentDescription("Adds a tally mark to today's count.")

    @Parameter(title: "Type")
    var type: EventType

    init() {}

    init(type: EventType) {
        self.type = type
    }

    func perform() async throws -> some IntentResult {
        await TallyDataManager.shared.log(type)
        return .result()
    }
}
