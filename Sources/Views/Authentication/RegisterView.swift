import SwiftUI

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showSuccess = false
    @ObserveInjection var inject
     @EnvironmentObject private var viewModel: AuthViewModel
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
            Button(action: {
                Task {
                    do {
                        // try await viewModel.register(
                        //     name: name,
                        //     email: email,
                        //     username: username,
                        //     password: password
                        // )

                        try await viewModel.register(
                            name: "wadawd",
                            username: "awdwd", email: "teaasast@test.com",
                            password: "tasddest1234"
                        )
                        showSuccess = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            dismiss()
                        }
                    } catch {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            }) {
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

            if showSuccess {
                Text("注册成功！")
                    .foregroundColor(.green)
                    .font(.headline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.green.opacity(0.1))
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }

            if showError {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
            }
        }
        .toolbar(.hidden)
        .enableInjection()
    }
}
