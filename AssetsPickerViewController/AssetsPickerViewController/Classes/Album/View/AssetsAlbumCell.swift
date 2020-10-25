//
//  AssetsAlbumCell.swift
//  Pods
//
//  Created by DragonCherry on 5/17/17.
//
//

import UIKit
import Photos

public protocol AssetsAlbumCellProtocol {
    var album: PHAssetCollection? { get set }
    var isSelected: Bool { get set }
    var imageView: UIImageView { get }
    var titleText: String? { get set }
    var count: Int { get set }
}

open class AssetsAlbumCell: UICollectionViewCell, AssetsAlbumCellProtocol {
    
    // MARK: - AssetsAlbumCellProtocol
    open var album: PHAssetCollection? {
        didSet {
            // customizable
        }
    }
    
    open override var isSelected: Bool {
        didSet {
            if isSelected {
                imageView.dim(animated: false)
            } else {
                imageView.undim(animated: false)
            }
        }
    }
    
    public let imageView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = UIColor(rgbHex: 0xF0F0F0)
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 5
        //view.frame = CGRect(x:0, y:0, width: 35, height: 35)
        return view
    }()
    
    public let arrowImageView: UIImageView = {
        let view = UIImageView(image: UIImage(named:"galka_right3"))
        return view
    }()
    
    open var titleText: String? {
        didSet {
            titleLabel.text = titleText
        }
    }
    
    open var count: Int = 0 {
        didSet {
            countLabel.text = "\(NumberFormatter.decimalString(value: count))"
        }
    }
    
    // MARK: - Views
    fileprivate let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont(name: "Verdana", size: 15)

       // label.font = UIFont.systemFont(forStyle: .subheadline)
        return label
    }()
    
    fileprivate let countLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(red:104/255, green:111/255, blue:116/255, alpha:1.0)
        label.font = UIFont(name: "Verdana", size: 14)
            //UIFont.systemFont(forStyle: .subheadline)
        //button.titleLabel?.font = UIFont(name: "Verdana", size: 20)

        return label
    }()

    
    // MARK: - Lifecycle
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    private func commonInit() {
        
        contentView.addSubview(imageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(arrowImageView)

        
        imageView.snp.makeConstraints { (make) in
            //make.height.equalTo(imageView.snp.width)
            make.height.equalTo(80)
            make.width.equalTo(80)
            make.top.equalToSuperview()
            //make.leading.equalToSuperview()
            //make.trailing.equalToSuperview()
        }
        
        titleLabel.snp.makeConstraints { (make) in
                    make.left.equalTo(imageView.snp.right).offset(8)
//                    make.top.equalTo(imageView.snp.top).offset(8)
            make.centerY.equalToSuperview().offset(-9)
                    make.height.equalTo(titleLabel.font.pointSize + 2)
                }
        
//        titleLabel.snp.makeConstraints { (make) in
//            make.left.equalTo(imageView.snp.right).offset(8)
//            make.top.equalTo(imageView.snp.top).offset(8)
//            make.height.equalTo(titleLabel.font.pointSize + 2)
//        }
        
        arrowImageView.snp.makeConstraints{(make) in
            make.trailing.equalToSuperview().offset(10)
            make.centerY.equalToSuperview()
        }

        countLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(2)
            make.left.equalTo(titleLabel.snp.left).offset(0)

//            make.leading.equalToSuperview()
//            make.trailing.equalToSuperview()
            make.height.equalTo(countLabel.font.pointSize + 2)
        }
    }
}
