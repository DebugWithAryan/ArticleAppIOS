//
//  ForgotPasswordView.swift
//  Article Feed
//
//  Created by Aryan Jaiswal on 05/11/25.
//

import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var authManager = AuthManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var showSuccessAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: Constants.UI.largePadding) {
                    VStack(spacing: Constants.UI.smallPadding) {
                        Image(systemName: "lock.rotation")
                            .font(.system(size: 60))
                            .foregroundColor(Constants.Colors.primary)
                        
                        Text("Forgot Password?")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Colors.textPrimary)
                        
                        Text("Enter your email address and we'll send you a link to reset your password.")
                            .font(.subheadline)
                            .foregroundColor(Constants.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                    .padding(.top, 60)
                    
                    CustomTextField(
                        text: $email,
                        placeholder: "Email",
                        iconName: "envelope.fill",
                        keyboardType: .emailAddress
                    )
                    .padding(.horizontal)
                    
                    if let error = authManager.errorMessage, !showSuccessAlert {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(Constants.Colors.error)
                            .padding(.horizontal)
                            .multilineTextAlignment(.center)
                    }
                    
                    PrimaryButton(
                        title: "Send Reset Link",
                        isLoading: authManager.isLoading
                    ) {
                        Task {
                            await sendResetLink()
                        }
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Constants.Colors.primary)
                }
            }
            .alert("Email Sent", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Check your email for a password reset link.")
            }
        }
    }
    
    private func sendResetLink() async {
        guard !email.isEmpty else {
            authManager.errorMessage = "Email is required"
            return
        }
        
        await authManager.requestPasswordReset(email: email)
        
        if authManager.errorMessage?.contains("sent") ?? false {
            showSuccessAlert = true
        }
    }
}
