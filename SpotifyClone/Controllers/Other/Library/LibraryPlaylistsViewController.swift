//
//  LibraryPlaylistsViewController.swift
//  SpotifyClone
//
//  Created by Alex on 23/11/2022.
//

import UIKit

class LibraryPlaylistsViewController: UIViewController {
    
    private var playlists = [Playlist]()
    
    private let noPlaylistsView = ActionLabelView()
    
    public var selectionHandler: ((Playlist) -> Void)?
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(SearchResultSubtitleTableViewCell.self, forCellReuseIdentifier: SearchResultSubtitleTableViewCell.identifier)
        tableView.isHidden = true
        return tableView
    }()
    
    private let spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(frame: CGRect(x: 10, y: 5, width: 50, height: 50))
        spinner.style = .medium
        return spinner
    }()
    
    let refresher = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(noPlaylistsView)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        noPlaylistsView.delegate = self
        noPlaylistsView.configure(with: ActionLabelViewViewModel(text: "You don't have any playlists yet.", actionTitle: "Create"))
        view.backgroundColor = .systemBackground
        
        if selectionHandler != nil {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        }
        refresher.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refresher
        } else {
            tableView.addSubview(refresher)
        }
    }
    
    @objc private func refreshData() {
        tableView.refreshControl?.beginRefreshing()
        DispatchQueue.global().asyncAfter(deadline: .now() + .seconds(1)) { [weak self] in
            DispatchQueue.main.async {
                self?.fetchData()
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchData()
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
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
        APICaller.shared.getCurrentUserPlaylists { [weak self] result in
            DispatchQueue.main.async {
                self?.tableView.refreshControl?.endRefreshing()
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
                    self?.playlists = model.items
                    self?.updateUI()
                }
            }
        }
    }
    
    private func updateUI() {
        if playlists.isEmpty {
            noPlaylistsView.isHidden = false
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
            tableView.reloadData()
            noPlaylistsView.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noPlaylistsView.frame = CGRect(x: 0, y: 0, width: 150, height: 150)
        noPlaylistsView.center = view.center
        tableView.frame = view.bounds
    }
    
    public func showCreatePlaylistAlert() {
        let alert = UIAlertController(title: "New Playlist", message: "Enter Playlist Name", preferredStyle: .alert)
        alert.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
        alert.addTextField { textField in
            textField.placeholder = "Playlist..."
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Create", style: .default, handler: { _ in
            guard let field = alert.textFields?.first,
                  let text = field.text,
                  !text.trimmingCharacters(in: .whitespaces).isEmpty else {
                return
            }
            APICaller.shared.createPlaylist(with: text) { [weak self] success in
                if success {
                    self?.fetchData()
                    HapticsManager.shared.vibrate(for: .success)
                } else {
                    HapticsManager.shared.vibrate(for: .error)
                    DispatchQueue.main.async { [weak self] in
                        let alert = UIAlertController(title: "Error", message: "Failed To Create Playlist", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
                        self?.present(alert, animated: true)
                    }
                }
            }
        }))
        present(alert, animated: true)
    }
}

extension LibraryPlaylistsViewController: ActionLabelViewDelegate {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        showCreatePlaylistAlert()
    }
}

extension LibraryPlaylistsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        playlists.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let playlist = playlists[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: playlist.name, subtitle: playlist.owner.display_name, imageURL: URL(string: playlist.images.first?.url ?? "")))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let playlist = playlists[indexPath.row]
        guard selectionHandler == nil else {
            selectionHandler?(playlist)
            dismiss(animated: true)
            return
        }
        
        let vc = PlaylistViewController(playlist: playlist)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
