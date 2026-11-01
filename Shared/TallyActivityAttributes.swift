//
//  TallyActivityAttributes.swift
//  TallyMarkiOS
//

import ActivityKit
import Foundation

/// The Live Activity showing today's tally. The app and the widget extension both compile this file,
/// so they agree on the type ActivityKit uses to match a running activity with its UI.
nonisolated struct TallyActivityAttributes: ActivityAttributes {
    typealias ContentState = DayCounts
}
