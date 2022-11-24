//
//  NewReleaseCollectionViewCell.swift
//  SpotifyClone
//
//  Created by Alex on 10/11/2022.
//

import UIKit
import SDWebImage

class AlbumViewCell: UICollectionViewCell {
    static let identifier = "AlbumViewCell"
    
    private let albumCoverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: "photo")
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.backgroundColor = .lightGray
        imageView.tintColor = .label
        return imageView
    }()
    
    private let albumNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.numberOfLines = 0
        return label
    }()
    
    private let numberOfTracksLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .thin)
        label.numberOfLines = 0
        return label
    }()
    
    private let artistNameLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 18, weight: .light)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .secondarySystemBackground
        contentView.addSubview(albumCoverImageView)
        contentView.addSubview(albumNameLabel)
        contentView.addSubview(artistNameLabel)
        contentView.addSubview(numberOfTracksLabel)
        contentView.clipsToBounds = true
        contentView.layer.cornerRadius = 10
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height - 16
        let albumLabelSize = albumNameLabel.sizeThatFits(CGSize(width: contentView.width - imageSize - 10, height: contentView.height - 10))
        albumNameLabel.sizeToFit()
        artistNameLabel.sizeToFit()
        numberOfTracksLabel.sizeToFit()
        
        let albumLabelHeight = min(60, albumLabelSize.height)
        
        albumCoverImageView.frame = CGRect(x: 8, y: 8, width: imageSize, height: imageSize)
        
        albumNameLabel.frame = CGRect(x: albumCoverImageView.right + 10, y: 5, width: albumLabelSize.width, height: albumLabelHeight)
        
        artistNameLabel.frame = CGRect(x: albumCoverImageView.right + 10, y: albumNameLabel.bottom, width: contentView.width - albumCoverImageView.right - 10, height: 30)
        
        numberOfTracksLabel.frame = CGRect(x: albumCoverImageView.right + 10, y: contentView.bottom - 44, width: contentView.width - albumCoverImageView.right - 10, height: 44)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        albumNameLabel.text = nil
        artistNameLabel.text = nil
        numberOfTracksLabel.text = nil
        albumCoverImageView.image = nil
    }
    
    public func configure(with viewModel: AlbumCellViewModel) {
        let spinner = UIActivityIndicatorView()
        spinner.color = .black
        spinner.hidesWhenStopped = true
        albumCoverImageView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.leadingAnchor.constraint(equalTo: albumCoverImageView.leadingAnchor),
            spinner.trailingAnchor.constraint(equalTo: albumCoverImageView.trailingAnchor),
            spinner.bottomAnchor.constraint(equalTo: albumCoverImageView.bottomAnchor),
            spinner.topAnchor.constraint(equalTo: albumCoverImageView.topAnchor)
        ])
        spinner.startAnimating()
        
        albumNameLabel.text = viewModel.name
        artistNameLabel.text = viewModel.artistName
        numberOfTracksLabel.text = "Tracks: \(viewModel.numberOfTracks)"
        albumCoverImageView.sd_setImage(with: viewModel.artworkURL) { [weak self] image, _, _, _ in
            spinner.stopAnimating()
            spinner.removeFromSuperview()
            
            guard image == nil else {
                return
            }
            self?.albumCoverImageView.image = UIImage(systemName: "photo.circle")
        }
    }
}
