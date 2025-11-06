import SwiftUI

struct ProfileView: View {
    @StateObject private var authManager = AuthManager.shared
    @State private var showLogoutAlert = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Constants.Colors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: Constants.UI.largePadding) {
                        VStack(spacing: Constants.UI.mediumPadding) {
                            Circle()
                                .fill(Constants.Colors.primary)
                                .frame(width: 100, height: 100)
                                .overlay(
                                    Text(String(authManager.currentUser?.name.prefix(1) ?? "U"))
                                        .font(.system(size: 40, weight: .bold))
                                        .foregroundColor(.white)
                                )
                            
                            Text(authManager.currentUser?.name ?? "User")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(Constants.Colors.textPrimary)
                            
                            Text(authManager.currentUser?.email ?? "")
                                .font(.subheadline)
                                .foregroundColor(Constants.Colors.textSecondary)
                        }
                        .padding(.top, 40)
                        
                        HStack(spacing: 0) {
                            StatView(
                                value: "\(ArticleManager.shared.myArticles.count)",
                                label: "Articles"
                            )
                            
                            Divider()
                                .frame(height: 50)
                                .background(Constants.Colors.divider)
                        
                            StatView(
                                value: "\(ArticleManager.shared.myArticles.reduce(0) { $0 + $1.viewCount })",
                                label: "Total Views"
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
                        
                        VStack(spacing: 0) {
                            SettingsRow(
                                icon: "person.fill",
                                title: "Account",
                                showChevron: true
                            ) {

                            }
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            SettingsRow(
                                icon: "bell.fill",
                                title: "Notifications",
                                showChevron: true
                            ) {

                            }
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            SettingsRow(
                                icon: "questionmark.circle.fill",
                                title: "Help & Support",
                                showChevron: true
                            ) {

                            }
                            
                            Divider()
                                .padding(.leading, 60)
                            
                            SettingsRow(
                                icon: "info.circle.fill",
                                title: "About",
                                showChevron: true
                            ) {

                            }
                        }
                        .background(Constants.Colors.cardBackground)
                        .cornerRadius(Constants.UI.cornerRadius)
                        .overlay(
                            RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                                .stroke(Constants.Colors.border, lineWidth: 1)
                        )
                        .padding(.horizontal)
                        
                        Button(action: { showLogoutAlert = true }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Logout")
                                    .fontWeight(.semibold)
                            }
                            .frame(maxWidth: .infinity)
                            .frame(height: Constants.UI.buttonHeight)
                            .foregroundColor(Constants.Colors.error)
                            .background(Constants.Colors.cardBackground)
                            .cornerRadius(Constants.UI.cornerRadius)
                            .overlay(
                                RoundedRectangle(cornerRadius: Constants.UI.cornerRadius)
                                    .stroke(Constants.Colors.error, lineWidth: 1)
                            )
                        }
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
            .alert("Logout", isPresented: $showLogoutAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Logout", role: .destructive) {
                    Task {
                        await authManager.logout()
                    }
                }
            } message: {
                Text("Are you sure you want to logout?")
            }
        }
    }
}

struct StatView: View {
    let value: String
    let label: String
    
    var body: some View {
        VStack(spacing: 8) {
            Text(value)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(Constants.Colors.primary)
            
            Text(label)
                .font(.caption)
                .foregroundColor(Constants.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SettingsRow: View {
    let icon: String
    let title: String
    let showChevron: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: Constants.UI.mediumPadding) {
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundColor(Constants.Colors.primary)
                    .frame(width: 30)
                
                Text(title)
                    .foregroundColor(Constants.Colors.textPrimary)
                
                Spacer()
                
                if showChevron {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(Constants.Colors.textTertiary)
                }
            }
            .padding()
        }
        .buttonStyle(PlainButtonStyle())
    }
}
