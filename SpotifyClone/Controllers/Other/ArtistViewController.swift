//
//  ArtistViewController.swift
//  SpotifyClone
//
//  Created by Alex on 15/11/2022.
//

import UIKit

enum ArtistSectionType {
    case albums(albums: [FeaturedPlaylistCellViewModel])
    case popularTracks(tracks: [RecommendedTrackCellViewModel])
    case relatedArtists(artists: [ArtistCollectionViewModel])
    
    var title: String {
        switch self {
        case .albums:
            return "Albums"
        case .popularTracks:
            return "Popular Tracks"
        case .relatedArtists:
            return "Related Artists"
        }
    }
}
class ArtistViewController: UIViewController {
    
    private var sections = [ArtistSectionType]()
    
    private let artist: Artist
    
    private var offset: CGFloat!
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: CustomCompositionalLayout(sectionProvider: { index, _ in
        switch index {
        case 0:
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(200)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .absolute(200)), subitem: item, count: 1)
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalWidth(1)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.boundarySupplementaryItems = [header]
            section.orthogonalScrollingBehavior = .groupPaging
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 10, trailing: 0)
            return section
        case 1:
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 4)
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(200)), subitem: item, count: 4)
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(200)), subitem: verticalGroup, count: 1)
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 1, bottom: 0, trailing: 0)
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.boundarySupplementaryItems = [header]
            section.orthogonalScrollingBehavior = .continuous
            return section
        case 2:
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(200)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.45), heightDimension: .absolute(200)), subitem: item, count: 1)
            let header = NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(40)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)
            header.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 1, bottom: 0, trailing: 0)
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [header]
            section.orthogonalScrollingBehavior = .continuous
            return section
        default:
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .fractionalHeight(1)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 5, leading: 5, bottom: 5, trailing: 5)
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(200)), subitem: item, count: 2)
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(400), heightDimension: .absolute(400)), subitems: [verticalGroup])
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            return section
        }
    }))
    
    var artists = [Artist]()
    var tracks = [AudioTrack]()
    var albums = [Album]()
    
    init(artist: Artist) {
        self.artist = artist
        super.init(nibName: nil, bundle: nil)
        title = artist.name
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.navigationController?.navigationBar.subviews.first?.alpha = 1
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(collectionView)
        view.backgroundColor = .systemBackground
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        collectionView.register(ArtistCollectionViewCell.self, forCellWithReuseIdentifier: ArtistCollectionViewCell.identifier)
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.register(HomeHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeHeaderCollectionReusableView.identifier)
        collectionView.register(StretchyCollectionHeaderView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: StretchyCollectionHeaderView.identifier)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchData()
        collectionView.delaysContentTouches = false
        self.navigationController?.navigationBar.subviews.first?.alpha = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        guard let navigationController = self.navigationController else { return }
        if !isSet {
            isSet = true
            offset = collectionView.contentOffset.y
        }
        
        let threshold: CGFloat = view.width - 40 // distance from bar where fade-in begins
        if (collectionView.contentOffset.y - offset) / threshold > 0.7 {
            let alpha = ((collectionView.contentOffset.y - offset) / threshold - 0.7)*3.3
            navigationController.navigationBar.subviews.first?.alpha = alpha
            navigationController.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.label.withAlphaComponent(alpha)
            ]
        }else {
            navigationController.navigationBar.subviews.first?.alpha = 0
            navigationController.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.label.withAlphaComponent(0)
            ]
        }
    }
    
    private func fetchData() {
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        
        var albums: AlbumsResponse?
        var relatedArtists: RelatedArtistsResponse?
        var popularTracks: RecommendationsResponse?
        
        APICaller.shared.getAlbums(of: artist) { result in
            defer {
                group.leave()
            }
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let model):
                albums = model
            }
        }
        
        APICaller.shared.getPopularTracks(of: artist) { result in
            defer {
                group.leave()
            }
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let model):
                popularTracks = model
            }
        }
        
        APICaller.shared.getRelatedArtists(to: artist) { result in
            defer {
                group.leave()
            }
            switch result {
            case .failure(let error):
                print(error.localizedDescription)
            case .success(let model):
                relatedArtists = model
            }
        }
        
        group.notify(queue: .main) { [weak self] in
            guard let relatedArtists = relatedArtists?.artists, let popularTracks = popularTracks?.tracks, let albums = albums?.items else {
                return
            }
            self?.configureModels(artists: relatedArtists, tracks: popularTracks, albums: albums)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    private func configureModels(artists: [Artist], tracks: [AudioTrack], albums: [Album]) {
        self.artists = artists
        self.tracks = tracks
        self.albums = albums
        
        sections.append(ArtistSectionType.albums(albums: albums.compactMap({ album in
            return FeaturedPlaylistCellViewModel(name: album.name, artworkURL: URL(string: album.images.first?.url ?? ""), creatorName: album.artists.first?.name ?? "-")
        })))
        sections.append(ArtistSectionType.popularTracks(tracks: tracks.compactMap({ track in
            return RecommendedTrackCellViewModel(name: track.name, artistName: track.artists.first?.name ?? "-", artworkURL: URL(string: track.album?.images.first?.url ?? ""))
        })))
        sections.append(ArtistSectionType.relatedArtists(artists: artists.compactMap({
            return ArtistCollectionViewModel(name: $0.name, artworkURL: URL(string: $0.images?.first?.url ?? ""))
        })))
        
        collectionView.reloadData()
    }
    var isSet: Bool = false
}

extension ArtistViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard let navigationController = self.navigationController else { return }
        if !isSet {
            isSet = true
            offset = collectionView.contentOffset.y
        }
        
        let threshold: CGFloat = view.width - 40 // distance from bar where fade-in begins
        if (collectionView.contentOffset.y - offset) / threshold > 0.7 {
            let alpha = ((collectionView.contentOffset.y - offset) / threshold - 0.7)*3.3
            navigationController.navigationBar.subviews.first?.alpha = alpha
            navigationController.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.label.withAlphaComponent(alpha)
            ]
        }else {
            navigationController.navigationBar.subviews.first?.alpha = 0
            navigationController.navigationBar.titleTextAttributes = [
                .foregroundColor: UIColor.label.withAlphaComponent(0)
            ]
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch sections[section] {
        case .relatedArtists(let artists):
            return artists.count
        case .popularTracks(let tracks):
            return tracks.count
        case .albums(let albums):
            return albums.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        switch sections[indexPath.section] {
        case .albums(let albums):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier, for: indexPath) as? FeaturedPlaylistCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: albums[indexPath.row])
            return cell
        case .popularTracks(let tracks):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as? RecommendedTrackCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: tracks[indexPath.row])
            return cell
        case .relatedArtists(let artists):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ArtistCollectionViewCell.identifier, for: indexPath) as? ArtistCollectionViewCell else {
                return UICollectionViewCell()
            }
            cell.configure(with: artists[indexPath.row])
            return cell
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        let section = sections[indexPath.section]
        switch section {
        case .albums:
            let vc = AlbumViewController(album: albums[indexPath.row])
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .relatedArtists:
            let vc = ArtistViewController(artist: artists[indexPath.row])
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        default:
            break
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState) {
            guard let cell = collectionView.cellForItem(at: indexPath) else {
                return
            }
            if !(cell is ArtistCollectionViewCell) {
                cell.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
            }
            cell.alpha = 0.7
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        UIView.animate(withDuration: 0.2, delay: 0, options: .beginFromCurrentState) {
            guard let cell = collectionView.cellForItem(at: indexPath) else {
                return
            }
            cell.transform = .identity
            cell.alpha = 1
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader else {
            return UICollectionReusableView()
        }
        
        switch indexPath.section {
        case 0:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: StretchyCollectionHeaderView.identifier, for: indexPath) as? StretchyCollectionHeaderView else {
                return UICollectionReusableView()
            }
            header.configure(with: StretchyCollectionHeaderViewModel(artistName: artist.name, followers: artist.followers?.total, imageURL: URL(string: artist.images?.first?.url ?? ""), title: sections[indexPath.section].title))
            return header
        case 1...2:
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeHeaderCollectionReusableView.identifier, for: indexPath) as? HomeHeaderCollectionReusableView else {
                return UICollectionReusableView()
            }
            header.configure(with: sections[indexPath.section].title)
            return header
        default:
            return UICollectionReusableView()
        }
    }
}
