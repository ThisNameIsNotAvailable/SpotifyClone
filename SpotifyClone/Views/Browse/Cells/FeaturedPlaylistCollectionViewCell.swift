//
//  FeaturedPlaylistCollectionViewCell.swift
//  SpotifyClone
//
//  Created by Alex on 10/11/2022.
//

import UIKit
import SDWebImage

class FeaturedPlaylistCollectionViewCell: UICollectionViewCell {
    static let identifier = "FeaturedPlaylistCollectionViewCell"
    
    private let playlistCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.backgroundColor = .lightGray
        imageView.tintColor = .label
        return imageView
    }()
    
    private let playlistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .regular)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let creatorNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .thin)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(playlistCoverImageView)
        contentView.addSubview(playlistNameLabel)
        contentView.addSubview(creatorNameLabel)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        creatorNameLabel.frame = CGRect(x: 3, y: contentView.height - 30, width: contentView.width - 6, height: 30)
        playlistNameLabel.frame = CGRect(x: 3, y: contentView.height - 60, width: contentView.width - 6, height: 30)
        let imageSize = contentView.height - 70
        playlistCoverImageView.frame = CGRect(x: (contentView.width - imageSize) / 2, y: 8, width: imageSize, height: imageSize)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playlistNameLabel.text = nil
        creatorNameLabel.text = nil
        playlistCoverImageView.image = nil
    }
    
    public func configure(with viewModel: FeaturedPlaylistCellViewModel) {
        let spinner = UIActivityIndicatorView()
        spinner.color = .black
        spinner.hidesWhenStopped = true
        playlistCoverImageView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.leadingAnchor.constraint(equalTo: playlistCoverImageView.leadingAnchor),
            spinner.trailingAnchor.constraint(equalTo: playlistCoverImageView.trailingAnchor),
            spinner.bottomAnchor.constraint(equalTo: playlistCoverImageView.bottomAnchor),
            spinner.topAnchor.constraint(equalTo: playlistCoverImageView.topAnchor)
        ])
        spinner.startAnimating()
        
        playlistNameLabel.text = viewModel.name
        creatorNameLabel.text = viewModel.creatorName
        playlistCoverImageView.sd_setImage(with: viewModel.artworkURL) { [weak self] image, _, _, _ in
            spinner.stopAnimating()
            spinner.removeFromSuperview()
            
            guard image == nil else {
                return
            }
            self?.playlistCoverImageView.image = UIImage(systemName: "photo.circle")
        }
    }
}
