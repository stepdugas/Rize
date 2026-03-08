//
//  SpotifyManager.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import Foundation
import Combine
import SpotifyiOS
import CommonCrypto

class SpotifyManager: NSObject, ObservableObject {
    static let shared = SpotifyManager()
    
    // MARK: - Properties
    private let clientID = "8a2f2309959e45af83179104c1e59f30"
    private let redirectURL = URL(string: "rize://spotify-callback")!
    private let scopes = [
        "user-read-recently-played",
        "user-read-playback-state",
        "user-modify-playback-state",
        "user-read-private",
        "playlist-read-private",
        "streaming"
    ]
    
    @Published var isConnected = false
    @Published var userDisplayName = ""
    @Published var isAuthenticating = false
    
    private var appRemote: SPTAppRemote?
    private var codeVerifier: String?
    
    // MARK: - Token Management
    var accessToken: String? {
        get { KeychainManager.shared.read(forKey: KeychainManager.Keys.accessToken) }
        set {
            if let token = newValue {
                KeychainManager.shared.save(token, forKey: KeychainManager.Keys.accessToken)
            } else {
                KeychainManager.shared.delete(forKey: KeychainManager.Keys.accessToken)
            }
        }
    }
    
    var refreshToken: String? {
        get { KeychainManager.shared.read(forKey: KeychainManager.Keys.refreshToken) }
        set {
            if let token = newValue {
                KeychainManager.shared.save(token, forKey: KeychainManager.Keys.refreshToken)
            } else {
                KeychainManager.shared.delete(forKey: KeychainManager.Keys.refreshToken)
            }
        }
    }
    
    var tokenExpiry: Date? {
        get {
            guard let str = KeychainManager.shared.read(forKey: KeychainManager.Keys.tokenExpiry),
                  let interval = Double(str) else { return nil }
            return Date(timeIntervalSince1970: interval)
        }
        set {
            if let date = newValue {
                KeychainManager.shared.save(
                    String(date.timeIntervalSince1970),
                    forKey: KeychainManager.Keys.tokenExpiry
                )
            } else {
                KeychainManager.shared.delete(forKey: KeychainManager.Keys.tokenExpiry)
            }
        }
    }
    
    var isTokenValid: Bool {
        guard let expiry = tokenExpiry, accessToken != nil else { return false }
        // Consider token expired 5 minutes early as safety buffer
        return Date() < expiry.addingTimeInterval(-300)
    }
    
    // MARK: - Init
    override init() {
        super.init()
        setupAppRemote()
        // If we have a valid token already, mark as connected
        if accessToken != nil {
            isConnected = true
        }
    }
    
    // MARK: - App Remote Setup
    private func setupAppRemote() {
        let config = SPTConfiguration(clientID: clientID, redirectURL: redirectURL)
        appRemote = SPTAppRemote(configuration: config, logLevel: .debug)
        appRemote?.delegate = self
    }
    
    // MARK: - PKCE Helpers
    private func generateCodeVerifier() -> String {
        var buffer = [UInt8](repeating: 0, count: 64)
        _ = SecRandomCopyBytes(kSecRandomDefault, buffer.count, &buffer)
        return Data(buffer).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
            .prefix(128)
            .description
    }
    
    private func generateCodeChallenge(from verifier: String) -> String {
        guard let data = verifier.data(using: .utf8) else { return "" }
        var buffer = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
        data.withUnsafeBytes {
            _ = CC_SHA256($0.baseAddress, CC_LONG(data.count), &buffer)
        }
        return Data(buffer).base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
    // MARK: - Connect / OAuth
    func connect() {
        let verifier = generateCodeVerifier()
        codeVerifier = verifier
        let challenge = generateCodeChallenge(from: verifier)
        let scopeString = scopes.joined(separator: "%20")
        
        var components = URLComponents(string: "https://accounts.spotify.com/authorize")!
        components.queryItems = [
            URLQueryItem(name: "client_id", value: clientID),
            URLQueryItem(name: "response_type", value: "code"),
            URLQueryItem(name: "redirect_uri", value: redirectURL.absoluteString),
            URLQueryItem(name: "code_challenge_method", value: "S256"),
            URLQueryItem(name: "code_challenge", value: challenge),
            URLQueryItem(name: "scope", value: scopes.joined(separator: " "))
        ]
        
        guard let url = components.url else { return }
        isAuthenticating = true
        UIApplication.shared.open(url)
    }
    
    // MARK: - Handle OAuth Callback
    func handleURL(_ url: URL) {
        // Handle App Remote callback
        if let parameters = appRemote?.authorizationParameters(from: url),
           let token = parameters[SPTAppRemoteAccessTokenKey] as? String {
            appRemote?.connectionParameters.accessToken = token
            appRemote?.connect()
            return
        }
        
        // Handle Web API OAuth callback
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let code = components.queryItems?.first(where: { $0.name == "code" })?.value,
              let verifier = codeVerifier else { return }
        
        exchangeCodeForToken(code: code, verifier: verifier)
    }
    
    // MARK: - Exchange Code for Token
    private func exchangeCodeForToken(code: String, verifier: String) {
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "client_id": clientID,
            "grant_type": "authorization_code",
            "code": code,
            "redirect_uri": redirectURL.absoluteString,
            "code_verifier": verifier
        ]
        .map { "\($0.key)=\($0.value)" }
        .joined(separator: "&")
        
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self, let data = data else { return }
            do {
                let response = try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
                DispatchQueue.main.async {
                    self.accessToken = response.access_token
                    self.refreshToken = response.refresh_token
                    self.tokenExpiry = Date().addingTimeInterval(Double(response.expires_in))
                    self.isConnected = true
                    self.isAuthenticating = false
                    self.connectAppRemote()
                    self.fetchUserProfile()
                }
            } catch {
                print("Token exchange error: \(error)")
                DispatchQueue.main.async { self.isAuthenticating = false }
            }
        }.resume()
    }
    
    // MARK: - Refresh Token
    func refreshAccessToken(completion: @escaping (Bool) -> Void) {
        guard let refresh = refreshToken,
              let url = URL(string: "https://accounts.spotify.com/api/token") else {
            completion(false)
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = [
            "client_id": clientID,
            "grant_type": "refresh_token",
            "refresh_token": refresh
        ]
        .map { "\($0.key)=\($0.value)" }
        .joined(separator: "&")
        
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let self = self, let data = data else {
                completion(false)
                return
            }
            do {
                let response = try JSONDecoder().decode(SpotifyTokenResponse.self, from: data)
                DispatchQueue.main.async {
                    self.accessToken = response.access_token
                    if let newRefresh = response.refresh_token {
                        self.refreshToken = newRefresh
                    }
                    self.tokenExpiry = Date().addingTimeInterval(Double(response.expires_in))
                    self.isConnected = true
                    completion(true)
                }
            } catch {
                print("Token refresh error: \(error)")
                completion(false)
            }
        }.resume()
    }
    
    // MARK: - Ensure Valid Token
    func ensureValidToken(completion: @escaping (String?) -> Void) {
        if isTokenValid, let token = accessToken {
            completion(token)
        } else {
            refreshAccessToken { [weak self] success in
                completion(success ? self?.accessToken : nil)
            }
        }
    }
    
    // MARK: - Connect App Remote
    private func connectAppRemote() {
        guard let token = accessToken else { return }
        appRemote?.connectionParameters.accessToken = token
        appRemote?.connect()
    }
    
    // MARK: - Fetch User Profile
    func fetchUserProfile() {
        ensureValidToken { [weak self] token in
            guard let token = token,
                  let url = URL(string: "https://api.spotify.com/v1/me") else { return }
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { data, _, _ in
                guard let data = data,
                      let profile = try? JSONDecoder().decode(SpotifyUserProfile.self, from: data) else { return }
                DispatchQueue.main.async {
                    self?.userDisplayName = profile.display_name ?? ""
                }
            }.resume()
        }
    }
    
    // MARK: - Disconnect
    func disconnect() {
        appRemote?.disconnect()
        isConnected = false
        userDisplayName = ""
        accessToken = nil
        refreshToken = nil
        tokenExpiry = nil
        codeVerifier = nil
    }
    
    // MARK: - Play Track
    func playTrack(uri: String) {
        ensureValidToken { [weak self] token in
            guard let self = self, token != nil else { return }
            if let appRemote = self.appRemote, appRemote.isConnected {
                appRemote.playerAPI?.play(uri, callback: { _, error in
                    if let error = error { print("Play error: \(error)") }
                })
            } else {
                self.connectAppRemote()
                UserDefaults.standard.set(uri, forKey: "pendingSpotifyURI")
            }
        }
    }
    
    // MARK: - Search Tracks
    func searchTracks(query: String, completion: @escaping ([TrackResult]) -> Void) {
        ensureValidToken { token in
            guard let token = token else { completion([]); return }
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            let urlString = "https://api.spotify.com/v1/search?q=\(encodedQuery)&type=track&limit=20"
            guard let url = URL(string: urlString) else { completion([]); return }
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { data, _, _ in
                guard let data = data else { DispatchQueue.main.async { completion([]) }; return }
                do {
                    let decoded = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
                    let results = decoded.tracks.items.map {
                        TrackResult(id: $0.id, name: $0.name,
                                   artist: $0.artists.first?.name ?? "Unknown",
                                   uri: $0.uri, albumName: $0.album.name)
                    }
                    DispatchQueue.main.async { completion(results) }
                } catch {
                    print("Search error: \(error)")
                    DispatchQueue.main.async { completion([]) }
                }
            }.resume()
        }
    }
    
    // MARK: - Search Playlists
    func searchPlaylists(query: String, completion: @escaping ([PlaylistResult]) -> Void) {
        ensureValidToken { token in
            guard let token = token else { completion([]); return }
            let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
            let urlString = "https://api.spotify.com/v1/search?q=\(encodedQuery)&type=playlist&limit=20"
            guard let url = URL(string: urlString) else { completion([]); return }
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { data, _, _ in
                guard let data = data else { DispatchQueue.main.async { completion([]) }; return }
                do {
                    let decoded = try JSONDecoder().decode(SpotifyPlaylistSearchResponse.self, from: data)
                    let results = decoded.playlists.items.map {
                        PlaylistResult(id: $0.id, name: $0.name,
                                      description: $0.description ?? "",
                                      uri: $0.uri, trackCount: $0.tracks?.total ?? 0)
                    }
                    DispatchQueue.main.async { completion(results) }
                } catch {
                    print("Playlist error: \(error)")
                    DispatchQueue.main.async { completion([]) }
                }
            }.resume()
        }
    }
    
    // MARK: - Recently Played Tracks
    func fetchRecentlyPlayedTracks(completion: @escaping ([TrackResult]) -> Void) {
        ensureValidToken { token in
            guard let token = token,
                  let url = URL(string: "https://api.spotify.com/v1/me/player/recently-played?limit=20") else {
                completion([])
                return
            }
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { data, _, _ in
                guard let data = data else { DispatchQueue.main.async { completion([]) }; return }
                do {
                    let decoded = try JSONDecoder().decode(SpotifyRecentlyPlayedResponse.self, from: data)
                    let results = decoded.items.map {
                        TrackResult(id: $0.track.id, name: $0.track.name,
                                   artist: $0.track.artists.first?.name ?? "Unknown",
                                   uri: $0.track.uri, albumName: $0.track.album.name)
                    }
                    DispatchQueue.main.async { completion(results) }
                } catch {
                    print("Recently played error: \(error)")
                    DispatchQueue.main.async { completion([]) }
                }
            }.resume()
        }
    }
    
    // MARK: - Recently Played Playlists
    func fetchUserPlaylists(completion: @escaping ([PlaylistResult]) -> Void) {
        ensureValidToken { token in
            guard let token = token,
                  let url = URL(string: "https://api.spotify.com/v1/me/playlists?limit=20") else {
                completion([])
                return
            }
            var request = URLRequest(url: url)
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            URLSession.shared.dataTask(with: request) { data, _, _ in
                guard let data = data else { DispatchQueue.main.async { completion([]) }; return }
                do {
                    let decoded = try JSONDecoder().decode(SpotifyPlaylistSearchResponse.self, from: data)
                    let results = decoded.playlists.items.map {
                        PlaylistResult(id: $0.id, name: $0.name,
                                      description: $0.description ?? "",
                                      uri: $0.uri, trackCount: $0.tracks?.total ?? 0)
                    }
                    DispatchQueue.main.async { completion(results) }
                } catch {
                    print("User playlists error: \(error)")
                    DispatchQueue.main.async { completion([]) }
                }
            }.resume()
        }
    }
}

// MARK: - SPTAppRemoteDelegate
extension SpotifyManager: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        isConnected = true
        print("Spotify App Remote connected ✅")
        if let pendingURI = UserDefaults.standard.string(forKey: "pendingSpotifyURI") {
            playTrack(uri: pendingURI)
            UserDefaults.standard.removeObject(forKey: "pendingSpotifyURI")
        }
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        print("Spotify App Remote disconnected")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        print("Spotify App Remote connection failed: \(String(describing: error))")
    }
}
