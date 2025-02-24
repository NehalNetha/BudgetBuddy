
import SwiftUI
import Charts


struct MonthlySpending: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
}

struct SpendingTrendsCard: View {
    let expenses: [Expense]
    @State private var timeRange: TimeRange = .oneMonth
    
    enum TimeRange {
        case oneMonth, sixMonths
    }
    
    private var monthlyData: [MonthlySpending] {
        let calendar = Calendar.current
        let today = Date()
        
        switch timeRange {
        case .sixMonths:
            let groupedExpenses = Dictionary(grouping: expenses) { expense in
                let components = calendar.dateComponents([.year, .month], from: expense.date)
                return calendar.date(from: components)!
            }
            
            let last6Months = (0..<6).compactMap { monthsAgo -> Date? in
                calendar.date(byAdding: .month, value: -monthsAgo, to: today)
            }
            
            return last6Months.map { date in
                let monthExpenses = groupedExpenses[date] ?? []
                let total = monthExpenses.reduce(0) { $0 + $1.amount }
                let monthStr = date.formatted(.dateTime.month(.abbreviated))
                return MonthlySpending(month: monthStr, amount: total)
            }.reversed()
            
        case .oneMonth:
            let currentMonth = calendar.component(.month, from: today)
            let currentYear = calendar.component(.year, from: today)
            
            let daysInMonth = (1...31).compactMap { day -> Date? in
                var components = DateComponents()
                components.year = currentYear
                components.month = currentMonth
                components.day = day
                return calendar.date(from: components)
            }.filter { date in
                calendar.component(.month, from: date) == currentMonth
            }
            
            return daysInMonth.map { date in
                let dayExpenses = expenses.filter {
                    calendar.isDate($0.date, inSameDayAs: date)
                }
                let total = dayExpenses.reduce(0) { $0 + $1.amount }
                let dayStr = date.formatted(.dateTime.day())
                return MonthlySpending(month: dayStr, amount: total)
            }
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Spending Trends")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Spacer()
                
                // Time range picker
                Picker("Time Range", selection: $timeRange) {
                    Text("1M").tag(TimeRange.oneMonth)
                    Text("6M").tag(TimeRange.sixMonths)
                }
                .pickerStyle(.segmented)
                .frame(width: 100)
            }
            
            Chart {
                ForEach(monthlyData) { data in
                    LineMark(
                        x: .value("Time", data.month),
                        y: .value("Spend", data.amount)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    
                    PointMark(
                        x: .value("Time", data.month),
                        y: .value("Spend", data.amount)
                    )
                    .foregroundStyle(Color.blue)
                }
            }
            .frame(height: 200)
            .chartYAxis {
                AxisMarks(position: .leading) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let amount = value.as(Double.self) {
                            Text("$\(Int(amount))")
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let label = value.as(String.self) {
                            Text(label)
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
            .animation(.easeInOut, value: timeRange)
        }
        .padding()
        .background(Color(hex: "191919"))
        .cornerRadius(20)
    }
}

struct BudgetComparisonCard: View {
    @StateObject private var budgetVM = BudgetSettingsViewModel()
    let expenses: [Expense]
    @StateObject private var currencyManager = CurrencyManager.shared

    
    private var categoryComparisons: [(category: String, spent: Double, budget: Double)] {
        guard let settings = budgetVM.budgetSettings else { return [] }
        
        return settings.categoryBudgets.map { categoryBudget in
            // Calculate total spent for this category
            let spent = expenses.filter { $0.category == categoryBudget.category }
                .reduce(0) { $0 + $1.amount }
            
            return (
                category: categoryBudget.category,
                spent: spent,
                budget: categoryBudget.amount
            )
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Budget vs Actual")
                .font(.headline)
                .foregroundStyle(.white)
            
            if budgetVM.isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(categoryComparisons, id: \.category) { comparison in
                    VStack(spacing: 8) {
                        HStack {
                            Text(comparison.category)
                                .foregroundStyle(.white)
                            Spacer()
                            Text("\(currencyManager.formatAmount(comparison.spent)) / \(currencyManager.formatAmount(comparison.budget))")
                            
                                .font(.system(size: 14))
                                .foregroundStyle(.gray)
                        }
                        
                        // Progress bar showing budget utilization
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                Rectangle()
                                    .fill(Color(hex: "1E1E1E"))
                                
                                Rectangle()
                                    .fill(getProgressColor(spent: comparison.spent, budget: comparison.budget))
                                    .frame(width: getProgressWidth(spent: comparison.spent, budget: comparison.budget, totalWidth: geometry.size.width))
                            }
                        }
                        .frame(height: 8)
                        .cornerRadius(4)
                    }
                }
            }
        }
        .padding()
        .background(Color(hex: "191919"))
        .cornerRadius(20)
        .task {
            do {
                try await budgetVM.fetchBudgetSettings()
            } catch {
                print("Error fetching budget settings: \(error)")
            }
        }
    }
    
    private func getProgressWidth(spent: Double, budget: Double, totalWidth: CGFloat) -> CGFloat {
        guard budget > 0 else { return 0 }
        let percentage = min(spent / budget, 1.0)
        return totalWidth * CGFloat(percentage)
    }
    
    private func getProgressColor(spent: Double, budget: Double) -> Color {
        if budget == 0 { return .gray }
        let percentage = spent / budget
        if percentage >= 1.0 {
            return Color(hex: "FF8E8E") // Red for over budget
        } else if percentage >= 0.8 {
            return Color(hex: "F59E0B") // Yellow for near budget
        } else {
            return Color(hex: "037D4F") // Green for within budget
        }
    }
}


struct RecurringExpensesCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Recurring Expenses")
                .font(.headline)
                .foregroundStyle(.white)
            
            ForEach(["Netflix", "Gym", "Rent"], id: \.self) { expense in
                HStack {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 8, height: 8)
                    
                    Text(expense)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Text("$9.99/month")
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding()
        .background(Color(hex: "191919"))
        .cornerRadius(20)
    }
}
