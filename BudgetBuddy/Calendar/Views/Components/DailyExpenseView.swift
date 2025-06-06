import SwiftUI

struct DailyExpense: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let amount: Double
    let time: String
    let icon: String
    let color: Color
}

struct DailyExpenseView: View {
    // Add state for edit sheet
    @State private var showEditExpense = false
    @State private var selectedExpense: Expense?
    @StateObject private var currencyManager = CurrencyManager.shared

    let date: Date
    let dateFormatter: (Date, String) -> String
    @ObservedObject var expenseVM: ExpenseViewModel
    @State private var showAddExpense = false
    
    init(date: Date, dateFormatter: @escaping (Date, String) -> String, expenseVM: ExpenseViewModel) {  // Update init
            self.date = date
            self.dateFormatter = dateFormatter
            self.expenseVM = expenseVM
    }
        
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Date and Total Header
            HStack(alignment: .center) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Expenses")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                    
                    Text(dateFormatter(date, "d MMMM yyyy"))
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .foregroundStyle(.white)
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Total Spent")
                        .font(.system(size: 14))
                        .foregroundStyle(.gray)
                    Text(currencyManager.formatAmount(expenseVM.calculateDailyTotal()))
                        .font(.system(size: 20))
                        .fontWeight(.semibold)
                        .foregroundStyle(.green)
                }
            }
            .padding(.horizontal)
            
            // Add Expense Button
            Button {
                showAddExpense = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.title3)
                    Text("Add Expense")
                        .font(.system(size: 16))
                }
                .foregroundStyle(.green)
                .padding(.vertical, 12)
                .padding(.horizontal, 16)
                .background(Color(hex: "1E1E1E"))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            

            List {
                if expenseVM.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(expenseVM.dailyExpenses) { expense in
                        DailyExpenseRow(expense: expense)
                            .onTapGesture {
                                // Immediately show the sheet with the selected expense
                                selectedExpense = expense
                                showEditExpense = true
                            }
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button(role: .destructive) {
                                    Task {
                                        if let id = expense.id {
                                            do {
                                                try await expenseVM.deleteExpense(id)
                                                try await expenseVM.fetchDailyExpenses(for: date)
                                            } catch {
                                                print("Error deleting expense: \(error)")
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
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .padding(.horizontal)

            .frame(height: UIScreen.main.bounds.height * 0.6)
        }
        .padding(.vertical, 25)
        .task {
               do {
                   try await expenseVM.fetchDailyExpenses(for: date)
               } catch {
                   print("Error fetching expenses: \(error)")
               }
           }
        .onChange(of: date) { _, newDate in
            Task {
                do {
                    try await expenseVM.fetchDailyExpenses(for: newDate)
                } catch {
                    print("Error fetching expenses: \(error)")
                }
            }
        }
        .sheet(isPresented: $showAddExpense) {
            AddExpenseCalendarView(expenseVM: expenseVM, selectedDate: date)
                .presentationDetents([.medium])
        }
        .sheet(isPresented: $showEditExpense) {
            if let expense = selectedExpense {
                EditExpenseView(expenseVM: expenseVM, expense: expense, date: date)
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.visible)
                    .interactiveDismissDisabled(false)
            }
        }
    }
}

struct DailyExpenseRow: View {
    let expense: Expense
    @StateObject private var currencyManager = CurrencyManager.shared

    var body: some View {
        HStack(spacing: 15) {
            // Icon Container
            ZStack {
                Circle()
                    .fill(Color(hex: expense.color).opacity(0.15))
                    .frame(width: 48, height: 48)
                
                Image(systemName: expense.icon)
                    .font(.system(size: 20))
                    .foregroundStyle(Color(hex: expense.color))
            }
            
            // Details
            VStack(alignment: .leading, spacing: 4) {
                Text(expense.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                
                HStack(spacing: 8) {
                    Text(expense.category)
                        .font(.system(size: 12)) // Reduced font size
                        .padding(.horizontal, 6) // Reduced horizontal padding
                        .padding(.vertical, 2)
                        .background(Color(hex: "1E1E1E"))
                        .cornerRadius(6)
                        .lineLimit(1)
                    
                    Text("•")
                        .foregroundStyle(.gray)
                    
                    Text(expense.time)
                        .font(.system(size: 12)) // Reduced font size
                        .lineLimit(1)
                }
                .foregroundStyle(.gray)
            }
            .frame(maxWidth: .infinity, alignment: .leading) // Ensure details take available space
            
            // Amount (with minimum spacing)
            Text(currencyManager.formatAmount(expense.amount))
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .padding()
    }
}

// Add sheet presentation for editing


// Helper function for dummy data
func getDummyExpenses() -> [DailyExpense] {
    return [
        DailyExpense(
            title: "Morning Coffee",
            category: "Food & Drinks",
            amount: 4.50,
            time: "09:30 AM",
            icon: "cup.and.saucer.fill",
            color: Color(hex: "FF8E8E")
        ),
        DailyExpense(
            title: "Uber Ride",
            category: "Transport",
            amount: 12.00,
            time: "10:15 AM",
            icon: "car.fill",
            color: Color(hex: "60A5FA")
        ),
        DailyExpense(
            title: "Lunch",
            category: "Food & Drinks",
            amount: 15.00,
            time: "01:30 PM",
            icon: "fork.knife",
            color: Color(hex: "037D4F")
        ),
        DailyExpense(
            title: "Office Supplies",
            category: "Shopping",
            amount: 25.00,
            time: "03:45 PM",
            icon: "cart.fill",
            color: Color(hex: "8B5CF6")
        )
    ]
}
