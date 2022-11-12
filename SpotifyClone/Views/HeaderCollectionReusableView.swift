//
//  HeaderCollectionReusableView.swift
//  SpotifyClone
//
//  Created by Alex on 11/11/2022.
//

import UIKit

final class HeaderCollectionReusableView: UICollectionReusableView {
    static let identifier = "HeaderCollectionReusableView"
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 26, weight: .bold)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(headerLabel)
        layer.cornerRadius = 6
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        headerLabel.frame = CGRect(x: 5, y: 0, width: width - 5, height: height)
    }
    
    func configure(with title: String) {
        headerLabel.text = title
    }
    
    override func prepareForReuse() {
        headerLabel.text = nil
    }
}
