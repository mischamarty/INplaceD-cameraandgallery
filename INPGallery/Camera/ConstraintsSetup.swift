import UIKit

// MARK: - BottomContainer autolayout

extension BottomContainerView {

  func setupConstraints() {

    for attribute: NSLayoutConstraint.Attribute in [.centerX, .centerY] {
      addConstraint(NSLayoutConstraint(item: pickerButton, attribute: attribute,
        relatedBy: .equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0))

      addConstraint(NSLayoutConstraint(item: borderPickerButton, attribute: attribute,
        relatedBy: .equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: borderPickerButton2, attribute: attribute,
                                         relatedBy: .equal, toItem: self, attribute: attribute,
                                         multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: videoButton, attribute: attribute,
                                         relatedBy: .equal, toItem: self, attribute: attribute,
                                         multiplier: 1, constant: 0))
        
    }

    for attribute: NSLayoutConstraint.Attribute in [.width, .left, .top] {
      addConstraint(NSLayoutConstraint(item: topSeparator, attribute: attribute,
        relatedBy: .equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0))
    }

    for attribute: NSLayoutConstraint.Attribute in [.width, .height] {
      addConstraint(NSLayoutConstraint(item: pickerButton, attribute: attribute,
        relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
        multiplier: 1, constant: ButtonPicker.Dimensions.buttonSize))

      addConstraint(NSLayoutConstraint(item: borderPickerButton, attribute: attribute,
        relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
        multiplier: 1, constant: ButtonPicker.Dimensions.buttonBorderSize))
        
      addConstraint(NSLayoutConstraint(item: borderPickerButton2, attribute: attribute,
                                         relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1, constant: ButtonPicker.Dimensions.buttonBorderSize2))
        
        addConstraint(NSLayoutConstraint(item: videoButton, attribute: attribute,
                                         relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1, constant: ButtonPicker.Dimensions.buttonBorderSize2))
        
//      addConstraint(NSLayoutConstraint(item: stackView, attribute: attribute,
//        relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
//        multiplier: 1, constant: ImageStackView.Dimensions.imageSize))
        
              addConstraint(NSLayoutConstraint(item: galleryButton, attribute: attribute,
                relatedBy: .greaterThanOrEqual, toItem: nil, attribute: .notAnAttribute,
                multiplier: 1, constant: ImageStackView.Dimensions.imageSize))
    }

    addConstraint(NSLayoutConstraint(item: doneButton, attribute: .centerY,
      relatedBy: .equal, toItem: self, attribute: .centerY,
      multiplier: 1, constant: -2))

//    addConstraint(NSLayoutConstraint(item: stackView, attribute: .centerY,
//      relatedBy: .equal, toItem: self, attribute: .centerY,
//      multiplier: 1, constant: -2))
    var widthDependingOnOrientation:CGFloat = 0.0
    if (UIScreen.main.bounds.width < UIScreen.main.bounds.height) {
        widthDependingOnOrientation = CGFloat(UIScreen.main.bounds.width)
    }
    else {
        widthDependingOnOrientation = CGFloat(UIScreen.main.bounds.height)

    }
    addConstraint(NSLayoutConstraint(item: galleryButton, attribute: .centerY,
              relatedBy: .equal, toItem: self, attribute: .centerY,
              multiplier: 1, constant: -2))
   ///!!! отодвигаем кнопки от центральной
    addConstraint(NSLayoutConstraint(item: doneButton, attribute: .centerX,
      relatedBy: .equal, toItem: self, attribute: .right,
      //multiplier: 1, constant: -(UIScreen.main.bounds.width - (ButtonPicker.Dimensions.buttonBorderSize + UIScreen.main.bounds.width)/2)/2))
        multiplier: 1, constant: -(widthDependingOnOrientation/4.5 - ButtonPicker.Dimensions.buttonBorderSize/1.5)-5))


//    addConstraint(NSLayoutConstraint(item: stackView, attribute: .centerX,
//      relatedBy: .equal, toItem: self, attribute: .left,
//      multiplier: 1, constant: UIScreen.main.bounds.width/4 - ButtonPicker.Dimensions.buttonBorderSize/1.5))
    
        addConstraint(NSLayoutConstraint(item: galleryButton, attribute: .centerX,
          relatedBy: .equal, toItem: self, attribute: .left,
          multiplier: 1, constant: widthDependingOnOrientation/4.5 - ButtonPicker.Dimensions.buttonBorderSize/1.5))


    addConstraint(NSLayoutConstraint(item: topSeparator, attribute: .height,
      relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
      multiplier: 1, constant: 1))
  }
}

// MARK: - TopView autolayout

extension TopView {

  func setupConstraints() {
    
    
//    flashButton.translatesAutoresizingMaskIntoConstraints = false
//       if #available(iOS 11.0, *) {
//           let guide = self.safeAreaLayoutGuide
//           //flashButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
//           //flashButton.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
//           flashButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
//           flashButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
//           flashButton.trailingAnchor.constraint(equalTo: guide.trailingAnchor, constant: 50).isActive = true
//         //topView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 30).isActive = true
//
//       }
    
    addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .left,
      relatedBy: .equal, toItem: self, attribute: .left,
      multiplier: 1, constant: Dimensions.leftOffset))

    addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .centerY,
      relatedBy: .equal, toItem: self, attribute: .centerY,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .width,
      relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
      multiplier: 1, constant: 55))


    if Configuration.canRotateCamera {
      addConstraint(NSLayoutConstraint(item: flashButton, attribute: .right,
        relatedBy: .equal, toItem: self, attribute: .right,
        multiplier: 1, constant: Dimensions.rightOffset+1))

      addConstraint(NSLayoutConstraint(item: flashButton, attribute: .centerY,
        relatedBy: .equal, toItem: self, attribute: .centerY,
        multiplier: 1, constant: 0))

      addConstraint(NSLayoutConstraint(item: flashButton, attribute: .width,
        relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
        multiplier: 1, constant: 55))

      addConstraint(NSLayoutConstraint(item: flashButton, attribute: .height,
        relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
        multiplier: 1, constant: 55))
    }
  }
}

// MARK: - Controller autolayout

extension ImagePickerController {

  func setupConstraints() {
   // let attributes: [NSLayoutConstraint.Attribute] = [.bottom, .right, .width]
   // let topViewAttributes: [NSLayoutConstraint.Attribute] = [.left, .top, .width]

//    for attribute in attributes {
//      view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: attribute,
//        relatedBy: .equal, toItem: view, attribute: attribute,
//        multiplier: 1, constant: 0))
//    }

//    for attribute: NSLayoutConstraint.Attribute in [.left, .top, .width] {
//      view.addConstraint(NSLayoutConstraint(item: cameraController.view, attribute: attribute,
//        relatedBy: .equal, toItem: view, attribute: attribute,
//        multiplier: 1, constant: 0))
//    }
    
    
//    cameraController.view.translatesAutoresizingMaskIntoConstraints = false
//
//    if #available(iOS 11.0, *) {
//        let guide = self.view.safeAreaLayoutGuide
//        cameraController.view.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
//        cameraController.view.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
//        cameraController.view.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
//        cameraController.view.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
//    }
    
    bottomContainer.translatesAutoresizingMaskIntoConstraints = false
              if #available(iOS 11.0, *) {
                  let guide = self.view.safeAreaLayoutGuide
                  bottomContainer.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
                  bottomContainer.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
                  bottomContainer.heightAnchor.constraint(equalToConstant: 100).isActive = true
                  //bottomContainer.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
                bottomContainer.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -30).isActive = true

              }
    
    
    topView.translatesAutoresizingMaskIntoConstraints = false
    if #available(iOS 11.0, *) {
        let guide = self.view.safeAreaLayoutGuide
        topView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        topView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        //topView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
      topView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 0).isActive = true

    }
       
    
    
    
    
  

    


//    for attribute in topViewAttributes {
//      view.addConstraint(NSLayoutConstraint(item: topView, attribute: attribute,
//        relatedBy: .equal, toItem: self.view, attribute: attribute,
//        multiplier: 1, constant: 0))
//    }

//    view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: .height,
//      relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
//      multiplier: 1, constant: BottomContainerView.Dimensions.height))

//    view.addConstraint(NSLayoutConstraint(item: topView, attribute: .height,
//      relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
//      multiplier: 1, constant: TopView.Dimensions.height))
    
    view.addConstraint(NSLayoutConstraint(item: timerCamera, attribute: .top,
                                          relatedBy: .equal, toItem: view, attribute: .top,
                                          multiplier: 1, constant: 5))

    
    view.addConstraint(NSLayoutConstraint(item: timerCamera, attribute: .height,
                                          relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                          multiplier: 1, constant: 25))
    
    view.addConstraint(NSLayoutConstraint(item: timerCamera, attribute: .centerX,
                                          relatedBy: .equal, toItem: self.view, attribute: .centerX,
                                          multiplier: 1, constant:0))
    
    view.addConstraint(NSLayoutConstraint(item: reddot, attribute: .top,
                                          relatedBy: .equal, toItem: view, attribute: .top,
                                          multiplier: 1, constant: 15))
    
    
    view.addConstraint(NSLayoutConstraint(item: reddot, attribute: .height,
                                          relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                          multiplier: 1, constant: 6))
    
    view.addConstraint(NSLayoutConstraint(item: reddot, attribute: .width,
                                          relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                          multiplier: 1, constant: 6))
    
    view.addConstraint(NSLayoutConstraint(item: reddot, attribute: .centerX,
                                          relatedBy: .equal, toItem: self.view, attribute: .centerX,
                                          multiplier: 1, constant:-41))

//    view.addConstraint(NSLayoutConstraint(item: cameraController.view, attribute: .height,
//      relatedBy: .equal, toItem: view, attribute: .height,
//      multiplier: 1, constant: -BottomContainerView.Dimensions.height + 101))
  }
}


extension ImagePickerGalleryController {

  func setupConstraints() {
   // let attributes: [NSLayoutConstraint.Attribute] = [.bottom, .right, .width]
   // let topViewAttributes: [NSLayoutConstraint.Attribute] = [.left, .top, .width]

//    for attribute in attributes {
//      view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: attribute,
//        relatedBy: .equal, toItem: view, attribute: attribute,
//        multiplier: 1, constant: 0))
//    }

//    for attribute: NSLayoutConstraint.Attribute in [.left, .top, .width] {
//      view.addConstraint(NSLayoutConstraint(item: cameraController.view, attribute: attribute,
//        relatedBy: .equal, toItem: view, attribute: attribute,
//        multiplier: 1, constant: 0))
//    }
    
    
//    cameraController.view.translatesAutoresizingMaskIntoConstraints = false
//
//    if #available(iOS 11.0, *) {
//        let guide = self.view.safeAreaLayoutGuide
//        cameraController.view.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
//        cameraController.view.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
//        cameraController.view.topAnchor.constraint(equalTo: guide.topAnchor).isActive = true
//        cameraController.view.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
//    }
    
    bottomContainer.translatesAutoresizingMaskIntoConstraints = false
              if #available(iOS 11.0, *) {
                  let guide = self.view.safeAreaLayoutGuide
                  bottomContainer.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
                  bottomContainer.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
                  bottomContainer.heightAnchor.constraint(equalToConstant: 100).isActive = true
                  //bottomContainer.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
                bottomContainer.bottomAnchor.constraint(equalTo: guide.bottomAnchor, constant: -30).isActive = true

              }
    
    
    topView.translatesAutoresizingMaskIntoConstraints = false
    if #available(iOS 11.0, *) {
        let guide = self.view.safeAreaLayoutGuide
        topView.trailingAnchor.constraint(equalTo: guide.trailingAnchor).isActive = true
        topView.leadingAnchor.constraint(equalTo: guide.leadingAnchor).isActive = true
        topView.heightAnchor.constraint(equalToConstant: 20).isActive = true
        //topView.bottomAnchor.constraint(equalTo: guide.bottomAnchor).isActive = true
      topView.topAnchor.constraint(equalTo: guide.topAnchor, constant: 0).isActive = true

    }
       
    
    
    
    
  

    


//    for attribute in topViewAttributes {
//      view.addConstraint(NSLayoutConstraint(item: topView, attribute: attribute,
//        relatedBy: .equal, toItem: self.view, attribute: attribute,
//        multiplier: 1, constant: 0))
//    }

//    view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: .height,
//      relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
//      multiplier: 1, constant: BottomContainerView.Dimensions.height))

//    view.addConstraint(NSLayoutConstraint(item: topView, attribute: .height,
//      relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
//      multiplier: 1, constant: TopView.Dimensions.height))
    
    view.addConstraint(NSLayoutConstraint(item: timerCamera, attribute: .top,
                                          relatedBy: .equal, toItem: view, attribute: .top,
                                          multiplier: 1, constant: 5))

    
    view.addConstraint(NSLayoutConstraint(item: timerCamera, attribute: .height,
                                          relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                          multiplier: 1, constant: 25))
    
    view.addConstraint(NSLayoutConstraint(item: timerCamera, attribute: .centerX,
                                          relatedBy: .equal, toItem: self.view, attribute: .centerX,
                                          multiplier: 1, constant:0))
    
    view.addConstraint(NSLayoutConstraint(item: reddot, attribute: .top,
                                          relatedBy: .equal, toItem: view, attribute: .top,
                                          multiplier: 1, constant: 15))
    
    
    view.addConstraint(NSLayoutConstraint(item: reddot, attribute: .height,
                                          relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                          multiplier: 1, constant: 6))
    
    view.addConstraint(NSLayoutConstraint(item: reddot, attribute: .width,
                                          relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                          multiplier: 1, constant: 6))
    
    view.addConstraint(NSLayoutConstraint(item: reddot, attribute: .centerX,
                                          relatedBy: .equal, toItem: self.view, attribute: .centerX,
                                          multiplier: 1, constant:-41))

//    view.addConstraint(NSLayoutConstraint(item: cameraController.view, attribute: .height,
//      relatedBy: .equal, toItem: view, attribute: .height,
//      multiplier: 1, constant: -BottomContainerView.Dimensions.height + 101))
  }
}

extension ImageGalleryViewCell {

  func setupConstraints() {

    for attribute: NSLayoutConstraint.Attribute in [.width, .height, .centerX, .centerY] {
      addConstraint(NSLayoutConstraint(item: imageView, attribute: attribute,
        relatedBy: .equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0))

      addConstraint(NSLayoutConstraint(item: selectedImageView, attribute: attribute,
        relatedBy: .equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0))
        
        addConstraint(NSLayoutConstraint(item: camImageView, attribute: attribute,
                                         relatedBy: .equal, toItem: self, attribute: attribute,
                                         multiplier: 1, constant: 0))
        
    }
    
    addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .bottom,
                                     relatedBy: .equal, toItem: self, attribute: .bottom,
                                     multiplier: 1, constant: -8))
    
    addConstraint(NSLayoutConstraint(item: timeLabel, attribute: .right,
                                     relatedBy: .equal, toItem: self, attribute: .right,
                                     multiplier: 1, constant: -6))
  }
}

extension ButtonPicker {

  func setupConstraints() {
    let attributes: [NSLayoutConstraint.Attribute] = [.centerX, .centerY]

    for attribute in attributes {
      addConstraint(NSLayoutConstraint(item: numberLabel, attribute: attribute,
        relatedBy: .equal, toItem: self, attribute: attribute,
        multiplier: 1, constant: 0))
    }
  }
}
