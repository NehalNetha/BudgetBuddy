import Foundation
import FirebaseVertexAI

class VertexServiceGemini {
    static let shared = VertexServiceGemini()
    private let vertex: VertexAI
    private let model: GenerativeModel
    
    private init() {
        vertex = VertexAI.vertexAI()
        model = vertex.generativeModel(modelName: "gemini-2.0-flash")
    }
    
    func analyzeSpendings(expenses: [Expense], monthlyBudget: Double, previousContext: String = "") async throws -> String {
        print("Starting expense analysis with \(expenses.count) expenses")
        
        let history = [
            ModelContent(role: "user", parts: """
                You are my personal finance advisor. Please analyze my expenses and provide:
                - Key spending patterns
                - Specific saving opportunities
                - Practical tips for better financial management
                Be concise, specific, and use bullet points. Keep it under 150 words.
                
                Previous Context:
                \(previousContext)
                """),
            ModelContent(role: "model", parts: "I'll analyze your spending patterns and provide personalized recommendations.")
        ]
        
        let chat = model.startChat(history: history)
        var result = ""
        
        // Format expenses for analysis
        let expenseDetails = expenses.map { expense in
            "Category: \(expense.category), Amount: \(expense.amount), Title: \(expense.title)"
        }.joined(separator: "\n")
        
        print("Formatted expense details:")
        print(expenseDetails)
        
        let message = """
        Monthly Budget: $\(monthlyBudget)
        
        Recent Expenses:
        \(expenseDetails)
        
        Based on this data, please provide your analysis and recommendations.
        """
        
        print("Final message being sent to AI:")
        print(message)
        
        let contentStream = try await chat.sendMessageStream(message)
        
        for try await chunk in contentStream {
            if let text = chunk.text {
                result += text
            }
        }
        
        return result
    }
}
