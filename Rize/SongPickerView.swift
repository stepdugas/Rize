//
//  SongPickerView.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/7/26.
//

import SwiftUI

struct SongPickerView: View {
    @Environment(\.dismiss) var dismiss
    var onSongSelected: (TrackResult) -> Void
    
    @State private var searchText = ""
    @State private var searchResults: [TrackResult] = []
    @State private var recentlyPlayed: [TrackResult] = []
    @State private var isSearching = false
    @State private var isLoadingRecent = false
    
    var isShowingRecent: Bool {
        searchText.isEmpty && !recentlyPlayed.isEmpty
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Header
                HStack {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.gray)
                    
                    Spacer()
                    
                    Text("Pick a Song")
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Button("Cancel") {}
                        .foregroundColor(.clear)
                        .disabled(true)
                }
                .padding(.horizontal)
                .padding(.top)
                
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    TextField("Search songs, artists...", text: $searchText)
                        .foregroundColor(.white)
                        .onSubmit {
                            searchSpotify()
                        }
                    if !searchText.isEmpty {
                        Button(action: {
                            searchText = ""
                            searchResults = []
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding()
                .background(Color(white: 0.1))
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 16)
                
                if isSearching || isLoadingRecent {
                    Spacer()
                    ProgressView()
                        .tint(Color(red: 0.0, green: 0.9, blue: 0.4))
                    Spacer()
                } else if !searchText.isEmpty && searchResults.isEmpty {
                    Spacer()
                    Text("No results found")
                        .foregroundColor(.gray)
                        .italic()
                    Spacer()
                } else if searchText.isEmpty && recentlyPlayed.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "music.note")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Search for a song")
                            .foregroundColor(.gray)
                            .italic()
                        Text("Type an artist or song name above")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.6))
                    }
                    Spacer()
                } else {
                    // Section header
                    HStack {
                        Text(isShowingRecent ? "RECENTLY PLAYED" : "RESULTS")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 4)
                    
                    List(isShowingRecent ? recentlyPlayed : searchResults) { track in
                        Button(action: {
                            onSongSelected(track)
                            dismiss()
                        }) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(white: 0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "music.note")
                                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                                }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(track.name)
                                        .foregroundColor(.white)
                                        .font(.system(size: 15, weight: .medium))
                                        .lineLimit(1)
                                    Text(track.artist)
                                        .foregroundColor(.gray)
                                        .font(.system(size: 13))
                                        .lineLimit(1)
                                    Text(track.albumName)
                                        .foregroundColor(.gray.opacity(0.6))
                                        .font(.system(size: 12))
                                        .lineLimit(1)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "plus.circle")
                                    .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                            }
                            .padding(.vertical, 4)
                        }
                        .listRowBackground(Color(white: 0.08))
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .padding(.top, 4)
                }
            }
        }
        .onAppear {
            loadRecentlyPlayed()
        }
    }
    
    func loadRecentlyPlayed() {
        isLoadingRecent = true
        SpotifyManager.shared.fetchRecentlyPlayedTracks { tracks in
            isLoadingRecent = false
            recentlyPlayed = tracks
        }
    }
    
    func searchSpotify() {
        guard !searchText.isEmpty else { return }
        isSearching = true
        SpotifyManager.shared.searchTracks(query: searchText) { results in
            isSearching = false
            searchResults = results
        }
    }
}
