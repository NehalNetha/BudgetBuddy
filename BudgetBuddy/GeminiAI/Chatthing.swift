import SwiftUI

struct TestAIView: View {
    @State private var response: String = ""
    @State private var isLoading = false
    @StateObject var expenseVM = ExpenseViewModel()
    @StateObject var budgetVM = BudgetSettingsViewModel()
    @StateObject var insightVM = InsightViewModel()
    @State private var savedInsights: [AIInsight] = []
    
    var body: some View {
        VStack(spacing: 20) {
            // Current Analysis Section
            VStack(alignment: .leading) {
                Text("Current Analysis")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                if isLoading {
                    ProgressView()
                        .progressViewStyle(.circular)
                } else {
                    ScrollView {
                        Text(response)
                            .foregroundStyle(.white)
                            .padding()
                    }
                }
            }
            
            // Saved Insights Section
            VStack(alignment: .leading) {
                Text("Previous Insights")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                ScrollView {
                    VStack(spacing: 16) {
                        ForEach(savedInsights) { insight in
                            VStack(alignment: .leading, spacing: 8) {
                                Text(insight.formattedDate)
                                    .font(.subheadline)
                                    .foregroundStyle(.gray)
                                Text(insight.insight)
                                    .foregroundStyle(.white)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(hex: "191919"))
                            .cornerRadius(12)
                        }
                    }
                }
            }
            
            // Action Buttons
            VStack(spacing: 16) {
                Button("Analyze My Spending") {
                    Task {
                        isLoading = true
                        do {
                            try await expenseVM.fetchAllExpensesGroupedByMonth()
                            try await budgetVM.fetchBudgetSettings()
                            let monthlyBudget = budgetVM.budgetSettings?.monthlyBudget ?? 1000
                            
                            let allExpenses = Array(expenseVM.expensesByMonth.values.flatMap { $0 })
                            response = try await VertexServiceGemini.shared.analyzeSpendings(
                                expenses: allExpenses,
                                monthlyBudget: monthlyBudget
                            )
                        } catch {
                            response = "Error: \(error.localizedDescription)"
                        }
                        isLoading = false
                    }
                }
                .padding()
                .background(Color(hex: "037D4F"))
                .foregroundStyle(.white)
                .cornerRadius(10)
                
                Button("Generate Daily Insight") {
                    Task {
                        isLoading = true
                        do {
                            try await insightVM.generateDailyInsight()
                            response = "Daily insight generated and saved successfully!"
                            // Fetch updated insights
                            savedInsights = try await insightVM.fetchRecentInsights()
                        } catch {
                            response = "Error generating daily insight: \(error.localizedDescription)"
                        }
                        isLoading = false
                    }
                }
                .padding()
                .background(Color(hex: "1E4E45"))
                .foregroundStyle(.white)
                .cornerRadius(10)
            }
        }
        .padding()
        .background(Color.black)
        .task {
            // Load saved insights when view appears
            do {
                savedInsights = try await insightVM.fetchRecentInsights()
            } catch {
                print("Error loading insights: \(error)")
            }
        }
    }
}
