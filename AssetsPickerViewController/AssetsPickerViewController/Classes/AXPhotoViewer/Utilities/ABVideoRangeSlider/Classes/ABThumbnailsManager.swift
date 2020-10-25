//
//  ABThumbnailsHelper.swift
//  selfband
//
//  Created by Oscar J. Irun on 27/11/16.
//  Copyright © 2016 appsboulevard. All rights reserved.
//

import UIKit
import AVFoundation

class ABThumbnailsManager: NSObject {
    
    var thumbnailViews = [UIImageView]()

    private func addImagesToView(images: [UIImage], view: UIView){
        //print("removing thumbnails")
        self.thumbnailViews.removeAll()
        var xPos: CGFloat = 0.0
        var width: CGFloat = 0.0
        for image in images{
            DispatchQueue.main.async {
                if xPos + view.frame.size.height < view.frame.width{
                    width = view.frame.size.height
                }else{
                    width = view.frame.size.width - xPos
                }
                
                let imageView = UIImageView(image: image)
                imageView.alpha = 0
                imageView.contentMode = UIView.ContentMode.scaleAspectFill
                imageView.clipsToBounds = true
                imageView.frame = CGRect(x: xPos,
                                         y: 0.0,
                                         width: width,
                                         height: view.frame.size.height)
                self.thumbnailViews.append(imageView)
                
                
                view.addSubview(imageView)
                UIView.animate(withDuration: 0.3, animations: {() -> Void in
                    imageView.alpha = 1.0
                })
                view.sendSubviewToBack(imageView)
                xPos = xPos + view.frame.size.height
            }
        }
    }
    
    private func thumbnailCount(inView: UIView) -> Int {
		
		var num : Double = 0;
		
		DispatchQueue.main.sync {
        	num = Double(inView.frame.size.width) / Double(inView.frame.size.height)
		}

        return Int(ceil(num))
    }
    
    func updateThumbnails(view: UIView, videoURL: URL, duration: Float64) -> [UIImageView]{
        print("updating thumbnails")
        var thumbnails = [UIImage]()
        var offset: Float64 = 0

        let duration2 = ABVideoHelper.videoDuration(videoURL: videoURL)

        
        for view in self.thumbnailViews{
            DispatchQueue.main.sync
            {
                view.removeFromSuperview()
            }
        }
        
        
        let imagesCount = self.thumbnailCount(inView: view)
//        print(" offset " ,offset)
//        print(" imagesCount " ,imagesCount)
//        print(" duration " ,duration)
//        print(" duration2 " ,duration2)



        for i in 0..<imagesCount{
            let thumbnail = ABVideoHelper.thumbnailFromVideo(videoUrl: videoURL,
                                                             time: CMTimeMake(value: Int64(offset), timescale: 1))
            offset = Float64(i) * (duration2 / Float64(imagesCount))
            thumbnails.append(thumbnail)
        }
        self.addImagesToView(images: thumbnails, view: view)
//        print(" thumbnails " ,thumbnails)
//        print(" view ", view)
        
        return self.thumbnailViews
    }
}
