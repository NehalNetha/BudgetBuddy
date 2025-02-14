import SwiftUI
import Charts

struct CategoryGrowthLineChart: View {
    let expenses: [Expense]
    @State private var selectedPeriod: GrowthPeriod = .month
    @State private var selectedMonth: String?
    
    private var growthData: [CategoryGrowth] {
        let calendar = Calendar.current
        let categories = Set(expenses.map { $0.category })
        let today = Date()
        let monthsToAnalyze = selectedPeriod == .month ? 1 : 6
        
        var result: [CategoryGrowth] = []
        
        for category in categories {
            let months = (0..<monthsToAnalyze).map { monthsAgo -> Date in
                calendar.date(byAdding: .month, value: -monthsAgo, to: today)!
            }.reversed()
            
            for currentMonth in months {
                let startOfMonth = calendar.startOfMonth(for: currentMonth)
                let endOfMonth = calendar.endOfMonth(for: currentMonth)
                let startOfPreviousMonth = calendar.date(byAdding: .month, value: -1, to: startOfMonth)!
                let endOfPreviousMonth = calendar.date(byAdding: .month, value: -1, to: endOfMonth)!
                
                let currentExpenses = expenses.filter {
                    $0.category == category &&
                    ($0.date >= startOfMonth && $0.date <= endOfMonth)
                }
                
                let previousExpenses = expenses.filter {
                    $0.category == category &&
                    ($0.date >= startOfPreviousMonth && $0.date <= endOfPreviousMonth)
                }
                
                let currentTotal = currentExpenses.reduce(0) { $0 + $1.amount }
                let previousTotal = previousExpenses.reduce(0) { $0 + $1.amount }
                
                let growth: Double
                if previousTotal == 0 {
                    growth = currentTotal > 0 ? 100 : 0
                } else {
                    growth = ((currentTotal - previousTotal) / previousTotal) * 100
                }
                
                result.append(CategoryGrowth(
                    category: category,
                    month: currentMonth.formatted(.dateTime.month(.abbreviated)),
                    growth: growth
                ))
            }
        }
        
        return result
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            HStack {
                Text("Category Growth Trends")
                    .font(.headline)
                    .foregroundStyle(.white)
                
                Spacer()
                
                HStack(spacing: 25) {
                    ForEach(GrowthPeriod.allCases, id: \.self) { period in
                        Button(action: {
                            withAnimation {
                                selectedPeriod = period
                                selectedMonth = nil
                            }
                        }) {
                            Text(period.rawValue)
                                .font(.system(size: 14))
                                .foregroundStyle(selectedPeriod == period ? .white : .gray)
                        }
                    }
                }
            }
            
            if growthData.isEmpty {
                Text("No growth data available")
                    .foregroundStyle(.gray)
                    .frame(maxWidth: .infinity, maxHeight: 200)
            } else {
                Chart {
                    ForEach(growthData) { data in
                        LineMark(
                            x: .value("Month", data.month),
                            y: .value("Growth", data.growth)
                        )
                        .foregroundStyle(by: .value("Category", data.category))
                        
                        PointMark(
                            x: .value("Month", data.month),
                            y: .value("Growth", data.growth)
                        )
                        .foregroundStyle(by: .value("Category", data.category))
                    }
                    
                    if let selectedMonth {
                        RuleMark(
                            x: .value("Month", selectedMonth)
                        )
                        .foregroundStyle(.gray.opacity(0.3))
                        .annotation(position: .top) {
                            VStack(alignment: .leading) {
                                ForEach(growthData.filter { $0.month == selectedMonth }) { data in
                                    HStack(spacing: 8) {
                                        Circle()
                                            .fill(getCategoryColor(data.category))
                                            .frame(width: 8, height: 8)
                                        Text("\(data.category): \(Int(data.growth))%")
                                            .font(.system(size: 12))
                                            .foregroundStyle(.white)
                                    }
                                }
                            }
                            .padding(8)
                            .background(Color(hex: "1E1E1E"))
                            .cornerRadius(8)
                        }
                    }
                }
                .frame(height: 200)
                .chartXAxis {
                    AxisMarks { value in
                        AxisValueLabel {
                            if let month = value.as(String.self) {
                                Text(month)
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 12))
                            }
                        }
                    }
                }
                .chartYAxis {
                    AxisMarks(position: .leading) { value in
                        AxisGridLine()
                        AxisValueLabel {
                            if let growth = value.as(Double.self) {
                                Text("\(Int(growth))%")
                                    .foregroundStyle(.gray)
                                    .font(.system(size: 12))
                            }
                        }
                    }
                }
                .chartLegend(position: .bottom, alignment: .center, spacing: 20)
                .chartForegroundStyleScale([
                    "Food": Color(hex: "FF8E8E"),
                    "Transport": Color(hex: "60A5FA"),
                    "Shopping": Color(hex: "8B5CF6"),
                    "Bills": Color(hex: "F59E0B"),
                    "Entertainment": Color(hex: "10B981")
                ])
                .chartOverlay { proxy in
                    GeometryReader { geometry in
                        Rectangle()
                            .fill(.clear)
                            .contentShape(Rectangle())
                            .gesture(
                                DragGesture()
                                    .onChanged { value in
                                        let x = value.location.x - geometry[proxy.plotAreaFrame].origin.x
                                        guard let month = proxy.value(atX: x, as: String.self) else { return }
                                        selectedMonth = month
                                    }
                                    .onEnded { _ in
                                        selectedMonth = nil
                                    }
                            )
                    }
                }
            }
        }
        .padding()
        .background(Color(hex: "191919"))
        .cornerRadius(20)
    }
    
    private func getCategoryColor(_ category: String) -> Color {
        switch category {
        case "Food": return Color(hex: "FF8E8E")
        case "Transport": return Color(hex: "60A5FA")
        case "Shopping": return Color(hex: "8B5CF6")
        case "Bills": return Color(hex: "F59E0B")
        case "Entertainment": return Color(hex: "10B981")
        default: return Color(hex: "6B7280")
        }
    }
}

private extension Calendar {
    func startOfMonth(for date: Date) -> Date {
        let components = dateComponents([.year, .month], from: date)
        return self.date(from: components)!
    }
    
    func endOfMonth(for date: Date) -> Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return self.date(byAdding: components, to: startOfMonth(for: date))!
    }
}
