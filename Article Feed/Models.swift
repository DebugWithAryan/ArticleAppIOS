//
//  Models.swift
//  Article Feed
//
//  Created by Aryan Jaiswal on 05/11/25.
//

import Foundation

struct User: Codable, Identifiable {
    let id: Int
    let email: String
    let name: String
    let role: String
    
    enum CodingKeys: String, CodingKey {
        case id = "userId"
        case email
        case name
        case role
    }
}

struct Article: Codable, Identifiable {
    let id: Int
    let title: String
    let content: String
    let authorName: String
    let authorId: Int
    let status: String
    let viewCount: Int
    let createdAt: String
    let updatedAt: String?
    
    var formattedCreatedAt: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        if let date = formatter.date(from: createdAt) {
            formatter.dateFormat = "dd MMM, yyyy"
            return formatter.string(from: date)
        }
        return createdAt
    }
}

struct RegisterRequest: Codable {
    let name: String
    let email: String
    let password: String
}

struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct AuthResponse: Codable {
    let accessToken: String
    let refreshToken: String
    let tokenType: String
    let userId: Int
    let email: String
    let name: String
    let message: String?
    
    enum CodingKeys: String, CodingKey {
        case accessToken
        case refreshToken
        case tokenType
        case userId
        case email
        case name
        case message
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        accessToken = try container.decode(String.self, forKey: .accessToken)
        refreshToken = try container.decode(String.self, forKey: .refreshToken)
        tokenType = try container.decode(String.self, forKey: .tokenType)
        userId = try container.decode(Int.self, forKey: .userId)
        email = try container.decode(String.self, forKey: .email)
        name = try container.decode(String.self, forKey: .name)
        message = try? container.decode(String.self, forKey: .message)
    }
}

struct RefreshTokenRequest: Codable {
    let refreshToken: String
}

struct MessageResponse: Codable {
    let message: String
}

struct ArticleRequest: Codable {
    let title: String
    let content: String
}

struct ArticlesResponse: Codable {
    let content: [Article]
    let pageable: Pageable
    let TotalElements: Int
    let TotalPages: Int
    let last: Bool
    let first: Bool
}

struct Pageable: Codable {
    let pageNumber: Int
    let pageSize: Int
}

struct ErrorResponse: Codable {
    let status: Int
    let message: String
    let timestamp: String
    let path: String
}

struct PasswordResetRequest: Codable {
    let email: String
}

struct ResetPasswordRequest: Codable {
    let token: String
    let newPassword: String
}

struct ResendVerificationRequest: Codable {
    let email: String
}

struct VerifyEmailRequest: Codable {
    let token: String
}

