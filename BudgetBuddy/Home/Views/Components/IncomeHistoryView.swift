import SwiftUI

struct IncomeHistoryView: View {
    @StateObject private var currencyManager = CurrencyManager.shared
    @ObservedObject var incomeVM: IncomeViewModel
    
    var body: some View {
        Group {
            if incomeVM.isLoading {
                LoadingView()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        IncomeHeaderView(incomeVM: incomeVM)
                        MonthlyIncomeListView(incomeVM: incomeVM)
                    }
                    .padding(24)
                }
            }
        }
        .navigationTitle("Income History")
        .navigationBarTitleDisplayMode(.inline)
        .background(Color.black)
        .task {
            await incomeVM.fetchIncomes()
        }
    }
}

struct IncomeHeaderView: View {
    @ObservedObject var incomeVM: IncomeViewModel
    @StateObject private var currencyManager = CurrencyManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(currencyManager.formatAmount(incomeVM.calculateTotalIncome()))
                .font(.system(size: 40, weight: .bold))
                .foregroundStyle(.white)
            
            Text("Total Income")
                .font(.system(size: 16))
                .foregroundStyle(.gray)
        }
    }
}

struct MonthlyIncomeListView: View {
    @ObservedObject var incomeVM: IncomeViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            ForEach(Array(incomeVM.incomesByMonth.keys.sorted().reversed()), id: \.self) { month in
                MonthlyIncomeSectionView(month: month, incomeVM: incomeVM)
            }
        }
    }
}

struct MonthlyIncomeSectionView: View {
    let month: String
    @ObservedObject var incomeVM: IncomeViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            MonthHeaderViewIncome(month: month, incomeVM: incomeVM)
            
            LazyVStack(spacing: 16) {
                ForEach(incomeVM.incomesByMonth[month] ?? []) { income in
                    IncomeRowView(income: income)
                        .background(Color(hex: "191919"))
                        .cornerRadius(16)
                        .swipeActions(edge: .trailing) {
                            Button(role: .destructive) {
                                if let id = income.id {
                                    Task {
                                        try? await incomeVM.deleteIncome(id)
                                    }
                                }
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
}

struct MonthHeaderViewIncome: View {
    let month: String
    @ObservedObject var incomeVM: IncomeViewModel
    @StateObject private var currencyManager = CurrencyManager.shared
    
    var body: some View {
        HStack {
            Text(month)
                .font(.system(size: 16))
                .foregroundStyle(.white)
            
            Spacer()
            
            Text(currencyManager.formatAmount(incomeVM.calculateMonthlyTotal(for: month)))
                .font(.system(size: 16))
                .foregroundStyle(.white)
        }
    }
}

struct IncomeRowView: View {
    let income: Income
    @StateObject private var currencyManager = CurrencyManager.shared
    
    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.green.opacity(0.2))
                    .frame(width: 48, height: 48)
                
                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 20))
                    .foregroundStyle(.green)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(income.title)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                
                HStack(spacing: 4) {
                    Text(income.date.formatted(date: .abbreviated, time: .omitted))
                    Text("•")
                    Text(income.time)
                }
                .font(.system(size: 14))
                .foregroundStyle(.gray)
            }
            
            Spacer()
            
            Text(currencyManager.formatAmount(income.amount))
                .font(.system(size: 16))
                .foregroundStyle(.white)
        }
        .padding()
    }
}
