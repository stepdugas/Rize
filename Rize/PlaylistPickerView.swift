//
//  PlaylistPickerView.swift
//  Rize
//
//  Created by Stephanie Dugas on 3/8/26.
//

import SwiftUI

struct PlaylistPickerView: View {
    @Environment(\.dismiss) var dismiss
    var onPlaylistSelected: (PlaylistResult) -> Void
    
    @State private var searchText = ""
    @State private var searchResults: [PlaylistResult] = []
    @State private var userPlaylists: [PlaylistResult] = []
    @State private var isSearching = false
    @State private var isLoadingPlaylists = false
    
    var isShowingUserPlaylists: Bool {
        searchText.isEmpty && !userPlaylists.isEmpty
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
                    
                    Text("Pick a Playlist")
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
                    TextField("Search playlists...", text: $searchText)
                        .foregroundColor(.white)
                        .onSubmit {
                            searchPlaylists()
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
                
                if isSearching || isLoadingPlaylists {
                    Spacer()
                    ProgressView()
                        .tint(Color(red: 0.0, green: 0.9, blue: 0.4))
                    Spacer()
                } else if !searchText.isEmpty && searchResults.isEmpty {
                    Spacer()
                    Text("No playlists found")
                        .foregroundColor(.gray)
                        .italic()
                    Spacer()
                } else if searchText.isEmpty && userPlaylists.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "music.note.list")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Search for a playlist")
                            .foregroundColor(.gray)
                            .italic()
                        Text("Type a playlist name above")
                            .font(.system(size: 14))
                            .foregroundColor(.gray.opacity(0.6))
                    }
                    Spacer()
                } else {
                    // Section header
                    HStack {
                        Text(isShowingUserPlaylists ? "YOUR PLAYLISTS" : "RESULTS")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundColor(.gray)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 4)
                    
                    List(isShowingUserPlaylists ? userPlaylists : searchResults) { playlist in
                        Button(action: {
                            onPlaylistSelected(playlist)
                            dismiss()
                        }) {
                            HStack(spacing: 12) {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color(white: 0.15))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: "music.note.list")
                                        .foregroundColor(Color(red: 0.0, green: 0.9, blue: 0.4))
                                }
                                
                                VStack(alignment: .leading, spacing: 3) {
                                    Text(playlist.name)
                                        .foregroundColor(.white)
                                        .font(.system(size: 15, weight: .medium))
                                        .lineLimit(1)
                                    if !playlist.description.isEmpty {
                                        Text(playlist.description)
                                            .foregroundColor(.gray)
                                            .font(.system(size: 12))
                                            .lineLimit(1)
                                    }
                                    Text("\(playlist.trackCount) songs")
                                        .foregroundColor(.gray.opacity(0.6))
                                        .font(.system(size: 12))
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
            loadUserPlaylists()
        }
    }
    
    func loadUserPlaylists() {
        isLoadingPlaylists = true
        SpotifyManager.shared.fetchUserPlaylists { playlists in
            isLoadingPlaylists = false
            userPlaylists = playlists
        }
    }
    
    func searchPlaylists() {
        guard !searchText.isEmpty else { return }
        isSearching = true
        SpotifyManager.shared.searchPlaylists(query: searchText) { results in
            isSearching = false
            searchResults = results
        }
    }
}
