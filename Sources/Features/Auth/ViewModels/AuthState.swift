//
//  AuthState.swift
//  CloneTwitter
//
//  Created by 潘令川 on 2025/2/5.
//

import Foundation
import SwiftUI

@MainActor
final class AuthState: ObservableObject {
    private let authService: AuthServiceProtocol
    
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    @Published var isLoading = false
    @Published var error: String?
    
    init(authService: AuthServiceProtocol) {
        self.authService = authService
        Task {
            await checkAuthStatus()
        }
    }
    
    // MARK: - Public Methods
    
    func login(email: String, password: String) async {
        await performAction {
          let response = try await self.authService.login(email: email, password: password)
            self.currentUser = response.user
            self.isAuthenticated = true
        }
    }
    
    func register(email: String, username: String, password: String, name: String) async {
        await performAction {
          let user = try await self.authService.register(
                email: email,
                username: username,
                password: password,
                name: name
            )
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    func signOut() {
        UserDefaults.standard.removeObject(forKey: "jwt")
        currentUser = nil
        isAuthenticated = false
    }
    
    func updateProfile(data: [String: Any]) async {
        await performAction {
          let updatedUser = try await self.authService.updateProfile(data: data)
            self.currentUser = updatedUser
        }
    }
    
    // MARK: - Private Methods
    
    private func checkAuthStatus() async {
        guard UserDefaults.standard.string(forKey: "jwt") != nil else {
            isAuthenticated = false
            return
        }
        
        await performAction {
          let user = try await self.authService.fetchCurrentUser()
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
    
    private func performAction(_ action: @escaping () async throws -> Void) async {
        isLoading = true
        error = nil
        
        do {
            try await action()
        } catch let networkError as NetworkError {
            error = networkError.errorDescription
            if case .unauthorized = networkError {
                signOut()
            }
        } catch {
            self.error = error.localizedDescription
        }
        
        isLoading = false
    }
}

#if DEBUG
extension AuthState {
    static var preview: AuthState {
        AuthState(authService: MockAuthService())
    }
}
#endif
