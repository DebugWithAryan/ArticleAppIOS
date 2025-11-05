//
//  AuthManager.swift
//  Article Feed
//
//  Created by Aryan Jaiswal on 05/11/25.
//

import Foundation
import Combine


class AuthManager: ObservableObject {
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    static let shared = AuthManager()
    
    private init(){
        checkAuthStatus()
    }
    
    func checkAuthStatus() {
        isAuthenticated = UserDefaults.standard.bool(forKey: Constants.UserDefaultsKeys.isLoggedIn)
        
        if isAuthenticated{
            if let userId = UserDefaults.standard.object(forKey: Constants.UserDefaultsKeys.userId) as? Int,
               let email = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.userEmail),
               let name = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.userName){
                currentUser = User(id: userId, email: email, name: name, role: "USER")
            }
        }
    }
    
    func register (name: String, email: String, password: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
            
        }
        do {
            let request = RegisterRequest(name: name, email: email, password: password)
            
            let response: MessageResponse = try await NetworkManager.shared.request(endpoint: Constants.EndPoints.register,
                                                                                    method: "POST",
                                                                                    body: request,
                                                                                    requireAuth: false)
            
            await MainActor.run{
                isLoading = false
                errorMessage = response.message
            }
        }
        catch{
            await MainActor.run{
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func login (email: String, password: String) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let request = LoginRequest(email: email, password: password)
            
            let response : AuthResponse = try await NetworkManager.shared.request(endpoint: Constants.EndPoints.login,
                                                                                  method: "POST",
                                                                                  body: request,
                                                                                  requireAuth: false)
            
            await MainActor.run{
                saveAuthData(response)
                isLoading = false
            }
        } catch {
            await MainActor.run{
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func logout() async {
        do{
            let _: MessageResponse = try await NetworkManager.shared.request(endpoint: Constants.EndPoints.logout,
                                                                             method: "POST")
        } catch {
            print("Logout error: \(error)")
        }
        
        await MainActor.run{
            clearAuthData()
        }
    }
    
    func requestPasswordReset(email: String) async {
        await MainActor.run{
            isLoading = true
            errorMessage = nil
        }
        do {
            let request = PasswordResetRequest(email: email)
            let response: MessageResponse = try await NetworkManager.shared.request(endpoint: Constants.EndPoints.forgotPassword,
                                                                                    method: "POST",
                                                                                    body: request,
                                                                                    requireAuth: false)
            await MainActor.run{
                isLoading = false
                errorMessage = response.message
            }
        }catch{
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    
    private func saveAuthData(_ response: AuthResponse) {
        UserDefaults.standard.set(response.accessToken, forKey: Constants.UserDefaultsKeys.accessToken)
        UserDefaults.standard.set(response.refreshToken, forKey: Constants.UserDefaultsKeys.refreshToken)
        UserDefaults.standard.set(response.userId, forKey: Constants.UserDefaultsKeys.userId)
        UserDefaults.standard.set(response.email, forKey: Constants.UserDefaultsKeys.userEmail)
        UserDefaults.standard.set(response.name, forKey: Constants.UserDefaultsKeys.userName)
        UserDefaults.standard.set(true, forKey: Constants.UserDefaultsKeys.isLoggedIn)
        
        currentUser = User(id: response.userId, email: response.email, name: response.name, role: "USER")
        isAuthenticated = true
    }
    private func clearAuthData() {
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.accessToken)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.refreshToken)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.userId)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.userEmail)
        UserDefaults.standard.removeObject(forKey: Constants.UserDefaultsKeys.userName)
        UserDefaults.standard.set(false, forKey: Constants.UserDefaultsKeys.isLoggedIn)
        
        currentUser = nil
        isAuthenticated = false
    }
}
