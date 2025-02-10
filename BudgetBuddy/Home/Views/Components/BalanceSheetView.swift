import SwiftUI

import SwiftUI

struct BalanceSheetView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var expenseVM: ExpenseViewModel
    
    var body: some View {
        NavigationStack {
            Group {
                if expenseVM.isLoading {
                    VStack {
                        Spacer()
                        ProgressView()
                            .tint(.white)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Balance Amount
                            VStack(alignment: .leading, spacing: 8) {
                                Text("$8,822.89")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundStyle(.white)
                                
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
                            
                            // Monthly Sections
                            ForEach(Array(expenseVM.expensesByMonth.keys.sorted().reversed()), id: \.self) { month in
                                VStack(alignment: .leading, spacing: 16) {
                                    // Month Header
                                    HStack {
                                        Text(month)
                                            .font(.system(size: 16))
                                            .foregroundStyle(.white)
                                        
                                        Spacer()
                                        
                                        Text("$\(String(format: "%.2f", expenseVM.calculateMonthlyTotal(for: expenseVM.expensesByMonth[month] ?? [])))")
                                            .font(.system(size: 16))
                                            .foregroundStyle(.white)
                                    }
                                    
//                                    // Month's Expenses
//                                    LazyVStack(spacing: 16) {
//                                        ForEach(expenseVM.expensesByMonth[month] ?? []) { expense in
//                                            ExpenseRowView(expense: expense)
//                                                .background(Color(hex: "191919"))
//                                                .cornerRadius(12)
//                                        }
//                                    }
                                    List {
                                        ForEach(expenseVM.expensesByMonth[month] ?? []) { expense in
                                            ExpenseRowView(expense: expense)
                                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                                    Button(role: .destructive) {
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
                                                    } label: {
                                                        Label("Delete", systemImage: "trash")
                                                    }
                                                    .tint(.red)
                                                }
                                                .listRowBackground(Color.clear)
                                                .listRowInsets(EdgeInsets())
                                                .listRowSeparator(.hidden)
                                                .background(Color(hex: "191919"))
                                                .cornerRadius(16)
                                                .padding(.bottom, 8)
                                        }
                                    }
                                    .listStyle(.plain)
                                    .scrollContentBackground(.hidden)
                                    .frame(height: UIScreen.main.bounds.height * 0.6)
                                }
                                .padding(.bottom, 20)
                            }
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
            } catch {
                print("Error fetching expenses: \(error)")
            }
        }
    }
}

struct ExpenseRowView: View {
    let expense: Expense
    
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
                
                Text(expense.time)
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            // Amount
            Text("$\(String(format: "%.2f", expense.amount))")
                .font(.system(size: 16))
                .foregroundStyle(.white)
        }
        .padding()
    }
}
