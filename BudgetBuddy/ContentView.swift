//
//  ContentView.swift
//  BudgetBuddy
//
//  Created by NehalNetha on 11/01/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject var authViewModel = AuthViewModel()

    var body: some View {
        Group{
            if authViewModel.userSession != nil{
                MainTabView()
                    .environmentObject(authViewModel)
            }else{
                Login()
                    .environmentObject(authViewModel)

            }
        }
    }
}
