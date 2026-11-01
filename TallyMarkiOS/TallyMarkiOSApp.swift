//
//  TallyMarkiOSApp.swift
//  TallyMarkiOS
//
//  Created by Miltos on 2/2/25.
//

import SwiftUI
import SwiftData

@main
struct TallyMarkiOSApp: App {
    @State private var tallyDataManager: TallyDataManager

    init() {
        // Import before the data manager loads today's counts so they include migrated history.
        LegacyStoreImporter.importIfNeeded(into: TallyStore.container)
        #if DEBUG
        DebugHistorySeeder.seedIfRequested(into: TallyStore.container)
        #endif
        _tallyDataManager = State(initialValue: .shared)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(tallyDataManager)
        }
        .modelContainer(TallyStore.container)
    }
}
