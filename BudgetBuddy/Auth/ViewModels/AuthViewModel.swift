//
//  AuthViewModel.swift
//  BudgetBuddy
//
//  Created by NehalNetha on 09/02/25.
//

import Foundation


import Foundation
import Firebase
import FirebaseFirestore
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth


protocol AuthenticationFormProtcol{
    var formIsValid: Bool {get}
}


struct GoogleSignResulModel{
    let idToken: String
    let accessToken: String
}



@MainActor
class AuthViewModel: ObservableObject{
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    
    private let db = Firestore.firestore()

    init(){
        Task{
            await fetchUser()
        }
        self.userSession = Auth.auth().currentUser

    }
    
    func signInGoogle() async throws{
        guard let topVC = Utilities.topViewController() else {
            throw URLError(.cannotFindHost)
        }
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken: String = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }
        let accessToken: String = gidSignInResult.user.accessToken.tokenString
        
        let tokens = GoogleSignResulModel(idToken: idToken, accessToken: accessToken)
        try await signInWithGoogle(tokens: tokens)
        print("user signed in: ", userSession!)
        
    }
    
    
    
    func Signin(withEmail email: String, password: String) async throws{
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        self.userSession = result.user
        await self.fetchUser()
        
    }
    
    func createUser(withEmail email: String, password: String) async throws{
        do{
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, email: email)
            let encodedUser = try Firestore.Encoder().encode(user)
            try await Firestore.firestore().collection("users").document(user.id).setData(encodedUser)
            try await saveUserToFirestore(user: result.user)
        }catch{
            print("debug: failed to create a user \(error.localizedDescription)" )

        }
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        }catch{
            print("failed to sign out \(error.localizedDescription)")
        }
    }

    func fetchUser() async{
        guard let uid = Auth.auth().currentUser?.uid else {return}
        guard let snapshot = try? await Firestore.firestore().collection("users").document(uid).getDocument() else {return}
        self.currentUser = try?snapshot.data(as: User.self)
    }
    
    
    func saveUserToFirestore(user: FirebaseAuth.User) async throws{
        let newUser = User(id: user.uid, email: user.email ?? "")
        let encodedUser = try Firestore.Encoder().encode(newUser)
        try await db.collection("users").document(user.uid).setData(encodedUser)
    }
    
//    func UpdateUser(fullname: String) async throws{
//        guard let uid = Auth.auth().currentUser?.uid else {return}
//        
//        let userRef = db.collection("users").document(uid)
//        
//        do{
//            try await userRef.updateData(["fullname": fullname])
//            
//            if var updatedUser = self.currentUser{
//                updatedUser.fullname = fullname
//                self.currentUser = updatedUser
//            }
//            print("User fullname updated successfully")
//        }catch{
//            print("error updating the user \(error.localizedDescription)")
//        }
//    }

}


extension AuthViewModel{
    
    func signInWithGoogle(tokens: GoogleSignResulModel) async throws{
        
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken,
                                                       accessToken: tokens.accessToken)
        
        return try await GoogleSignInCustom(crendential: credential)
    }
    
    func GoogleSignInCustom(crendential: AuthCredential) async throws{
        let authDataResult = try await Auth.auth().signIn(with: crendential)
        self.userSession = authDataResult.user
    }
}

