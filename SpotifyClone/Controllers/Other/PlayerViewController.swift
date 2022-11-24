//
//  PlayerViewController.swift
//  SpotifyClone
//
//  Created by Alex on 06/11/2022.
//

import UIKit
import SDWebImage

protocol PlayerViewControllerDelegate: AnyObject {
    func didTapPlayPause()
    func didTapForward()
    func didTapBackward()
    func didSlideSlider(_ value: Float)
    func didTapDismiss()
    func didTapShare()
}

class PlayerViewController: UIViewController {
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 8
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let controlsView = PlayerControlsView()
    
    weak var dataSource: PlaybackPresenterDataSource?
    weak var delegate: PlayerViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(imageView)
        view.addSubview(controlsView)
        controlsView.delegate = self
        configureBarButtons()
        configure()
    }
    
    private func configure() {
        imageView.sd_setImage(with: dataSource?.imageURL)
        controlsView.configure(with: PlayerControlsViewViewModel(title: dataSource?.songName, subtitle: dataSource?.subtitle))
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        imageView.frame = CGRect(x: 10, y: view.safeAreaInsets.top + 10, width: view.width - 20, height: view.width - 20)
        controlsView.frame = CGRect(x: 10, y: imageView.bottom + 10, width: view.width - 20, height: view.height - imageView.height - view.safeAreaInsets.top - view.safeAreaInsets.bottom - 15)
    }
    
    private func configureBarButtons() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .close, target: self, action: #selector(didTapClose))
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(didTapAction))
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        delegate?.didTapDismiss()
    }
    
    @objc private func didTapClose() {
        dismiss(animated: true)
    }
    
    @objc private func didTapAction() {
        delegate?.didTapShare()
    }
    
    func refreshUI() {
        configure()
    }
}

extension PlayerViewController: PlayerControlsViewDelegate {
    func playerControlsViewDidTapPlayPauseButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapPlayPause()
    }
    
    func playerControlsViewDidTapForwardButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapForward()
    }
    
    func playerControlsViewDidTapBackwardsButton(_ playerControlsView: PlayerControlsView) {
        delegate?.didTapBackward()
    }
    
    func playerControlsView(_ playerControlsView: PlayerControlsView, didSlideSlider value: Float) {
        delegate?.didSlideSlider(value)
    }
}
