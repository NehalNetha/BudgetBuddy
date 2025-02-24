//
//  IncomeViewModel.swift
//  BudgetBuddy
//
//  Created by NehalNetha on 14/02/25.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth

@MainActor
class IncomeViewModel: ObservableObject {
    @Published var incomes: [Income] = []
    @Published var incomesByMonth: [String: [Income]] = [:]
    @Published var isLoading = false
    private let db = Firestore.firestore()
    
    func addIncome(_ income: Income) async throws {
        do {
            let _ = try await db.collection("incomes").addDocument(from: income)
            await fetchIncomes()
        } catch {
            throw error
        }
    }
    
    func fetchIncomes() async {
        isLoading = true
        defer { isLoading = false }
        
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let snapshot = try await db.collection("incomes")
                .whereField("userId", isEqualTo: userId)
                .order(by: "date", descending: true)
                .getDocuments()
            
            self.incomes = snapshot.documents.compactMap { document in
                try? document.data(as: Income.self)
            }
            
            // Group incomes by month
            var groupedIncomes: [String: [Income]] = [:]
            for income in incomes {
                let month = income.date.formatted(.dateTime.year().month())
                groupedIncomes[month, default: []].append(income)
            }
            self.incomesByMonth = groupedIncomes
            
        } catch {
            print("Error fetching incomes: \(error)")
        }
    }
    
    func deleteIncome(_ id: String) async throws {
        try await db.collection("incomes").document(id).delete()
        await fetchIncomes()
    }
    
    func calculateTotalIncome() -> Double {
        incomes.reduce(0) { $0 + $1.amount }
    }
    
    func calculateMonthlyTotal(for month: String) -> Double {
        incomesByMonth[month]?.reduce(0) { $0 + $1.amount } ?? 0
    }
}
