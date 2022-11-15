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
    let available_markets: [String]
    let disc_number: Int
    let duration_ms: Int
    let explicit: Bool
    let external_urls: [String: String]
    let id: String
    let name: String
}

//{
//    album =                     {
//        "album_type" = album;
//        artists =                         (
//                                        {
//                "external_urls" =                                 {
//                    spotify = "https://open.spotify.com/artist/5K4W6rqBFWDnAN6FQUkS6x";
//                };
//                href = "https://api.spotify.com/v1/artists/5K4W6rqBFWDnAN6FQUkS6x";
//                id = 5K4W6rqBFWDnAN6FQUkS6x;
//                name = "Kanye West";
//                type = artist;
//                uri = "spotify:artist:5K4W6rqBFWDnAN6FQUkS6x";
//            }
//        );
//        "available_markets" =                         ;
//        "external_urls" =                         {
//            spotify = "https://open.spotify.com/album/20r762YmB5HeofjMCiPMLv";
//        };
//        href = "https://api.spotify.com/v1/albums/20r762YmB5HeofjMCiPMLv";
//        id = 20r762YmB5HeofjMCiPMLv;
//        images =                         (
//                                        {
//                height = 640;
//                url = "https://i.scdn.co/image/ab67616d0000b273d9194aa18fa4c9362b47464f";
//                width = 640;
//            },
//                                        {
//                height = 300;
//                url = "https://i.scdn.co/image/ab67616d00001e02d9194aa18fa4c9362b47464f";
//                width = 300;
//            },
//                                        {
//                height = 64;
//                url = "https://i.scdn.co/image/ab67616d00004851d9194aa18fa4c9362b47464f";
//                width = 64;
//            }
//        );
//        name = "My Beautiful Dark Twisted Fantasy";
//        "release_date" = "2010-11-22";
//        "release_date_precision" = day;
//        "total_tracks" = 13;
//        type = album;
//        uri = "spotify:album:20r762YmB5HeofjMCiPMLv";
//    };
//    artists =                     (
//                                {
//            "external_urls" =                             {
//                spotify = "https://open.spotify.com/artist/5K4W6rqBFWDnAN6FQUkS6x";
//            };
//            href = "https://api.spotify.com/v1/artists/5K4W6rqBFWDnAN6FQUkS6x";
//            id = 5K4W6rqBFWDnAN6FQUkS6x;
//            name = "Kanye West";
//            type = artist;
//            uri = "spotify:artist:5K4W6rqBFWDnAN6FQUkS6x";
//        },
//                                {
//            "external_urls" =                             {
//                spotify = "https://open.spotify.com/artist/0ONHkAv9pCAFxb0zJwDNTy";
//            };
//            href = "https://api.spotify.com/v1/artists/0ONHkAv9pCAFxb0zJwDNTy";
//            id = 0ONHkAv9pCAFxb0zJwDNTy;
//            name = "Pusha T";
//            type = artist;
//            uri = "spotify:artist:0ONHkAv9pCAFxb0zJwDNTy";
//        }
//    );
//    "available_markets" =                     ;
//    "disc_number" = 1;
//    "duration_ms" = 547733;
//    episode = 0;
//    explicit = 1;
//    "external_ids" =                     {
//        isrc = USUM71027402;
//    };
//    "external_urls" =                     {
//        spotify = "https://open.spotify.com/track/3DK6m7It6Pw857FcQftMds";
//    };
//    href = "https://api.spotify.com/v1/tracks/3DK6m7It6Pw857FcQftMds";
//    id = 3DK6m7It6Pw857FcQftMds;
//    "is_local" = 0;
//    name = Runaway;
//    popularity = 78;
//    "preview_url" = "<null>";
//    track = 1;
//    "track_number" = 9;
//    type = track;
//    uri = "spotify:track:3DK6m7It6Pw857FcQftMds";
//}
