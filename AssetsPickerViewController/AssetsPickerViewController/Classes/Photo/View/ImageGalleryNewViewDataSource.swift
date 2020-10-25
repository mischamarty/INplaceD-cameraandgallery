//import UIKit
//import Photos
//
//extension ImageGalleryNewView: UICollectionViewDataSource {
//
//  public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//         let count = AssetsManager.shared.assetArray.count
//         updateEmptyView(count: count)
//         return count
//     }
//     
//     public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//         let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath)
//         guard let cellDelegate = cell as? AssetsPhotoCell else {
//             logw("Failed to cast AssetsPhotoCellProtocolDelegate.")
//             return cell
//         }
//         guard var photoCell = cell as? AssetsPhotoCellProtocol else {
//             logw("Failed to cast UICollectionViewCell.")
//             return cell
//         }
//        
//         
//         photoCell.isVideo = AssetsManager.shared.assetArray[indexPath.row].mediaType == .video
//         photoCell.markedSelected = selectedArray.contains(AssetsManager.shared.assetArray[indexPath.row])
//         //cellDelegate.delegate = self
//         cell.setNeedsUpdateConstraints()
//         cell.updateConstraintsIfNeeded()
//
//         
//         return cell
//     }
//     
//     public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
//         guard var photoCell = cell as? AssetsPhotoCellProtocol else {
//             logw("Failed to cast UICollectionViewCell.")
//             return
//         }
//         
//         let asset = AssetsManager.shared.assetArray[indexPath.row]
//         photoCell.asset = asset
//         photoCell.isVideo = asset.mediaType == .video
//         if photoCell.isVideo {
//             photoCell.duration = asset.duration
//         }
//         
//         if let selectedAsset = selectedMap[asset.localIdentifier] {
//             // update cell UI as selected
//             if let targetIndex = selectedArray.firstIndex(of: selectedAsset) {
//                 photoCell.count = targetIndex + 1
//             }
//         }
//         
//         cancelFetching(at: indexPath)
//         let requestId = AssetsManager.shared.image(at: indexPath.row, size: pickerConfig.assetCacheSize, completion: { [weak self] (image, isDegraded) in
//             if self?.isFetching(indexPath: indexPath) ?? true {
//                 if !isDegraded {
//                     self?.removeFetching(indexPath: indexPath)
//                 }
//                 UIView.transition(
//                     with: photoCell.imageView,
//                     duration: 0.125,
//                     options: .transitionCrossDissolve,
//                     animations: {
//                         photoCell.imageView.image = image
//                 },
//                     completion: nil
//                 )
//             }
//         })
//         registerFetching(requestId: requestId, at: indexPath)
//     }
//     
////     public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
////         cancelFetching(at: indexPath)
////     }
//     
//     public func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
//         guard let footerView = collectionView.dequeueReusableSupplementaryView(ofKind: UICollectionView.elementKindSectionFooter, withReuseIdentifier: footerReuseIdentifier, for: indexPath) as? AssetsPhotoFooterView else {
//             logw("Failed to cast AssetsPhotoFooterView.")
//             return AssetsPhotoFooterView()
//         }
//         footerView.setNeedsUpdateConstraints()
//         footerView.updateConstraintsIfNeeded()
//         footerView.set(imageCount: AssetsManager.shared.count(ofType: .image), videoCount: AssetsManager.shared.count(ofType: .video))
//         return footerView
//     }
//            
//        func cancelFetching(at indexPath: IndexPath) {
//            if let requestId = requestIdMap[indexPath] {
//                requestIdMap.removeValue(forKey: indexPath)
//                AssetsManager.shared.cancelRequest(requestId: requestId)
//            }
//        }
//        
//        func registerFetching(requestId: PHImageRequestID, at indexPath: IndexPath) {
//            requestIdMap[indexPath] = requestId
//        }
//        
//        func removeFetching(indexPath: IndexPath) {
//            if let _ = requestIdMap[indexPath] {
//                requestIdMap.removeValue(forKey: indexPath)
//            }
//        }
//        
//        func isFetching(indexPath: IndexPath) -> Bool {
//            if let _ = requestIdMap[indexPath] {
//                return true
//            } else {
//                return false
//            }
//        }
//}
