
import SwiftUI
import Charts


struct MonthlySpending: Identifiable {
    let id = UUID()
    let month: String
    let amount: Double
}

struct SpendingTrendsCard: View {
    let expenses: [Expense]
    
    private var monthlyData: [MonthlySpending] {
        let calendar = Calendar.current
        let groupedExpenses = Dictionary(grouping: expenses) { expense in
            let components = calendar.dateComponents([.year, .month], from: expense.date)
            return calendar.date(from: components)!
        }
        
        // Get last 6 months
        let today = Date()
        let last6Months = (0..<6).compactMap { monthsAgo -> Date? in
            calendar.date(byAdding: .month, value: -monthsAgo, to: today)
        }
        
        return last6Months.map { date in
            let monthExpenses = groupedExpenses[date] ?? []
            let total = monthExpenses.reduce(0) { $0 + $1.amount }
            let monthStr = date.formatted(.dateTime.month(.abbreviated))
            return MonthlySpending(month: monthStr, amount: total)
        }.reversed()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Spending Trends")
                .font(.headline)
                .foregroundStyle(.white)
            
            Chart {
                ForEach(monthlyData) { data in
                    LineMark(
                        x: .value("Month", data.month),
                        y: .value("Spend", data.amount)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    
                    PointMark(
                        x: .value("Month", data.month),
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
                        if let month = value.as(String.self) {
                            Text(month)
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color(hex: "191919"))
        .cornerRadius(20)
    }
}

struct BudgetComparisonCard: View {
    @StateObject private var budgetVM = BudgetSettingsViewModel()
    let expenses: [Expense]
    
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
                            Text("$\(String(format: "%.2f", comparison.spent)) / $\(String(format: "%.2f", comparison.budget))")
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

struct SavingsProgressCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Savings Goal")
                .font(.headline)
                .foregroundStyle(.white)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("$5,000")
                        .font(.title2)
                        .foregroundStyle(.white)
                    Text("of $10,000 goal")
                        .font(.subheadline)
                        .foregroundStyle(.gray)
                }
                
                Spacer()
                
                Circle()
                    .trim(from: 0, to: 0.5)
                    .stroke(Color.green, lineWidth: 10)
                    .frame(width: 60, height: 60)
                    .rotationEffect(.degrees(-90))
            }
        }
        .padding()
        .background(Color(hex: "191919"))
        .cornerRadius(20)
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
