//
//  ArticleManager.swift
//  Article Feed
//
//  Created by Aryan Jaiswal on 05/11/25.
//

import Foundation
import Combine

class ArticleManager: ObservableObject {
    
    @Published var articles: [Article] = []
    @Published var myArticles: [Article] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var currentPage = 0
    @Published var totalPages = 0
    @Published var searchKeyword = ""
    
    static let shared = ArticleManager()
    
    private init() {}
    
    func fetchArticles(page: Int = 0, size: Int = 10, sortBy: String = "createdAt", sortDir: String = "desc") async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let queryParams = "?page=\(page)&size=\(size)&sortBy=\(sortBy)&sortDir=\(sortDir)"
            
            let response: ArticlesResponse = try await NetworkManager.shared.request(endpoint: Constants.EndPoints.articles + queryParams)
            
            await MainActor.run {
                if page == 0 {
                    articles = response.content
                } else {
                    articles.append(contentsOf: response.content)
                }
                currentPage = page
                totalPages = response.TotalPages
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func searchArticles(keyword: String, page: Int = 0, size: Int = 10)  async {
        
        guard !keyword.isEmpty else {
            await fetchArticles()
            return
        }
        
        await MainActor.run{
            isLoading = true
            errorMessage = nil
            searchKeyword = keyword
        }
        
        do {
            let encodedKeyword = keyword.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? keyword
            
            let queryParams = "?keyword=\(encodedKeyword)&page=\(page)&size=\(size)"
            
            let response: ArticlesResponse = try await NetworkManager.shared.request(endpoint: Constants.EndPoints.searchArticles + queryParams)
            
            await MainActor.run {
                if page == 0 {
                    articles = response.content
                }else {
                    articles.append(contentsOf: response.content)
                }
                currentPage = page
                totalPages = response.TotalPages
                isLoading = false
            }
        }
        catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func fetchMyArticles(page: Int = 0, size: Int = 10) async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let queryParams = "?page=\(page)&size=\(size)"
            
            let response: ArticlesResponse = try await NetworkManager.shared.request(
                endpoint: Constants.EndPoints.myArticles + queryParams
            )
            
            await MainActor.run {
                if page == 0 {
                    myArticles = response.content
                } else {
                    myArticles.append(contentsOf: response.content)
                }
                currentPage = page
                totalPages = response.TotalPages
                isLoading = false
            }
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
        }
    }
    
    func getArticle(id: Int) async -> Article? {
        do {
            let article: Article = try await NetworkManager.shared.request(
                endpoint: Constants.EndPoints.articles + "/\(id)"
            )
            return article
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
            }
            return nil
        }
    }
    
    func createArticle(title: String, content: String) async -> Bool {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            guard !title.isEmpty, !content.isEmpty else {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Title and content are required"
                }
                return false
            }
            
            let request = ArticleRequest(title: title, content: content)
            
            let article: Article = try await NetworkManager.shared.request(
                endpoint: Constants.EndPoints.articles,
                method: "POST",
                body: request
            )
            
            await MainActor.run {
                articles.insert(article, at: 0)
                myArticles.insert(article, at: 0)
                isLoading = false
            }
            
            return true
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    func updateArticle(id: Int, title: String, content: String) async -> Bool {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            guard !title.isEmpty, !content.isEmpty else {
                await MainActor.run {
                    isLoading = false
                    errorMessage = "Title and content are required"
                }
                return false
            }
            
            let request = ArticleRequest(title: title, content: content)
            
            let updatedArticle: Article = try await NetworkManager.shared.request(
                endpoint: Constants.EndPoints.articles + "/\(id)",
                method: "PUT",
                body: request
            )
            
            await MainActor.run {
                if let index = articles.firstIndex(where: { $0.id == id }) {
                    articles[index] = updatedArticle
                }
                if let index = myArticles.firstIndex(where: { $0.id == id }) {
                    myArticles[index] = updatedArticle
                }
                isLoading = false
            }
            
            return true
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    func deleteArticle(id: Int) async -> Bool {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }
        
        do {
            let _: MessageResponse = try await NetworkManager.shared.request(
                endpoint: Constants.EndPoints.articles + "/\(id)",
                method: "DELETE"
            )
            
            await MainActor.run {
                articles.removeAll { $0.id == id }
                myArticles.removeAll { $0.id == id }
                isLoading = false
            }
            
            return true
        } catch {
            await MainActor.run {
                isLoading = false
                errorMessage = error.localizedDescription
            }
            return false
        }
    }
    
    func clearSearch() async {
        await MainActor.run {
            searchKeyword = ""
        }
        await fetchArticles()
    }
}
