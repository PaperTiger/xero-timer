import Foundation
import OAuthSwift
import CryptoKit
import AppKit

public class XeroAuthManager: ObservableObject {
    public static let shared: XeroAuthManager = {
        let instance = XeroAuthManager()
        return instance
    }()
    
    @Published public private(set) var isAuthenticated = false
    private var oauthSwift: OAuth2Swift?
    private var credentials: OAuthSwiftCredential?
    
    private let clientId = "4B3D7199295741A68991DEE8EED5D0B4"
    private let clientSecret = "YOUR_CLIENT_SECRET"
    private let vercelRedirectUrl = "https://v0-mkdir-xero-redirect.vercel.app"
    
    private init() {
        loadCredentials()
    }
    
    public func authenticate() async throws {
        // Construct the URL with all necessary parameters
        var components = URLComponents(string: vercelRedirectUrl)!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientId),
            URLQueryItem(name: "redirect_uri", value: "xerotimer://oauth/callback"),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "scope", value: "openid profile email offline_access accounting.transactions accounting.settings accounting.contacts projects.read.all projects.read projects.write timesheets.read timesheets.write")
        ]
        
        if let url = components.url {
            print("Opening URL: \(url)") // Debug print
            DispatchQueue.main.async {
                NSWorkspace.shared.open(url)
            }
        }
    }
    
    public func signOut() {
        isAuthenticated = false
        credentials = nil
        oauthSwift = nil
        UserDefaults.standard.removeObject(forKey: "xeroCredentials")
    }
    
    public func handleCallback(url: URL) {
        print("Handling callback URL: \(url)") // Debug print
        
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else {
            print("Invalid URL")
            return
        }
        
        // Extract tokens from query parameters
        if let accessToken = queryItems.first(where: { $0.name == "access_token" })?.value,
           let refreshToken = queryItems.first(where: { $0.name == "refresh_token" })?.value,
           let expiresInStr = queryItems.first(where: { $0.name == "expires_in" })?.value,
           let expiresIn = Double(expiresInStr) {
            
            print("Received tokens successfully") // Debug print
            
            let credential = OAuthSwiftCredential(
                consumerKey: clientId,
                consumerSecret: clientSecret
            )
            
            credential.oauthToken = accessToken
            credential.oauthRefreshToken = refreshToken
            credential.oauthTokenExpiresAt = Date(timeIntervalSinceNow: expiresIn)
            
            DispatchQueue.main.async { [weak self] in
                self?.credentials = credential
                self?.saveCredentials(credential)
                self?.isAuthenticated = true
                
                // Bring app to front after successful authentication
                NSApplication.shared.activate(ignoringOtherApps: true)
            }
        }
    }
    
    private func saveCredentials(_ credential: OAuthSwiftCredential) {
        if let data = try? JSONEncoder().encode(credential) {
            UserDefaults.standard.set(data, forKey: "xeroCredentials")
        }
    }
    
    private func loadCredentials() {
        guard let data = UserDefaults.standard.data(forKey: "xeroCredentials"),
              let credential = try? JSONDecoder().decode(OAuthSwiftCredential.self, from: data)
        else { return }
        
        credentials = credential
        
        if let expirationDate = credential.oauthTokenExpiresAt, expirationDate > Date() {
            isAuthenticated = true
        } else {
            refreshToken()
        }
    }
    
    private func refreshToken() {
        guard let refreshToken = credentials?.oauthRefreshToken else {
            isAuthenticated = false
            return
        }
        
        oauthSwift?.renewAccessToken(
            withRefreshToken: refreshToken
        ) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let (credential, _, _)):
                self.credentials = credential
                self.saveCredentials(credential)
                self.isAuthenticated = true
            case .failure:
                self.isAuthenticated = false
                self.credentials = nil
            }
        }
    }
}

extension XeroAuthManager {
    static func createForPreview() -> XeroAuthManager {
        let manager = XeroAuthManager()
        manager.isAuthenticated = true
        return manager
    }
} 