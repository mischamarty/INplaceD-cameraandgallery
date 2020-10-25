import UIKit
import Photos


class ImageGalleryViewCell: UICollectionViewCell {

  lazy var imageView = UIImageView()
  lazy var selectedImageView = UIImageView()
  lazy var camImageView = UIImageView()
  lazy var timeLabel = UILabel()

  override init(frame: CGRect) {
    super.init(frame: frame)

    for view in [imageView, selectedImageView, camImageView] {
      view.contentMode = .scaleAspectFill
      view.translatesAutoresizingMaskIntoConstraints = false
      view.clipsToBounds = true
      contentView.addSubview(view)
    }
    
    timeLabel.contentMode = .scaleAspectFill
    timeLabel.translatesAutoresizingMaskIntoConstraints = false
    timeLabel.clipsToBounds = true
    contentView.addSubview(timeLabel)

    isAccessibilityElement = true
    accessibilityLabel = "Photo"

    setupConstraints()
  }

  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }

  // MARK: - Configuration
    
    func drawImage(image foreGroundImage:UIImage, inImage backgroundImage:UIImage, atPoint point:CGPoint) -> UIImage{
        UIGraphicsBeginImageContextWithOptions(backgroundImage.size, false, 0.0)
        backgroundImage.draw(in: CGRect(x:0, y:0, width:backgroundImage.size.width, height:backgroundImage.size.height))
        foreGroundImage .draw(in: CGRect(x:point.x, y:point.y, width:backgroundImage.size.width/10, height:backgroundImage.size.width/10))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func stringFromTimeInterval(interval: TimeInterval) -> NSString {
        
        let ti = NSInteger(interval)
        
        //let ms = Int((interval % 1) * 1000)
        
        let seconds = ti % 60
        let minutes = (ti / 60) % 60
        //let hours = (ti / 3600)
        
        return NSString(format: "%0.2d:%0.2d",minutes,seconds)
    }

    func configureCell(_ image: UIImage, _ asset: PHAsset) {
    let camImage = UIImage(named: "buttonPlay")
    imageView.image = image
        timeLabel.textColor = .white
        timeLabel.font = UIFont(name: "Verdana", size: 8)

        switch asset.mediaType {
        case .image:
            print("image")
            //imageView.image = nil
            camImageView.image = nil
            timeLabel.text = ""
        case .video:
            print("video")
            print("image width \(image.size.width)")
            print("image height \(image.size.height)")
            
            timeLabel.text = stringFromTimeInterval(interval: asset.duration) as String

//            imageView.image = self.drawImage(image: camImage!,inImage: image,atPoint: CGPoint(x:image.size.width - 160 + image.size.width/10,y:150))
            camImageView.image = camImage
//            if (image.size.width > image.size.height){
//            imageView.image = self.drawImage(image: camImage!,inImage: image,atPoint: CGPoint(x:image.size.width/10,y:150))
//            }
//            else
//            {
//            imageView.image = self.drawImage(image: camImage!,inImage: image,atPoint: CGPoint(x:image.size.height/10,y:150))
//            }
        default:
            print("default")
        }

  }
}
