import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @ObserveInjection var inject

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                HStack {
                    Button(action: { dismiss() }) {
                        Text("Cancel")
                            .foregroundColor(Color("BG"))
                    }
                    Spacer()
                }

                Image("X")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 24, height: 24)
            }
           .padding(.horizontal) 

            Text("Create your account")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.horizontal)

            // Form Fields
            CustomAuthTextField(
                placeholder: "Name",
                text: $name,
                keyboardType: .default
            )

            CustomAuthTextField(
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress
            )

            SecureAuthTextField(
                placeholder: "Password",
                text: $password
            )

            Spacer()

            // Next Button
            Button(action: {}) {
                Text("Next")
                    .foregroundColor(.white)
                    .font(.title3)
                    .fontWeight(.medium)
                    .frame(maxWidth: .infinity)
                    .frame(height: 52)
                    .background(Color("BG"))
                    .clipShape(Capsule())
            }
            .padding(.horizontal)
            .padding(.bottom, 48)
        }
        .toolbar(.hidden)
        .enableInjection()
    }
}
