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
                AddIncomeView()
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
    func Navbar() -> some View {
        HStack {
            HStack {
                Image(systemName: "person.circle")
                    .foregroundStyle(.white)
                    .font(.system(size: 36))
                VStack(alignment: .leading) {
                    Text("Hi Nehal")
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
                Text("$1000.23")
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
            Text("32$ left")
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
                Text("Income")
                    .foregroundStyle(.white)
                    .font(.title2)
                    .fontWeight(.bold)
                    .padding(.leading)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        Button {
                            // TODO: Implement add income action
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

                      
                        HorizontalIncomeItemView(icon: "dollarsign.circle.fill", title: "Salary", amount: "$1000", iconColor: .blue)
                        HorizontalIncomeItemView(icon: "gift.fill", title: "Bonus", amount: "$500", iconColor: .orange)
                      
                    }
                    .padding()
                }
            }
        }

}

#Preview {
    HomeMainView()
}
