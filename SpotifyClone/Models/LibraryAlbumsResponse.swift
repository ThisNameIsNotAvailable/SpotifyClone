//
//  LibraryAlbumsResponse.swift
//  SpotifyClone
//
//  Created by Alex on 23/11/2022.
//

import Foundation

struct LibraryAlbumsResponse: Codable {
    let items: [UserAlbum]
}

struct UserAlbum: Codable {
    let album: Album
}
