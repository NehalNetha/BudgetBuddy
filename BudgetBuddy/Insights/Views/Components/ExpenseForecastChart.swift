import SwiftUI
import Charts

struct ExpenseForecastChart: View {
    let expenses: [Expense]
    
    private var forecastData: [(month: String, actual: Double?, predicted: Double?)] {
        let calendar = Calendar.current
        let today = Date()
        
        // Get last 3 months data and predict next 2 months
        return (0..<5).map { monthOffset -> (String, Double?, Double?) in
            let date = calendar.date(byAdding: .month, value: monthOffset - 3, to: today)!
            let monthStr = date.formatted(.dateTime.month(.abbreviated))
            
            if monthOffset < 3 {
                // Past months: actual data
                let monthExpenses = expenses.filter {
                    calendar.isDate($0.date, equalTo: date, toGranularity: .month)
                }
                let total = monthExpenses.reduce(0) { $0 + $1.amount }
                return (monthStr, total, nil)
            } else {
                // Future months: predicted data
                let predictedAmount = calculatePrediction(for: date)
                return (monthStr, nil, predictedAmount)
            }
        }
    }
    
    private func calculatePrediction(for date: Date) -> Double {
        // Simple prediction based on average growth
        let pastThreeMonths = forecastData.prefix(3)
        let amounts = pastThreeMonths.compactMap { $0.actual }
        guard amounts.count >= 2 else { return 0 }
        
        let averageGrowth = zip(amounts, amounts.dropFirst()).map { $1 - $0 }.reduce(0, +) / Double(amounts.count - 1)
        return (amounts.last ?? 0) + averageGrowth
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Expense Forecast")
                .font(.headline)
                .foregroundStyle(.white)
            
            Chart {
                ForEach(forecastData, id: \.month) { data in
                    if let actual = data.actual {
                        LineMark(
                            x: .value("Month", data.month),
                            y: .value("Amount", actual)
                        )
                        .foregroundStyle(Color.blue.gradient)
                        .symbol(Circle())
                    }
                    
                    if let predicted = data.predicted {
                        LineMark(
                            x: .value("Month", data.month),
                            y: .value("Amount", predicted)
                        )
                        .foregroundStyle(Color.gray.opacity(0.5).gradient)
                        .symbol(Circle())
                        .lineStyle(StrokeStyle(dash: [5, 5]))
                    }
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