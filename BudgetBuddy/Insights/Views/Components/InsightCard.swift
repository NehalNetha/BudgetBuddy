
//
//  InsightCard.swift
//  BudgetBuddy
//
//  Created by NehalNetha on 09/02/25.
//

import SwiftUI


struct InsightCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "sparkles")
                    .foregroundStyle(.yellow)
                Text("AI Insight")
                    .font(.system(size: 14))
                    .foregroundStyle(.gray)
            }
            
            Text("Your food expenses have increased by 15% compared to last month. Consider setting a stricter budget for dining out.")
                .font(.system(size: 16))
                .foregroundStyle(.white)
                .multilineTextAlignment(.leading)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(hex: "191919"))
        .cornerRadius(16)
    }
}

#Preview {
    InsightCard()
}

