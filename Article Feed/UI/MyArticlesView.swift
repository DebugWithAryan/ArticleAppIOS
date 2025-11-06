import SwiftUI

struct MyArticlesView: View {
    @StateObject private var articleManager = ArticleManager.shared
    @State private var selectedArticle: Article?
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()
                
                if articleManager.isLoading && articleManager.myArticles.isEmpty {
                    LoadingView()
                } else if articleManager.myArticles.isEmpty {
                    EmptyStateView(
                        icon: "doc.text",
                        title: "No Articles Yet",
                        subtitle: "Start writing your first article!",
                        actionTitle: "Create Article",
                        action: {
                            
                        }
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: Constants.UI.mediumPadding) {
                            ForEach(articleManager.myArticles) { article in
                                ArticleCard(article: article) {
                                    selectedArticle = article
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding(.vertical)
                    }
                    .refreshable {
                        await articleManager.fetchMyArticles()
                    }
                }
            }
            .navigationTitle("My Articles")
            .navigationBarTitleDisplayMode(.large)
            .sheet(item: $selectedArticle) { article in
                ArticleDetailView(article: article)
            }
            .onAppear {
                if articleManager.myArticles.isEmpty {
                    Task {
                        await articleManager.fetchMyArticles()
                    }
                }
            }
        }
    }
}
