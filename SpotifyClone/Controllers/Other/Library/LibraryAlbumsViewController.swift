//
//  LibraryAlbumsViewController.swift
//  SpotifyClone
//
//  Created by Alex on 23/11/2022.
//

import UIKit


class LibraryAlbumsViewController: UIViewController {
    
    private var albums = [Album]()
    
    private let noAlbumsView = ActionLabelView()
    
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
        view.addSubview(noAlbumsView)
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        noAlbumsView.delegate = self
        noAlbumsView.configure(with: ActionLabelViewViewModel(text: "You don't have any saved albums yet.", actionTitle: "Browse"))
        view.backgroundColor = .systemBackground
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
        APICaller.shared.getCurrentUserAlbums { [weak self] result in
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
                    self?.albums = model.items.compactMap({
                        $0.album
                    })
                    self?.updateUI()
                }
            }
        }
    }
    
    private func updateUI() {
        if albums.isEmpty {
            noAlbumsView.isHidden = false
            tableView.isHidden = true
        } else {
            tableView.isHidden = false
            tableView.reloadData()
            noAlbumsView.isHidden = true
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        noAlbumsView.frame = CGRect(x: (view.width - 150) / 2, y: (view.height - 150) / 2, width: 150, height: 150)
        tableView.frame = view.bounds
    }
}

extension LibraryAlbumsViewController: ActionLabelViewDelegate {
    func actionLabelViewDidTapButton(_ actionView: ActionLabelView) {
        tabBarController?.selectedIndex = 0
    }
}

extension LibraryAlbumsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        albums.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: SearchResultSubtitleTableViewCell.identifier, for: indexPath) as? SearchResultSubtitleTableViewCell else {
            return UITableViewCell()
        }
        let album = albums[indexPath.row]
        cell.configure(with: SearchResultSubtitleTableViewCellViewModel(title: album.name, subtitle: album.artists.first?.name ?? "-", imageURL: URL(string: album.images.first?.url ?? "")))
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        HapticsManager.shared.vibrateForSelection()
        let album = albums[indexPath.row]
        
        let vc = AlbumViewController(album: album)
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}

