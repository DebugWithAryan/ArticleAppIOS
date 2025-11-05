//
//  Custom.swift
//  Article Feed
//
//  Created by Aryan Jaiswal on 05/11/25.
//


import SwiftUI

struct CustomTextField: View {
    
    @Binding var text: String
    
    let placeholder: String
    let isSecure: Bool
    let iconName: String?
    let keyboardType: UIKeyboardType
    
    init(
        text: Binding<String>,
        placeholder: String,
        isSecure: Bool = false,
        iconName: String? = nil,
        keyboardType: UIKeyboardType = .default
    ){
        self._text = text
        self.placeholder = placeholder
        self.isSecure = isSecure
        self.iconName = iconName
        self.keyboardType = keyboardType
    }
    
    var body: some View{
        HStack(spacing: Constants.UI.mediumPadding){
            if let icon = iconName{
                Image(systemName: icon)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .frame(width: 20)
            }
            
            if isSecure {
                SecureField(placeholder, text: $text)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .keyboardType(keyboardType)
            } else {
                TextField(placeholder, text: $text)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
        }
        .padding()
        .background(Constants.Colors.cardBackground)
        .cornerRadius(Constants.UI.cornerRadius)
        .overlay(
            RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                .stroke(Constants.Colors.border, lineWidth: 1)
        )
    }
}

struct PrimaryButton: View {
    let title: String
    let isLoading: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                } else {
                    Text(title)
                        .fontWeight(.semibold)
                }
            }
            .frame(maxWidth: .infinity)
            .frame(height: Constants.UI.buttonHeight)
            .foregroundColor(.white)
            .background(Constants.Colors.primary)
            .cornerRadius(Constants.UI.cornerRadius)
        }
        .disabled(isLoading)
    }
}

struct ArticleCard: View {
    let article: Article
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            VStack(alignment: .leading, spacing: Constants.UI.mediumPadding) {
                Text(article.title)
                    .font(.headline)
                    .foregroundColor(Constants.Colors.textPrimary)
                    .lineLimit(2)
                
                Text(article.content)
                    .font(.subheadline)
                    .foregroundColor(Constants.Colors.textSecondary)
                    .lineLimit(3)
                
                HStack {
                    Label(article.authorName, systemImage: "person.fill")
                        .font(.caption)
                        .foregroundColor(Constants.Colors.textTertiary)
                    
                    Spacer()
                    
                    Label("\(article.viewCount)", systemImage: "eye.fill")
                        .font(.caption)
                        .foregroundColor(Constants.Colors.textTertiary)
                    
                    Text(article.formattedCreateAt)
                        .font(.caption)
                        .foregroundColor(Constants.Colors.textTertiary)
                }
            }
            .padding()
            .background(Constants.Colors.cardBackground)
            .cornerRadius(Constants.UI.cornerRadius)
            .overlay(
                RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                    .stroke(Constants.Colors.border, lineWidth: 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.black.opacity(0.3)
                .ignoresSafeArea()
            
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: Constants.Colors.primary))
                .scaleEffect(1.5)
        }
    }
}

struct EmptyStateView: View {
    let icon: String
    let title: String
    let subtitle: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    var body: some View {
        VStack(spacing: Constants.UI.largePadding) {
            Image(systemName: icon)
                .font(.system(size: 60))
                .foregroundColor(Constants.Colors.textSecondary)
            
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(Constants.Colors.textPrimary)
            
            Text(subtitle)
                .font(.body)
                .foregroundColor(Constants.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            if let actionTitle = actionTitle, let action = action {
                Button(action: action) {
                    Text(actionTitle)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 30)
                        .padding(.vertical, 12)
                        .background(Constants.Colors.primary)
                        .cornerRadius(Constants.UI.cornerRadius)
                }
            }
        }
        .padding()
    }
}

