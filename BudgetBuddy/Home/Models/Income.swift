//
//  Income.swift
//  BudgetBuddy
//
//  Created by NehalNetha on 14/02/25.
//

import Foundation
import FirebaseFirestore

struct Income: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let amount: Double
    let date: Date
    let time: String
    let userId: String
    
    init(id: String? = nil, title: String, amount: Double, date: Date, userId: String) {
        self.id = id
        self.title = title
        self.amount = amount
        self.date = date
        self.time = date.formatted(date: .omitted, time: .shortened)
        self.userId = userId
    }
}
