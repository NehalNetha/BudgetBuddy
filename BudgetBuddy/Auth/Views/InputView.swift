//
//  InputView.swift
//  firebase-practice
//
//  Created by NehalNetha on 18/01/24.
//

import SwiftUI

struct InputView: View {
    
    @Binding var text: String
    let placeholder: String
    var secureField = false
    let label: String
    
    var body: some View {
        VStack(alignment: .leading) {
            if !label.isEmpty {
                Text(label)
                    .foregroundStyle(.white)
                    .font(.system(size: 14))
            }
            
            if secureField {
                SecureField("", text: $text)
                    .padding()
                    .background(Color(hex: "1E1E1E"))
                    .cornerRadius(16)
                    .foregroundStyle(.white)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .foregroundStyle(.gray)
                            .padding(.leading, 4)
                    }
            } else {
                TextField("", text: $text)
                    .padding()
                    .background(Color(hex: "1E1E1E"))
                    .cornerRadius(16)
                    .foregroundStyle(.white)
                    .placeholder(when: text.isEmpty) {
                        Text(placeholder)
                            .foregroundStyle(.gray)
                            .padding(.leading, 4)
                    }
            }
        }
    }
}

#Preview {
    InputView(text: .constant(""), placeholder: "example@gmail.com", label: "Email Address")
}


extension View {
    func placeholder<Content: View>(
        when shouldShow: Bool,
        alignment: Alignment = .leading,
        @ViewBuilder placeholder: () -> Content
    ) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow {
                placeholder()
            }
            self
        }
    }
}
