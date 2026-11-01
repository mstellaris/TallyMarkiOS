//
//  LegacyStoreImporterTests.swift
//  TallyMarkiOSTests
//

import CoreData
import Foundation
import SwiftData
import Testing
@testable import TallyMarkiOS

struct LegacyStoreImporterTests {
    let directory: URL
    let storeURL: URL
    let defaults: UserDefaults
    let suiteName = "LegacyStoreImporterTests-\(UUID().uuidString)"

    init() throws {
        directory = FileManager.default.temporaryDirectory.appending(path: UUID().uuidString)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        storeURL = directory.appending(path: "TallyMarkiOS.sqlite")
        defaults = try #require(UserDefaults(suiteName: suiteName))
    }

    /// Writes a store in the original Core Data format, using the model still bundled in the app.
    private func makeLegacyStore(rows: [(timestamp: Date?, type: String?)]) throws {
        let legacy = NSPersistentContainer(name: "TallyMarkiOS")
        legacy.persistentStoreDescriptions = [NSPersistentStoreDescription(url: storeURL)]
        legacy.loadPersistentStores { _, _ in }
        try #require(!legacy.persistentStoreCoordinator.persistentStores.isEmpty)

        for row in rows {
            let object = NSEntityDescription.insertNewObject(forEntityName: "DistractionEvent", into: legacy.viewContext)
            object.setValue(UUID(), forKey: "id")
            object.setValue(row.timestamp, forKey: "timestamp")
            object.setValue(row.type, forKey: "eventType")
        }
        try legacy.viewContext.save()
        for store in legacy.persistentStoreCoordinator.persistentStores {
            try legacy.persistentStoreCoordinator.remove(store)
        }
    }

    @Test func importsValidRowsOnce() throws {
        try makeLegacyStore(rows: [
            (utcDate(2026, 3, 1, 10), "distracted"),
            (utcDate(2026, 3, 1, 11), "resisted"),
            (utcDate(2026, 3, 2, 9), "resisted"),
            (utcDate(2026, 3, 2, 9), "sample"), // Old preview data: skipped.
            (nil, "distracted")                 // No timestamp: skipped.
        ])
        let container = try TallyStore.makeContainer(inMemory: true)

        LegacyStoreImporter.importIfNeeded(into: container, from: storeURL, defaults: defaults)
        LegacyStoreImporter.importIfNeeded(into: container, from: storeURL, defaults: defaults)

        let events = try container.mainContext.fetch(FetchDescriptor<DistractionEvent>(sortBy: [SortDescriptor(\.timestamp)]))
        #expect(events.map(\.eventType) == ["distracted", "resisted", "resisted"])
        #expect(events.first?.timestamp == utcDate(2026, 3, 1, 10))
        // The original store is kept as a backup.
        #expect(FileManager.default.fileExists(atPath: storeURL.path(percentEncoded: false)))

        defaults.removePersistentDomain(forName: suiteName)
        try? FileManager.default.removeItem(at: directory)
    }

    @Test func doesNothingWithoutALegacyStore() throws {
        let container = try TallyStore.makeContainer(inMemory: true)

        LegacyStoreImporter.importIfNeeded(into: container, from: storeURL, defaults: defaults)

        #expect(try container.mainContext.fetchCount(FetchDescriptor<DistractionEvent>()) == 0)
        defaults.removePersistentDomain(forName: suiteName)
        try? FileManager.default.removeItem(at: directory)
    }
}
