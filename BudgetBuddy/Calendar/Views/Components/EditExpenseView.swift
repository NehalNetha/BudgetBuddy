import SwiftUI

struct EditExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var expenseVM: ExpenseViewModel
    let expense: Expense
    let date: Date
    
    // Add loading state
    @State private var isLoading = true
    
    // Create a dedicated struct for editable expense details
    @State private var editableExpense: EditableExpense
    @State private var categories = ["Food", "Transport", "Shopping", "Bills", "Entertainment", "Other"]
    
    init(expenseVM: ExpenseViewModel, expense: Expense, date: Date) {
        self.expenseVM = expenseVM
        self.expense = expense
        self.date = date
        // Initialize editableExpense with current expense values
        _editableExpense = State(initialValue: EditableExpense(
            title: expense.title,
            amount: String(format: "%.2f", expense.amount),
            category: expense.category
        ))
    }
    
    var body: some View {
        NavigationView {
            Group {
                if isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color(hex: "191919"))
                } else {
                    VStack(spacing: 20) {
                        // Custom nav bar
                        HStack {
                            Text("Edit Expense")
                                .font(.title2)
                                .foregroundStyle(.white)
                            Spacer()
                            Button {
                                dismiss()
                            } label: {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundStyle(.gray)
                                    .font(.title2)
                            }
                        }
                        .padding(.horizontal)
                        
                        // Amount input
                        HStack(alignment: .center) {
                            Text("$")
                                .foregroundStyle(.white)
                                .font(.system(size: 24, weight: .medium))
                            TextField("0.00", text: $editableExpense.amount)
                                .keyboardType(.decimalPad)
                                .font(.system(size: 24, weight: .medium))
                                .foregroundStyle(.white)
                        }
                        .padding()
                        .background(Color(hex: "1E1E1E"))
                        .cornerRadius(16)
                        .padding(.horizontal)
                        
                        // Title input
                        TextField("Expense Title", text: $editableExpense.title)
                            .padding()
                            .background(Color(hex: "1E1E1E"))
                            .cornerRadius(16)
                            .foregroundStyle(.white)
                            .padding(.horizontal)
                        
                        // Category selector
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(categories, id: \.self) { category in
                                    Button {
                                        editableExpense.category = category
                                    } label: {
                                        Text(category)
                                            .font(.system(size: 14))
                                            .foregroundStyle(.white)
                                            .padding(.horizontal, 16)
                                            .padding(.vertical, 8)
                                            .background(
                                                RoundedRectangle(cornerRadius: 20)
                                                    .fill(editableExpense.category == category ? Color(hex: "037D4F") : Color(hex: "2D2D2D"))
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        
                        // Update button
                        Button {
                            updateExpense()
                        } label: {
                            Text("Update Expense")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "037D4F"))
                                .cornerRadius(16)
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.top, 60)
                    .background(Color(hex: "191919"))
                }
            }
            .navigationBarHidden(true)
            .background(Color(hex: "191919"))
            .onAppear {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isLoading = false
                }
            }
        }
    }
    
    private func updateExpense() {
        guard let amount = Double(editableExpense.amount),
              let id = expense.id,
              !editableExpense.title.isEmpty else { return }
        
        let iconAndColor = expenseVM.getIconAndColor(for: editableExpense.category)
        
        Task {
            do {
                try await expenseVM.updateExpense(
                    id: id,
                    title: editableExpense.title,
                    amount: amount,
                    category: editableExpense.category,
                    icon: iconAndColor.icon,
                    color: iconAndColor.color,
                    date: date
                )
                dismiss()
            } catch {
                print("Error updating expense: \(error)")
            }
        }
    }
}

// Add this struct to hold editable expense details
struct EditableExpense {
    var title: String
    var amount: String
    var category: String
}
