import SwiftUI

struct AddIncomeView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var incomeTitle = ""
    @State private var incomeAmount = ""
    @State private var incomeDate = Date()

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

                // Add button
                Button {
                    // Add income logic here
                    dismiss()
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
        }
    }
}

#Preview {
    AddIncomeView()
        .preferredColorScheme(.dark)
}
