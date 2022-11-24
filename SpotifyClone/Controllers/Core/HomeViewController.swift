//
//  ViewController.swift
//  SpotifyClone
//
//  Created by Alex on 06/11/2022.
//

import UIKit

enum BrowseSectionType {
    case newReleases(viewModels: [AlbumCellViewModel])
    case featuredPlaylists(viewModels: [FeaturedPlaylistCellViewModel])
    case recommendedTracks(viewModels: [RecommendedTrackCellViewModel])
    
    var title: String {
        switch self {
        case .featuredPlaylists:
            return "Featured Playlists"
        case .newReleases:
            return "New Released Albums"
        case .recommendedTracks:
            return "Recommended"
        }
    }
}

class HomeViewController: UIViewController {
    
    private var collectionView: UICollectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout { sectionIndex, _ in
        return HomeViewController.createSectionLayout(sectionIndex: sectionIndex)
    })
    
    private let noDataLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.textAlignment = .center
        label.numberOfLines = 0
        label.text = "No Data. Try Pull To Refresh."
        label.font = .systemFont(ofSize: 32, weight: .semibold)
        return label
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        spinner.hidesWhenStopped = true
        spinner.style = .medium
        return spinner
    }()
    
    private var newAlbums = [Album]()
    private var playlists = [Playlist]()
    private var tracks = [AudioTrack]()
    
    private var sections = [BrowseSectionType]()
    var source = [Int]()
    var prime_occurrencies = [Int]()
    var occurrencies = [Int]()
    
    let refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Browse"
        view.backgroundColor = .systemBackground
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gear"), style: .done, target: self, action: #selector(didTapSettings))
        configureCollectionView()
        fetchData()
    }
    
    @objc private func refreshData() {
        collectionView.refreshControl?.beginRefreshing()
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            DispatchQueue.main.async {
                self?.fetchData()
            }
        }
    }
    
    private func configureCollectionView() {
        view.addSubview(collectionView)
        collectionView.register(AlbumViewCell.self, forCellWithReuseIdentifier: AlbumViewCell.identifier)
        collectionView.register(FeaturedPlaylistCollectionViewCell.self, forCellWithReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier)
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.register(HomeHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: HomeHeaderCollectionReusableView.identifier)
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = .systemBackground
        collectionView.delaysContentTouches = false
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refresher
        } else {
            collectionView.addSubview(refresher)
        }
    }
    
    private func fetchData() {
        let alert = UIAlertController(title: "", message: "Loading...", preferredStyle: .alert)
        alert.view.addSubview(spinner)
        spinner.startAnimating()
        var isDismissed = false
        present(alert, animated: true) { [weak self] in
            if isDismissed {
                self?.dismiss(animated: true)
            }
        }
        let group = DispatchGroup()
        group.enter()
        group.enter()
        group.enter()
        var newReleases: NewReleasesResponse?
        var featuredPlaylist: FeaturedPlaylistsResponse?
        var recommendations: RecommendationsResponse?
        // New Releases
        APICaller.shared.getNewReleases { result in
            defer {
                group.leave()
            }
            
            switch result {
            case .success(let model):
                newReleases = model
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.dismiss(animated: true) {
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        self?.present(alert, animated: true)
                    }
                    self?.collectionView.refreshControl?.endRefreshing()
                    guard let strongSelf = self else {
                        return
                    }
                    if strongSelf.sections.isEmpty {
                        self?.collectionView.backgroundView = self?.noDataLabel
                    }
                }
            }
        }
        //Featured Playlists
        APICaller.shared.getFeaturedPlaylists { result in
            defer {
                group.leave()
            }
            switch result {
            case .success(let model):
                featuredPlaylist = model
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.dismiss(animated: true) {
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        self?.present(alert, animated: true)
                    }
                    self?.collectionView.refreshControl?.endRefreshing()
                    guard let strongSelf = self else {
                        return
                    }
                    if strongSelf.sections.isEmpty {
                        self?.collectionView.backgroundView = self?.noDataLabel
                    }
                }
            }
        }
        //Recommended Tracks
        APICaller.shared.getRecommendedGenres { [weak self] result in
            switch result {
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    self?.dismiss(animated: true) {
                        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        self?.present(alert, animated: true)
                    }
                }
                DispatchQueue.main.async {
                    self?.collectionView.refreshControl?.endRefreshing()
                    guard let strongSelf = self else {
                        return
                    }
                    if strongSelf.sections.isEmpty {
                        self?.collectionView.backgroundView = self?.noDataLabel
                    }
                }

                group.leave()
            case .success(let model):
                let genres = model.genres
                var seeds = Set<String>()
                while seeds.count < 5 {
                    if let random = genres.randomElement() {
                        seeds.insert(random)
                    }
                }
                APICaller.shared.getRecommendations(genres: seeds) { recommendedResults in
                    defer {
                        group.leave()
                    }
                    switch recommendedResults {
                    case .failure(let error):
                        DispatchQueue.main.async { [weak self] in
                            self?.dismiss(animated: true) {
                                let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                                self?.present(alert, animated: true)
                            }
                            self?.collectionView.refreshControl?.endRefreshing()
                            guard let strongSelf = self else {
                                return
                            }
                            if strongSelf.sections.isEmpty {
                                self?.collectionView.backgroundView = self?.noDataLabel
                            }
                        }
                    case .success(let model):
                        recommendations = model
                    }
                }
            }
        }
        group.notify(queue: .main) { [weak self] in
            self?.collectionView.refreshControl?.endRefreshing()
            guard let newAlbums = newReleases?.albums.items, let playlists = featuredPlaylist?.playlists.items, let tracks = recommendations?.tracks else {
                DispatchQueue.main.async { [weak self] in
                    self?.dismiss(animated: true) {
                        let alert = UIAlertController(title: "Error", message: "Failed To Get Data", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        self?.present(alert, animated: true)
                    }
                    guard let strongSelf = self else {
                        return
                    }
                    if strongSelf.sections.isEmpty {
                        self?.collectionView.backgroundView = self?.noDataLabel
                    }
                }
                return
            }
            self?.dismiss(animated: true, completion: {
                self?.spinner.stopAnimating()
                isDismissed = true
            })
            self?.configureModels(newAlbums: newAlbums, playlists: playlists, tracks: tracks)
        }
        
    }
    
    private func configureModels(newAlbums: [Album], playlists: [Playlist], tracks: [AudioTrack]) {
        // Configure models
        self.newAlbums = newAlbums
        self.playlists = playlists
        self.tracks = tracks
        sections.removeAll()
        sections.append(.newReleases(viewModels: newAlbums.compactMap({ album in
            return AlbumCellViewModel(name: album.name, artworkURL: URL(string: album.images.first?.url ?? ""), numberOfTracks: album.total_tracks, artistName: album.artists.first?.name ?? "-")
        })))
        sections.append(.featuredPlaylists(viewModels: playlists.compactMap({ playlist in
            return FeaturedPlaylistCellViewModel(name: playlist.name, artworkURL: URL(string: playlist.images.first?.url ?? ""), creatorName: playlist.owner.display_name)
        })))
        sections.append(.recommendedTracks(viewModels: tracks.compactMap({ track in
            return RecommendedTrackCellViewModel(name: track.name, artistName: track.artists.first?.name ?? "-", artworkURL: URL(string: track.album?.images.first?.url ?? ""))
        })))
        collectionView.backgroundView = nil
        collectionView.reloadData()
        
        
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
    
    @objc private func didTapSettings() {
        let vc = SettingsViewController()
        vc.title = "Settings"
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
}

extension HomeViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let section = sections[indexPath.section]
        switch section {
        case .featuredPlaylists:
            let playlist = playlists[indexPath.row]
            let vc = PlaylistViewController(playlist: playlist)
            vc.title = playlist.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .newReleases:
            let album = newAlbums[indexPath.row]
            let vc = AlbumViewController(album: album)
            vc.title = album.name
            vc.navigationItem.largeTitleDisplayMode = .never
            navigationController?.pushViewController(vc, animated: true)
        case .recommendedTracks:
            PlaybackPresenter.shared.startPlayback(from: self, tracks: tracks, index: indexPath.row)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if indexPath.section != 2 {
            UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: {
                cell?.transform = CGAffineTransform(scaleX: 0.90, y: 0.90)
                cell?.alpha = 0.7
            })
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
        let cell = collectionView.cellForItem(at: indexPath)
        if indexPath.section != 2 {
            UIView.animate(withDuration: 0.3, delay: 0, options: .beginFromCurrentState, animations: {
                cell?.transform = .identity
                cell?.alpha = 1
            })
        }
    }
    
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader, let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HomeHeaderCollectionReusableView.identifier, for: indexPath) as? HomeHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        headerView.configure(with: sections[indexPath.section].title)
        return headerView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let type = sections[section]
        switch type {
        case .newReleases(let viewModels):
            return viewModels.count
        case .featuredPlaylists(let viewModels):
            return viewModels.count
        case .recommendedTracks(let viewModels):
            return viewModels.count
        }
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        sections.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let type = sections[indexPath.section]
        switch type {
        case .newReleases(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: AlbumViewCell.identifier, for: indexPath) as? AlbumViewCell else {
                return UICollectionViewCell()
            }
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
            return cell
        case .featuredPlaylists(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FeaturedPlaylistCollectionViewCell.identifier, for: indexPath) as? FeaturedPlaylistCollectionViewCell else {
                return UICollectionViewCell()
            }
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
            return cell
        case .recommendedTracks(let viewModels):
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as? RecommendedTrackCollectionViewCell else {
                return UICollectionViewCell()
            }
            let viewModel = viewModels[indexPath.row]
            cell.configure(with: viewModel)
            cell.addInteraction(UIContextMenuInteraction(delegate: self))
            return cell
        }
    }
    
    private static func createSectionLayout(sectionIndex: Int) -> NSCollectionLayoutSection {
        let footerHeaderSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(50.0))
        let header = NSCollectionLayoutBoundarySupplementaryItem(
            layoutSize: footerHeaderSize,
            elementKind: UICollectionView.elementKindSectionHeader,
            alignment: .top)
        header.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)
        switch sectionIndex {
        case 0:
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(390)), subitem: item, count: 3)
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.9), heightDimension: .absolute(390)), subitem: verticalGroup, count: 1)
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .groupPaging
            section.boundarySupplementaryItems = [header]
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
            return section
        case 1:
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(200)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)
            let verticalGroup = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400)), subitem: item, count: 2)
            let horizontalGroup = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .absolute(200), heightDimension: .absolute(400)), subitem: verticalGroup, count: 1)
            let section = NSCollectionLayoutSection(group: horizontalGroup)
            section.orthogonalScrollingBehavior = .continuous
            section.boundarySupplementaryItems = [header]
            section.contentInsets = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 20, trailing: 0)
            return section
        case 2:
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)
            let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(80)), subitem: item, count: 1)
            let section = NSCollectionLayoutSection(group: group)
            section.boundarySupplementaryItems = [header]
            return section
        default:
            let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
            item.contentInsets = NSDirectionalEdgeInsets(top: 3, leading: 3, bottom: 3, trailing: 3)
            let group = NSCollectionLayoutGroup.horizontal(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(390)), subitem: item, count: 3)
            let section = NSCollectionLayoutSection(group: group)
            return section
        }
    }
}

extension HomeViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ -> UIMenu? in
            let locationInCollectionView = interaction.location(in: self?.collectionView)
            guard let indexPath = self?.collectionView.indexPathForItem(at: locationInCollectionView) else {
                return nil
            }
            guard let model = self?.tracks[indexPath.row] else {
                return nil
            }
            let addAction = UIAction(title: "Add To Playlist", image: UIImage(systemName: "plus.app")) { _ in
                DispatchQueue.main.async {
                    let vc = LibraryPlaylistsViewController()
                    vc.selectionHandler = { playlist in
                        APICaller.shared.addTrackToPlaylist(track: model, playlist: playlist) { success in
                            if success {
                                HapticsManager.shared.vibrate(for: .success)
                            } else {
                                DispatchQueue.main.async { [weak self] in
                                    let alert = UIAlertController(title: "Error", message: "Failed To Add To Playlist", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                                    self?.present(alert, animated: true)
                                }
                            }
                        }
                    }
                    vc.title = "Select Playlist"
                    self?.present(UINavigationController(rootViewController: vc), animated: true)
                }
            }
            let cancelAction = UIAction(title: "Cancel") { _ in
                
            }
            return UIMenu(title: "", children: [addAction, cancelAction])
        }
    }
}
