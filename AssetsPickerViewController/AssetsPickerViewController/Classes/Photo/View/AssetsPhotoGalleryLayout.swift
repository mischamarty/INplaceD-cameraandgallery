//
//  AssetsPhotoLayout.swift
//  Pods
//
//  Created by DragonCherry on 5/18/17.
//
//

import UIKit
import Device

open class AssetsPhotoGalleryLayout: UICollectionViewFlowLayout {
    
    open var translatedOffset: CGPoint?
    fileprivate var pickerConfig: AssetsPickerConfig
    
    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public init(pickerConfig: AssetsPickerConfig) {
        self.pickerConfig = pickerConfig
        super.init()
    }
    
    
    
//    open override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
//        print("()----------------------invalidateLayout")
//        print("()---------------------- context.contentOffsetAdjustment \( context.contentOffsetAdjustment)")
//        print("()---------------------- context.contentSizeAdjustment \( context.contentSizeAdjustment)")
//    
//        //self.invalidateLayout()
//        let indexp = [IndexPath(item: 0, section: 0)]
//        context.invalidateItems(at: indexp)
//        
//    }
//     

    
//    open override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
//           let attributes = super.layoutAttributesForElements(in: rect)
//
//        
//        print("()---- layoutAttributesForElements ")
//           var leftMargin = sectionInset.left
//        print("()----  attributes \(attributes)")
//           var maxX: CGFloat = -1.0
//           attributes?.forEach { layoutAttribute in
//               if layoutAttribute.frame.origin.x >= maxX {
//                   leftMargin = sectionInset.left
//               }
//
//               layoutAttribute.frame.origin.x = leftMargin
//
//               leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
//               maxY = max(layoutAttribute.frame.maxX , maxY)
//           }
//
//           return attributes
//       }
//    
//    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint
//        {
//            if let collectionViewBounds = self.collectionView?.bounds
//            {
//                let halfWidthOfVC = collectionViewBounds.size.width * 0.5
//                let proposedContentOffsetCenterX = proposedContentOffset.x + halfWidthOfVC
//                if let attributesForVisibleCells = self.layoutAttributesForElements(in: collectionViewBounds)
//                {
//                    var candidateAttribute : UICollectionViewLayoutAttributes?
//                    for attributes in attributesForVisibleCells
//                    {
//                        let candAttr : UICollectionViewLayoutAttributes? = candidateAttribute
//                        if candAttr != nil
//                        {
//                            let a = attributes.center.x - proposedContentOffsetCenterX
//                            let b = candAttr!.center.x - proposedContentOffsetCenterX
//                            if fabs(a) < fabs(b)
//                            {
//                                candidateAttribute = attributes
//                            }
//                        }
//                        else
//                        {
//                            candidateAttribute = attributes
//                            continue
//                        }
//                    }
//
//                    if candidateAttribute != nil
//                    {
//                        return CGPoint(x: candidateAttribute!.center.x - halfWidthOfVC, y: proposedContentOffset.y);
//                    }
//                }
//            }
//            return CGPoint.zero
//        }
    
//    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint, withScrollingVelocity velocity: CGPoint) -> CGPoint {
//        return targetContentOffset(forProposedContentOffset: proposedContentOffset)
//    }
//
//    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
//        if let translatedOffset = self.translatedOffset {
//            return translatedOffset
//        } else {
//            return proposedContentOffset
//        }
//    }
}

extension AssetsPhotoGalleryLayout {
    
//    open override func targetContentOffset(forProposedContentOffset proposedContentOffset: CGPoint) -> CGPoint {
//        let itemIndex = round(proposedContentOffset.x)
//          let xOffset = itemIndex
//        print("targetContentOffset")
//          return CGPoint(x: 0, y: 0)
//    }
//    open func expectedContentHeight(forViewSize size: CGSize, isPortrait: Bool) -> CGFloat {
//        var rows = AssetsManager.shared.assetArray.count / (isPortrait ? pickerConfig.assetPortraitColumnCount : pickerConfig.assetLandscapeColumnCount)
//        let remainder = AssetsManager.shared.assetArray.count % (isPortrait ? pickerConfig.assetPortraitColumnCount : pickerConfig.assetLandscapeColumnCount)
//        rows += remainder > 0 ? 1 : 0
//
//        let cellSize = isPortrait ? pickerConfig.assetPortraitCellSize(forViewSize: UIScreen.main.portraitContentSize) : pickerConfig.assetLandscapeCellSize(forViewSize: UIScreen.main.landscapeContentSize)
//        let lineSpace = isPortrait ? pickerConfig.assetPortraitLineSpace : pickerConfig.assetLandscapeLineSpace
//        let contentHeight = CGFloat(rows) * cellSize.height + (CGFloat(max(rows - 1, 0)) * lineSpace)
//        let bottomHeight = cellSize.height * 2/3 + Device.safeAreaInsets(isPortrait: isPortrait).bottom
//
//        return contentHeight + bottomHeight
//    }
//
//    private func offsetRatio(collectionView: UICollectionView, offset: CGPoint, contentSize: CGSize, isPortrait: Bool) -> CGFloat {
//        print("currentRatio")
//
//        return (offset.x > 0 ? offset.x : 0) / ((contentSize.width + Device.safeAreaInsets(isPortrait: isPortrait).left) - collectionView.bounds.width)
//    }
//
//    open func translateOffset(forChangingSize size: CGSize, currentOffset: CGPoint) -> CGPoint? {
//        guard let collectionView = self.collectionView else {
//            return nil
//        }
//        print("currentRatio2")
//
//        let isPortraitFuture = size.height > size.width
//        let isPortraitCurrent = collectionView.bounds.size.height > collectionView.bounds.size.width
//        let contentHeight = expectedContentHeight(forViewSize: size, isPortrait: isPortraitFuture)
//        let currentRatio = offsetRatio(collectionView: collectionView, offset: currentOffset, contentSize: collectionView.contentSize, isPortrait: isPortraitCurrent)
//        var futureOffsetX = (contentHeight - size.width) * currentRatio
//
//        if currentOffset.x < 0 {
//            let insetRatio = (-currentOffset.y) / Device.safeAreaInsets(isPortrait: isPortraitCurrent).top
//            let insetDiff = Device.safeAreaInsets(isPortrait: isPortraitFuture).top * insetRatio
//            futureOffsetX -= insetDiff
//        }
//        print("translate offset")
//        return CGPoint(x: futureOffsetX, y: 0)
//    }
}
