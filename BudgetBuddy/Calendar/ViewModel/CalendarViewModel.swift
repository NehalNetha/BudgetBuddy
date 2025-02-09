//
import Foundation


import Foundation
import SwiftUI

class CalendarViewModel: ObservableObject{
    
    
    

    @Published var currentWeek : [Date] = []
    @Published var currentDate : Date = Date()
    private var weekOffset: Int = 0

    
    
    init(){
        fetchCurrentWeek()
    }
    
 
    
 
    func fetchCurrentWeek(offset: Int = 0) {
        currentWeek.removeAll()
        
        let today = Date()
        let calendar = Calendar.current
        
        guard let week = calendar.dateInterval(of: .weekOfMonth, for: calendar.date(byAdding: .weekOfMonth, value: offset, to: today)!) else {
            return
        }
        
        let firstWeek = week.start
        
        (0..<7).forEach { day in
            if let weekDay = calendar.date(byAdding: .day, value: day, to: firstWeek) {
                currentWeek.append(weekDay)
            }
        }
    }
                
    func loadNextWeek() {
        weekOffset += 1
        fetchCurrentWeek(offset: weekOffset)
    }
    
    
    func loadPrevWeek() {
        weekOffset -= 1
        fetchCurrentWeek(offset: weekOffset)
    }
            
    
    func extractDate(date: Date, format: String) -> String{
        let formatter = DateFormatter()
        
        formatter.dateFormat = format
        return formatter.string(from: date)
    }
    
    func isToday(date: Date) -> Bool{
        let calendar = Calendar.current
        
        return calendar.isDate(currentDate, inSameDayAs: date)
    }
}

