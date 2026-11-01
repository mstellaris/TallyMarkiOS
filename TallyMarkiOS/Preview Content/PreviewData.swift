//
//  PreviewData.swift
//  TallyMarkiOS
//

import SwiftData
import SwiftUI

/// An in-memory store with three weeks of sample tallies, for SwiftUI previews.
struct SampleTallies: PreviewModifier {
    static func makeSharedContext() throws -> ModelContainer {
        let container = try TallyStore.makeContainer(inMemory: true)
        let calendar = Calendar.current
        for dayOffset in 0..<21 {
            guard let day = calendar.date(byAdding: .day, value: -dayOffset, to: .now) else { continue }
            // Deterministic but varied counts per day.
            let distracted = (dayOffset * 7 + 3) % 9
            let resisted = (dayOffset * 5 + 4) % 8
            for index in 0..<(distracted + resisted) {
                let type: EventType = index < distracted ? .distracted : .resisted
                let timestamp = dayOffset == 0 ? .now : calendar.startOfDay(for: day).addingTimeInterval(Double(index + 9) * 1800)
                container.mainContext.insert(DistractionEvent(type: type, timestamp: timestamp))
            }
        }
        try container.mainContext.save()
        return container
    }

    func body(content: Content, context: ModelContainer) -> some View {
        content
            .modelContainer(context)
            .environment(TallyDataManager(container: context))
    }
}

extension PreviewTrait where T == Preview.ViewTraits {
    static var sampleTallies: Self { .modifier(SampleTallies()) }
}
