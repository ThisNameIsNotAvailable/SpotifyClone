//
//  RecommendationsResponse.swift
//  SpotifyClone
//
//  Created by Alex on 09/11/2022.
//

import Foundation

struct RecommendationsResponse: Codable {
    let tracks: [AudioTrack]
}
