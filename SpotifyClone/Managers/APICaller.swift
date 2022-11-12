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
                print(error)
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