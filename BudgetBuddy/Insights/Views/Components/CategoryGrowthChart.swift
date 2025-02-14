import SwiftUI
import Charts

struct CategoryGrowth: Identifiable {
    let id = UUID()
    let category: String
    let month: String
    let growth: Double
}

enum GrowthPeriod: String, CaseIterable {
    case month = "1M"
    case sixMonths = "6M"
}

struct CategoryGrowthChart: View {
    let expenses: [Expense]
    @State private var selectedPeriod: GrowthPeriod = .month
    
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
                   
                   // If there's no previous data, consider it as 100% growth if there's current data
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
                
                // Time period selector
                HStack(spacing: 25) {
                    ForEach(GrowthPeriod.allCases, id: \.self) { period in
                        Button(action: {
                            withAnimation {
                                selectedPeriod = period
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
                           BarMark(
                               x: .value("Month", data.month),
                               y: .value("Growth", data.growth),
                               width: .fixed(20)
                           )
                           .foregroundStyle(by: .value("Category", data.category))
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
            }
        }
        .padding()
        .background(Color(hex: "191919"))
        .cornerRadius(20)
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
