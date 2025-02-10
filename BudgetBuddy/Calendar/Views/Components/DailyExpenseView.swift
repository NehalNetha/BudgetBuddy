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
                    Text("$\(String(format: "%.2f", expenseVM.calculateDailyTotal()))")
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
            
            // Expense List
            
           
//        VStack(spacing: 15) {
//             if expenseVM.isLoading {
//                 ProgressView()
//             } else {
//                 ForEach(expenseVM.dailyExpenses) { expense in
//                     DailyExpenseRow(expense: expense)
//                         .background(Color(hex: "191919"))
//                         .cornerRadius(16)
//                 }
//             }
//          }
//          .padding(.horizontal)
            
            List {
                if expenseVM.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .listRowBackground(Color.clear)
                } else {
                    ForEach(expenseVM.dailyExpenses) { expense in
                        DailyExpenseRow(expense: expense)
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
    }
}

struct DailyExpenseRow: View {
    let expense: Expense
    
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
                
                HStack(spacing: 8) {
                    Text(expense.category)
                        .font(.system(size: 13))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 2)
                        .background(Color(hex: "1E1E1E"))
                        .cornerRadius(8)
                    
                    Text("•")
                        .foregroundStyle(.gray)
                    
                    Text(expense.time)
                        .font(.system(size: 13))
                }
                .foregroundStyle(.gray)
            }
            
            Spacer()
            
            // Amount
            Text("-$\(String(format: "%.2f", expense.amount))")
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(.white)
        }
        .padding()
      
    }
}

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
