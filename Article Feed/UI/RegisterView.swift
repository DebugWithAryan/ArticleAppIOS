//
//  RegisterView.swift
//  Article Feed
//
//  Created by Aryan Jaiswal on 05/11/25.
//

import SwiftUI

struct RegisterView: View {
    @StateObject private var authManager = AuthManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var name = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @State private var showPassword = false
    @State private var showConfirmPassword = false
    @State private var showSuccessAlert = false
    
    @State private var passwordErrors: [String] = []
    
    var body: some View {
        ZStack {
            Constants.Colors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: Constants.UI.largePadding) {
                    // MARK: - Header
                    VStack(spacing: Constants.UI.smallPadding) {
                        Text("Create Account")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Colors.textPrimary)
                        
                        Text("Join our community of writers")
                            .font(.subheadline)
                            .foregroundColor(Constants.Colors.textSecondary)
                    }
                    .padding(.top, 40)
                    .padding(.bottom, 20)
                    
                    VStack(spacing: Constants.UI.mediumPadding) {
                        CustomTextField(
                            text: $name,
                            placeholder: "Full Name",
                            iconName: "person.fill"
                        )
                        
                        CustomTextField(
                            text: $email,
                            placeholder: "Email",
                            iconName: "envelope.fill",
                            keyboardType: .emailAddress
                        )
                        
                        HStack(spacing: Constants.UI.mediumPadding) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Constants.Colors.textSecondary)
                                .frame(width: 20)
                            
                            if showPassword {
                                TextField("Password", text: $password)
                                    .foregroundColor(Constants.Colors.textPrimary)
                                    .onChange(of: password) { _ in validatePassword() }
                            } else {
                                SecureField("Password", text: $password)
                                    .foregroundColor(Constants.Colors.textPrimary)
                                    .onChange(of: password) { _ in validatePassword() }
                            }
                            
                            Button(action: { showPassword.toggle() }) {
                                Image(systemName: showPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(Constants.Colors.textSecondary)
                            }
                        }
                        .padding()
                        .background(Constants.Colors.cardBackground)
                        .cornerRadius(Constants.UI.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                                .stroke(Constants.Colors.border, lineWidth: 1)
                        )
                        
                        HStack(spacing: Constants.UI.mediumPadding) {
                            Image(systemName: "lock.fill")
                                .foregroundColor(Constants.Colors.textSecondary)
                                .frame(width: 20)
                            
                            if showConfirmPassword {
                                TextField("Confirm Password", text: $confirmPassword)
                                    .foregroundColor(Constants.Colors.textPrimary)
                            } else {
                                SecureField("Confirm Password", text: $confirmPassword)
                                    .foregroundColor(Constants.Colors.textPrimary)
                            }
                            
                            Button(action: { showConfirmPassword.toggle() }) {
                                Image(systemName: showConfirmPassword ? "eye.slash.fill" : "eye.fill")
                                    .foregroundColor(Constants.Colors.textSecondary)
                            }
                        }
                        .padding()
                        .background(Constants.Colors.cardBackground)
                        .cornerRadius(Constants.UI.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                                .stroke(Constants.Colors.border, lineWidth: 1)
                        )
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Password must contain:")
                                .font(.caption)
                                .foregroundColor(Constants.Colors.textSecondary)
                            
                            PasswordRequirement(text: "At least 8 characters", isMet: password.count >= 8)
                            PasswordRequirement(text: "One uppercase letter", isMet: password.contains(where: { $0.isUppercase }))
                            PasswordRequirement(text: "One lowercase letter", isMet: password.contains(where: { $0.isLowercase }))
                            PasswordRequirement(text: "One number", isMet: password.contains(where: { $0.isNumber }))
                            PasswordRequirement(text: "One special character (@#$%^&+=)", isMet: password.contains(where: { "!@#$%^&*()_+-=[]{}|;':,.<>?".contains($0) }))
                        }
                        .padding(.horizontal, 4)
                    }
                    .padding(.horizontal)
                    
                    if let error = authManager.errorMessage, !showSuccessAlert {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(Constants.Colors.error)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                    
                    PrimaryButton(
                        title: "Create Account",
                        isLoading: authManager.isLoading
                    ) {
                        Task {
                            await register()
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, Constants.UI.mediumPadding)
                    
                    Spacer()
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Registration Successful", isPresented: $showSuccessAlert) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text("Please check your email to verify your account.")
        }
    }
    
    private func validatePassword() {
        passwordErrors.removeAll()
        
        if password.count < 8 {
            passwordErrors.append("At least 8 characters")
        }
        if !password.contains(where: { $0.isUppercase }) {
            passwordErrors.append("One uppercase letter")
        }
        if !password.contains(where: { $0.isLowercase }) {
            passwordErrors.append("One lowercase letter")
        }
        if !password.contains(where: { $0.isNumber }) {
            passwordErrors.append("One number")
        }
        if !password.contains(where: { "!@#$%^&*()_+-=[]{}|;':,.<>?".contains($0) }) {
            passwordErrors.append("One special character")
        }
    }
    
    private func register() async {
        guard !name.isEmpty else {
            authManager.errorMessage = "Name is required"
            return
        }
        
        guard !email.isEmpty else {
            authManager.errorMessage = "Email is required"
            return
        }
        
        guard password == confirmPassword else {
            authManager.errorMessage = "Passwords do not match"
            return
        }
        
        guard passwordErrors.isEmpty else {
            authManager.errorMessage = "Please meet all password requirements"
            return
        }
        
        await authManager.register(name: name, email: email, password: password)
        
        if authManager.errorMessage?.contains("successful") ?? false {
            showSuccessAlert = true
        }
    }
}

struct PasswordRequirement: View {
    let text: String
    let isMet: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: isMet ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundColor(isMet ? Constants.Colors.success : Constants.Colors.textTertiary)
                .font(.caption)
            
            Text(text)
                .font(.caption)
                .foregroundColor(isMet ? Constants.Colors.success : Constants.Colors.textTertiary)
        }
    }
}

