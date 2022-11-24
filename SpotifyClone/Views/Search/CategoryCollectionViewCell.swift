//
//  GenreCollectionViewCell.swift
//  SpotifyClone
//
//  Created by Alex on 15/11/2022.
//

import UIKit
import SDWebImage

class CategoryCollectionViewCell: UICollectionViewCell {
    
    static let identifier = "GenreCollectionViewCell"
    
    private let backImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.alpha = 0.4
        imageView.layer.masksToBounds = true
        return imageView
    }()
    
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        return label
    }()
    
    private let colors: [UIColor] = [
        .systemPink,
        .systemBlue,
        .systemPurple,
        .systemGreen,
        .systemRed,
        .systemYellow,
        .darkGray,
        .systemTeal,
        .systemOrange
    ]
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.layer.cornerRadius = 8
        contentView.layer.masksToBounds = true
        addSubview(backImageView)
        addSubview(label)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        backImageView.image = nil
        contentView.backgroundColor = nil
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backImageView.frame = contentView.bounds
        label.frame = CGRect(x: 10, y: 10, width: contentView.width - 20, height: contentView.height)
    }
    
    func configure(with viewModel: CategoryCollectionViewCellViewModel) {
        label.text = viewModel.title
        backImageView.sd_setImage(with: viewModel.artworkURL)
        contentView.backgroundColor = colors.randomElement()
    }
}
