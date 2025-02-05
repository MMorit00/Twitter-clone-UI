import SwiftUI 

struct RegisterView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var name = ""
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @ObserveInjection var inject
    @EnvironmentObject private var authState: AuthState
    @State private var showSuccessOverlay = false  // 添加这一行
    var body: some View {

        ZStack{
        
            
        
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
            .disabled(authState.isLoading)
            
            CustomAuthTextField(
                placeholder: "Username",
                text: $username,
                keyboardType: .default
            )
            .disabled(authState.isLoading)
            
            CustomAuthTextField(
                placeholder: "Email",
                text: $email,
                keyboardType: .emailAddress
            )
            .disabled(authState.isLoading)
            
            SecureAuthTextField(
                placeholder: "Password",
                text: $password
            )
            .disabled(authState.isLoading)
            
            Spacer()
            
            // Register Button
            Button(action: {
                Task {
                    await authState.register(
                        email: email,
                        username: username,
                        password: password,
                        name: name
                    )
                    
                    if authState.isAuthenticated {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
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
                    
                    Text(authState.isLoading ? "注册中..." : "注册")
                        .foregroundColor(.white)
                        .font(.title3)
                        .fontWeight(.medium)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 52)
                .background(
                    isFormValid && !authState.isLoading
                        ? Color("BG")
                        : Color.gray
                )
                .clipShape(Capsule())
            }
            .disabled(!isFormValid || authState.isLoading)
            .padding(.horizontal)
            .padding(.bottom, 48)
        }
        .toolbar(.hidden)
        .enableInjection()
        .disabled(authState.isLoading)
        .animation(.easeInOut, value: authState.isLoading)
        .alert("注册失败", isPresented: .init(
            get: { authState.error != nil },
            set: { if !$0 { authState.error = nil } }
        )) {
            Button("确定", role: .cancel) {
                authState.error = nil
            }
        } message: {
            Text(authState.error ?? "未知错误")
        }
        
    // 成功提示覆盖层
            if showSuccessOverlay {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                
                VStack(spacing: 16) {
                    Image(systemName: "checkmark.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.green)
                    
                    Text("注册成功！")
                        .font(.title3)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                }
                .transition(.scale.combined(with: .opacity))
            }

    }
    }
    // 表单验证
    private var isFormValid: Bool {
        !name.isEmpty && 
        !username.isEmpty && 
        !email.isEmpty && 
        !password.isEmpty &&
        email.contains("@") &&
        password.count >= 6
    }
}
