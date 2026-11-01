//
//  LegacyStoreImporter.swift
//  TallyMarkiOS
//

import CoreData
import OSLog
import SwiftData

/// Copies events from the original Core Data store (in the app's sandbox) into the SwiftData store in the
/// App Group, once. The old store is opened read-only and left on disk as a backup.
enum LegacyStoreImporter {
    private static let didImportKey = "didImportLegacyCoreDataStore"
    private static let logger = Logger(subsystem: "com.hyperstellarlabs.TallyMarkiOS", category: "LegacyStoreImporter")

    static let defaultStoreURL = NSPersistentContainer.defaultDirectoryURL().appending(path: "TallyMarkiOS.sqlite")

    static func importIfNeeded(
        into container: ModelContainer,
        from storeURL: URL = defaultStoreURL,
        defaults: UserDefaults = .standard
    ) {
        guard !defaults.bool(forKey: didImportKey) else { return }

        guard FileManager.default.fileExists(atPath: storeURL.path(percentEncoded: false)) else {
            defaults.set(true, forKey: didImportKey)
            return
        }

        let legacy = NSPersistentContainer(name: "TallyMarkiOS")
        let description = NSPersistentStoreDescription(url: storeURL)
        description.isReadOnly = true
        legacy.persistentStoreDescriptions = [description]
        // SQLite stores load synchronously, so the coordinator is ready when this returns.
        legacy.loadPersistentStores { _, error in
            if let error {
                logger.error("Couldn't open the legacy store: \(error)")
            }
        }
        guard !legacy.persistentStoreCoordinator.persistentStores.isEmpty else { return }

        do {
            let objects = try legacy.viewContext.fetch(NSFetchRequest<NSManagedObject>(entityName: "DistractionEvent"))
            let context = ModelContext(container)
            var imported = 0
            for object in objects {
                // Skip rows without a timestamp or with an unknown type (e.g. old preview "sample" rows).
                guard let timestamp = object.value(forKey: "timestamp") as? Date,
                      let rawType = object.value(forKey: "eventType") as? String,
                      let type = EventType(rawValue: rawType)
                else { continue }
                context.insert(DistractionEvent(type: type, timestamp: timestamp))
                imported += 1
            }
            try context.save()
            defaults.set(true, forKey: didImportKey)
            logger.info("Imported \(imported) of \(objects.count) legacy events")
        } catch {
            // Leave the flag unset so the import is retried on the next launch.
            logger.error("Legacy import failed: \(error)")
        }
    }
}
