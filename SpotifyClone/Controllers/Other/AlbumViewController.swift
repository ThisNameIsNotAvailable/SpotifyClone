//
//  AlbumViewController.swift
//  SpotifyClone
//
//  Created by Alex on 12/11/2022.
//

import UIKit

class AlbumViewController: UIViewController {
    
    private let album: Album
    
    private var tracks = [AudioTrack]()
    
    private var shareURL: URL?
    
    private var viewModels = [RecommendedTrackCellViewModel]()
    
    private let collectionView = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewCompositionalLayout(sectionProvider: { _, _ in
        let item = NSCollectionLayoutItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalHeight(1.0)))
        item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 3, bottom: 1, trailing: 3)
        let group = NSCollectionLayoutGroup.vertical(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .absolute(60)), subitem: item, count: 1)
        let section = NSCollectionLayoutSection(group: group)
        section.boundarySupplementaryItems = [NSCollectionLayoutBoundarySupplementaryItem(layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0), heightDimension: .fractionalWidth(1.0)), elementKind: UICollectionView.elementKindSectionHeader, alignment: .top)]
        return section
    }))
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        spinner.style = .medium
        return spinner
    }()
    
    let refresher = UIRefreshControl()
    
    init(album: Album) {
        self.album = album
        super.init(nibName: nil, bundle: nil)
        view.addSubview(collectionView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = album.name
        collectionView.backgroundColor = .systemBackground
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchData()
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "list.bullet"), style: .plain, target: self, action: #selector(didTapRightButton))
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        if #available(iOS 10.0, *) {
            collectionView.refreshControl = refresher
        } else {
            collectionView.addSubview(refresher)
        }
    }
    
    @objc private func refreshData() {
        collectionView.refreshControl?.beginRefreshing()
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            DispatchQueue.main.async {
                self?.fetchData()
            }
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
        APICaller.shared.getAlbumDetails(for: album) { [weak self] result in
            DispatchQueue.main.async {
                self?.collectionView.refreshControl?.endRefreshing()
                self?.dismiss(animated: true, completion: {
                    self?.spinner.stopAnimating()
                    isDismissed = true
                })
                switch result {
                case .failure(let error):
                    DispatchQueue.main.async { [weak self] in
                        self?.dismiss(animated: true) {
                            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            self?.present(alert, animated: true)
                        }
                    }
                case .success(let model):
                    self?.shareURL = URL(string: model.external_urls["spotify"] ?? "")
                    self?.tracks = model.tracks.items
                    self?.viewModels = model.tracks.items.compactMap { track in
                        return RecommendedTrackCellViewModel(name: track.name, artistName: track.artists.first?.name ?? "-", artworkURL: URL(string: self?.album.images.first?.url ?? ""))
                    }
                    self?.collectionView.reloadData()
                    break
                }
            }
        }
    }
    
    @objc private func didTapRightButton() {
        let alert = UIAlertController(title: "What do you want to do?", message: "", preferredStyle: .actionSheet)
        alert.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        alert.addAction(UIAlertAction(title: "Share Album", style: .default, handler: { [weak self] _ in
            guard let url = self?.shareURL else {
                return
            }
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
            vc.popoverPresentationController?.barButtonItem = self?.navigationItem.rightBarButtonItem
            self?.present(vc, animated: true)
        }))
        
        APICaller.shared.getCurrentUserAlbums { [weak self] result in
            guard let strongSelf = self else {
                return
            }
            switch result {
            case .success(let response):
                if !response.items.contains (where: { userAlbum in
                    userAlbum.album.id == strongSelf.album.id
                }) {
                    DispatchQueue.main.async {
                        alert.addAction(UIAlertAction(title: "Add To Saved Albums", style: .default, handler: { [weak self] _ in
                            guard let strongSelf = self else {
                                return
                            }
                            APICaller.shared.saveAlbum(album: strongSelf.album) { success in
                                if success {
                                    HapticsManager.shared.vibrate(for: .success)
                                } else {
                                    HapticsManager.shared.vibrate(for: .error)
                                }
                            }
                        }))
                    }
                } else {
                    DispatchQueue.main.async {
                        alert.addAction(UIAlertAction(title: "Remove From Saved Albums", style: .destructive, handler: { [weak self] _ in
                            guard let strongSelf = self else {
                                return
                            }
                            APICaller.shared.removeAlbum(album: strongSelf.album) { success in
                                if success {
                                    HapticsManager.shared.vibrate(for: .success)
                                } else {
                                    DispatchQueue.main.async { [weak self] in
                                        let alert = UIAlertController(title: "Error", message: "Failed To Delete From Saved Albums", preferredStyle: .alert)
                                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                                        self?.present(alert, animated: true)
                                    }
                                    HapticsManager.shared.vibrate(for: .error)
                                }
                            }
                        }))
                    }
                }
            case .failure(let error):
                DispatchQueue.main.async { [weak self] in
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                    self?.present(alert, animated: true)
                }
            }
            
            
            DispatchQueue.main.async {
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                strongSelf.present(alert, animated: true)
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}


extension AlbumViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as? RecommendedTrackCollectionViewCell else {
            return UICollectionViewCell()
        }
        let model = viewModels[indexPath.row]
        cell.configure(with: model)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let index = indexPath.row
        let tracksWithAlbum: [AudioTrack] = tracks.compactMap({
            var track = $0
            track.album = album
            return track
        })
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracksWithAlbum, index: index)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader, let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier, for: indexPath) as? PlaylistHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        let headerViewModel = PlaylistHeaderViewModel(name: album.name, ownerName: album.artists.first?.name, description: "Release Date: \(String.formattedDate(string: album.release_date))", artworkURL: URL(string: album.images.first?.url ?? ""))
        header.configure(with: headerViewModel)
        header.delegate = self
        return header
    }
}

extension AlbumViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        let tracksWithAlbum: [AudioTrack] = tracks.compactMap({
            var track = $0
            track.album = album
            return track
        })
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracksWithAlbum)
    }
}
