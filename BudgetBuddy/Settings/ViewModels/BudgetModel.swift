import Foundation
import FirebaseFirestore

struct BudgetSettings: Identifiable, Codable {
    @DocumentID var id: String?
    let userId: String
    var monthlyBudget: Double
    var categoryBudgets: [CategoryBudget]
    let createdAt: Date
    let updatedAt: Date
    
    enum CodingKeys: String, CodingKey {
        case id
        case userId
        case monthlyBudget
        case categoryBudgets
        case createdAt
        case updatedAt
    }
}

struct CategoryBudget: Codable, Identifiable {
    var id: String { category }
    let category: String
    var amount: Double
    var icon: String
    var color: String
}
