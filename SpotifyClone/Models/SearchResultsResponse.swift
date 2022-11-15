//
//  SearchResultsResponse.swift
//  SpotifyClone
//
//  Created by Alex on 15/11/2022.
//

import Foundation

struct SearchResultsResponse: Codable {
    let albums: AlbumsResponse
    let artists: SearchArtistsResponse
    let playlists: PlaylistResponse
    let tracks: TracksResponse
}

struct SearchArtistsResponse: Codable {
    let items: [Artist]
}
