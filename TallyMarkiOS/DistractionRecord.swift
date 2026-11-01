//
//  DistractionRecord.swift
//  TallyMarkiOS
//

import Foundation

struct DistractionRecord: Identifiable, Hashable {
    let id: UUID
    let timestamp: Date
    let eventType: String
    
    init(from event: DistractionEvent) {
        self.id = event.id ?? UUID()
        self.timestamp = event.timestamp ?? Date()
        self.eventType = event.eventType ?? "distracted"
    }
    
    init(id: UUID = UUID(), timestamp: Date = Date(), eventType: String) {
        self.id = id
        self.timestamp = timestamp
        self.eventType = eventType
    }
}
