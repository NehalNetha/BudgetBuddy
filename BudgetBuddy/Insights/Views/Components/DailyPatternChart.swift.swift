import SwiftUI
import Charts

struct HourlySpending: Identifiable {
    let id = UUID()
    let hour: Int
    let amount: Double
}

struct DailyPatternChart: View {
    let expenses: [Expense]
    
    private var hourlyData: [HourlySpending] {
        let calendar = Calendar.current
        var hourlyTotals = Array(repeating: 0.0, count: 24)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm a"
        
        for expense in expenses {
            if let date = dateFormatter.date(from: expense.time) {
                let hour = calendar.component(.hour, from: date)
                hourlyTotals[hour] += expense.amount
            }
        }
        
        return hourlyTotals.enumerated().map { hour, amount in
            HourlySpending(hour: hour, amount: amount)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Daily Spending Pattern")
                .font(.headline)
                .foregroundStyle(.white)
            
            Chart {
                ForEach(hourlyData) { data in
                    AreaMark(
                        x: .value("Hour", "\(data.hour):00"),
                        y: .value("Amount", data.amount)
                    )
                    .foregroundStyle(Color.blue.gradient.opacity(0.3))
                    
                    LineMark(
                        x: .value("Hour", "\(data.hour):00"),
                        y: .value("Amount", data.amount)
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
                AxisMarks(values: .stride(by: 6)) { value in
                    AxisGridLine()
                    AxisValueLabel {
                        if let hour = value.as(String.self) {
                            Text(hour)
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