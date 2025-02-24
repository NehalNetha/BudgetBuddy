//
//  HomeMainView.swift
//  BudgetBuddy
//
//  Created by NehalNetha on 12/01/25.
//

import SwiftUI
import Charts


struct CustomCorner: Shape {
    var corners: UIRectCorner
    var radius: CGFloat

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}


struct HomeMainView: View {
    // Add this line
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject private var currencyManager = CurrencyManager.shared
    
    @StateObject private var incomeVM = IncomeViewModel()
    @State private var showIncomeHistory = false
    let data: [(category: String, value: Double)] = [
        ("Housing", 45),
        ("Category 2", 30),
        ("Empty", 25)
    ]
    @State private var showAddExpense = false
    @State private var showAddIncome = false
    @StateObject private var expenseVM = ExpenseViewModel()

    @State private var showBalanceSheet = false

    var body: some View {
        
        NavigationStack {
            ScrollView(.vertical){
                
                VStack {
                    Navbar()
                        .padding(.horizontal)
                        .padding(.top)
                    
                    PieChart()
                        .padding(.horizontal)
                        .padding(.top)
                    
                    BudgetLeft()
                    
                    
                    RecentExpensesView(expenseVM: expenseVM, showAddExpense: $showAddExpense)
                        .padding(.top)
                    
                }
                .padding(.top, 50)
                .frame(maxWidth: .infinity)
                .background(
                    Color(hex: "191919")
                )
                
                
                HorizontalIncomeSection()
                
                VStack{
                    HStack{
                        Text("Insights")
                            .foregroundStyle(.white)
                            .font(.title2)
                        
                        Spacer()
                    }
                    .padding()
                    
                    InsightsScrollView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black)
            .ignoresSafeArea(.all)
            
            .sheet(isPresented: $showAddIncome) {
                AddIncomeView(incomeVM: incomeVM)
                    .presentationDetents([.medium])
            }
            .sheet(isPresented: $showAddExpense){
                AddExpenseView(expenseVM: expenseVM)
                    .presentationDetents([.medium])
                
            }
        }
        .preferredColorScheme(.dark)

    }

}

extension HomeMainView {
    // Update the Navbar function
    func Navbar() -> some View {
        HStack {
            HStack {
                // Update the image to use AsyncImage if profile image exists
                if let profileUrl = authViewModel.currentUser?.profileImageUrl,
                   let url = URL(string: profileUrl) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                    } placeholder: {
                        Image(systemName: "person.circle")
                            .foregroundStyle(.white)
                            .font(.system(size: 36))
                    }
                } else {
                    Image(systemName: "person.circle")
                        .foregroundStyle(.white)
                        .font(.system(size: 36))
                }
                
                VStack(alignment: .leading) {
                    Text("Hi \(authViewModel.currentUser?.fullname ?? "User")")
                        .font(.system(size: 14))
                    Text("Monthly Budget")
                        .font(.system(size: 16))
                }
                .foregroundStyle(.white)
            }
            Spacer()

            Button {
                showBalanceSheet = true
            } label: {
                HStack {
                    Circle()
                        .fill(Color.green)
                        .frame(width: 8, height: 8)
                    Text("Balance")
                        .font(.system(size: 12))
                        .foregroundStyle(.white)
                }
                .padding(.vertical, 6)
                .padding(.horizontal, 15)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "1E1E1E"))
                )
            }

        }
        .navigationDestination(isPresented: $showBalanceSheet) {
            BalanceSheetView(expenseVM: expenseVM)
        }
    }

    func PieChart() -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text("Total Expenses")
                    .foregroundStyle(.white)
                    .font(.system(size: 16))
                  Text(currencyManager.formatAmount(1000.23))
                    .foregroundStyle(.white)
                    .font(.system(size: 24))
                    .fontWeight(.semibold)
            }

            Spacer()

            Chart(data, id: \.category) { item in
                SectorMark(
                    angle: .value("Value", item.value),
                    innerRadius: .ratio(0.5),
                    angularInset: 1.0
                )
                .foregroundStyle(by: .value("Category", item.category))

            }
            .chartLegend(.hidden)
            .frame(width: 100, height: 80)

        }
    }

    func BudgetLeft() -> some View {
        HStack {
             Text(currencyManager.formatAmount(32))
                .foregroundStyle(Color(hex: "CDCBCB"))
                .font(.system(size: 12))
                .padding(.vertical, 4)
                .padding(.horizontal, 16)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color(hex: "1E1E1E"))

                )

            Spacer()

        }
        .padding(.horizontal)
    }
    
    func HorizontalIncomeSection() -> some View {
        VStack(alignment: .leading) {
            HStack {
                Text("Income")
                    .foregroundStyle(.white)
                    .font(.title2)
                    .fontWeight(.bold)
                
                Spacer()
                NavigationLink {
                   IncomeHistoryView(incomeVM: incomeVM)
                } label: {
                   Image(systemName: "arrow.right.circle.fill")
                       .foregroundStyle(.green)
                       .font(.title2)
                }
            }
            .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 15) {
                    Button {
                        showAddIncome = true
                    } label: {
                        VStack {
                            Image(systemName: "plus")
                                .font(.title2)
                            Text("Add New")
                                .font(.caption)
                        }
                        .foregroundColor(.green)
                        .padding()
                        .frame(width: 100, height: 100)
                        .background(RoundedRectangle(cornerRadius: 16).fill(Color.gray.opacity(0.2)))
                    }

                    ForEach(incomeVM.incomes.prefix(3)) { income in
                        HorizontalIncomeItemView(
                            icon: "dollarsign.circle.fill",
                            title: income.title,
                            amount: currencyManager.formatAmount(income.amount),
                            iconColor: .green
                        )
                    }
                }
                .padding()
            }
        }
        .task {
            await incomeVM.fetchIncomes()
        }
        .sheet(isPresented: $showIncomeHistory) {
            IncomeHistoryView(incomeVM: incomeVM)
        }
    }

    
    

}
