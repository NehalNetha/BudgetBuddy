import SwiftUI

struct CalendarView: View {
    @State private var increPrevWeek = 0
    @State private var increNextWeek = 0
    @StateObject var calendarTaskViewModel = CalendarViewModel()
    @StateObject private var expenseVM = ExpenseViewModel() 
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        Button {
                            calendarTaskViewModel.loadPrevWeek()
                            increPrevWeek += 1
                            if increNextWeek != 0 {
                                increNextWeek -= 1
                            }
                            increNextWeek = max(0, increNextWeek - 1)
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: "arrow.left")
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                
                              
                            }
                        }
                        .disabled(increPrevWeek >= 2 && increNextWeek == 0)

                        ForEach(calendarTaskViewModel.currentWeek, id: \.self) { day in
                            VStack(spacing: 10) {
                                Text(calendarTaskViewModel.extractDate(date: day, format: "dd"))
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                
                                Text(calendarTaskViewModel.extractDate(date: day, format: "EEE"))
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                
                                Circle()
                                    .fill(.white)
                                    .frame(width: 8, height: 8)
                                    .opacity(calendarTaskViewModel.isToday(date: day) ? 1 : 0)
                            }
                            .foregroundStyle(calendarTaskViewModel.isToday(date: day) ? .white : .gray)
                            .frame(width: 45, height: 90)
                            .background(
                                ZStack {
                                    if calendarTaskViewModel.isToday(date: day) {
                                        Capsule()
                                            .fill(Color(hex: "037D4F"))
                                    }
                                }
                            )
                            .contentShape(Capsule())
                            .onTapGesture {
                                withAnimation {
                                    calendarTaskViewModel.currentDate = day
                                }
                            }
                        }
                        
                        Button {
                            calendarTaskViewModel.loadNextWeek()
                            increNextWeek += 1
                            increPrevWeek = max(0, increPrevWeek - 1)
                        } label: {
                            VStack(spacing: 10) {
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 14))
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                
                               
                            }
                        }
                        .disabled(increNextWeek >= 2)
                    }
                    .padding(.horizontal)
                    
                  
                }
                
                DailyExpenseView(
                   date: calendarTaskViewModel.currentDate,
                   dateFormatter: calendarTaskViewModel.extractDate,
                   expenseVM: expenseVM
               )
            }
            .padding(.top, 50) // Add top padding
            Spacer() // Push content to the top
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black)
        .safeAreaInset(edge: .top) { // Add safe area inset
            Color.clear.frame(height: 0)
        }
    }
}
