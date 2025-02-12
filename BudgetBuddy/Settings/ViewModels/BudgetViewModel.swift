//
//  BudgetSettingsViewModel.swift
//  BudgetBuddy
//
//  Created by NehalNetha on 09/02/25.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

@MainActor
class BudgetSettingsViewModel: ObservableObject {
    @Published var budgetSettings: BudgetSettings?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    
    private var userId: String? {
        Auth.auth().currentUser?.uid
    }
    
    func saveBudgetSettings(monthlyBudget: Double, categoryBudgets: [CategoryBudget]) async throws {
        guard let userId = userId else {
            throw NSError(domain: "BudgetError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        let settings = BudgetSettings(
            userId: userId,
            monthlyBudget: monthlyBudget,
            categoryBudgets: categoryBudgets,
            createdAt: Date(),
            updatedAt: Date()
        )
        
        let encoder = Firestore.Encoder()
        let data = try encoder.encode(settings)
        
        if let existingId = budgetSettings?.id {
            try await db.collection("budgetSettings").document(existingId).setData(data)
        } else {
            try await db.collection("budgetSettings").addDocument(data: data)
        }
        
        budgetSettings = settings
    }
    
    func fetchBudgetSettings() async throws {
        guard let userId = userId else {
            throw NSError(domain: "BudgetError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let snapshot = try await db.collection("budgetSettings")
            .whereField("userId", isEqualTo: userId)
            .order(by: "updatedAt", descending: true)
            .limit(to: 1)
            .getDocuments()
        
        budgetSettings = try snapshot.documents.first?.data(as: BudgetSettings.self)
        
        // If no settings exist, create default settings
        if budgetSettings == nil {
            let defaultCategories = ["Food", "Transport", "Shopping", "Bills", "Entertainment"]
            let categoryBudgets = defaultCategories.map { category in
                let (icon, color) = getIconAndColor(for: category)
                return CategoryBudget(category: category, amount: 0, icon: icon, color: color)
            }
            
            try await saveBudgetSettings(monthlyBudget: 0, categoryBudgets: categoryBudgets)
        }
    }
    
    func getIconAndColor(for category: String) -> (icon: String, color: String) {
        switch category {
        case "Food":
            return ("fork.knife", "FF8E8E")
        case "Transport":
            return ("car.fill", "60A5FA")
        case "Shopping":
            return ("cart.fill", "8B5CF6")
        case "Bills":
            return ("doc.text.fill", "F59E0B")
        case "Entertainment":
            return ("tv.fill", "10B981")
        default:
            return ("creditcard.fill", "6B7280")
        }
    }
}
