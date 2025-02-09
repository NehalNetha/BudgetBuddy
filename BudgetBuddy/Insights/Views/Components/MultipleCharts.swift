
import SwiftUI
import Charts


struct SpendingTrendsCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Spending Trends")
                .font(.headline)
                .foregroundStyle(.white)
            
            Chart {
                LineMark(
                    x: .value("Month", "Jan"),
                    y: .value("Spend", 1200)
                )
                LineMark(
                    x: .value("Month", "Feb"),
                    y: .value("Spend", 1500)
                )
                // Add more points
            }
            .frame(height: 200)
        }
        .padding()
        .background(Color(hex: "191919"))
        .cornerRadius(20)
    }
}

struct BudgetComparisonCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Budget vs Actual")
                .font(.headline)
                .foregroundStyle(.white)
            
            ForEach(["Food", "Transport", "Entertainment"], id: \.self) { category in
                HStack {
                    Text(category)
                        .foregroundStyle(.white)
                    Spacer()
                    
                    // Progress bar showing budget utilization
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            Rectangle()
                                .fill(Color(hex: "1E1E1E"))
                            
                            Rectangle()
                                .fill(Color.green)
                                .frame(width: geometry.size.width * 0.7)
                        }
                    }
                    .frame(height: 8)
                    .cornerRadius(4)
                }
            }
        }
        .padding()
        .background(Color(hex: "191919"))
        .cornerRadius(20)
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
