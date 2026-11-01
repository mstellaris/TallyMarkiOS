//
//  TallyMarkiOSApp.swift
//  TallyMarkiOS
//
//  Created by Miltos on 2/2/25.
//

import SwiftUI

@main
struct TallyMarkiOSApp: App {
    let persistenceController = PersistenceController.shared
    @State private var tallyDataManager: TallyDataManager

    init() {
        let context = PersistenceController.shared.container.viewContext
        _tallyDataManager = State(initialValue: TallyDataManager(context: context))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environment(tallyDataManager)
        }
    }
}
