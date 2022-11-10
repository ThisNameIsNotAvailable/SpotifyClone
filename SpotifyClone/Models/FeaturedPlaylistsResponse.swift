//
//  FeaturedPlaylistsResponse.swift
//  SpotifyClone
//
//  Created by Alex on 09/11/2022.
//

import Foundation

struct FeaturedPlaylistsResponse: Codable {
    let playlists: PlaylistResponse
}

struct PlaylistResponse: Codable {
    let items: [Playlist]
}
