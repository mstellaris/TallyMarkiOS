//
//  ContentView.swift
//  TallyMarkiOS
//
//  Created by Miltos on 2/2/25.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @Environment(TallyDataManager.self) private var dataManager
    @Environment(\.scenePhase) private var scenePhase
    
    private let haptic = UIImpactFeedbackGenerator(style: .medium)
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 40) {
                // Distraction Logged Section
                VStack {
                    Text("Distractions")
                        .font(.headline)
                    TallyMarksView(count: dataManager.today.distracted)
                    Button(action: {
                        haptic.impactOccurred()
                        withAnimation {
                            dataManager.log(.distracted)
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
                    TallyMarksView(count: dataManager.today.resisted)
                    Button(action: {
                        haptic.impactOccurred()
                        withAnimation {
                            dataManager.log(.resisted)
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
                            dataManager.undoLast()
                        }
                    }) {
                        Image(systemName: "arrow.uturn.backward")
                    }
                    .disabled(!dataManager.canUndo)
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
            // Reload when returning to the app (it may have been logged to from the Live Activity, or a new
            // day may have started) and at midnight while the app stays open.
            .onChange(of: scenePhase, initial: true) { _, phase in
                if phase == .active {
                    dataManager.refresh()
                }
            }
            .task {
                for await _ in NotificationCenter.default.notifications(named: UIApplication.significantTimeChangeNotification) {
                    dataManager.refresh()
                }
            }
        }
    }
}

#Preview(traits: .sampleTallies) {
    ContentView()
}
