//
//  NotificationService.swift
//  RizeNotificationService
//
//  Created by Stephanie Dugas on 3/8/26.
//

import UserNotifications

class NotificationService: UNNotificationServiceExtension {
    
    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
    
    override func didReceive(_ request: UNNotificationRequest,
                             withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        
        guard let bestAttemptContent = bestAttemptContent else {
            contentHandler(request.content)
            return
        }
        
        // Get the song URI from notification payload
        let songURI = request.content.userInfo["songURI"] as? String ?? ""
        
        // Read tokens from shared Keychain
        let accessToken = KeychainManager.shared.read(forKey: KeychainManager.Keys.accessToken)
        let refreshToken = KeychainManager.shared.read(forKey: KeychainManager.Keys.refreshToken)
        let expiryString = KeychainManager.shared.read(forKey: KeychainManager.Keys.tokenExpiry)
        
        // Check if token is still valid
        var tokenValid = false
        if let expiryString = expiryString,
           let interval = Double(expiryString) {
            let expiry = Date(timeIntervalSince1970: interval)
            tokenValid = Date() < expiry.addingTimeInterval(-300)
        }
        
        if tokenValid, let token = accessToken, !songURI.isEmpty {
            // Token is valid — play the song
            playSpotifyTrack(uri: songURI, token: token) {
                contentHandler(bestAttemptContent)
            }
        } else if let refresh = refreshToken, !songURI.isEmpty {
            // Token expired — refresh it first then play
            refreshAndPlay(refreshToken: refresh, songURI: songURI) {
                contentHandler(bestAttemptContent)
            }
        } else {
            // No token or no song — just fire the notification
            contentHandler(bestAttemptContent)
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // iOS is giving up — fire the notification as-is
        if let contentHandler = contentHandler,
           let bestAttemptContent = bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }
    
    // MARK: - Play Track
    private func playSpotifyTrack(uri: String, token: String, completion: @escaping () -> Void) {
        guard let url = URL(string: "https://api.spotify.com/v1/me/player/play") else {
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body = ["uris": [uri]]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { _, response, error in
            if let error = error {
                print("Playback error: \(error)")
            }
            completion()
        }.resume()
    }
    
    // MARK: - Refresh Token Then Play
    private func refreshAndPlay(refreshToken: String, songURI: String, completion: @escaping () -> Void) {
        let clientID = "8a2f2309959e45af83179104c1e59f30"
        guard let url = URL(string: "https://accounts.spotify.com/api/token") else {
            completion()
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        let body = "client_id=\(clientID)&grant_type=refresh_token&refresh_token=\(refreshToken)"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, _, error in
            guard let data = data,
                  let response = try? JSONDecoder().decode(SpotifyTokenResponse.self, from: data) else {
                completion()
                return
            }
            
            // Save new token to Keychain
            KeychainManager.shared.save(response.access_token,
                                       forKey: KeychainManager.Keys.accessToken)
            let expiry = Date().addingTimeInterval(Double(response.expires_in))
            KeychainManager.shared.save(String(expiry.timeIntervalSince1970),
                                       forKey: KeychainManager.Keys.tokenExpiry)
            if let newRefresh = response.refresh_token {
                KeychainManager.shared.save(newRefresh,
                                           forKey: KeychainManager.Keys.refreshToken)
            }
            
            // Now play the track
            self?.playSpotifyTrack(uri: songURI, token: response.access_token, completion: completion)
        }.resume()
    }
}
