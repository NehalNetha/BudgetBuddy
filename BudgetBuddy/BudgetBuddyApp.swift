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
    init(){
        FirebaseApp.configure()
        
    }
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
