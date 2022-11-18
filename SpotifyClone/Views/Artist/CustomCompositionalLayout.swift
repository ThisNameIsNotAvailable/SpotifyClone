//
//  CustomCompositionalLayout.swift
//  SpotifyClone
//
//  Created by Alex on 16/11/2022.
//

import UIKit

class CustomCompositionalLayout: UICollectionViewCompositionalLayout {
    override init(sectionProvider: @escaping UICollectionViewCompositionalLayoutSectionProvider) {
        super.init(sectionProvider: sectionProvider)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var isSet = false
    private var offset: CGFloat!
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let layoutAttributes = super.layoutAttributesForElements(in: rect)

        layoutAttributes?.forEach { attribute in
            if attribute.representedElementKind == UICollectionView.elementKindSectionHeader && attribute.indexPath.section == 0 {
                guard let collectionView = collectionView else { return }
                let contentOffsetY = collectionView.contentOffset.y
                if !isSet {
                    isSet = true
                    offset = contentOffsetY
                }
                if contentOffsetY < 0 {
                    let width = collectionView.frame.width
                    let height = attribute.frame.width - contentOffsetY
                    attribute.frame = CGRect(x: 0, y: contentOffsetY, width: width, height: height)
                }
                guard let header = collectionView.supplementaryView(forElementKind: UICollectionView.elementKindSectionHeader, at: attribute.indexPath) as? StretchyCollectionHeaderView else {
                    return
                }
                let start = collectionView.width - header.headerLabel.height
                let alpha = 1 - (contentOffsetY - offset) / start
                if alpha < 0.5 {
                    header.imageView.alpha = 2*alpha
                    switch alpha {
                    case 0.3...0.4:
                        header.label.alpha = 2*alpha
                        header.followersLabel.alpha = 2*alpha
                    case 0.15...0.3:
                        header.label.alpha = 1.6*alpha
                        header.followersLabel.alpha = 1.6*alpha
                    case 0...0.15:
                        header.label.alpha = 1.2*alpha
                        header.followersLabel.alpha = 1.2*alpha
                    default:
                        break
                    }
                    header.headerLabel.alpha = 1
                }else {
                    header.label.alpha = 1
                    header.followersLabel.alpha = 1
                    header.imageView.alpha = 1
                }
            }
        }

        return layoutAttributes
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
}
