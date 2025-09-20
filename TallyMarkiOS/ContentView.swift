//
//  ContentView.swift
//  TallyMarkiOS
//
//  Created by Miltos on 2/2/25.
//

import SwiftUI

struct ContentView: View {
    @State private var distractionCount = 0
    @State private var resistedCount = 0
    
    // If using Core Data, get the managedObjectContext:
    @Environment(\.managedObjectContext) private var viewContext
    
    var body: some View {
        VStack(spacing: 40) {
            // Distraction Logged Section
            VStack {
                Text("Distractions")
                    .font(.headline)
                // Replace number with the animated tally marks
                TallyMarksView(count: distractionCount)
                Button(action: {
                    withAnimation {
                        distractionCount += 1
                    }
                    saveEvent(type: "distracted")
                }) {
                    Text("Log Distraction")
                        .padding()
                        .background(Color.red.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
            // Distraction Resisted Section
            VStack {
                Text("Resisted")
                    .font(.headline)
                TallyMarksView(count: resistedCount)
                Button(action: {
                    withAnimation {
                        resistedCount += 1
                    }
                    saveEvent(type: "resisted")
                }) {
                    Text("Log Resisted")
                        .padding()
                        .background(Color.green.opacity(0.7))
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
            }
        }
        .padding()
    }
    
    // Save event to Core Data
    private func saveEvent(type: String) {
        let newEvent = DistractionEvent(context: viewContext)
        newEvent.id = UUID()
        newEvent.timestamp = Date()
        newEvent.eventType = type
        do {
            try viewContext.save()
        } catch {
            print("Error saving event: \(error)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
