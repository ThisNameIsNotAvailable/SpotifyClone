//
//  PlaylistViewController.swift
//  SpotifyClone
//
//  Created by Alex on 06/11/2022.
//

import UIKit

class PlaylistViewController: UIViewController {
    
    private let playlist: Playlist
    
    private var viewModels = [RecommendedTrackCellViewModel]()
    
    private var tracks = [AudioTrack]()
    
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
    
    init(playlist: Playlist) {
        self.playlist = playlist
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = playlist.name
        view.addSubview(collectionView)
        collectionView.backgroundColor = .systemBackground
        collectionView.register(RecommendedTrackCollectionViewCell.self, forCellWithReuseIdentifier: RecommendedTrackCollectionViewCell.identifier)
        collectionView.register(PlaylistHeaderCollectionReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        fetchData()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapShare))
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
        APICaller.shared.getPlaylistDetails(for: playlist) { [weak self] result in
            DispatchQueue.main.async {
                self?.collectionView.refreshControl?.endRefreshing()
                self?.dismiss(animated: true, completion: {
                    self?.spinner.stopAnimating()
                    isDismissed = true
                })
                switch result {
                case .success(let model):
                    self?.tracks = model.tracks.items.compactMap({ item in
                        return item.track
                    })
                    self?.viewModels = model.tracks.items.compactMap({ playlist in
                        guard let track = playlist.track else {
                            return RecommendedTrackCellViewModel(name: "", artistName: "", artworkURL: nil)
                        }
                        return RecommendedTrackCellViewModel(name: track.name, artistName: track.artists.first?.name ?? "-", artworkURL: URL(string: track.album?.images.first?.url ?? ""))
                    }).filter({ viewModel in
                        return viewModel.artworkURL != nil
                    })
                    self?.collectionView.reloadData()
                case .failure(let error):
                    DispatchQueue.main.async { [weak self] in
                        self?.dismiss(animated: true) {
                            let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            self?.present(alert, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    @objc private func didTapShare() {
        guard let url = URL(string: playlist.external_urls["spotify"] ?? "") else {
            return
        }
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
        vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        present(vc, animated: true)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        collectionView.frame = view.bounds
    }
}

extension PlaylistViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        viewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: RecommendedTrackCollectionViewCell.identifier, for: indexPath) as? RecommendedTrackCollectionViewCell else {
            
            return UICollectionViewCell()
        }
        let model = viewModels[indexPath.row]
        cell.configure(with: model)
        cell.addInteraction(UIContextMenuInteraction(delegate: self))
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let index = indexPath.row
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracks, index: index)
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard kind == UICollectionView.elementKindSectionHeader, let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: PlaylistHeaderCollectionReusableView.identifier, for: indexPath) as? PlaylistHeaderCollectionReusableView else {
            return UICollectionReusableView()
        }
        let headerViewModel = PlaylistHeaderViewModel(name: playlist.name, ownerName: playlist.owner.display_name, description: playlist.description, artworkURL: URL(string: playlist.images.first?.url ?? ""))
        header.configure(with: headerViewModel)
        header.delegate = self
        return header
    }
    
    
}

extension PlaylistViewController: PlaylistHeaderCollectionReusableViewDelegate {
    func playlistHeaderCollectionReusableViewDidTapPlayAll(_ header: PlaylistHeaderCollectionReusableView) {
        PlaybackPresenter.shared.startPlayback(from: self, tracks: tracks)
    }
}

extension PlaylistViewController: UIContextMenuInteractionDelegate {
    func contextMenuInteraction(_ interaction: UIContextMenuInteraction, configurationForMenuAtLocation location: CGPoint) -> UIContextMenuConfiguration? {
        return UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { [weak self] _ -> UIMenu? in
            let locationInCollectionView = interaction.location(in: self?.collectionView)
            
            guard let indexPath = self?.collectionView.indexPathForItem(at: locationInCollectionView),
                  let model = self?.tracks[indexPath.row],
                  let playlist = self?.playlist else {
                return nil
            }
            let userID = UserDefaults.standard.value(forKey: "userID") as? String
            
            let addAction = UIAction(title: "Remove From Playlist", image: UIImage(systemName: "trash"), attributes: (userID == playlist.owner.id) ? .destructive : .disabled) { _ in
                APICaller.shared.removeTrackFromPlaylist(track: model, playlist: playlist) { success in
                    if success {
                        DispatchQueue.main.async {
                            self?.tracks.remove(at: indexPath.row)
                            self?.viewModels.remove(at: indexPath.row)
                            self?.collectionView.deleteItems(at: [indexPath])
                        }
                    } else {
                        HapticsManager.shared.vibrate(for: .error)
                        DispatchQueue.main.async { [weak self] in
                            let alert = UIAlertController(title: "Error", message: "Failed To Delete From Playlist", preferredStyle: .alert)
                            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                            self?.present(alert, animated: true)
                        }
                    }
                }
            }
            let cancelAction = UIAction(title: "Cancel") { _ in
                
            }
            
            return UIMenu(title: "", children: [addAction, cancelAction])
        }
    }
}

