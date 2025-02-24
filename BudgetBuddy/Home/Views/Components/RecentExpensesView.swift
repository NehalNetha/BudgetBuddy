import SwiftUI

struct RecentExpensesView: View {
    @ObservedObject var expenseVM: ExpenseViewModel
    @Binding var showAddExpense: Bool
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 15) {
                Button {
                    showAddExpense = true
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 18))
                        .foregroundStyle(.white)
                        .padding(12)
                        .padding(.vertical, 28)
                }
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "2D2D2D"))
                )

                ForEach(expenseVM.recentExpenses) { expense in
                    ExpenseBlock(
                        title: expense.title,
                        money: expense.amount,
                        tag: expense.category,
                        color: expense.color
                    )
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 45)
            .padding(.top)
        }
        .task {
            do {
                try await expenseVM.fetchRecentExpenses()
            } catch {
                print("Error fetching recent expenses:", error)
            }
        }
    }
}

struct ExpenseBlock: View {
    let title: String
    let money: Double
    let tag: String
    let color: String
    @StateObject private var currencyManager = CurrencyManager.shared

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 18))
                .fontWeight(.medium)
            Text(currencyManager.formatAmount(money))
                .font(.system(size: 14))
            Text(tag)
                .font(.system(size: 10))
                .padding(.horizontal, 12)
                .padding(.vertical, 2)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.black)
                        .opacity(0.21)
                )
        }
        .foregroundStyle(.white)
        .padding(.leading, 16)
        .padding(.trailing, 25)
        .padding(.vertical, 12)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: color))
        )
    }
}
