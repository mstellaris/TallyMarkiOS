//
//  TallyActivityAttributes.swift
//  TallyMarkiOS
//

import ActivityKit
import Foundation

struct TallyActivityAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable {
        var distractedCount: Int
        var resistedCount: Int
    }
}
