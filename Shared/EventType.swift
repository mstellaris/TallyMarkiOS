//
//  EventType.swift
//  TallyMarkiOS
//

import AppIntents
import SwiftUI

/// The two kinds of moments the app tallies.
nonisolated enum EventType: String, Codable, CaseIterable, Sendable {
    case distracted
    case resisted

    var title: LocalizedStringResource {
        switch self {
        case .distracted: "Distractions"
        case .resisted: "Resisted"
        }
    }

    /// Fits the narrow Live Activity and widget buttons.
    var shortTitle: LocalizedStringResource {
        switch self {
        case .distracted: "Distracted"
        case .resisted: "Resisted"
        }
    }

    var logTitle: LocalizedStringResource {
        switch self {
        case .distracted: "Log Distraction"
        case .resisted: "Log Resisted"
        }
    }

    /// "1 Distraction", "3 Distractions", "2 Resisted", with grammatical agreement.
    func countDescription(_ count: Int) -> LocalizedStringResource {
        switch self {
        case .distracted: "^[\(count) Distraction](inflect: true)"
        case .resisted: "\(count) Resisted"
        }
    }

    var color: Color {
        switch self {
        case .distracted: .red
        case .resisted: .green
        }
    }

    var systemImage: String {
        switch self {
        case .distracted: "xmark.circle"
        case .resisted: "checkmark.circle"
        }
    }
}

extension EventType: AppEnum {
    static let typeDisplayRepresentation: TypeDisplayRepresentation = "Tally Type"

    static let caseDisplayRepresentations: [EventType: DisplayRepresentation] = [
        .distracted: "Distraction",
        .resisted: "Resisted"
    ]
}
