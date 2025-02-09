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
    @Namespace private var animation
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented Picker with custom style
            HStack {
                ForEach(0..<2) { tab in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedTab = tab
                        }
                    } label: {
                        VStack {
                            Text(tab == 0 ? "Charts" : "AI Insights")
                                .font(.system(size: 16))
                                .foregroundStyle(selectedTab == tab ? .white : .gray)
                            
                            if selectedTab == tab {
                                Rectangle()
                                    .fill(Color.white)
                                    .frame(height: 2)
                                    .matchedGeometryEffect(id: "TAB", in: animation)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding()
            .background(Color(hex: "191919"))
            
            // Content with transition
            TabView(selection: $selectedTab) {
                // Charts View
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
                .tag(0)
                
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
                .tag(1)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut(duration: 0.3), value: selectedTab)
        }
        .background(Color.black)
    }
}

// New Components

// Helper View for AI Insights


#Preview {
    InsightMainView()
}
