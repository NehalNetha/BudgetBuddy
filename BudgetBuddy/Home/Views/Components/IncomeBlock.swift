import SwiftUI



struct HorizontalIncomeItemView: View {
    var icon: String
    var title: String
    var amount: String
    var iconColor: Color

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(iconColor)
                    .padding(10)
                    .background(Circle().fill(iconColor.opacity(0.2)))
                Spacer()
                Button {
                    
                    print("More actions for \(title)")
                } label: {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            Text(amount)
                .font(.subheadline)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(width: 150) 
        .background(RoundedRectangle(cornerRadius: 16).fill(Color(hex: "2D2D2D")))
    }
}

