//
//  ButtonStatusView.swift
//  AssetsPickerViewController
//
//  Created by mischa on 25/08/2019.
//

import UIKit

class ButtonStatusView: UIView {
    
    var prevCount:Int = 0;
    
    let button:UIButton = {
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 35, height: 35)
        button.backgroundColor = UIColor(red: 5/255, green: 203/255, blue: 201/255, alpha: 1)
        
        button.contentMode = .center
        
        //button.layer.cornerRadius = 0.5 * button.frame.size.width
        
        button.layer.cornerRadius = button.frame.width / 2;
        
        button.titleLabel?.font = UIFont(name: "Verdana", size: 20)
        
        
        
        //button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 0
        button.clipsToBounds = true
        
        button.setTitleColor(UIColor.white, for: .normal)
        button.isHidden = true
        return button
    }()
    
    convenience init(frame: CGRect, count: Int) {
        self.init(frame: frame)
        self.updateStatusView(count: count, animated: false)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        //        let viewExt = UIView()
        //        viewExt.frame =  CGRect(x: 0, y: 0, width: 60, height: 60)
        //button.frame = frame
        self.addSubview(button)
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open func updateStatusView(count: Int, animated: Bool) {
        
        if (count >= 1) {
            button.isHidden = false
            
            if(animated) {
                if (prevCount == 0 && count >= 1){
                    self.button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    
                    
                    
                    UIView.animate(withDuration: 0.15, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
                        self.button.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                        
                    }, completion: { _ in
                        
                    })
                    
                }
            }
        }
        else {
            if(animated) {
                self.button.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
                UIView.animate(withDuration: 0.15, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
                    self.button.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
                    
                }, completion: { _ in
                    self.button.isHidden = true
                })
            } else {
                self.button.isHidden = true
            }
        }
        if (count == 0){
            button.setTitle("1", for: .normal)
        }
        else {
            button.setTitle("\(count)", for: .normal)
        }
        prevCount =  count;
        
    }
    
    
    
}
