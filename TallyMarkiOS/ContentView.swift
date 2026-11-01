//
//  ContentView.swift
//  TallyMarkiOS
//
//  Created by Miltos on 2/2/25.
//

import SwiftUI
import UIKit
import CoreData

struct ContentView: View {
    @Environment(TallyDataManager.self) private var dataManager
    
    private let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // Distraction Logged Section
                VStack {
                    Text("Distractions")
                        .font(.headline)
                    TallyMarksView(count: dataManager.distractionCount)
                    Button(action: {
                        haptic.impactOccurred()
                        withAnimation {
                            dataManager.saveEvent(type: "distracted")
                        }
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
                    TallyMarksView(count: dataManager.resistedCount)
                    Button(action: {
                        haptic.impactOccurred()
                        withAnimation {
                            dataManager.saveEvent(type: "resisted")
                        }
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
            .navigationTitle("Tally Mark")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        withAnimation {
                            dataManager.undoLastEvent()
                        }
                    }) {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    .disabled(dataManager.lastEvent == nil)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: HistoryView()) {
                        Image(systemName: "clock.arrow.circlepath")
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    Button(action: {
                        if dataManager.isLiveActivityActive {
                            dataManager.endLiveActivity()
                        } else {
                            dataManager.startLiveActivity()
                        }
                    }) {
                        Label(
                            dataManager.isLiveActivityActive ? "Stop Live Activity" : "Start Live Activity",
                            systemImage: dataManager.isLiveActivityActive ? "stop.circle" : "play.circle"
                        )
                    }
                }
            }
            .onAppear {
                dataManager.loadTodayCounts()
            }
        }
    }
}

#Preview {
    ContentView()
        .environment(TallyDataManager(context: PersistenceController.preview.container.viewContext))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
}
