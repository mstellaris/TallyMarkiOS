//
//  TallyDataManager.swift
//  TallyMarkiOS
//

import Foundation
import CoreData
import ActivityKit

@Observable
class TallyDataManager {
    var distractionCount: Int = 0
    var resistedCount: Int = 0
    private(set) var lastEvent: DistractionRecord?
    private(set) var currentActivity: Activity<TallyActivityAttributes>?
    
    var isLiveActivityActive: Bool {
        currentActivity != nil
    }
    
    private let viewContext: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }
    
    func loadTodayCounts() {
        let startOfDay = Calendar.current.startOfDay(for: Date())
        let request: NSFetchRequest<DistractionEvent> = DistractionEvent.fetchRequest()
        request.predicate = NSPredicate(format: "timestamp >= %@", startOfDay as NSDate)
        
        do {
            let todayEvents = try viewContext.fetch(request)
            distractionCount = todayEvents.filter { $0.eventType == "distracted" }.count
            resistedCount = todayEvents.filter { $0.eventType == "resisted" }.count
        } catch {
            print("Error loading today's counts: \(error)")
        }
    }
    
    func saveEvent(type: String) {
        let newEvent = DistractionEvent(context: viewContext)
        newEvent.id = UUID()
        newEvent.timestamp = Date()
        newEvent.eventType = type
        
        do {
            try viewContext.save()
            lastEvent = DistractionRecord(from: newEvent)
            
            if type == "distracted" {
                distractionCount += 1
            } else {
                resistedCount += 1
            }
            updateLiveActivity()
        } catch {
            print("Error saving event: \(error)")
        }
    }
    
    func undoLastEvent() {
        guard let last = lastEvent else { return }
        
        let request: NSFetchRequest<DistractionEvent> = DistractionEvent.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", last.id as CVarArg)
        request.fetchLimit = 1
        
        do {
            if let eventToDelete = try viewContext.fetch(request).first {
                let type = eventToDelete.eventType
                viewContext.delete(eventToDelete)
                try viewContext.save()
                
                if type == "distracted" {
                    distractionCount = max(0, distractionCount - 1)
                } else if type == "resisted" {
                    resistedCount = max(0, resistedCount - 1)
                }
                
                lastEvent = nil
                updateLiveActivity()
            }
        } catch {
            print("Error undoing event: \(error)")
        }
    }
    
    // MARK: - Live Activity
    
    func startLiveActivity() {
        guard ActivityAuthorizationInfo().areActivitiesEnabled else { return }
        
        let attributes = TallyActivityAttributes()
        let state = TallyActivityAttributes.ContentState(
            distractedCount: distractionCount,
            resistedCount: resistedCount
        )
        let content = ActivityContent(state: state, staleDate: nil)
        
        do {
            currentActivity = try Activity.request(
                attributes: attributes,
                content: content
            )
        } catch {
            print("Error starting Live Activity: \(error)")
        }
    }
    
    func updateLiveActivity() {
        guard let activity = currentActivity else { return }
        
        let state = TallyActivityAttributes.ContentState(
            distractedCount: distractionCount,
            resistedCount: resistedCount
        )
        let content = ActivityContent(state: state, staleDate: nil)
        let id = activity.id

        Task {
            await Self.update(activityID: id, with: content)
        }
    }

    // `Activity` isn't Sendable, so look it up by ID off the main actor instead of passing it across.
    @concurrent
    private nonisolated static func update(activityID: String, with content: ActivityContent<TallyActivityAttributes.ContentState>) async {
        guard let activity = Activity<TallyActivityAttributes>.activities.first(where: { $0.id == activityID }) else { return }
        await activity.update(content)
    }

    @concurrent
    private nonisolated static func end(activityID: String, with content: ActivityContent<TallyActivityAttributes.ContentState>) async {
        guard let activity = Activity<TallyActivityAttributes>.activities.first(where: { $0.id == activityID }) else { return }
        await activity.end(content, dismissalPolicy: .default)
    }
    
    func endLiveActivity() {
        guard let activity = currentActivity else { return }
        
        let state = TallyActivityAttributes.ContentState(
            distractedCount: distractionCount,
            resistedCount: resistedCount
        )
        let content = ActivityContent(state: state, staleDate: nil)
        let id = activity.id
        currentActivity = nil

        Task {
            await Self.end(activityID: id, with: content)
        }
    }
}
