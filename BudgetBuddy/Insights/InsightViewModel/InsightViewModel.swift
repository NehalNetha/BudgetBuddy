//
//  InsightViewModel.swift
//  BudgetBuddy
//
//  Created by NehalNetha on 22/02/25.
//

import Foundation
import FirebaseFirestore
import FirebaseAuth

struct AIInsight: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    let date: Date
    let insight: String
    let expenses: [String] // References to analyzed expenses
    let previousContext: String // Previous AI conversation context
    
    var formattedDate: String {
        date.formatted(date: .abbreviated, time: .shortened)
    }
}


@MainActor
class InsightViewModel: ObservableObject {
    @Published var insights: [AIInsight] = []
    @Published var isLoading = false
    private let db = Firestore.firestore()
    
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    func generateDailyInsight() async throws {
        guard let userId = userId else {
            print("⛔️ No userId found")
            return
        }
        print("👤 UserId: \(userId)")
        
        // Check if we already have today's insight
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: Date())
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        print("📅 Analyzing for date range: \(startOfDay) to \(endOfDay)")
        
        // Fetch today's expenses
        let expenseVM = ExpenseViewModel()
        try await expenseVM.fetchDailyExpenses(for: Date())
        let expenses = expenseVM.dailyExpenses
        print("💰 Found \(expenses.count) expenses")
        expenses.forEach { expense in
            print("   - \(expense.title): $\(expense.amount) (\(expense.category))")
        }
        
        // Fetch budget settings
        let budgetVM = BudgetSettingsViewModel()
        try await budgetVM.fetchBudgetSettings()
        let monthlyBudget = budgetVM.budgetSettings?.monthlyBudget ?? 0
        print("💵 Monthly Budget: $\(monthlyBudget)")
        
        // Fetch previous insights for context
        let previousInsights = try await fetchRecentInsights(limit: 5)
        print("🔍 Found \(previousInsights.count) previous insights")
        let context = previousInsights.map { "Previous Insight (\($0.formattedDate)): \($0.insight)" }.joined(separator: "\n")
        print("📝 Context being passed to AI:\n\(context)")
        
        // Generate new insight
        print("🤖 Generating new insight...")
        let newInsight = try await VertexServiceGemini.shared.analyzeSpendings(
            expenses: expenses,
            monthlyBudget: monthlyBudget,
            previousContext: context
        )
        print("✅ Generated insight: \(newInsight)")
        
        // Save new insight
        let insight = AIInsight(
            userId: userId,
            date: Date(),
            insight: newInsight,
            expenses: expenses.compactMap { $0.id },
            previousContext: context
        )
        
        print("💾 Saving insight to database...")
        try await saveInsight(insight)
        print("✅ Insight saved successfully")
    }
    
    func fetchRecentInsights(limit: Int = 10) async throws -> [AIInsight] {
        guard let userId = userId else { return [] }
        
        let snapshot = try await db.collection("insights")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .limit(to: limit)
            .getDocuments()
        
        return snapshot.documents.compactMap { try? $0.data(as: AIInsight.self) }
    }
    
    private func saveInsight(_ insight: AIInsight) async throws {
        let _ = try await db.collection("insights").addDocument(from: insight)
    }
}
