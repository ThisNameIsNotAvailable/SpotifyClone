//
//  SearchResultSubtitleTableViewCell.swift
//  SpotifyClone
//
//  Created by Alex on 15/11/2022.
//

import UIKit
import SDWebImage

class SearchResultSubtitleTableViewCell: UITableViewCell {
    static let identifier = "SearchResultSubtitleTableViewCell"
    
    private let label: UILabel = {
        let label = UILabel()
        label.numberOfLines = 1
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .secondaryLabel
        label.numberOfLines = 1
        return label
    }()
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = .label
        imageView.layer.masksToBounds = true
        imageView.layer.cornerRadius = 6
        imageView.backgroundColor = .lightGray
        return imageView
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        accessoryType = .disclosureIndicator
        contentView.addSubview(label)
        contentView.addSubview(subtitleLabel)
        contentView.addSubview(iconImageView)
        contentView.clipsToBounds = true
        backgroundColor = .secondarySystemBackground
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        let imageSize: CGFloat = contentView.height - 10
        iconImageView.frame = CGRect(x: 5, y: 5, width: imageSize, height: imageSize)
        let labelHeight = contentView.height / 2
        label.frame = CGRect(x: iconImageView.right + 10, y: 0, width: contentView.width - iconImageView.right - 15, height: labelHeight)
        subtitleLabel.frame = CGRect(x: iconImageView.right + 10, y: labelHeight, width: contentView.width - iconImageView.right - 15, height: labelHeight)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        iconImageView.image = nil
        label.text = nil
        subtitleLabel.text = nil
    }
    
    func configure(with viewModel: SearchResultSubtitleTableViewCellViewModel) {
        let spinner = UIActivityIndicatorView()
        spinner.color = .black
        spinner.hidesWhenStopped = true
        iconImageView.addSubview(spinner)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            spinner.leadingAnchor.constraint(equalTo: iconImageView.leadingAnchor),
            spinner.trailingAnchor.constraint(equalTo: iconImageView.trailingAnchor),
            spinner.bottomAnchor.constraint(equalTo: iconImageView.bottomAnchor),
            spinner.topAnchor.constraint(equalTo: iconImageView.topAnchor)
        ])
        spinner.startAnimating()
        
        label.text = viewModel.title
        subtitleLabel.text = viewModel.subtitle
        iconImageView.sd_setImage(with: viewModel.imageURL) { [weak self] image, _, _, _ in
            spinner.stopAnimating()
            spinner.removeFromSuperview()
            
            guard image == nil else {
                return
            }
            
            self?.iconImageView.image = UIImage(systemName: "photo.circle")
        }
    }
}
