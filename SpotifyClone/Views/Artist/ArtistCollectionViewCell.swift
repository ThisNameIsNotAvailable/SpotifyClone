//
//  ArtistCollectionViewCell.swift
//  SpotifyClone
//
//  Created by Alex on 17/11/2022.
//

import UIKit
import SDWebImage

class ArtistCollectionViewCell: UICollectionViewCell {
    static let identifier = "ArtistCollectionViewCell"
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 20)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = .systemBackground
        contentView.addSubview(label)
        contentView.addSubview(imageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        label.text = nil
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        imageView.frame = CGRect(x: 0, y: 0, width: contentView.width - 10, height: contentView.width - 10)
        imageView.layer.cornerRadius = imageView.width / 2
        label.frame = CGRect(x: 0, y: imageView.bottom + 10, width: contentView.width, height: contentView.height - imageView.height - 10)
    }
    
    func configure(with model: ArtistCollectionViewModel) {
        imageView.sd_setImage(with: model.artworkURL)
        label.text = model.name
    }
}
