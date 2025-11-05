//
//  LoginView.swift
//  Article Feed
//
//  Created by Aryan Jaiswal on 05/11/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject private var authManager = AuthManager.shared
    
    @State private var email = ""
    @State private var password = ""
    
    @State private var showPassword = false
    @State private var showForgotPassword = false
    
    var body: some View {
            NavigationView {
                ZStack {
                    Constants.Colors.background
                        .ignoresSafeArea()
                    
                    ScrollView {
                        VStack(spacing: Constants.UI.largePadding) {
                            Spacer(minLength: 60)
 
                            VStack(spacing: Constants.UI.smallPadding) {
                                Image(systemName: "newspaper.fill")
                                    .font(.system(size: 70))
                                    .foregroundColor(Constants.Colors.primary)
                                
                                Text("Article Hub")
                                    .font(.largeTitle)
                                    .fontWeight(.bold)
                                    .foregroundColor(Constants.Colors.textPrimary)
                                
                                Text("Share your thoughts with the world")
                                    .font(.subheadline)
                                    .foregroundColor(Constants.Colors.textSecondary)
                            }
                            .padding(.bottom, 40)
                            
                            VStack(spacing: Constants.UI.mediumPadding) {
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
                                    } else {
                                        SecureField("Password", text: $password)
                                            .foregroundColor(Constants.Colors.textPrimary)
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
                                
                                HStack {
                                    Spacer()
                                    Button(action: { showForgotPassword = true }) {
                                        Text("Forgot Password?")
                                            .font(.subheadline)
                                            .foregroundColor(Constants.Colors.primary)
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            if let error = authManager.errorMessage {
                                Text(error)
                                    .font(.caption)
                                    .foregroundColor(Constants.Colors.error)
                                    .padding(.horizontal)
                                    .multilineTextAlignment(.center)
                            }
                            

                            PrimaryButton(
                                title: "Login",
                                isLoading: authManager.isLoading
                            ) {
                                Task {
                                    await authManager.login(email: email, password: password)
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, Constants.UI.mediumPadding)

                            HStack {
                                Text("Don't have an account?")
                                    .foregroundColor(Constants.Colors.textSecondary)
                                
                                NavigationLink(destination: RegisterView()) {
                                    Text("Sign Up")
                                        .fontWeight(.semibold)
                                        .foregroundColor(Constants.Colors.primary)
                                }
                            }
                            .font(.subheadline)
                            
                            Spacer()
                        }
                    }
                }
                .sheet(isPresented: $showForgotPassword) {
                    ForgotPasswordView()
                }
            }
        }
    }
