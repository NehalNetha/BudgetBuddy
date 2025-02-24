import SwiftUI

struct ExpenseCategory: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
    let code: String
}

struct ExpenseProgressChart: View {
    let expenses: [Expense] // Add this line
    @State private var selectedCategory: ExpenseCategory?
    @State private var showDetails = false
    @State private var selectedPeriod: TimePeriod = .week
    @State private var showBreakdown = false
    @StateObject private var currencyManager = CurrencyManager.shared

    // Remove the hardcoded categories array
    
    var filteredExpenses: [Expense] {
        let calendar = Calendar.current
        let today = Date()
        
        switch selectedPeriod {
        case .week:
            let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
            return expenses.filter { expense in
                calendar.isDate(expense.date, equalTo: weekStart, toGranularity: .weekOfYear)
            }
        case .month:
            let month = calendar.component(.month, from: today)
            let year = calendar.component(.year, from: today)
            return expenses.filter { expense in
                let expenseMonth = calendar.component(.month, from: expense.date)
                let expenseYear = calendar.component(.year, from: expense.date)
                return expenseMonth == month && expenseYear == year
            }
        case .year:
            let year = calendar.component(.year, from: today)
            return expenses.filter { expense in
                calendar.component(.year, from: expense.date) == year
            }
        }
    }
    
    var categories: [ExpenseCategory] {
        let categoryGroups = Dictionary(grouping: filteredExpenses) { $0.category }
        
        let categoryTotals = categoryGroups.map { (category, expenses) in
            let total = expenses.reduce(0) { $0 + $1.amount }
            let (icon, colorHex) = getIconAndColorForCategory(category)
            return ExpenseCategory(
                name: category,
                amount: total,
                color: Color(hex: colorHex),
                code: icon
            )
        }
        
        return categoryTotals.sorted { $0.amount > $1.amount }
    }
    
    private func getIconAndColorForCategory(_ category: String) -> (icon: String, color: String) {
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
    
    enum TimePeriod: String, CaseIterable {
        case week = "This Week"
        case month = "This Month"
        case year = "This Year"
    }
    
    var totalSpend: Double {
        categories.reduce(0) { $0 + $1.amount }
    }
    
    var body: some View {
        VStack(spacing: 25) {
            // Time Period Selector
            HStack(spacing: 30) {
                ForEach(TimePeriod.allCases, id: \.self) { period in
                    Button(action: {
                        withAnimation {
                            selectedPeriod = period
                            selectedCategory = nil  // Reset selected category
                            showDetails = false     // Reset details view
                        }
                    }) {
                        Text(period.rawValue)
                            .font(.system(size: 14))
                            .foregroundStyle(selectedPeriod == period ? .white : .gray)
                    }
                }
            }
            .padding(.top, 10)
            
            VStack(alignment: .leading, spacing: 20) {
                // Progress Chart
                ZStack {
                    // Background Circle
                    Circle()
                        .trim(from: 0, to: 0.8)
                        .stroke(Color(hex: "1E1E1E"), lineWidth: 30)
                        .frame(height: 200)
                        .rotationEffect(.degrees(120))
                    
                    // Category Segments
                    CategorySegments(categories: categories, selectedCategory: $selectedCategory, showDetails: $showDetails)
                    
                    // Center Display
                    CenterDisplay(selectedCategory: selectedCategory, totalSpend: totalSpend)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                
                // Default Center Value or Selected Category Details
               
                
                // Category Breakdown
                if showBreakdown {
                    VStack(spacing: 15) {
                        ForEach(categories) { category in
                            HStack(spacing: 12) {
                                Circle()
                                    .fill(category.color)
                                    .frame(width: 10, height: 10)
                                
                                Text(category.name)
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white)
                                
                                Spacer()
                                
                                Text(currencyManager.formatAmount(category.amount))
                                    .font(.system(size: 14))
                                    .foregroundStyle(.white)
                            }
                        }
                    }
                    .padding(.top, 10)
                    .transition(.opacity)
                }
                
                // Class Breakdown Button
                Button {
                    withAnimation {
                        showBreakdown.toggle()
                    }
                } label: {
                    HStack {
                        Text("Class Breakdown")
                            .font(.system(size: 14))
                        
                        Image(systemName: showBreakdown ? "chevron.up" : "chevron.down")
                            .font(.system(size: 12))
                    }
                    .foregroundStyle(showBreakdown ? .white : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
                    .background(Color(hex: "1E1E1E"))
                    .cornerRadius(12)
                }
            }
            .padding()
        }
        .background(Color(hex: "191919"))
        .cornerRadius(20)
    }
}

// Add these new structures
private struct CategorySegments: View {
    let categories: [ExpenseCategory]
    @Binding var selectedCategory: ExpenseCategory?
    @Binding var showDetails: Bool
    
    var body: some View {
        ForEach(Array(zip(categories.indices, categories)), id: \.0) { index, category in
            let startAngle = Double(index) * (0.8 / Double(categories.count))
            let endAngle = Double(index + 1) * (0.8 / Double(categories.count))
            
            Circle()
                .trim(from: startAngle, to: endAngle)
                .stroke(category.color, lineWidth: selectedCategory?.id == category.id ? 35 : 30)
                .frame(height: 200)
                .rotationEffect(.degrees(120))
                .onTapGesture {
                    withAnimation(.spring()) {
                        selectedCategory = selectedCategory?.id == category.id ? nil : category
                        showDetails = true
                    }
                }
        }
    }
}

private struct CenterDisplay: View {
    let selectedCategory: ExpenseCategory?
    let totalSpend: Double
    @StateObject private var currencyManager = CurrencyManager.shared

    var body: some View {
        VStack(spacing: 4) {
            if let selected = selectedCategory {
                Text(currencyManager.formatAmount(selected.amount))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                
                HStack {
                    Image(systemName: selected.code)
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                    Text(selected.name)
                        .font(.caption)
                        .foregroundStyle(.gray)
                }
            } else {
                Text(currencyManager.formatAmount(totalSpend))
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(.white)
                Text("Total Spend")
                    .font(.caption)
                    .foregroundStyle(.gray)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "1E1E1E"))
        )
    }
}

