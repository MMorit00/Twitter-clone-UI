import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var emailDone = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @ObserveInjection var inject

    var body: some View {
        VStack(spacing: 0) {
            // Header
            ZStack {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
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

            if !emailDone {
                // Email Input View
                Text("Enter your email, phone number or username")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 40)

                CustomAuthTextField(
                    placeholder: "Phone, email, or username",
                    text: $email,
                    keyboardType: .emailAddress
                )
                .padding(.top, 30)

                Spacer()

                // Bottom Buttons
                VStack(spacing: 12) {
                    Button(action: {
                        if !email.isEmpty {
                            emailDone.toggle()
                        }
                    }) {
                        Text("Next")
                            .foregroundColor(.white)
                            .font(.title3)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .frame(height: 44)
                            .background(email.isEmpty ? Color.gray : Color("BG"))
                            .clipShape(Capsule())
                    }
                    .disabled(email.isEmpty)
                    .padding(.horizontal)

                    Button("Forgot Password?") {
                        // 后续添加忘记密码功能
                    }
                    .foregroundColor(Color("BG"))
                }
                .padding(.bottom, 30)
            } else {
                // Password Input View
                Text("Enter your password")
                    .font(.title2)
                    .fontWeight(.heavy)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.top, 40)

                SecureAuthTextField(
                    placeholder: "Password",
                    text: $password
                )
                .padding(.top, 30)

                Spacer()

                // Login Button
                Button(action: {
                    // 后续添加登录验证逻辑
                }) {
                    Text("Log in")
                        .foregroundColor(.white)
                        .font(.title3)
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(password.isEmpty ? Color.gray : Color("BG"))
                        .clipShape(Capsule())
                }
                .disabled(password.isEmpty)
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
        }
        .toolbar(.hidden)
        .enableInjection()
    }
}
