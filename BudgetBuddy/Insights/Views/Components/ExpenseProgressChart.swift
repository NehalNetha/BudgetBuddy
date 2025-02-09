import SwiftUI

struct ExpenseCategory: Identifiable {
    let id = UUID()
    let name: String
    let amount: Double
    let color: Color
    let code: String
}

struct ExpenseProgressChart: View {
    @State private var selectedCategory: ExpenseCategory?
    @State private var showDetails = false
    @State private var selectedPeriod: TimePeriod = .week
    @State private var showBreakdown = false
    
    enum TimePeriod: String, CaseIterable {
        case week = "This Week"
        case month = "This Month"
        case year = "This Year"
    }
    
    let categories: [ExpenseCategory] = [
        ExpenseCategory(name: "Housing", amount: 1815.67, color: Color(hex: "8B5CF6"), code: "B07MCGRV7M"),
        ExpenseCategory(name: "Food", amount: 450.00, color: Color(hex: "EC4899"), code: "F12MHTRP9N"),
        ExpenseCategory(name: "Transport", amount: 320.33, color: Color(hex: "FCD34D"), code: "T98KPLQW3X"),
        ExpenseCategory(name: "Entertainment", amount: 250.00, color: Color(hex: "60A5FA"), code: "E45NVBST2Y"),
        ExpenseCategory(name: "Others", amount: 149.00, color: Color(hex: "34D399"), code: "O23WXUHY7Z")
    ]
    
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
                    Circle()
                        .trim(from: 0, to: 0.8)
                        .stroke(Color(hex: "1E1E1E"), lineWidth: 30)
                        .frame(height: 200)
                        .rotationEffect(.degrees(120))
                    
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
                    
                    // Default Center Value or Selected Category Details
                    VStack(spacing: 4) {
                        if let selected = selectedCategory {
                            Text("$\(String(format: "%.2f", selected.amount))")
                                .font(.system(size: 24, weight: .bold))
                                .foregroundStyle(.white)
                            Text(selected.code)
                                .font(.caption)
                                .foregroundStyle(.gray)
                        } else {
                            Text("$\(String(format: "%.2f", totalSpend))")
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
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                
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
                                
                                Text("$\(String(format: "%.2f", category.amount))")
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

#Preview {
    ExpenseProgressChart()
}
