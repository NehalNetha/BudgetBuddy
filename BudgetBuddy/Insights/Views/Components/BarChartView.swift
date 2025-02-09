import SwiftUI

struct DailyData: Identifiable {
    let id = UUID()
    let day: String
    let value: Double
    let dayNumber: String
}

enum TimePeriod: String, CaseIterable {
    case hours = "12H"
    case week = "1W"
    case month = "1M"
    case sixMonths = "6M"
    case year = "12M"
}

struct BarChartView: View {
    @State private var selectedPeriod: TimePeriod = .week
    @State private var selectedBar: String? = nil
    
    let data: [DailyData] = [
        DailyData(day: "Mon", value: 0.6, dayNumber: "10"),
        DailyData(day: "Tue", value: 1.3, dayNumber: "11"),
        DailyData(day: "Wed", value: 0.8, dayNumber: "12"),
        DailyData(day: "Thu", value: 0.7, dayNumber: "13"),
        DailyData(day: "Fri", value: 1.2, dayNumber: "14"),
        DailyData(day: "Sat", value: 1.8, dayNumber: "15"),
        DailyData(day: "Sun", value: 1.5, dayNumber: "16")
    ]
    
    var body: some View {
        VStack(spacing: 40) {
            // Time Period Selector
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
            
            // Bar Chart
            HStack(alignment: .bottom, spacing: 20) {
                ForEach(data) { item in
                    VStack(spacing: 8) {
                        if selectedBar == item.day {
                            Text("+\(String(format: "%.1f", item.value))%")
                                .font(.system(size: 12))
                                .foregroundStyle(.white)
                                .transition(.opacity)
                        }
                                                
                        
                        Rectangle()
                            .fill(getBarColor(for: item))
                            .frame(width: 38, height: item.value * 100)
                            .cornerRadius(6)
                            .onTapGesture {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    selectedBar = selectedBar == item.day ? nil : item.day
                                }
                            }
                        
                        Text(item.day)
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                        
                        Text(item.dayNumber)
                            .font(.system(size: 12))
                            .foregroundStyle(.gray)
                    }
                }
            }
            .frame(height: 200)
            .padding(.horizontal)
        }
        .padding(.vertical)
        .background(Color(hex: "191919"))
        .cornerRadius(20)
    }


    private func getBarColor(for item: DailyData) -> Color {
        if selectedBar == item.day {
            return Color(hex: "37D485")
        } else if item.day == "Sat" && selectedBar == nil {
            return Color(hex: "37D485")
        } else {
            return Color(hex: "1E1E1E")
        }
    }
}

#Preview {
    BarChartView()
}
