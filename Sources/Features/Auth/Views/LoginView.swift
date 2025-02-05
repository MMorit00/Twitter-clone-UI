import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var emailDone = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @ObserveInjection var inject
    @EnvironmentObject private var authState: AuthState

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
                .disabled(authState.isLoading)

                Spacer()

                VStack(spacing: 12) {
                    // Login Button
                    Button(action: {
                        Task {
                            await authState.login(email: email, password: password)
                            
                            if authState.isAuthenticated {
                                // 延迟2秒后关闭页面
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    dismiss()
                                }
                            }
                        }
                    }) {
                        HStack {
                            if authState.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 8)
                            }

                            Text(authState.isLoading ? "登录中..." : "Log in")
                                .foregroundColor(.white)
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            password.isEmpty || authState.isLoading
                                ? Color.gray
                                : Color("BG")
                        )
                        .clipShape(Capsule())
                    }
                    .disabled(password.isEmpty || authState.isLoading)
                    .padding(.horizontal)
                }
                .padding(.bottom, 30)
            }
        }
        .toolbar(.hidden)
        .enableInjection()
        .disabled(authState.isLoading)
        .animation(.easeInOut, value: authState.isLoading)
        .alert("登录失败", isPresented: .init(
            get: { authState.error != nil },
            set: { if !$0 { authState.error = nil } }
        )) {
            Button("确定", role: .cancel) {
                authState.error = nil
            }
        } message: {
            Text(authState.error ?? "未知错误")
        }
    }
}
