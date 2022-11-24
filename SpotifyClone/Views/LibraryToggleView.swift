//
//  LibraryToggleView.swift
//  SpotifyClone
//
//  Created by Alex on 23/11/2022.
//

import UIKit

protocol LibraryToggleViewDelegate: AnyObject {
    func libraryToggleViewDidTapPlaylists(_ toggleView: LibraryToggleView)
    func libraryToggleViewDidTapAlbums(_ toggleView: LibraryToggleView)
}

enum LibraryToggleViewState {
    case playlist
    case album
}

class LibraryToggleView: UIView {
    
    var state: LibraryToggleViewState = .playlist
    
    private let playlistButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Playlists", for: .normal)
        button.backgroundColor = .secondarySystemBackground
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.label.cgColor
        return button
    }()
    
    private let albumsButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.label, for: .normal)
        button.setTitle("Albums", for: .normal)
        button.backgroundColor = .secondarySystemBackground
        button.layer.masksToBounds = true
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.clear.cgColor
        return button
    }()
    
    weak var delegate: LibraryToggleViewDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(albumsButton)
        addSubview(playlistButton)
        
        NotificationCenter.default.addObserver(self, selector: #selector(didScrollToPlaylists), name: NSNotification.Name("Playlist"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didScrollToAlbum), name: NSNotification.Name("Album"), object: nil)
        
        playlistButton.addTarget(self, action: #selector(didTapPlaylists), for: .touchUpInside)
        albumsButton.addTarget(self, action: #selector(didTapAlbums), for: .touchUpInside)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func didTapPlaylists() {
        delegate?.libraryToggleViewDidTapPlaylists(self)
    }
    
    @objc private func didTapAlbums() {
        delegate?.libraryToggleViewDidTapAlbums(self)
    }
    
    @objc private func didScrollToPlaylists() {
        state = .playlist
        UIView.animate(withDuration: 0.3) {
            self.playlistButton.layer.borderColor = UIColor.label.cgColor
            self.albumsButton.layer.borderColor = UIColor.clear.cgColor
        }
    }
    
    @objc private func didScrollToAlbum() {
        state = .album
        UIView.animate(withDuration: 0.3) {
            self.playlistButton.layer.borderColor = UIColor.clear.cgColor
            self.albumsButton.layer.borderColor = UIColor.label.cgColor
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playlistButton.frame = CGRect(x: 0, y: 0, width: 100, height: 50)
        albumsButton.frame = CGRect(x: playlistButton.right + 10, y: 0, width: 100, height: 50)
        
        playlistButton.layer.cornerRadius = playlistButton.height / 2
        albumsButton.layer.cornerRadius = albumsButton.height / 2
    }
}
