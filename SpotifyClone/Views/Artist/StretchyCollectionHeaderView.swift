//
//  StretchyCollectionHeaderView.swift
//  SpotifyClone
//
//  Created by Alex on 16/11/2022.
//

import UIKit
import SDWebImage

class StretchyCollectionHeaderView: UICollectionReusableView {
    
    static let identifier = "StretchyCollectionHeaderView"
    public let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    public let label: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 50, weight: .semibold)
        label.textColor = .label
        label.backgroundColor = .tertiarySystemBackground.withAlphaComponent(0.65)
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        return label
    }()
    
    public let followersLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .light)
        label.textColor = .label
        label.backgroundColor = .tertiarySystemBackground.withAlphaComponent(0.65)
        label.layer.cornerRadius = 6
        label.layer.masksToBounds = true
        return label
    }()
    
    public let headerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(imageView)
        addSubview(label)
        addSubview(followersLabel)
        addSubview(headerLabel)
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func configure(with model: StretchyCollectionHeaderViewModel) {
        imageView.sd_setImage(with: model.imageURL)
        label.text = model.artistName
        headerLabel.text = model.title
        if let followers = model.followers {
            followersLabel.text = "Followers: \(followers)"
        } else {
            followersLabel.text = "No Followers Yet"
        }
        setViewConstraints()
    }
    
    func setViewConstraints() {
        
        NSLayoutConstraint.activate([
            headerLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            headerLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            headerLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
            headerLabel.heightAnchor.constraint(equalToConstant: 40),

            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            imageView.bottomAnchor.constraint(equalTo: headerLabel.topAnchor),

            followersLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            followersLabel.bottomAnchor.constraint(equalTo: imageView.bottomAnchor, constant: -10),
            followersLabel.heightAnchor.constraint(equalToConstant: 20),

            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 10),
            label.bottomAnchor.constraint(equalTo: followersLabel.topAnchor),
            label.heightAnchor.constraint(equalToConstant: 50)
            
        ])
    }
}
