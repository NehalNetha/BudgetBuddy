//
//  ExpenseViewModel.swift
//  BudgetBuddy
//
//  Created by NehalNetha on 09/02/25.
//

import Foundation
import Firebase
import FirebaseFirestore
import FirebaseAuth


@MainActor
class ExpenseViewModel: ObservableObject {
    @Published var expenses: [Expense] = []
    @Published var dailyExpenses: [Expense] = []
    @Published var isLoading = false
    @Published var error: Error?
    @Published var recentExpenses: [Expense] = []
    @Published var expensesByMonth: [String: [Expense]] = [:]

    private let db = Firestore.firestore()
    
    private var userId: String? {
           Auth.auth().currentUser?.uid
    }
       
    
    
    // Add new expense
    func addExpense(title: String, amount: Double, category: String, icon: String, color: String, date: Date) async throws {
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "hh:mm a"
        timeFormatter.dateFormat = "hh:mm a"
        guard let userId = userId else {
                    throw NSError(domain: "ExpenseError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
                }
                
        
        let expense = Expense(
            title: title,
            amount: amount,
            category: category,
            date: date,
            time: timeFormatter.string(from: date),
            icon: icon,
            color: color,
            userId: userId
        )
        
        print("Created expense object:", expense)
           
       let encoder = Firestore.Encoder()
       let data = try encoder.encode(expense)
       print("Encoded data:", data)
       
       do {
           let docRef = try await db.collection("expenses").addDocument(data: data)
           print("Successfully added document with ID:", docRef.documentID)
           try await fetchDailyExpenses(for: date)
           try await fetchRecentExpenses()
           print("Successfully fetched updated daily expenses")
       } catch {
           print("Error adding document:", error)
           throw error
       }

    }
    
    func fetchDailyExpenses(for date: Date) async throws {
        guard let userId = userId else {
            throw NSError(domain: "ExpenseError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
                
        isLoading = true
        defer { isLoading = false }
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        print("Fetching expenses for date:", date)
        print("Start of day:", startOfDay)
        print("End of day:", endOfDay)
        
        let snapshot = try await db.collection("expenses")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: startOfDay))
            .whereField("date", isLessThan: Timestamp(date: endOfDay))
            .order(by: "date", descending: false)
            .getDocuments()
        
        print("Found \(snapshot.documents.count) expenses")
        
        dailyExpenses = snapshot.documents.compactMap { document in
            try? document.data(as: Expense.self)
        }
    }
    
    func fetchRecentExpenses() async throws {
        guard let userId = userId else {
            throw NSError(domain: "ExpenseError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let snapshot = try await db.collection("expenses")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .limit(to: 10)
            .getDocuments()
        
        recentExpenses = snapshot.documents.compactMap { document in
            try? document.data(as: Expense.self)
        }
    }
    
    // Add this property
    func fetchAllExpenses() async throws -> [Expense] {
        guard let userId = userId else {
            throw NSError(domain: "ExpenseError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])
        }
        
        isLoading = true
        defer { isLoading = false }
        
        let snapshot = try await db.collection("expenses")
            .whereField("userId", isEqualTo: userId)
            .order(by: "date", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { document in
            try? document.data(as: Expense.self)
        }
    }

    // Add this method
    func fetchAllExpensesGroupedByMonth() async throws {
        let allExpenses = try await fetchAllExpenses()
        let calendar = Calendar.current
        
        // Group expenses by month
        expensesByMonth = Dictionary(grouping: allExpenses) { expense in
            let date = expense.date
            let components = calendar.dateComponents([.year, .month], from: date)
            let monthDate = calendar.date(from: components)!
            return monthDate.formatted(.dateTime.year().month())
        }
    }

    func calculateMonthlyTotal(for expenses: [Expense]) -> Double {
        expenses.reduce(0) { $0 + $1.amount }
    }
    
    // Calculate total expenses for a specific date
    func calculateDailyTotal() -> Double {
        dailyExpenses.reduce(0) { $0 + $1.amount }
    }
    
    // Delete expense
    func deleteExpense(_ expenseId: String) async throws {
        try await db.collection("expenses").document(expenseId).delete()
    }

    func updateExpense(_ expense: Expense) async throws {
        guard let expenseId = expense.id else { return }
        let encoder = Firestore.Encoder()
        let data = try encoder.encode(expense)
        try await db.collection("expenses").document(expenseId).setData(data)
    }
    
    func removeExpenseLocally(_ id: String, from month: String) {
            if var monthExpenses = expensesByMonth[month] {
                monthExpenses.removeAll { $0.id == id }
                expensesByMonth[month] = monthExpenses
                
                // If month becomes empty, remove it
                if monthExpenses.isEmpty {
                    expensesByMonth.removeValue(forKey: month)
                }
            }
        }
    
    // Helper method to get icon and color for category
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
