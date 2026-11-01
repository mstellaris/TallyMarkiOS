//
//  TallyActivityAttributes.swift
//  TallyMarkiOS
//

import ActivityKit
import Foundation

nonisolated struct TallyActivityAttributes: ActivityAttributes {
    nonisolated struct ContentState: Codable, Hashable {
        var distractedCount: Int
        var resistedCount: Int
    }
}
