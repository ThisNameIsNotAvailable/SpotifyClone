//
//  SearchResult.swift
//  SpotifyClone
//
//  Created by Alex on 15/11/2022.
//

import Foundation

enum SearchResult {
    case artist(model: Artist)
    case album(model: Album)
    case track(model: AudioTrack)
    case playlist(model: Playlist)
}
