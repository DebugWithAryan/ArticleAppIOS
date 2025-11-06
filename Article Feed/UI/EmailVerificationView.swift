//
//  EmailVerificationView.swift
//  Article Feed
//
//  Created by Aryan Jaiswal on 05/11/25.
//

import SwiftUI

struct EmailVerificationView: View {
    @StateObject private var authManager = AuthManager.shared
    @Environment(\.dismiss) private var dismiss
    
    let email: String
    
    @State private var verificationToken = ""
    @State private var showTokenInput = false
    @State private var isResending = false
    @State private var resendMessage: String?
    @State private var resendSuccess = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Constants.UI.largePadding) {
                        Spacer(minLength: 40)
                        
                        Image(systemName: "envelope.badge.fill")
                            .font(.system(size: 80))
                            .foregroundColor(Constants.Colors.primary)
                            .padding(.bottom, 20)
                        
                        VStack(spacing: Constants.UI.smallPadding) {
                            Text("Verify Your Email")
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            Text("We've sent a verification email to:")
                                .font(.subheadline)
                                .foregroundColor(Constants.Colors.textSecondary)
                                .multilineTextAlignment(.center)
                            
                            Text(email)
                                .font(.headline)
                                .foregroundColor(Constants.Colors.primary)
                                .padding(.horizontal)
                        }
                        .padding(.bottom, 20)
                        
                        VStack(alignment: .leading, spacing: 12) {
                            InstructionRow(
                                number: "1",
                                text: "Check your email inbox (and spam folder)"
                            )
                            
                            InstructionRow(
                                number: "2",
                                text: "Click the verification link in the email"
                            )
                            
                            InstructionRow(
                                number: "3",
                                text: "Return here and login"
                            )
                        }
                        .padding()
                        .background(Constants.Colors.cardBackground)
                        .cornerRadius(Constants.UI.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                                .stroke(Constants.Colors.border, lineWidth: 1)
                        )
                        .padding(.horizontal)
                        
                        if let message = resendMessage {
                            HStack(spacing: 8) {
                                Image(systemName: resendSuccess ? "checkmark.circle.fill" : "info.circle.fill")
                                    .foregroundColor(resendSuccess ? Constants.Colors.success : Constants.Colors.warning)
                                
                                Text(message)
                                    .font(.subheadline)
                                    .foregroundColor(resendSuccess ? Constants.Colors.success : Constants.Colors.warning)
                                    .multilineTextAlignment(.leading)
                            }
                            .padding()
                            .background(Constants.Colors.cardBackground)
                            .cornerRadius(Constants.UI.cornerRadius)
                            .padding(.horizontal)
                        }
                        
                        VStack(spacing: Constants.UI.mediumPadding) {
                            Text("Didn't receive the email?")
                                .font(.subheadline)
                                .foregroundColor(Constants.Colors.textSecondary)
                            
                            Button(action: resendVerificationEmail) {
                                HStack {
                                    if isResending {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    } else {
                                        Image(systemName: "arrow.clockwise")
                                        Text("Resend Verification Email")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .frame(height: Constants.UI.buttonHeight)
                                .foregroundColor(.white)
                                .background(Constants.Colors.primary)
                                .cornerRadius(Constants.UI.cornerRadius)
                            }
                            .disabled(isResending)
                            .padding(.horizontal)
                        }
                        
                        VStack(spacing: Constants.UI.mediumPadding) {
                            Button(action: { showTokenInput.toggle() }) {
                                HStack {
                                    Text(showTokenInput ? "Hide" : "Have a verification token?")
                                        .font(.subheadline)
                                        .foregroundColor(Constants.Colors.primary)
                                    
                                    Image(systemName: showTokenInput ? "chevron.up" : "chevron.down")
                                        .font(.caption)
                                        .foregroundColor(Constants.Colors.primary)
                                }
                            }
                            
                            if showTokenInput {
                                VStack(spacing: Constants.UI.mediumPadding) {
                                    CustomTextField(
                                        text: $verificationToken,
                                        placeholder: "Paste verification token here",
                                        iconName: "key.fill"
                                    )
                                    
                                    PrimaryButton(
                                        title: "Verify Now",
                                        isLoading: authManager.isLoading
                                    ) {
                                        Task {
                                            await verifyWithToken()
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: { dismiss() }) {
                            Text("Back to Login")
                                .fontWeight(.semibold)
                                .foregroundColor(Constants.Colors.primary)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Constants.Colors.primary)
                }
            }
        }
    }
    
    private func resendVerificationEmail() {
        isResending = true
        resendMessage = nil
        
        Task {
            await authManager.resendVerificationEmail(email)
            
            await MainActor.run {
                isResending = false
                
                if let errorMsg = authManager.errorMessage {
                    if errorMsg.contains("sent") || errorMsg.contains("success") {
                        resendMessage = "✅ Verification email sent! Please check your inbox."
                        resendSuccess = true
                    } else {
                        resendMessage = errorMsg
                        resendSuccess = false
                    }
                } else {
                    resendMessage = "✅ Verification email sent successfully!"
                    resendSuccess = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
                    resendMessage = nil
                }
            }
        }
    }
    
    private func verifyWithToken() async {
        guard !verificationToken.isEmpty else {
            authManager.errorMessage = "Please enter verification token"
            return
        }
        
        await authManager.verifyEmail(verificationToken)
        
        if authManager.isAuthenticated {
            dismiss()
        }
    }
}

struct InstructionRow: View {
    let number: String
    let text: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Text(number)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .frame(width: 30, height: 30)
                .background(Constants.Colors.primary)
                .clipShape(Circle())
            
            Text(text)
                .font(.subheadline)
                .foregroundColor(Constants.Colors.textPrimary)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}
