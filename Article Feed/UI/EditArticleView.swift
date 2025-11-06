import SwiftUI

struct EditArticleView: View {
    let article: Article
    @StateObject private var articleManager = ArticleManager.shared
    @Environment(\.dismiss) private var dismiss
    
    @State private var title: String
    @State private var content: String
    
    @State private var showSuccessAlert = false
    @FocusState private var focusedField: Field?
    
    enum Field {
        case title, content
    }
    
    init(article: Article) {
        self.article = article
        _title = State(initialValue: article.title)
        _content = State(initialValue: article.content)
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
                            title: "Update Article",
                            isLoading: articleManager.isLoading
                        ) {
                            Task {
                                await updateArticle()
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Edit Article")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Constants.Colors.primary)
                }
                
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        focusedField = nil
                    }
                }
            }
            .alert("Success", isPresented: $showSuccessAlert) {
                Button("OK") {
                    dismiss()
                }
            } message: {
                Text("Your article has been updated successfully!")
            }
        }
    }
    
    private func updateArticle() async {
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
        
        let success = await articleManager.updateArticle(id: article.id, title: title, content: content)
        
        if success {
            showSuccessAlert = true
        }
    }
}
