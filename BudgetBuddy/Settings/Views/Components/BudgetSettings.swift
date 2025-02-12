import SwiftUI

struct BudgetSettingsView: View {
    @StateObject private var budgetSettingsVM = BudgetSettingsViewModel()
    @State private var monthlyBudget: String = ""
    @State private var selectedCategory: String = "Food"
    @State private var categoryBudget: String = ""
    @State private var isEditingMonthly = false
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    private let categories = ["Food", "Transport", "Shopping", "Bills", "Entertainment"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) { // Reduced from 24
                // Monthly Budget Card
                VStack(alignment: .leading, spacing: 12) {
                    HStack(alignment: .center) {
                        Label("Monthly Budget", systemImage: "dollarsign.circle.fill")
                            .font(.title3.bold()) // Reduced from title2
                            .foregroundStyle(.white)
                        Spacer()
                        if let _ = budgetSettingsVM.budgetSettings, !isEditingMonthly {
                            Button(action: { isEditingMonthly = true }) {
                                Image(systemName: "pencil.circle.fill")
                                    .foregroundStyle(Color(hex: "037D4F"))
                                    .font(.title3) // Reduced from title2
                            }
                            .transition(.scale)
                        }
                    }
                    
                    if let settings = budgetSettingsVM.budgetSettings, !isEditingMonthly {
                        VStack(spacing: 8) { // Reduced from 12
                            Text("$\(String(format: "%.2f", settings.monthlyBudget))")
                                .font(.system(size: 28, weight: .bold)) // Reduced from 36
                                .foregroundStyle(.white)
                            
                            Label("Budget Set", systemImage: "checkmark.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.gray)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 4)
                                .background(Color(hex: "1E1E1E"))
                                .cornerRadius(16)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12) // Reduced from 16
                        .background(Color(hex: "1E1E1E"))
                        .cornerRadius(12)
                    } else {
                        HStack(spacing: 12) {
                            HStack {
                                Text("$")
                                    .foregroundStyle(.gray)
                                TextField("0.00", text: $monthlyBudget)
                                    .keyboardType(.decimalPad)
                            }
                            .padding()
                            .background(Color(hex: "1E1E1E"))
                            .cornerRadius(12)
                            .foregroundStyle(.white)
                            
                            HStack(spacing: 8) {
                                Button(action: saveMonthlyBudget) {
                                    Image(systemName: "checkmark")
                                        .foregroundStyle(.white)
                                        .padding(12)
                                        .background(Color(hex: "037D4F"))
                                        .clipShape(Circle())
                                }
                                
                                if isEditingMonthly {
                                    Button(action: {
                                        isEditingMonthly = false
                                        monthlyBudget = String(format: "%.2f", budgetSettingsVM.budgetSettings?.monthlyBudget ?? 0)
                                    }) {
                                        Image(systemName: "xmark")
                                            .foregroundStyle(.white)
                                            .padding(12)
                                            .background(Color.red.opacity(0.8))
                                            .clipShape(Circle())
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(16) // Reduced from 20
                .background(Color(hex: "191919"))
                .cornerRadius(16) // Reduced from 20
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2) // Reduced shadow

                // Category Budgets
                VStack(alignment: .leading, spacing: 12) { // Reduced from 16
                    Label("Category Budgets", systemImage: "folder.fill")
                        .font(.title3.bold()) // Reduced from title2
                        .foregroundStyle(.white)
                    
                    if let categoryBudgets = budgetSettingsVM.budgetSettings?.categoryBudgets, !categoryBudgets.isEmpty {
                        VStack(spacing: 8) { // Reduced from 12
                            ForEach(categoryBudgets, id: \.category) { budget in
                                CategoryBudgetRow(
                                    budget: budget,
                                    onEdit: { editCategoryBudget(category: budget.category) }
                                )
                                .transition(.slide)
                            }
                        }
                    } else {
                        EmptyBudgetView()
                    }
                }
                .padding(16) // Reduced from 20
                .background(Color(hex: "191919"))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)

                // Add Category Budget section adjustments
                VStack(alignment: .leading, spacing: 12) { // Reduced from 16
                    Label("Add Category Budget", systemImage: "plus.circle.fill")
                        .font(.title3.bold()) // Reduced from title2
                        .foregroundStyle(.white)
                    
                    Menu {
                        ForEach(categories, id: \.self) { category in
                            Button(action: { selectedCategory = category }) {
                                HStack {
                                    Text(category)
                                    if category == selectedCategory {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Color(hex: "037D4F"))
                                    }
                                }
                            }
                        }
                    } label: {
                        HStack {
                            Text(selectedCategory)
                                .foregroundStyle(.white)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundStyle(.gray)
                        }
                        .padding()
                        .background(Color(hex: "1E1E1E"))
                        .cornerRadius(12)
                    }
                    
                    HStack(spacing: 12) {
                        HStack {
                            Text("$")
                                .foregroundStyle(.gray)
                            TextField("0.00", text: $categoryBudget)
                                .keyboardType(.decimalPad)
                        }
                        .padding()
                        .background(Color(hex: "1E1E1E"))
                        .cornerRadius(12)
                        .foregroundStyle(.white)
                        
                        Button(action: saveCategoryBudget) {
                            Image(systemName: "plus")
                                .foregroundStyle(.white)
                                .padding(12)
                                .background(Color(hex: "037D4F"))
                                .clipShape(Circle())
                        }
                    }
                }
                .padding(16) // Reduced from 20
                .background(Color(hex: "191919"))
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            .padding(12) // Reduced from default padding
        }
        .background(Color.black)
        .task {
            await loadBudgetSettings()
        }
    }
}

// Adjust CategoryBudgetRow
struct CategoryBudgetRow: View {
    let budget: CategoryBudget
    let onEdit: () -> Void
    
    var body: some View {
        HStack(spacing: 12) { // Reduced from 16
            Image(systemName: budget.icon)
                .foregroundStyle(Color(hex: budget.color))
                .font(.title3) // Reduced from title2
                .frame(width: 28) // Reduced from 32
            
            VStack(alignment: .leading, spacing: 2) { // Reduced from 4
                Text(budget.category)
                    .foregroundStyle(.white)
                    .font(.subheadline) // Reduced from headline
                
                Text("Monthly limit")
                    .font(.caption2) // Reduced from caption
                    .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Text("$\(String(format: "%.2f", budget.amount))")
                .foregroundStyle(.white)
                .font(.subheadline.bold()) // Adjusted font
            
            Button(action: onEdit) {
                Image(systemName: "pencil.circle.fill")
                    .foregroundStyle(.gray)
                    .font(.system(size: 16)) // Reduced from 18
            }
        }
        .padding(12) // Reduced from default padding
        .background(Color(hex: "1E1E1E"))
        .cornerRadius(12)
    }
}

// Adjust EmptyBudgetView
struct EmptyBudgetView: View {
    var body: some View {
        VStack(spacing: 8) { // Reduced from 12
            Image(systemName: "dollarsign.circle")
                .font(.system(size: 32)) // Reduced from 40
                .foregroundStyle(.gray)
            
            Text("No category budgets set")
                .font(.subheadline) // Reduced from headline
                .foregroundStyle(.gray)
            
            Text("Add a category budget below to get started")
                .font(.caption)
                .foregroundStyle(.gray.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 24) // Reduced from 32
    }
}


extension BudgetSettingsView{
    private func editCategoryBudget(category: String) {
        selectedCategory = category
        if let budget = budgetSettingsVM.budgetSettings?.categoryBudgets.first(where: { $0.category == category }) {
            categoryBudget = String(format: "%.2f", budget.amount)
        }
    }
    
    private func loadBudgetSettings() async {
        do {
            try await budgetSettingsVM.fetchBudgetSettings()
            if let settings = budgetSettingsVM.budgetSettings {
                monthlyBudget = String(format: "%.2f", settings.monthlyBudget)
            }
        } catch {
            print("Error loading budget settings: \(error)")
        }
    }
    
    private func saveMonthlyBudget() {
        guard let amount = Double(monthlyBudget) else { return }
        Task {
            do {
                try await budgetSettingsVM.saveBudgetSettings(
                    monthlyBudget: amount,
                    categoryBudgets: budgetSettingsVM.budgetSettings?.categoryBudgets ?? []
                )
            } catch {
                print("Error saving monthly budget: \(error)")
            }
        }
    }
    
    private func saveCategoryBudget() {
        guard let amount = Double(categoryBudget) else { return }
        let (icon, color) = budgetSettingsVM.getIconAndColor(for: selectedCategory)
        
        var currentBudgets = budgetSettingsVM.budgetSettings?.categoryBudgets ?? []
        if let index = currentBudgets.firstIndex(where: { $0.category == selectedCategory }) {
            currentBudgets[index].amount = amount
        } else {
            currentBudgets.append(CategoryBudget(
                category: selectedCategory,
                amount: amount,
                icon: icon,
                color: color
            ))
        }
        
        Task {
            do {
                try await budgetSettingsVM.saveBudgetSettings(
                    monthlyBudget: Double(monthlyBudget) ?? 0,
                    categoryBudgets: currentBudgets
                )
                categoryBudget = ""
            } catch {
                print("Error saving category budget: \(error)")
            }
        }
    }
}
