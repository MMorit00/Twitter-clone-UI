import SwiftUI

struct WelcomeView: View {
    @ObserveInjection var inject

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    // Top Logo Area
                    HStack {
                        Spacer()
                        Image("X")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40)
                        Spacer()
                    }
                    .padding(.top, 60)
                    Spacer()

                    // Main Title
                    Text("See what's happening in the world right now.")
                        .font(.system(size: 30, weight: .black))
                        .padding(.top, 40)
                        .padding(.horizontal, 20)

                    Spacer()

                    // Buttons Area
                    VStack(spacing: 16) {
                        // Google Sign In Button
                        Button(action: {}) {
                            HStack {
                                Image("GoogleLogo")
                                    .resizable()
                                    .frame(width: 24, height: 24)

                                Text("Continue with Google")
                                    .font(.title3)
                            }
                            .frame(width: geometry.size.width * 0.8, height: 52)
                        }

                        .background(Color.white)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.gray.opacity(0.6), lineWidth: 3)
                        )

                        .foregroundColor(.black)
                        .clipShape(Capsule(style: .continuous))

                        // Apple Sign In Button
                        Button(action: {}) {
                            HStack {
                                Image(systemName: "applelogo")
                                Text("Continue with Apple")
                                    .font(.title3)
                            }
                            .frame(width: geometry.size.width * 0.8, height: 52)
                        }
                        .background(Color.white)
                        .overlay(
                            Capsule(style: .continuous)
                                .stroke(Color.gray.opacity(0.6), lineWidth: 3)
                        )
                        .foregroundColor(.black)
                        .clipShape(Capsule(style: .continuous))

                        // Divider
                        ZStack {
                            Divider()
                                .frame(width: geometry.size.width * 0.8)
                            Text("Or")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                                .background {
                                    Color.white
                                        .frame(width: 25, height: 1)
                                }
                        }
                        .padding(.horizontal, 20)

                        // Create Account Button
                        NavigationLink {
                            RegisterView()
                        } label: {
                            Text("Create account")
                                .foregroundColor(.white)
                                .font(.title3)
                                .fontWeight(.medium)
                                .frame(width: geometry.size.width * 0.8, height: 52)
                        }
                        .background(Color("BG"))
                        .clipShape(Capsule(style: .continuous))
                    }

                    Spacer()

                    // Bottom Disclaimer
                    VStack(spacing: 4) {
                        Group {
                            Text("By signing up, you agree to our ")
                                .foregroundColor(.gray) +
                                Text("Terms")
                                .foregroundColor(Color("BG"))
                                .fontWeight(.bold) +
                                Text(", ")
                                .foregroundColor(.gray) +
                                Text("Privacy Policy")
                                .foregroundColor(Color("BG"))
                                .fontWeight(.bold) +
                                Text(", and ")
                                .foregroundColor(.gray) +
                                Text("Cookie Use")
                                .foregroundColor(Color("BG"))
                                .fontWeight(.bold)
                        }
                        .font(.caption)
                        .multilineTextAlignment(.leading)

                        HStack(spacing: 4) {
                            Text("Have an account already?")
                                .foregroundColor(.gray)
                            NavigationLink {
                                LoginView()
                            } label: {
                                Text("Log in")
                                    .foregroundColor(Color("BG"))
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .font(.caption)
                    .padding(.bottom, 48)
                }

                .frame(width: geometry.size.width)
            }
        }
        .toolbar(.hidden)
        .enableInjection()
        .ignoresSafeArea()
    }
}

#Preview {
    WelcomeView()
}
