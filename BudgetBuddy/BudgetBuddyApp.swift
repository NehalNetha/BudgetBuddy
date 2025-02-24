//
//  BudgetBuddyApp.swift
//  BudgetBuddy
//
//  Created by NehalNetha on 11/01/25.
//

import SwiftUI
import Firebase

@main
struct BudgetBuddyApp: App {
    init() {
        FirebaseApp.configure()
        setupDailyAnalysis()
    }
    
    private func setupDailyAnalysis() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            if granted {
                let content = UNMutableNotificationContent()
                content.title = "Daily Financial Analysis"
                content.body = "Analyzing your daily spending patterns..."
                
                var dateComponents = DateComponents()
                dateComponents.hour = 23 // Run at 11 PM
                dateComponents.minute = 0
                
                let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
                let request = UNNotificationRequest(identifier: "dailyAnalysis", content: content, trigger: trigger)
                
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
