//
//  Constants.swift
//  Article Feed
//
//  Created by Aryan Jaiswal on 05/11/25.
//


import SwiftUI

struct Constants {
    
    static let baseUrl = "https://articlems-backend.onrender.com"
    
    struct EndPoints {
        static let register = "/auth/register"
        static let login = "/auth/login"
        static let verifyEmail = "/auth/verify-email"
        static let resendVerification = "/auth/resend-verification"
        static let forgotPassword = "/auth/forgot-password"
        static let resetPassword = "/auth/reset-password"
        static let refreshToken = "/auth/refresh-token"
        static let logout = "/auth/logout"
        
        static let articles = "/articles"
        static let myArticles = "/articles/my"
        static let searchArticles = "/articles/search"
        
        static let emailHealth = "/health/email"
    }
    
    
    struct Colors {
        
        static let primary = Color("007AFF")
        static let background = Color("000000")
        static let cardBackground = Color("1C1C1E")
        static let secondaryBackground = Color("2C2C2E")
        
        static let textPrimary = Color.white
        static let textSecondary = Color("8E8E93")
        static let textTertiary = Color("636366")
        
        static let success = Color("34C759")
        static let error = Color("FF3B30")
        static let warning = Color("FF9500")
        
        static let border = Color("38383A")
        static let divider = Color("48484A")
    }
    
    struct UI {
        static let cornerRadius: CGFloat = 12
        static let largePadding: CGFloat = 20
        static let mediumPadding: CGFloat = 16
        static let smallPadding: CGFloat = 8
        static let buttonHeight: CGFloat = 50
        static let textFieldHeight: CGFloat = 50
    }
    
    struct UserDefaultsKeys {
        
        static let accessToken = "accessToken"
        static let refreshToken = "refreshToken"
        static let userId = "userId"
        static let userEmail = "userEmail"
        static let userName = "userName"
        static let isLoggedIn = "isLoggedIn"
    }
}
