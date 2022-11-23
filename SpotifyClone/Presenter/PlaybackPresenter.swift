//
//  PlaybackPresenter.swift
//  SpotifyClone
//
//  Created by Alex on 19/11/2022.
//

import UIKit
import AVFoundation

protocol PlaybackPresenterDataSource: AnyObject {
    var songName: String? { get }
    var subtitle: String? { get }
    var imageURL: URL? { get }
}

final class PlaybackPresenter {
    static let shared = PlaybackPresenter()
    private var track: AudioTrack?
    private var tracks = [AudioTrack]()
    
    var currentTrack: AudioTrack? {
        if let track = track, tracks.isEmpty {
            return track
        } else if let player = player, !tracks.isEmpty {
            let item = player.currentItem
            guard let index = playerItems.firstIndex(where: { $0 == item }) else {
                return nil
            }
            return tracks[index]
        }
        return nil
    }
    var player: AVPlayer?
    private var playerItems = [AVPlayerItem]()
    
    private var playerVC: PlayerViewController?
    
    private init() {}
    
    func startPlayback(from viewController: UIViewController, track: AudioTrack) {
        guard let url = URL(string: track.preview_url ?? "") else {
            let alert = UIAlertController(title: "No Preview For This Track", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            viewController.present(alert, animated: true)
            return
        }
        player = AVPlayer(url: url)
        player?.volume = 0.5
        
        self.track = track
        self.tracks = []
        let vc = PlayerViewController()
        vc.title = track.name
        vc.dataSource = self
        vc.delegate = self
        viewController.present(UINavigationController(rootViewController: vc), animated: true) { [weak self] in
            self?.player?.play()
        }
        self.playerVC = vc
    }
    
    func startPlayback(from viewController: UIViewController, tracks inputTracks: [AudioTrack], index: Int = 0) {
        
        let currentTrack = inputTracks[index]
        
        let tracks = inputTracks.filter({
            $0.preview_url != nil
        })
        
        if tracks.isEmpty {
            let alert = UIAlertController(title: "No Preview For This Album", message: "", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
            viewController.present(alert, animated: true)
            return
        } else if currentTrack.preview_url == nil {
            let alert = UIAlertController(title: "No Preview For This Track", message: "Playing Track That Have A Preview", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: { [weak self] _ in
                self?.createPlayer(from: viewController, currentTrack: currentTrack, tracks: tracks)
            }))
            viewController.present(alert, animated: true)
        } else {
            createPlayer(from: viewController, currentTrack: currentTrack, tracks: tracks)
        }
    }
    
    private func createPlayer(from viewController: UIViewController, currentTrack: AudioTrack, tracks: [AudioTrack]) {
        self.tracks = tracks
        self.track = nil

        let items: [AVPlayerItem] = tracks.compactMap { track in
            guard let url = URL(string: track.preview_url ?? "") else {
                return nil
            }
            return AVPlayerItem(url: url)
        }
        
        self.playerItems = items
        
        let currentIndex = tracks.firstIndex(where: { $0.id == currentTrack.id })
        self.player = AVPlayer(playerItem: currentTrack.preview_url == nil ? items.first : items[currentIndex!])
        self.player?.volume = 0.5

        let vc = PlayerViewController()
        vc.dataSource = self
        vc.delegate = self
        vc.title = currentTrack.name
        viewController.present(UINavigationController(rootViewController: vc), animated: true) {
            self.player?.play()
        }
        self.playerVC = vc
    }
}

extension PlaybackPresenter: PlaybackPresenterDataSource {
    var songName: String? {
        return currentTrack?.name
    }
    
    var subtitle: String? {
        currentTrack?.artists.first?.name
    }
    
    var imageURL: URL? {
        URL(string: currentTrack?.album?.images.first?.url ?? "")
    }
}

extension PlaybackPresenter: PlayerViewControllerDelegate {
    func didTapPlayPause() {
        if let player = player {
            if player.timeControlStatus == .playing {
                player.pause()
            } else if player.timeControlStatus == .paused {
                player.play()
            }
        }
    }
    
    func didTapForward() {
        if tracks.isEmpty {
            player?.pause()
            player?.seek(to: .zero)
            player?.play()
        } else if let player = player {
            player.pause()
            player.seek(to: .zero)
            if let currentItem = player.currentItem {
                if let index = playerItems.firstIndex(of: currentItem), index != playerItems.count - 1 {
                    player.replaceCurrentItem(with: playerItems[index + 1])
                    player.play()
                } else {
                    player.replaceCurrentItem(with: playerItems[0])
                    player.play()
                }
            }
            playerVC?.refreshUI()
        }
    }
    
    func didTapBackward() {
        if tracks.isEmpty {
            player?.pause()
            player?.seek(to: .zero)
            player?.play()
        } else if let player = player {
            player.pause()
            if let currentItem = player.currentItem {
                if let index = playerItems.firstIndex(of: currentItem), index != 0 {
                    player.replaceCurrentItem(with: playerItems[index - 1])
                }
                player.seek(to: .zero)
                player.play()
            }
            playerVC?.refreshUI()
        }
    }
    
    func didSlideSlider(_ value: Float) {
        player?.volume = value
    }
    
    func didTapDismiss() {
        player?.pause()
        player?.seek(to: .zero)
    }
    
    func didTapShare() {
        guard let url = URL(string: currentTrack?.external_urls["spotify"] ?? "") else {
            return
        }
        player?.pause()
        let vc = UIActivityViewController(activityItems: [url], applicationActivities: [])
        vc.completionWithItemsHandler = { [weak self] _, _, _, _ in
            self?.player?.play()
        }
        vc.popoverPresentationController?.barButtonItem = playerVC?.navigationItem.rightBarButtonItem
        playerVC?.present(vc, animated: true)
    }
}
