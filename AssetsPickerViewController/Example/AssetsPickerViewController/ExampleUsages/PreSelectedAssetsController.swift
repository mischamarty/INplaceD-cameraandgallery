//
//  PreSelectedAssetsController.swift
//  AssetsPickerViewController_Example
//
//  Created by DragonCherry on 9/27/17.
//  Copyright © 2017 CocoaPods. All rights reserved.
//

import AssetsPickerViewController

class PreSelectedAssetsController: CommonExampleController {
    
    override func pressedPick(_ sender: Any) {
        
        let pickerConfig = AssetsPickerConfig()
        
        // set previously selected assets as selected assets on initial load
        pickerConfig.selectedAssets = self.assets
        
        let picker = AssetsPickerViewController()
        picker.pickerConfig = pickerConfig
        picker.pickerDelegate = self
        
        present(picker, animated: true, completion: nil)
    }
}
