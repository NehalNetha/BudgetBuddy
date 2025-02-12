
import SwiftUI

struct Settings: View {
    @State private var isDarkMode = true
    @State private var showBudgetSettings = false
    @State private var showNotificationSettings = false
    @State private var showCurrencySettings = false
    @State private var showAbout = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Section
                    VStack(spacing: 15) {
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 80))
                            .foregroundStyle(.white)
                        
                        Text("Nehal Netha")
                            .font(.title2)
                            .foregroundStyle(.white)
                        
                        Text("nehalnetha@gmail.com")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(hex: "191919"))
                    .cornerRadius(15)
                    
                    // Budget Settings
                    NavigationLink(destination: BudgetSettingsView()) {
                        SettingsRow(icon: "dollarsign.circle.fill", title: "Budget Settings", iconColor: Color(hex: "037D4F"))
                    }
                    
                    // Notifications
                    Button {
                        showNotificationSettings.toggle()
                    } label: {
                        SettingsRow(icon: "bell.fill", title: "Notifications", iconColor: .blue)
                    }
                    
                    // Currency
                    Button {
                        showCurrencySettings.toggle()
                    } label: {
                        SettingsRow(icon: "dollarsign.circle", title: "Currency", iconColor: .orange)
                    }
                    
                    // App Settings Section
                    VStack(spacing: 0) {
                        // Dark Mode Toggle
                        Toggle(isOn: $isDarkMode) {
                            SettingsRow(icon: "moon.fill", title: "Dark Mode", iconColor: .purple)
                        }
                        .padding()
                        .background(Color(hex: "191919"))
                        .cornerRadius(15)
                        
                        // About
                        Button {
                            showAbout.toggle()
                        } label: {
                            SettingsRow(icon: "info.circle.fill", title: "About", iconColor: .gray)
                        }
                        .padding(.top, 10)
                    }
                    
                    // Sign Out Button
                    Button {
                        // Sign out functionality placeholder
                    } label: {
                        Text("Sign Out")
                            .foregroundStyle(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "191919"))
                            .cornerRadius(15)
                    }
                }
                .padding()
            }
            .background(Color.black)
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.large)
        }
        .preferredColorScheme(.dark)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let iconColor: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundStyle(iconColor)
                .font(.system(size: 22))
                .frame(width: 30)
            
            Text(title)
                .foregroundStyle(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundStyle(.gray)
                .font(.system(size: 14))
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color(hex: "191919"))
        .cornerRadius(15)
    }
}

// Currency Settings Sheet
struct CurrencySettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedCurrency = "USD"
    let currencies = ["USD", "EUR", "GBP", "JPY", "INR"]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(currencies, id: \.self) { currency in
                    Button {
                        selectedCurrency = currency
                    } label: {
                        HStack {
                            Text(currency)
                                .foregroundStyle(.white)
                            Spacer()
                            if currency == selectedCurrency {
                                Image(systemName: "checkmark")
                                    .foregroundStyle(Color(hex: "037D4F"))
                            }
                        }
                    }
                }
            }
            .navigationTitle("Select Currency")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

// Notification Settings Sheet
struct NotificationSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var dailyReminder = true
    @State private var weeklyReport = true
    @State private var budgetAlerts = true
    
    var body: some View {
        NavigationView {
            List {
                Toggle("Daily Reminder", isOn: $dailyReminder)
                Toggle("Weekly Report", isOn: $weeklyReport)
                Toggle("Budget Alerts", isOn: $budgetAlerts)
            }
            .navigationTitle("Notifications")
            .navigationBarItems(trailing: Button("Done") {
                dismiss()
            })
        }
    }
}

#Preview {
    Settings()
}
