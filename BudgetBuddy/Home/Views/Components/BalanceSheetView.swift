import SwiftUI

import SwiftUI

struct BalanceSheetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var expenseVM: ExpenseViewModel
    @StateObject private var budgetVM = BudgetSettingsViewModel()
    @StateObject private var currencyManager = CurrencyManager.shared
    
    var body: some View {
        NavigationStack {
            Group {
                if expenseVM.isLoading {
                    LoadingView()
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            BalanceHeaderView(budgetVM: budgetVM)
                            SpendingProgressView(expenseVM: expenseVM, budgetVM: budgetVM)
                            MonthlyExpensesListView(expenseVM: expenseVM)
                        }
                        .padding(24)
                    }
                }
            }
            .navigationTitle("My Balance")
            .navigationBarTitleDisplayMode(.inline)
        }
        .background(Color.black)
        .preferredColorScheme(.dark)
        .task {
            do {
                try await expenseVM.fetchAllExpensesGroupedByMonth()
                try await budgetVM.fetchBudgetSettings()
            } catch {
                print("Error fetching expenses: \(error)")
            }
        }
    }
}

// Loading View
struct LoadingView: View {
    var body: some View {
        VStack {
            Spacer()
            ProgressView()
                .tint(.white)
            Spacer()
        }
    }
}

// Balance Header View
struct BalanceHeaderView: View {
    @ObservedObject var budgetVM: BudgetSettingsViewModel
    @StateObject private var currencyManager = CurrencyManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let settings = budgetVM.budgetSettings {
                Text(currencyManager.formatAmount(settings.monthlyBudget))
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.white)
            }
            
            HStack(spacing: 4) {
                Image(systemName: "arrow.up.right")
                    .foregroundStyle(.green)
                Text("+08%")
                    .font(.system(size: 14))
                    .foregroundStyle(.green)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.green.opacity(0.2))
                    .cornerRadius(8)
            }
        }
    }
}

// Spending Progress View
struct SpendingProgressView: View {
    @ObservedObject var expenseVM: ExpenseViewModel
    @ObservedObject var budgetVM: BudgetSettingsViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Spending \(Date().formatted(.dateTime.month()))")
                .font(.headline)
                .foregroundStyle(.white)
            
            if let settings = budgetVM.budgetSettings {
                SpendingDetailsView(expenseVM: expenseVM, settings: settings)
            }
        }
        .padding()
        .background(Color(hex: "191919"))
        .cornerRadius(16)
    }
}

// Spending Details View
struct SpendingDetailsView: View {
    @ObservedObject var expenseVM: ExpenseViewModel
    @StateObject private var currencyManager = CurrencyManager.shared
    let settings: BudgetSettings
    
    var body: some View {
        VStack(spacing: 12) {
            let monthlyTotal = expenseVM.calculateMonthlyTotal(for: expenseVM.expensesByMonth[Date().formatted(.dateTime.year().month())] ?? [])
            
            Text(currencyManager.formatAmount(monthlyTotal))
                .font(.system(size: 20, weight: .bold))
                .foregroundStyle(.white)
            
            CategoryProgressBarsView(expenseVM: expenseVM, settings: settings)
            CategoryLegendView(expenseVM: expenseVM, settings: settings)
        }
    }
}

// Category Progress Bars View
struct CategoryProgressBarsView: View {
    @ObservedObject var expenseVM: ExpenseViewModel
    let settings: BudgetSettings
    
    var body: some View {
        HStack(spacing: 2) {
            ForEach(settings.categoryBudgets) { budget in
                let expenses = (expenseVM.expensesByMonth[Date().formatted(.dateTime.year().month())] ?? [])
                    .filter { $0.category == budget.category }
                let spent = expenses.reduce(0) { $0 + $1.amount }
                let width = (spent / settings.monthlyBudget) * 100
                
                Rectangle()
                    .fill(Color(hex: budget.color))
                    .frame(width: max(0, min(width, 100)) * 3, height: 8)
                    .cornerRadius(4)
            }
            
            Rectangle()
                .fill(Color(hex: "1E1E1E"))
                .frame(height: 8)
                .cornerRadius(4)
        }
    }
}

// Category Legend View
struct CategoryLegendView: View {
    @ObservedObject var expenseVM: ExpenseViewModel
    let settings: BudgetSettings
    
    var body: some View {
        VStack(spacing: 8) {
            ForEach(settings.categoryBudgets) { budget in
                CategoryLegendItemView(expenseVM: expenseVM, budget: budget)
            }
        }
        .padding(.top, 8)
    }
}

// Category Legend Item View
struct CategoryLegendItemView: View {
    @ObservedObject var expenseVM: ExpenseViewModel
    @StateObject private var currencyManager = CurrencyManager.shared
    let budget: CategoryBudget
    
    var body: some View {
        let expenses = (expenseVM.expensesByMonth[Date().formatted(.dateTime.year().month())] ?? [])
            .filter { $0.category == budget.category }
        let spent = expenses.reduce(0) { $0 + $1.amount }
        
        HStack {
            Circle()
                .fill(Color(hex: budget.color))
                .frame(width: 8, height: 8)
            Text(budget.category)
                .font(.caption)
                .foregroundStyle(.gray)
            Spacer()
            Text("\(currencyManager.formatAmount(spent)) / \(currencyManager.formatAmount(budget.amount))")
                .font(.caption)
                .foregroundStyle(.white)
        }
    }
}

// Monthly Expenses List View
struct MonthlyExpensesListView: View {
    @ObservedObject var expenseVM: ExpenseViewModel
    
    var body: some View {
        ForEach(Array(expenseVM.expensesByMonth.keys.sorted().reversed()), id: \.self) { month in
            MonthlyExpenseSectionView(month: month, expenseVM: expenseVM)
        }
    }
}

// Monthly Expense Section View
struct MonthlyExpenseSectionView: View {
    let month: String
    @ObservedObject var expenseVM: ExpenseViewModel
    @State private var selectedExpense: Expense?
    @State private var showEditSheet = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            MonthHeaderView(month: month, expenseVM: expenseVM)
            
            LazyVStack(spacing: 16) {
                ForEach(expenseVM.expensesByMonth[month] ?? []) { expense in
                    ExpenseRowView(expense: expense)
                        .background(Color(hex: "191919"))
                        .cornerRadius(16)
                        .contextMenu {
                            Button(role: .destructive) {
                                deleteExpense(expense, from: month)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                            
                            Button {
                                selectedExpense = expense
                                showEditSheet = true
                            } label: {
                                Label("Edit", systemImage: "pencil")
                            }
                        }
                }
            }
        }
        .padding(.bottom, 20)
        .sheet(isPresented: $showEditSheet) {
            if let expense = selectedExpense {
                EditExpenseView(expenseVM: expenseVM, expense: expense, date: expense.date)
                    .presentationDetents([.medium])

            }
        }
    }
    
    private func deleteExpense(_ expense: Expense, from month: String) {
        Task {
            if let id = expense.id {
                do {
                    expenseVM.removeExpenseLocally(id, from: month)
                    try await expenseVM.deleteExpense(id)
                } catch {
                    print("Error deleting expense: \(error)")
                    try? await expenseVM.fetchAllExpensesGroupedByMonth()
                }
            }
        }
    }
}

// Month Header View
struct MonthHeaderView: View {
    let month: String
    @ObservedObject var expenseVM: ExpenseViewModel
    @StateObject private var currencyManager = CurrencyManager.shared
    
    var body: some View {
        HStack {
            Text(month)
                .font(.system(size: 16))
                .foregroundStyle(.white)
            
            Spacer()
            
            Text(currencyManager.formatAmount(expenseVM.calculateMonthlyTotal(for: expenseVM.expensesByMonth[month] ?? [])))
                .font(.system(size: 16))
                .foregroundStyle(.white)
        }
    }
}

// Keep the existing ExpenseRowView as is
struct ExpenseRowView: View {
    let expense: Expense
    @StateObject private var currencyManager = CurrencyManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            // Icon
            ZStack {
                Circle()
                    .fill(Color(hex: expense.color).opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: expense.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: expense.color))
            }
            
            // Title and Date
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                
                HStack(spacing: 4) {
                    Text(expense.date.formatted(.dateTime.day().month()))
                    Text("•")
                    Text(expense.time)
                }
                .font(.system(size: 14))
                .foregroundStyle(.gray)
            }
            
            Spacer()
            
            // Amount
            Text(currencyManager.formatAmount(expense.amount))
                .font(.system(size: 16))
                .foregroundStyle(.white)
        }
        .padding()
    }
}

