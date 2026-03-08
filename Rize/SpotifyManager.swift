//
//  SpotifyManager.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import Foundation
import Combine
import SpotifyiOS

class SpotifyManager: NSObject, ObservableObject {
    static let shared = SpotifyManager()
    
    private let clientID = "8a2f2309959e45af83179104c1e59f30"
    private let redirectURL = URL(string: "rize://spotify-callback")!
    
    @Published var isConnected = false
    @Published var userDisplayName = ""
    
    private var appRemote: SPTAppRemote?
    private var accessToken: String? {
        didSet {
            if let token = accessToken {
                UserDefaults.standard.set(token, forKey: "spotifyAccessToken")
            }
        }
    }
    
    override init() {
        super.init()
        accessToken = UserDefaults.standard.string(forKey: "spotifyAccessToken")
        setupAppRemote()
    }
    
    private func setupAppRemote() {
        let config = SPTConfiguration(clientID: clientID, redirectURL: redirectURL)
        appRemote = SPTAppRemote(configuration: config, logLevel: .debug)
        appRemote?.delegate = self
    }
    
    // MARK: - Connect to Spotify
    func connect() {
        guard let appRemote = appRemote else { return }
        
        if let token = accessToken {
            appRemote.connectionParameters.accessToken = token
            appRemote.connect()
        } else {
            appRemote.authorizeAndPlayURI("")
        }
    }
    
    // MARK: - Disconnect
    func disconnect() {
        appRemote?.disconnect()
        isConnected = false
        userDisplayName = ""
        accessToken = nil
        UserDefaults.standard.removeObject(forKey: "spotifyAccessToken")
    }
    
    // MARK: - Play a track by URI
    func playTrack(uri: String) {
        guard let appRemote = appRemote else { return }
        
        if appRemote.isConnected {
            appRemote.playerAPI?.play(uri, callback: { result, error in
                if let error = error {
                    print("Error playing track: \(error)")
                }
            })
        } else {
            appRemote.connectionParameters.accessToken = accessToken
            appRemote.connect()
            UserDefaults.standard.set(uri, forKey: "pendingSpotifyURI")
        }
    }
    
    // MARK: - Handle redirect from Spotify
    func handleURL(_ url: URL) {
        let parameters = appRemote?.authorizationParameters(from: url)
        if let token = parameters?[SPTAppRemoteAccessTokenKey] as? String {
            accessToken = token
            appRemote?.connectionParameters.accessToken = token
            appRemote?.connect()
        }
    }
    
    // MARK: - Search Tracks
    func searchTracks(query: String, completion: @escaping ([TrackResult]) -> Void) {
        guard let token = accessToken else {
            completion([])
            return
        }
        
        let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
        let urlString = "https://api.spotify.com/v1/search?q=\(encodedQuery)&type=track&limit=20"
        
        guard let url = URL(string: urlString) else {
            completion([])
            return
        }
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async { completion([]) }
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(SpotifySearchResponse.self, from: data)
                let results = decoded.tracks.items.map { item in
                    TrackResult(
                        id: item.id,
                        name: item.name,
                        artist: item.artists.first?.name ?? "Unknown Artist",
                        uri: item.uri,
                        albumName: item.album.name
                    )
                }
                DispatchQueue.main.async { completion(results) }
            } catch {
                print("Search decode error: \(error)")
                DispatchQueue.main.async { completion([]) }
            }
        }.resume()
    }
}

// MARK: - Search Playlists
func searchPlaylists(query: String, completion: @escaping ([PlaylistResult]) -> Void) {
    guard let token = accessToken else {
        completion([])
        return
    }
    
    let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
    let urlString = "https://api.spotify.com/v1/search?q=\(encodedQuery)&type=playlist&limit=20"
    
    guard let url = URL(string: urlString) else {
        completion([])
        return
    }
    
    var request = URLRequest(url: url)
    request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    
    URLSession.shared.dataTask(with: request) { data, response, error in
        guard let data = data else {
            DispatchQueue.main.async { completion([]) }
            return
        }
        
        do {
            let decoded = try JSONDecoder().decode(SpotifyPlaylistSearchResponse.self, from: data)
            let results = decoded.playlists.items.map { item in
                PlaylistResult(
                    id: item.id,
                    name: item.name,
                    description: item.description ?? "",
                    uri: item.uri,
                    trackCount: item.tracks?.total ?? 0
                )
            }
            DispatchQueue.main.async { completion(results) }
        } catch {
            print("Playlist search decode error: \(error)")
            DispatchQueue.main.async { completion([]) }
        }
    }.resume()
}

// MARK: - SPTAppRemoteDelegate
extension SpotifyManager: SPTAppRemoteDelegate {
    func appRemoteDidEstablishConnection(_ appRemote: SPTAppRemote) {
        isConnected = true
        print("Spotify connected ✅")
        
        if let pendingURI = UserDefaults.standard.string(forKey: "pendingSpotifyURI") {
            playTrack(uri: pendingURI)
            UserDefaults.standard.removeObject(forKey: "pendingSpotifyURI")
        }
        
        appRemote.userAPI?.fetchCurrentUser { result, error in
            if let user = result as? SPTAppRemoteUserDetails {
                DispatchQueue.main.async {
                    self.userDisplayName = user.displayName ?? ""
                }
            }
        }
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didDisconnectWithError error: Error?) {
        isConnected = false
        print("Spotify disconnected")
    }
    
    func appRemote(_ appRemote: SPTAppRemote, didFailConnectionAttemptWithError error: Error?) {
        isConnected = false
        print("Spotify connection failed: \(String(describing: error))")
    }
}
