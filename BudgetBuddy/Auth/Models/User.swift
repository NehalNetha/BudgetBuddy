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
    var profileImageUrl: String? 
    
    init(id: String, email: String,  profileImageUrl: String? = nil){
        self.id = id
        self.email = email
        self.fullname = User.extractName(email)
        self.profileImageUrl = profileImageUrl

    }
    
    
    static func extractName(_ email: String) -> String{
        guard let index = email.firstIndex(of : "@") else {
            return email
        }
        
        return String(email[..<index])
    }

}
