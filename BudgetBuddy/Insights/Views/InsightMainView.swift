//
//  InsightMainView.swift
//  BudgetBuddy
//
//  Created by NehalNetha on 09/02/25.
//

import SwiftUI
import Charts

struct InsightMainView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented Picker
            Picker("Insight Type", selection: $selectedTab) {
                Text("Charts").tag(0)
                Text("AI Insights").tag(1)
            }
            .pickerStyle(.segmented)
            .padding()
            .background(Color(hex: "191919"))
            
            if selectedTab == 0 {
                ScrollView {
                    VStack(spacing: 20) {
                        // Spending Trends
                        SpendingTrendsCard()
                            .padding(.horizontal)
                        
                        // Existing Bar Chart
                        BarChartView()
                            .padding(.horizontal)
                        
                        // Existing Pie Chart
                        ExpenseProgressChart()
                            .padding(.horizontal)
                        
                        // Budget vs Actual
                        BudgetComparisonCard()
                            .padding(.horizontal)
                        
                        // Monthly Savings Track
                        SavingsProgressCard()
                            .padding(.horizontal)
                        
                        // Recurring Expenses
                        RecurringExpensesCard()
                            .padding(.horizontal)
                    }
                    .padding(.top, 20)
                }
            } else {
                // AI Insights View
                ScrollView {
                    VStack(alignment: .leading, spacing: 15) {
                        ForEach(0..<5) { _ in
                            InsightCard()
                        }
                    }
                    .padding(.top, 20)
                    .padding(.horizontal)
                }
            }
        }
        .background(Color.black)
    }
}

// New Components

// Helper View for AI Insights


#Preview {
    InsightMainView()
}
