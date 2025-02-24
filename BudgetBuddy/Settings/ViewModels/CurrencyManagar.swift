//
//  CurrencyManagar.swift
//  BudgetBuddy
//
//  Created by NehalNetha on 14/02/25.
//

import Foundation

class CurrencyManager: ObservableObject {
    @Published var selectedCurrency: String {
        didSet {
            UserDefaults.standard.set(selectedCurrency, forKey: "selectedCurrency")
        }
    }
    
    static let shared = CurrencyManager()
    
    init() {
        self.selectedCurrency = UserDefaults.standard.string(forKey: "selectedCurrency") ?? "USD"
    }
    
    func formatAmount(_ amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = selectedCurrency
        
        return formatter.string(from: NSNumber(value: amount)) ?? "\(selectedCurrency) \(amount)"
    }
}
