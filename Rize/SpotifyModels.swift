//
//  SpotifyModels.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import Foundation

struct TrackResult: Identifiable, Codable {
    var id: String
    var name: String
    var artist: String
    var uri: String
    var albumName: String
}

// MARK: - Spotify Search Response Models
struct SpotifySearchResponse: Codable {
    let tracks: SpotifyTrackList
}

struct SpotifyTrackList: Codable {
    let items: [SpotifyTrack]
}

struct SpotifyTrack: Codable {
    let id: String
    let name: String
    let uri: String
    let artists: [SpotifyArtist]
    let album: SpotifyAlbum
}

struct SpotifyArtist: Codable {
    let name: String
}

struct SpotifyAlbum: Codable {
    let name: String
}
