import SwiftUI

struct DailyData: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
    let dayNumber: String
}

enum TimePeriod: String, CaseIterable {
    case week = "1W"
    case month = "1M"
    case sixMonths = "6M"
  
}

struct BarChartView: View {
    @State private var selectedPeriod: TimePeriod = .week
    @State private var selectedBar: String? = nil
    @State private var currentWeekOffset: Int = 0  // Add this for week navigation
    let expenses: [Expense]
    @StateObject private var currencyManager = CurrencyManager.shared

    var data: [DailyData] {
        let calendar = Calendar.current
        
        switch selectedPeriod {
        case .week:
            return getWeekData(calendar: calendar)
        case .month:
            return getMonthData(calendar: calendar)
        case .sixMonths:
            return getSixMonthData(calendar: calendar)
     
        }
    }
    
    private func getWeekData(calendar: Calendar) -> [DailyData] {
        let today = calendar.date(byAdding: .day, value: currentWeekOffset * 7, to: Date())!
        
        var dailyTotals: [String: Double] = [:]
        var dayNumbers: [String: String] = [:]
        
        // Get the start of the week (Sunday)
        let weekStart = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!
        
        let weekDays = (0..<7).map { dayOffset -> Date in
            calendar.date(byAdding: .day, value: dayOffset, to: weekStart)!
        }
        
        // Initialize daily totals
        for date in weekDays {
            let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            let dayNumber = String(calendar.component(.day, from: date))
            dailyTotals[dayName] = 0
            dayNumbers[dayName] = dayNumber
        }
        
        // Sum up expenses for the current week only
        for expense in expenses {
            if calendar.isDate(expense.date, equalTo: weekStart, toGranularity: .weekOfYear) {
                let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: expense.date) - 1]
                dailyTotals[dayName, default: 0] += expense.amount
            }
        }
        
        return weekDays.map { date in
            let dayName = calendar.shortWeekdaySymbols[calendar.component(.weekday, from: date) - 1]
            let value = dailyTotals[dayName] ?? 0
            let dayNumber = dayNumbers[dayName] ?? ""
            return DailyData(day: dayName, value: value, dayNumber: dayNumber)
        }
    }
    
    private func getMonthData(calendar: Calendar) -> [DailyData] {
        let today = Date()
        let currentMonth = calendar.component(.month, from: today)
        let currentYear = calendar.component(.year, from: today)
        
        var components = DateComponents()
        components.year = currentYear
        components.month = currentMonth
        
        guard let startOfMonth = calendar.date(from: components),
                 let _ = calendar.date(byAdding: DateComponents(month: 1, day: -1), to: startOfMonth) else {
               return []
        }
        
        var dailyTotals: [String: Double] = [:]
        var dayNumbers: [String: String] = [:]
        
        // Create data points for each week of the month
        let weeks = calendar.range(of: .weekOfMonth, in: .month, for: startOfMonth)?.count ?? 0
        
        for weekOffset in 0..<weeks {
            guard let weekStart = calendar.date(byAdding: .weekOfMonth, value: weekOffset, to: startOfMonth) else { continue }
            let weekNumber = "W\(weekOffset + 1)"
            dailyTotals[weekNumber] = 0
            dayNumbers[weekNumber] = "\(weekOffset + 1)"
            
            // Sum expenses for this week
            for expense in expenses {
                if calendar.isDate(expense.date, equalTo: weekStart, toGranularity: .weekOfMonth) {
                    dailyTotals[weekNumber, default: 0] += expense.amount
                }
            }
        }
        
        return (0..<weeks).map { week in
            let weekNumber = "W\(week + 1)"
            return DailyData(
                day: weekNumber,
                value: dailyTotals[weekNumber] ?? 0,
                dayNumber: dayNumbers[weekNumber] ?? ""
            )
        }
    }
    
    private func getSixMonthData(calendar: Calendar) -> [DailyData] {
        let today = Date()
        var monthlyData: [(name: String, value: Double, number: String)] = []
        
        // Get data for last 6 months
        for monthOffset in (0..<6).reversed() {  // Reverse the iteration
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: today) else { continue }
            
            let monthName = calendar.shortMonthSymbols[calendar.component(.month, from: monthDate) - 1]
            let monthNumber = "\(calendar.component(.month, from: monthDate))"
            
            // Sum expenses for this month
            let monthTotal = expenses.reduce(0) { sum, expense in
                calendar.isDate(expense.date, equalTo: monthDate, toGranularity: .month) ? sum + expense.amount : sum
            }
            
            monthlyData.append((name: monthName, value: monthTotal, number: monthNumber))
        }
        
        // Convert to DailyData array (already in chronological order)
        return monthlyData.map { month in
            DailyData(
                day: month.name,
                value: month.value,
                dayNumber: month.number
            )
        }
    }
    

    
    private func getYearData(calendar: Calendar) -> [DailyData] {
        let today = Date()
        let _ = calendar.component(.year, from: today)  // Replace with _ if not used

        var monthlyTotals: [String: Double] = [:]
        var monthNumbers: [String: String] = [:]
        
        // Get data for all months in the year
        for monthOffset in 0..<12 {
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: today) else { continue }
            
            let monthName = calendar.shortMonthSymbols[calendar.component(.month, from: monthDate) - 1]
            monthlyTotals[monthName] = 0
            monthNumbers[monthName] = "\(calendar.component(.month, from: monthDate))"
            
            // Sum expenses for this month
            for expense in expenses {
                if calendar.isDate(expense.date, equalTo: monthDate, toGranularity: .month) {
                    monthlyTotals[monthName, default: 0] += expense.amount
                }
            }
        }
        
        // Convert to array and reverse to show oldest to newest
        return calendar.shortMonthSymbols
            .filter { monthName in monthNumbers[monthName] != nil }
            .map { monthName in
                DailyData(
                    day: monthName,
                    value: monthlyTotals[monthName] ?? 0,
                    dayNumber: monthNumbers[monthName] ?? ""
                )
            }
            .reversed()
    }
    
    // Add similar functions for sixMonths and year...
    
    private var maxValue: Double {
           data.map { $0.value }.max() ?? 1
    }
    
    var body: some View {
        VStack(spacing: 40) {
            // Time Period Selector with Navigation Controls
            HStack {
                // Week Navigation
                HStack(spacing: 15) {
                    Button(action: {
                        withAnimation {
                            currentWeekOffset -= 1
                        }
                    }) {
                        Image(systemName: "chevron.left")
                            .foregroundStyle(.gray)
                    }
                    
                    Button(action: {
                        withAnimation {
                            currentWeekOffset = 0
                        }
                    }) {
                        Text("Current")
                            .font(.system(size: 14))
                            .foregroundStyle(currentWeekOffset == 0 ? .white : .gray)
                    }
                    
                    Button(action: {
                        withAnimation {
                            currentWeekOffset += 1
                        }
                    }) {
                        Image(systemName: "chevron.right")
                            .foregroundStyle(.gray)
                    }
                }
                
                Spacer()
                
                // Existing time period selector
                HStack(spacing: 25) {
                    ForEach(TimePeriod.allCases, id: \.self) { period in
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
            .padding(.horizontal)
            
            // Bar Chart
            HStack(alignment: .bottom, spacing: 12) {
                ForEach(data) { item in
                    VStack(spacing: 8) {
                        // Reserve space for the popup even when not shown
                        ZStack(alignment: .bottom) {
                            if selectedBar == item.day {
                                Text(currencyManager.formatAmount(item.value))
                                    .font(.system(size: 12))
                                    .foregroundStyle(.white)
                                    .transition(.opacity)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(Color(hex: "1E1E1E"))
                                    .cornerRadius(4)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.5)
                                    .frame(minWidth: 60)
                            }
                        }
                        .frame(height: 25) // Fixed height for popup area
                        
                        Rectangle()
                            .fill(getBarColor(for: item))
                            .frame(width: 30, height: max(20, (item.value / maxValue) * 140))
                            .cornerRadius(6)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedBar = selectedBar == item.day ? nil : item.day
                                }
                            }
                        
                        Text(item.day)
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                            .fixedSize()
                            .frame(width: 35)
                        
                        Text(item.dayNumber)
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                            .fixedSize()
                    }
                }
            }
            .frame(height: 200)
            .frame(maxWidth: .infinity) // Changed from minWidth to maxWidth
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(hex: "191919"))
        .cornerRadius(20)
    }


    private func getBarColor(for item: DailyData) -> Color {
        if selectedBar == item.day {
            return Color(hex: "37D485")
        } else if Calendar.current.isDateInToday(Date()) &&
                  Calendar.current.shortWeekdaySymbols[Calendar.current.component(.weekday, from: Date()) - 1] == item.day {
            return Color(hex: "37D485")
        } else {
            return Color(hex: "1E1E1E")
        }
    }
}

