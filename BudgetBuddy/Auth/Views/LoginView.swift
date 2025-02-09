// Login.swift
import SwiftUI

struct Login: View {
    @State private var email = ""
    @State private var password = ""
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 25) {
                    // Logo and Title
                    VStack(spacing: 15) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 60))
                            .foregroundStyle(Color(hex: "037D4F"))
                        
                        Text("Budget Buddy")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                        
                        Text("Track your expenses with ease")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                    }
                    .padding(.top, 60)
                    .padding(.bottom, 40)
                    
                    // Input Fields
                    VStack(spacing: 20) {
                        InputView(text: $email, placeholder: "Email", label: "")
                        InputView(text: $password, placeholder: "Password", secureField: true, label: "")
                    }
                    .padding(.horizontal)
                    
                    // Login Button
                    Button {
                        Task {
                            try await authViewModel.Signin(withEmail: email, password: password)
                        }
                    } label: {
                        Text("Login")
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "037D4F"))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)
                    
                    OrSeparator()
                    
                    // Social Login Buttons
                    VStack(spacing: 15) {
                        Button {
                            Task {
                                try await authViewModel.signInGoogle()
                            }
                        } label: {
                            HStack {
                                Image("googleImage")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Text("Continue with Google")
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "1E1E1E"))
                            .cornerRadius(16)
                        }
                        
                        Button {
                            // Apple Sign In
                        } label: {
                            HStack {
                                Image(systemName: "apple.logo")
                                Text("Continue with Apple")
                                    .foregroundStyle(.white)
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "1E1E1E"))
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Sign Up Link
                    HStack {
                        Text("Don't have an account?")
                            .foregroundStyle(.gray)
                        NavigationLink(destination: SignupView().environmentObject(authViewModel)) {
                            Text("Sign Up")
                                .foregroundStyle(Color(hex: "037D4F"))
                        }
                    }
                    .padding(.vertical)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(hex: "191919"))
            .ignoresSafeArea()
        }
    }
}


#Preview {
    NavigationStack{
        Login().environmentObject(AuthViewModel())
    }
    
}


extension Login {
    func headingLogin() -> some View {
        VStack(spacing: 15) {
            Text("HomeworkHomie")
                .font(.title2)
                .fontWeight(.medium)
            Text("Get done with your homeworks")
                .font(.system(size: 17))
                .foregroundStyle(.black)
                .opacity(0.9)
        }
    }
}
