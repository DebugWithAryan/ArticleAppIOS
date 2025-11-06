//
//  MainTabView.swift
//  Article Feed
//
//  Created by Aryan Jaiswal on 05/11/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab)
        {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
                .tag(0)
            
            SearchView()
                .tabItem {
                    Label("Search", systemImage: "magnifyingglass")
                }
                .tag(1)
            
            CreateArticleView()
                .tabItem {
                    Label("Create", systemImage: "plus.square.fill")
                }
                .tag(2)
            
            MyArticlesView()
                .tabItem {
                    Label("My Articles", systemImage: "doc.text.fill")
                }
                .tag(3)
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person.fill")
                }
                .tag(4)
        }
        .accentColor(Constants.Colors.primary)
    }
}


import SwiftUI

struct HomeView: View {
    
    @StateObject private var articleManager = ArticleManager.shared
    @State private var selectedArticle: Article?
    @State private var showArticleDetail = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()
                
                if articleManager.isLoading && articleManager.articles.isEmpty {
                    LoadingView()
                }else if articleManager.articles.isEmpty {
                    EmptyStateView(
                        icon: "doc.text",
                        title: "No Articles Yet",
                        subtitle: "Be the first to create an article!",
                        actionTitle: "Create Article",
                        action: {
                        }
                    )
                }else {
                    ScrollView {
                        LazyVStack(spacing: Constants.UI.mediumPadding) {
                            ForEach(articleManager.articles) { article in
                                ArticleCard(article: article) {
                                    selectedArticle = article
                                    showArticleDetail = true
                                }
                                .padding(.horizontal)
                                
                                if article.id == articleManager.articles.last?.id {
                                    if articleManager.currentPage < articleManager.totalPages - 1 {
                                        ProgressView()
                                            .onAppear {
                                                Task {
                                                    await articleManager.fetchArticles(
                                                        page: articleManager.currentPage + 1
                                                    )
                                                }
                                            }
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        await articleManager.fetchArticles()
                    }
                }
            }
            .navigationTitle("Articles")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
            }
            .onAppear {
                if articleManager.articles.isEmpty {
                    Task {
                        await articleManager.fetchArticles()
                    }
                }
            }
        }
    }
}

import SwiftUI

struct SearchView: View {
    @StateObject private var articleManager = ArticleManager.shared
    @State private var searchText = ""
    @State private var selectedArticle: Article?
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(Constants.Colors.textSecondary)
                        
                        TextField("Search articles...", text: $searchText)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .onSubmit {
                                performSearch()
                            }
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                                Task {
                                    await articleManager.clearSearch()
                                }
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(Constants.Colors.textSecondary)
                            }
                        }
                    }
                    .padding()
                    .background(Constants.Colors.cardBackground)
                    .cornerRadius(Constants.UI.cornerRadius)
                    .padding()
                    
                    if articleManager.isLoading && articleManager.articles.isEmpty {
                        LoadingView()
                    } else if searchText.isEmpty {
                        EmptyStateView(
                            icon: "magnifyingglass",
                            title: "Search Articles",
                            subtitle: "Enter a keyword to find articles",
                            actionTitle: nil,
                            action: nil
                        )
                    } else if articleManager.articles.isEmpty {
                        EmptyStateView(
                            icon: "doc.text.magnifyingglass",
                            title: "No Results",
                            subtitle: "No articles found for '\(searchText)'",
                            actionTitle: nil,
                            action: nil
                        )
                    } else {
                        ScrollView {
                            LazyVStack(spacing: Constants.UI.mediumPadding) {
                                ForEach(articleManager.articles) { article in
                                    ArticleCard(article: article) {
                                        selectedArticle = article
                                    }
                                    .padding(.horizontal)
                                }
                            }
                            .padding(.vertical)
                        }
                    }
                }
            }
            .navigationTitle("Search")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
            }
        }
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        Task {
            await articleManager.searchArticles(keyword: searchText)
        }
    }
}


import SwiftUI

struct ArticleDetailView: View {
    let article: Article
    @Environment(\.dismiss) private var dismiss
    @StateObject private var articleManager = ArticleManager.shared
    @StateObject private var authManager = AuthManager.shared
    
    @State private var showEditSheet = false
    @State private var showDeleteAlert = false
    
    private var isAuthor: Bool {
        authManager.currentUser?.id == article.authorId
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(alignment: .leading, spacing: Constants.UI.largePadding) {
                        Text(article.title)
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Constants.Colors.textPrimary)
                        
                        HStack {
                            HStack(spacing: 8) {
                                Image(systemName: "person.circle.fill")
                                    .foregroundColor(Constants.Colors.primary)
                                Text(article.authorName)
                                    .foregroundColor(Constants.Colors.textSecondary)
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 4) {
                                Image(systemName: "eye.fill")
                                    .foregroundColor(Constants.Colors.textSecondary)
                                Text("\(article.viewCount)")
                                    .foregroundColor(Constants.Colors.textSecondary)
                            }
                        }
                        .font(.subheadline)
                        
                        Text(article.formattedCreatedAt)
                            .font(.caption)
                            .foregroundColor(Constants.Colors.textTertiary)
                        
                        Divider()
                            .background(Constants.Colors.divider)
                        
                        Text(article.content)
                            .font(.body)
                            .foregroundColor(Constants.Colors.textPrimary)
                            .lineSpacing(8)
                    }
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(Constants.Colors.primary)
                }
                
                if isAuthor {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button(action: { showEditSheet = true }) {
                                Label("Edit", systemImage: "pencil")
                            }
                            
                            Button(role: .destructive, action: { showDeleteAlert = true }) {
                                Label("Delete", systemImage: "trash")
                            }
                        } label: {
                            Image(systemName: "ellipsis.circle")
                                .foregroundColor(Constants.Colors.primary)
                        }
                    }
                }
            }
            .sheet(isPresented: $showEditSheet) {
                EditArticleView(article: article)
            }
            .alert("Delete Article", isPresented: $showDeleteAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Delete", role: .destructive) {
                    Task {
                        let success = await articleManager.deleteArticle(id: article.id)
                        if success {
                            dismiss()
                        }
                    }
                }
            } message: {
                Text("Are you sure you want to delete this article? This action cannot be undone.")
            }
        }
    }
}


import SwiftUI

struct CreateArticleView: View {
    @StateObject private var articleManager = ArticleManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var title = ""
    @State private var content = ""
    
    @State private var showSuccessAlert = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, content
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Constants.UI.largePadding) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Title")
                                .font(.headline)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            TextField("Enter article title...", text: $title)
                                .padding()
                                .background(Constants.Colors.cardBackground)
                                .cornerRadius(Constants.UI.cornerRadius)
                                .foregroundColor(Constants.Colors.textPrimary)
                                .focused($focusedField, equals: .title)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                                        .stroke(Constants.Colors.border, lineWidth: 1)
                                )
                            
                            HStack {
                                Spacer()
                                Text("\(title.count)/200")
                                    .font(.caption)
                                    .foregroundColor(title.count > 200 ? Constants.Colors.error : Constants.Colors.textTertiary)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Content")
                                .font(.headline)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            TextEditor(text: $content)
                                .frame(minHeight: 300)
                                .padding()
                                .background(Constants.Colors.cardBackground)
                                .cornerRadius(Constants.UI.cornerRadius)
                                .foregroundColor(Constants.Colors.textPrimary)
                                .focused($focusedField, equals: .content)
                                .overlay(
                                    RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                                        .stroke(Constants.Colors.border, lineWidth: 1)
                                )
                            
                            HStack {
                                Spacer()
                                Text("\(content.count) characters")
                                    .font(.caption)
                                    .foregroundColor(Constants.Colors.textTertiary)
                            }
                        }
                        
                        if let error = articleManager.errorMessage {
                            Text(error)
                                .font(.caption)
                                .foregroundColor(Constants.Colors.error)
                                .multilineTextAlignment(.center)
                        }
                        
                        PrimaryButton(
                            title: "Publish Article",
                            isLoading: articleManager.isLoading
                        ) {
                            Task {
                                await createArticle()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("New Article")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK") {
                    title = ""
                    content = ""
                }
            } message: {
                Text("Your article has been published successfully!")
            }
        }
    }
    
    private func createArticle() async {
        guard !title.isEmpty else {
            articleManager.errorMessage = "Title is required"
            return
        }
        
        guard title.count >= 5 && title.count <= 200 else {
            articleManager.errorMessage = "Title must be between 5 and 200 characters"
            return
        }
        
        guard !content.isEmpty else {
            articleManager.errorMessage = "Content is required"
            return
        }
        
        guard content.count >= 10 else {
            articleManager.errorMessage = "Content must be at least 10 characters"
            return
        }
        
        let success = await articleManager.createArticle(title: title, content: content)
        
        if success {
            showSuccessAlert = true
        }
    }
}
