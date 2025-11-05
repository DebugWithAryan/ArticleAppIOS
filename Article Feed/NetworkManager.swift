//
//  NetworkManager.swift
//  Article Feed
//
//  Created by Aryan Jaiswal on 05/11/25.
//

import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError
    case serverError(String)
    case unauthorized
    case forbidden
    case notFound
    case rateLimitExceeded
    case unknown
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received from server"
        case .decodingError:
                return "Failed to decode server response"
        case .serverError(let message):
            return message
        case .unauthorized:
            return "Session expired. Please login again."
        case .forbidden:
            return "You don't have permission to perform this action"
        case .notFound:
            return "Resource not found"
        case .rateLimitExceeded:
            return "Too many requests. Please try again later."
        case .unknown:
            return "An unexpected error occurred"
        }
    }
}

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func request<T: Decodable>(
        endpoint: String,
        method: String = "GET",
        body: Encodable? = nil,
        requireAuth: Bool = true
    ) async throws -> T {
        guard let url = URL(string: Constants.baseUrl + endpoint) else {
            throw NetworkError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if requireAuth {
            if let token = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.accessToken) {
                request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            }
        }
        
        if let body = body {
            request.httpBody = try JSONEncoder().encode(body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.unknown
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            if data.isEmpty, T.self == MessageResponse?.self {
                throw NetworkError.noData
            }
            do {
                let decodedResponse = try JSONDecoder().decode(T.self, from: data)
                return decodedResponse
            } catch {
                print("Decoding error: \(error)")
                throw NetworkError.decodingError
            }
            
        case 401:
            if requireAuth {
                try await refreshAccessToken()
                return try await self.request(endpoint: endpoint, method: method, body: body, requireAuth: requireAuth)
            }
            throw NetworkError.unauthorized
            
        case 403:
            throw NetworkError.forbidden
            
        case 404:
            throw NetworkError.notFound
            
        case 429:
            throw NetworkError.rateLimitExceeded
            
        case 400...499, 500...599:
            if let errorResponse = try? JSONDecoder().decode(ErrorResponse.self, from: data) {
                throw NetworkError.serverError(errorResponse.message)
            }
            throw NetworkError.unknown
            
        default:
            throw NetworkError.unknown
        }
    }
    
    private func refreshAccessToken() async throws {
        guard let refreshToken = UserDefaults.standard.string(forKey: Constants.UserDefaultsKeys.refreshToken) else {
            throw NetworkError.unauthorized
        }
        
        let refreshRequest = RefreshTokenRequest(refreshToken: refreshToken)
        
        let response: AuthResponse = try await self.request(
            endpoint: Constants.EndPoints.refreshToken,
            method: "POST",
            body: refreshRequest,
            requireAuth: false
        )
        
        UserDefaults.standard.set(response.accessToken, forKey: Constants.UserDefaultsKeys.accessToken)
        UserDefaults.standard.set(response.refreshToken, forKey: Constants.UserDefaultsKeys.refreshToken)
    }
}

