//
//  APICaller.swift
//  SpotifyClone
//
//  Created by Alex on 06/11/2022.
//

import Foundation

final class APICaller {
    static let shared = APICaller()
    
    private init() {}
    
    struct Constants {
        static let baseAPIURL = "https://api.spotify.com/v1"
    }
    
    enum APIError: Error {
        case failedToGetData
    }
    
    enum HTTPMethod: String {
        case GET
        case POST
    }
    
    //MARK: - Artist
    
    public func getAlbums(of artist: Artist, completion: @escaping (Result<AlbumsResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/artists/\(artist.id)/albums?include_groups=album&limit=10"), type: .GET) { [weak self] request in
            self?.performRequest(with: request, of: AlbumsResponse.self, completion: completion)
        }
    }
    
    public func getPopularTracks(of artist: Artist, completion: @escaping (Result<RecommendationsResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/artists/\(artist.id)/top-tracks?market=US"), type: .GET) { [weak self] request in
            self?.performRequest(with: request, of: RecommendationsResponse.self, completion: completion)
        }
    }
    
    public func getRelatedArtists(to artist: Artist, completion: @escaping (Result<RelatedArtistsResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/artists/\(artist.id)/related-artists"), type: .GET) { [weak self] request in
            self?.performRequest(with: request, of: RelatedArtistsResponse.self, completion: completion)
        }
    }
    
    //MARK: - Category
    
    public func getAllCategories(completion: @escaping (Result<AllCategoriesResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/categories?limit=30"), type: .GET) { [weak self] request in
            self?.performRequest(with: request, of: AllCategoriesResponse.self, completion: completion)
        }
    }
    
    public func getCategoryPlaylist(category: Category, completion: @escaping (Result<FeaturedPlaylistsResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/categories/\(category.id)/playlists?limit=30"), type: .GET) { [weak self] request in
            self?.performRequest(with: request, of: FeaturedPlaylistsResponse.self, completion: completion)
        }
    }
    
    //MARK: - Albums
    
    public func getAlbumDetails(for album: Album, completion: @escaping  (Result<AlbumDetailsResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/albums/" + album.id), type: .GET) { [weak self] request in
            self?.performRequest(with: request, of: AlbumDetailsResponse.self, completion: completion)
        }
    }
    
    //MARK: - Playlists
    
    public func getPlaylistDetails(for playlist: Playlist, completion: @escaping  (Result<PlaylistDetailsResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/playlists/" + playlist.id), type: .GET) { [weak self] request in
            self?.performRequest(with: request, of: PlaylistDetailsResponse.self, completion: completion)
        }
    }
    
    public func getCurrentUserPlaylists(completion: @escaping (Result<LibraryPlaylistsResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me/playlists?limit=30"), type: .GET) { [weak self] request in
            self?.performRequest(with: request, of: LibraryPlaylistsResponse.self, completion: completion)
        }
    }
    
    public func createPlaylist(with name: String, completion: @escaping (Bool) -> Void) {
        getCurrentUserProfile { [weak self] result in
            switch result {
            case .success(let profile):
                self?.createRequest(with: URL(string: Constants.baseAPIURL + "/users/\(profile.id)/playlists"), type: .POST) { baseRequest in
                    var request = baseRequest
                    let json = [
                        "name": name
                    ]
                    request.httpBody = try? JSONSerialization.data(withJSONObject: json, options: .fragmentsAllowed)
                    URLSession.shared.dataTask(with: request) { data, _, error in
                        guard let data = data, error == nil else {
                            completion(false)
                            return
                        }
                        
                        do {
                            let result = try JSONSerialization.jsonObject(with: data, options: .fragmentsAllowed)
                            if let response = result as? [String: Any], response["id"] as? String != nil {
                                completion(true)
                            }else {
                                completion(false)
                            }
                        } catch {
                            completion(false)
                        }
                    }.resume()
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    public func addTrackToPlaylist(track: AudioTrack, playlist: Playlist, completion: @escaping (Bool) -> Void) {
        
    }
    
    public func removeTrackFromPlaylist(track: AudioTrack, playlist: Playlist, completion: @escaping (Bool) -> Void) {
        
    }
    
    
    //MARK: - Profile
    
    public func getCurrentUserProfile(completion: @escaping (Result<UserProfile, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/me"), type: .GET) { [weak self] request in
            self?.performRequest(with: request, of: UserProfile.self, completion: completion)
        }
    }
    
    //MARK: - Browse
    
    public func getNewReleases(completion: @escaping (Result<NewReleasesResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/new-releases?limit=20"), type: .GET) { [weak self] request in
            self?.performRequest(with: request, of: NewReleasesResponse.self, completion: completion)
        }
    }
    
    public func getFeaturedPlaylists(completion: @escaping (Result<FeaturedPlaylistsResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/browse/featured-playlists?limit=20"), type: .GET) { [weak self] request in
            self?.performRequest(with: request, of: FeaturedPlaylistsResponse.self, completion: completion)
        }
    }
    
    public func getRecommendations(genres: Set<String>, completion: @escaping (Result<RecommendationsResponse, Error>) -> Void) {
        let seeds = genres.joined(separator: ",")
        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations?limit=20&seed_genres=\(seeds)"), type: .GET) { [weak self] request in
            self?.performRequest(with: request, of: RecommendationsResponse.self, completion: completion)
        }
    }
    
    public func getRecommendedGenres(completion: @escaping (Result<RecommendedGenresResponse, Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/recommendations/available-genre-seeds"), type: .GET) { [weak self] request in
            self?.performRequest(with: request, of: RecommendedGenresResponse.self, completion: completion)
        }
    }
    
    //MARK: - Search
    
    public func search(with query: String, completion: @escaping (Result<[SearchResult], Error>) -> Void) {
        createRequest(with: URL(string: Constants.baseAPIURL + "/search?limit=5&type=album,artist,playlist,track&q=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"), type: .GET) { request in
            URLSession.shared.dataTask(with: request) { data, _, error in
                guard let data = data, error == nil else {
                    completion(.failure(APIError.failedToGetData))
                    print(error?.localizedDescription ?? "error")
                    return
                }
                do {
                    let result = try JSONDecoder().decode(SearchResultsResponse.self, from: data)
                    
                    var searchResults = [SearchResult]()
                    searchResults.append(contentsOf: result.tracks.items.compactMap { track in
                        return SearchResult.track(model: track)
                    })
                    searchResults.append(contentsOf: result.albums.items.compactMap { album in
                        return SearchResult.album(model: album)
                    })
                    searchResults.append(contentsOf: result.artists.items.compactMap { artist in
                        return SearchResult.artist(model: artist)
                    })
                    searchResults.append(contentsOf: result.playlists.items.compactMap { playlist in
                        return SearchResult.playlist(model: playlist)
                    })
                    
                    completion(.success(searchResults))
                } catch {
                    completion(.failure(error))
                    print(error)
                }
            }.resume()
        }
    }
    
    //MARK: - Helper functions
    private func createRequest(with url: URL?, type: HTTPMethod, completion: @escaping (URLRequest) -> Void) {
        AuthManager.shared.withValidToken { token in
            guard let apiURL = url else {
                return
            }
            var request = URLRequest(url: apiURL)
            request.httpMethod = type.rawValue
            request.timeoutInterval = 30
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
            completion(request)
        }
    }
    
    private func performRequest<T>(with request: URLRequest, of type: T.Type, completion: @escaping (Result<T, Error>) -> Void) where T: Decodable {
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                completion(.failure(APIError.failedToGetData))
                print(error?.localizedDescription ?? "error")
                return
            }
            do {
                let result = try JSONDecoder().decode(type, from: data)
                completion(.success(result))
            } catch {
                completion(.failure(error))
                print(error)
            }
        }.resume()
    }
}
