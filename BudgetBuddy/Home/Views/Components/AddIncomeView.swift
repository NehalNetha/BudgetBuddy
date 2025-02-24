import SwiftUI
import FirebaseAuth
struct AddIncomeView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var incomeVM: IncomeViewModel
    @State private var incomeTitle = ""
    @State private var incomeAmount = ""
    @State private var incomeDate = Date()
    @State private var showAlert = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                HStack {
                    Text("Add Income")
                        .font(.title2)
                        .foregroundStyle(.white)
                    Spacer()
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.gray)
                            .font(.title2)
                    }
                }
                .padding(.horizontal)

                HStack(alignment: .center) {
                    Text("$")
                        .foregroundStyle(.white)
                        .font(.system(size: 24, weight: .medium))
                    TextField("0.00", text: $incomeAmount)
                        .keyboardType(.decimalPad)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(hex: "1E1E1E"))
                )
                .padding(.horizontal)

                // Title input
                TextField("Income Title", text: $incomeTitle)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "1E1E1E"))
                    )
                    .foregroundStyle(.white)
                    .padding(.horizontal)

                // Date picker
                DatePicker("Date", selection: $incomeDate, displayedComponents: .date)
                    .datePickerStyle(.compact)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color(hex: "1E1E1E"))
                    )
                    .foregroundStyle(.white)
                    .padding(.horizontal)

                // Update Add button
                Button {
                    addIncome()
                } label: {
                    Text("Add Income")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color(hex: "037D4F"))
                        )
                        .padding(.horizontal)
                }

                Spacer()
            }
            .padding(.top, 60)
            .padding(.bottom, 30)
            .frame(maxHeight: .infinity)
            .background(Color(hex: "191919"))
            .clipShape(
                CustomCorner(corners: [.topLeft, .topRight], radius: 30)
            )
            .alert("Error", isPresented: $showAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorMessage)
            }
        }
    }
    
    private func addIncome() {
        guard let amount = Double(incomeAmount),
              let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "Please enter a valid amount"
            showAlert = true
            return
        }
        
        guard !incomeTitle.isEmpty else {
            errorMessage = "Please enter a title"
            showAlert = true
            return
        }
        
        let income = Income(
            title: incomeTitle,
            amount: amount,
            date: incomeDate,
            userId: userId
        )
        
        Task {
            do {
                try await incomeVM.addIncome(income)
                dismiss()
            } catch {
                errorMessage = error.localizedDescription
                showAlert = true
            }
        }
    }
}
