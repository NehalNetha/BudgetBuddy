//
//  User.swift
//  BudgetBuddy
//
//  Created by NehalNetha on 09/02/25.
//

import Foundation



struct User: Identifiable, Codable{
    let id : String
    let email: String
    var fullname: String?
    
    init(id: String, email: String){
        self.id = id
        self.email = email
        self.fullname = User.extractName(email)
    }
    
    
    static func extractName(_ email: String) -> String{
        guard let index = email.firstIndex(of : "@") else {
            return email
        }
        
        return String(email[..<index])
    }

}
