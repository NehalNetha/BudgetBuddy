//
//  ExpenseModel.swift
//  BudgetBuddy
//
//  Created by NehalNetha on 09/02/25.
//

import Foundation
import FirebaseFirestore

struct Expense: Identifiable, Codable {
    @DocumentID var id: String?
    let title: String
    let amount: Double
    let category: String
    let date: Date
    let time: String
    let icon: String
    let color: String
    let userId: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case amount
        case category
        case date
        case time
        case icon
        case color
        case userId
    }
}
