//
//  SignupView.swift
//  NewHomeWorkOne
//
//  Created by NehalNetha on 13/06/24.
//

import SwiftUI

struct SignupView: View {
    
    @State private var emailSignup = ""
    @State private var passwordSignup = ""
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        ZStack {
            Color(hex: "191919").ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Illustration
                Image("signUpImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 400)
                
                VStack(spacing: 25) {
                    // Header
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Create Account")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        Text("Start tracking your expenses")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal)
                    
                    // Input Fields
                    VStack(spacing: 20) {
                        InputView(text: $emailSignup, placeholder: "Email", label: "")
                        InputView(text: $passwordSignup, placeholder: "Password", secureField: true, label: "")
                    }
                    .padding(.horizontal)
                    
                    // Sign Up Button
                    Button {
                        Task {
                            try await authViewModel.createUser(withEmail: emailSignup, password: passwordSignup)
                        }
                    } label: {
                        Text("Create Account")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "037D4F"))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1 : 0.5)
                    
                    OrSeparator()
                    
                    // Social Sign Up Button
                    Button {
                        Task {
                            try await authViewModel.signInGoogle()
                        }
                    } label: {
                        HStack {
                            Image("googleImage")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Sign up with Google")
                                .foregroundStyle(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(hex: "1E1E1E"))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    // Login Link
                    HStack {
                        Text("Already have an account?")
                            .foregroundStyle(.gray)
                        Button {
                            dismiss()
                        } label: {
                            Text("Login")
                                .foregroundStyle(Color(hex: "037D4F"))
                        }
                    }
                }
            }
            .padding(.bottom, 20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(hex: "191919"))
        .scrollIndicators(.hidden)
        .overlay(alignment: .top) {
            GeometryReader { geometry in
                Color(hex: "191919")
                    .frame(height: geometry.safeAreaInsets.top)
                    .ignoresSafeArea()
            }
        }
    }
}

extension SignupView: AuthenticationFormProtcol {
    var formIsValid: Bool {
        return !emailSignup.isEmpty &&
               emailSignup.contains("@") &&
               !passwordSignup.isEmpty &&
               passwordSignup.count > 5
    }
}


struct OrSeparator: View {
    var body: some View {
        HStack {
            Spacer()
            Divider()
                .frame(width: 152, height: 1)
                .background(Color.gray)
            Text("OR")
                .font(.callout)
                .foregroundColor(.gray)
                .padding(.horizontal, 8)
            Divider()
                .frame(width: 152, height: 1)
                .background(Color.gray)
            Spacer()
        }
    }
}

#Preview {
    SignupView()
}
