//
//  AudioTrack.swift
//  SpotifyClone
//
//  Created by Alex on 06/11/2022.
//

import Foundation

struct AudioTrack: Codable {
    let album: Album?
    let artists: [Artist]
    let available_markets: [String]?
    let duration_ms: Int
    let explicit: Bool
    let external_urls: [String: String]
    let id: String
    let name: String
}
