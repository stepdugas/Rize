//
//  SpotifyModels.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import Foundation

struct TrackResult: Identifiable, Codable, Sendable {
    var id: String
    var name: String
    var artist: String
    var uri: String
    var albumName: String
}

struct SpotifySearchResponse: Codable, Sendable {
    let tracks: SpotifyTrackList
}

struct SpotifyTrackList: Codable, Sendable {
    let items: [SpotifyTrack]
}

struct SpotifyTrack: Codable, Sendable {
    let id: String
    let name: String
    let uri: String
    let artists: [SpotifyArtist]
    let album: SpotifyAlbum
}

struct SpotifyArtist: Codable, Sendable {
    let name: String
}

struct SpotifyAlbum: Codable, Sendable {
    let name: String
}

struct PlaylistResult: Identifiable, Codable, Sendable {
    var id: String
    var name: String
    var description: String
    var uri: String
    var trackCount: Int
}

struct SpotifyPlaylistSearchResponse: Codable, Sendable {
    let playlists: SpotifyPlaylistList
}

struct SpotifyPlaylistList: Codable, Sendable {
    let items: [SpotifyPlaylist]
}

struct SpotifyPlaylist: Codable, Sendable {
    let id: String
    let name: String
    let description: String?
    let uri: String
    let tracks: SpotifyPlaylistTracks?
}

struct SpotifyPlaylistTracks: Codable, Sendable {
    let total: Int
}
