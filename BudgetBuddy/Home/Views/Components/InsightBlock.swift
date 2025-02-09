import SwiftUI

struct InsightBlock: View {
    var insightText: String
    @State private var isBookmarked = false

    var body: some View {
        VStack(alignment: .leading) {
            Text(insightText)
                .font(.body)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .padding(.bottom)

            HStack {
                Spacer()
                Button {
                    isBookmarked.toggle()
                    // TODO: Implement bookmark action
                    print("Insight bookmarked: \(isBookmarked)")
                } label: {
                    Image(systemName: isBookmarked ? "bookmark.fill" : "bookmark")
                        .font(.title3)
                        .foregroundColor(isBookmarked ? .yellow : .gray)
                }
            }
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(hex: "2D2D2D"))
        )
    }
}

struct InsightsScrollView: View {
    let insights: [String] = [
        "Consider reducing your dining out expenses this month. You've spent 15% more than the previous month in this category.",
        "Your savings rate is currently at 10%, which is good. Aiming for 15% could help you reach your long-term goals faster.",
        "You have a recurring subscription for a service you haven't used in the past 30 days. Consider cancelling it to save money.",
        "Based on your spending patterns, setting up a budget for entertainment could help you stay within your financial plan.",
        "You received a higher than usual income this month! Think about allocating a portion of it towards your debt or savings."
    ]

    var body: some View {
      
            VStack(spacing: 15) {
                ForEach(insights, id: \.self) { insight in
                    InsightBlock(insightText: insight)
                }
            }
           
    }
}

#Preview {
    InsightsScrollView()
        .preferredColorScheme(.dark)
}
