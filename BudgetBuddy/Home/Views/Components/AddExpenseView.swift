import SwiftUI

struct AddExpenseView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var expenseTitle = ""
    @State private var expenseAmount = ""
    @State private var selectedCategory = "Food"
    @State private var isAddingNewCategory = false
    @State private var newCategoryName = ""
    @State private var expenseDate = Date()
    @State private var categories = ["Food", "Transport", "Shopping", "Bills", "Entertainment", "Other"]
    @ObservedObject var expenseVM: ExpenseViewModel

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Custom nav bar
                HStack {
                    Text("Add Expense")
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
                    TextField("0.00", text: $expenseAmount)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "1E1E1E")))
                .padding(.horizontal)

                // Title input
                TextField("Expense Title", text: $expenseTitle)
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "1E1E1E")))
                    .foregroundStyle(.white)
                    .padding(.horizontal)

                // Category selector with "Add Category" button
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            Button {
                                selectedCategory = category
                            } label: {
                                Text(category)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        RoundedRectangle(cornerRadius: 20)
                                            .fill(selectedCategory == category ? Color(hex: "037D4F") : Color(hex: "2D2D2D"))
                                    )
                            }
                        }

                        // "Add Category" button
                        Button {
                            isAddingNewCategory = true
                        } label: {
                            Image(systemName: "plus.circle.fill")
                                .font(.title2)
                                .foregroundStyle(.green)
                        }
                    }
                    .padding(.horizontal)
                }

                // New Category Input (Shown when isAddingNewCategory is true)
                if isAddingNewCategory {
                    TextField("New Category Name", text: $newCategoryName)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "1E1E1E")))
                        .foregroundStyle(.white)
                        .padding(.horizontal)

                    HStack {
                        Button("Cancel") {
                            isAddingNewCategory = false
                            newCategoryName = ""
                        }
                        .padding()
                        .foregroundStyle(.white)

                        Button("Add") {
                            if !newCategoryName.isEmpty {
                                categories.append(newCategoryName)
                                selectedCategory = newCategoryName // Optionally select the new category
                                newCategoryName = ""
                                isAddingNewCategory = false
                            }
                        }
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.blue))
                        .foregroundStyle(.white)
                    }
                    .padding(.horizontal)
                }

                // Date picker
                DatePicker("Date", selection: $expenseDate, displayedComponents: .date)
                   .datePickerStyle(.compact)
                   .padding()
                   .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "1E1E1E")))
                   .foregroundStyle(.white)
                   .padding(.horizontal)

              
                // Add button
                Button {
                    // Add expense logic here
                    addExpense()
                } label: {
                    Text("Add Expense")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "037D4F")))
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top, 60) // Increased top padding
            .padding(.bottom, 30) // Added bottom padding
            .frame(maxHeight: .infinity) // Allow the view to take up more vertical space if needed
            .background(Color(hex: "191919"))
           
        }
    }
    
    private func addExpense() {
          
        
          guard let amount = Double(expenseAmount), !expenseTitle.isEmpty else { return }
       
            
          
          // Get icon and color for the category
          let iconAndColor = expenseVM.getIconAndColor(for: selectedCategory)
          
          Task {
              do {
                  try await expenseVM.addExpense(
                      title: expenseTitle,
                      amount: amount,
                      category: selectedCategory,
                      icon: iconAndColor.icon,
                      color: iconAndColor.color,
                      date: expenseDate
                  )
                  print("Successfully added expense")

                  dismiss()
              } catch {
                  print("Error adding expense: \(error)")
              }
          }
    }
    
   
    
}
