//
//  HeaderCollectionReusableView.swift
//  SpotifyClone
//
//  Created by Alex on 11/11/2022.
//

import UIKit

final class HomeHeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "HomeHeaderCollectionReusableView"
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .label
        label.numberOfLines = 1
        label.font = .systemFont(ofSize: 26, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
        addSubview(headerLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        headerLabel.frame = CGRect(x: 15, y: 0, width: width - 30, height: height)
    }
    
    func configure(with title: String) {
        headerLabel.text = title
    }
    
    override func prepareForReuse() {
        headerLabel.text = nil
    }
}
