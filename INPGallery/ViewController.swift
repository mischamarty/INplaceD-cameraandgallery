//
//  ViewController.swift
//  INPGallery
//
//  Created by mischa on 19/06/2019.
//  Copyright © 2019 mischa. All rights reserved.
//

import UIKit
import AssetsPickerViewController
import Photos


private let imageSize = CGSize(width: 80, height: 80)

class ViewController: UIViewController, AssetsPickerViewControllerDelegate {
    func assetsPicker(controller: AssetsPickerViewController, selected assets: [PHAsset]) {
        print("selected assets delegate")
    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    //--- custom cell for Album

    
    class CustomAlbumCell: UICollectionViewCell, AssetsAlbumCellProtocol {
        //private let imageSize = CGSize(width: 80, height: 80)

        // MARK: - AssetsAlbumCellProtocol
        var album: PHAssetCollection? {
            didSet {}
        }
        
        override var isSelected: Bool {
            didSet {
                if isSelected {
                    contentView.dim(animated: false, color: .gray, alpha: 0.3)
                } else {
                    contentView.undim()
                }
            }
        }
        
        var imageView: UIImageView = {
            let view = UIImageView()
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFill
            view.backgroundColor = UIColor(rgbHex: 0xF0F0F0)
            return view
        }()
        
        var titleText: String? {
            didSet {
                if let titleText = self.titleText {
                    titleLabel.text = "\(titleText) (\(count))"
                } else {
                    titleLabel.text = nil
                }
            }
        }
        
        var count: Int = 0 {
            didSet {
                if let titleText = self.titleText {
                    titleLabel.text = "\(titleText) (\(count))"
                } else {
                    titleLabel.text = nil
                }
            }
        }
        
        // MARK: - At your service
        
        var titleLabel: UILabel = {
            let label = UILabel()
            label.clipsToBounds = true
            return label
        }()
        
        required init?(coder aDecoder: NSCoder) {
            super.init(coder: aDecoder)
            commonInit()
        }
        override init(frame: CGRect) {
            super.init(frame: frame)
            commonInit()
        }
        
        private func commonInit() {
            contentView.addSubview(imageView)
            contentView.addSubview(titleLabel)
            
            imageView.snp.makeConstraints { (make) in
                make.size.equalTo(imageSize)
                make.leading.equalToSuperview()
            }
            titleLabel.snp.makeConstraints { (make) in
                make.leading.equalTo(imageView.snp.trailing).inset(10)
                make.top.equalToSuperview()
                make.bottom.equalToSuperview()
                make.trailing.equalToSuperview()
            }
        }
    }
    
    // ---
    @IBOutlet weak var imageView: UIImageView!
    @IBAction func pressedCamera(_ sender: Any) {
//        print("hehehehehe2");


        let controller = ImagePickerGalleryController()
              //controller.delegate = self
              //controller.sourceType = .camera
        controller.modalPresentationStyle = .fullScreen

              self.present(controller, animated: true, completion:nil)
        
    }
    
    @IBAction func pressedGo(_ sender: Any) {
        print("Go Pressed")
        let pickerConfig = AssetsPickerConfig()
        pickerConfig.assetCellType = AssetsPhotoCell.classForCoder()
        pickerConfig.albumCellType = CustomAlbumCell.classForCoder()
        pickerConfig.albumPortraitForcedCellHeight = imageSize.height
        pickerConfig.albumLandscapeForcedCellHeight = imageSize.height
        pickerConfig.albumForcedCacheSize = imageSize
        pickerConfig.albumDefaultSpace = 1
        pickerConfig.albumLineSpace = 1
        pickerConfig.albumPortraitColumnCount = 1
        pickerConfig.albumLandscapeColumnCount = 1

        let picker = AssetsPickerViewController()
        picker.pickerConfig = pickerConfig
        //picker.pickerDelegate = self

        picker.modalPresentationStyle = .fullScreen
        self.present(picker, animated: true, completion: nil)
        
    }
    
    @IBAction func pressedGo2(_ sender: Any) {

        print("Go2 Pressed")
        let pickerConfig = AssetsPickerConfig()
        pickerConfig.assetCellType = AssetsPhotoCell.classForCoder()
        pickerConfig.albumCellType = CustomAlbumCell.classForCoder()
        pickerConfig.albumPortraitForcedCellHeight = imageSize.height
        pickerConfig.albumLandscapeForcedCellHeight = imageSize.height
        pickerConfig.albumForcedCacheSize = imageSize
        pickerConfig.albumDefaultSpace = 1
        pickerConfig.albumLineSpace = 1
        pickerConfig.albumPortraitColumnCount = 1
        pickerConfig.albumLandscapeColumnCount = 1        
        
        let config = pickerConfig.prepare()

    
        AssetsManager.shared.pickerConfig = pickerConfig
        let controller = AssetsGalleryPhotoViewController()
        AssetsManager.shared.pickerConfig = config

        controller.pickerConfig = config

//        TinyLog.isShowInfoLog = false
//        TinyLog.isShowErrorLog = false
        AssetsManager.shared.registerObserver()

        controller.modalPresentationStyle = .fullScreen
        self.present(controller, animated: true, completion: nil)
        
       // self.navigationController?.pushViewController(controller, animated: true)
    
    }
    
    
  
}

