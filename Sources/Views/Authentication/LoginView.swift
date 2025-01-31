import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var emailDone = false
    @State private var showError = false
    @State private var isLoading = false
    @State private var loginStatus = ""
    @State private var showSuccessMessage = false
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.dismiss) private var dismiss
    @ObserveInjection var inject
    @EnvironmentObject private var viewModel: AuthViewModel

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
                .disabled(isLoading)

                Spacer()

                VStack(spacing: 12) {
                    // Login Button
                    Button(action: {
                        Task {
                            isLoading = true
                            showError = false
                            showSuccessMessage = false
                            loginStatus = "正在登录..."

                            do {
                                // 使用模拟数据进行测试
                                viewModel.login(
                                    email: "teaasast@test.com", // 模拟数据
                                    password: "tasddest1234" // 模拟数据
                                )

                                // 登录成功
                                showSuccessMessage = true
                                loginStatus = "登录成功！正在跳转..."

                                // 延迟2秒后关闭页面
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    dismiss()
                                }

                            } catch {
                                showError = true
                                loginStatus = "登录失败：\(error.localizedDescription)"
                            }

                            isLoading = false
                        }
                    }) {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .padding(.trailing, 8)
                            }

                            Text(isLoading ? "登录中..." : "Log in")
                                .foregroundColor(.white)
                                .font(.title3)
                                .fontWeight(.bold)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 44)
                        .background(
                            password.isEmpty || isLoading
                                ? Color.gray
                                : Color("BG")
                        )
                        .clipShape(Capsule())
                    }
                    .disabled(password.isEmpty || isLoading)
                    .padding(.horizontal)

                    // 状态信息显示
                    if !loginStatus.isEmpty {
                        Text(loginStatus)
                            .foregroundColor(
                                showSuccessMessage ? .green :
                                    showError ? .red : .gray
                            )
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                            .animation(.easeInOut, value: loginStatus)
                    }

                    // 成功信息
                    if showSuccessMessage {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.green)
                            Text("登录成功")
                                .foregroundColor(.green)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }

                    // 错误信息
                    if showError {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("登录失败，请检查邮箱和密码")
                                .foregroundColor(.red)
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .padding(.bottom, 30)
            }
        }
        .toolbar(.hidden)
        .enableInjection()
        .disabled(isLoading)
        .animation(.easeInOut, value: isLoading)
    }
}
