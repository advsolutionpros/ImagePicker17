import UIKit

// MARK: - BottomContainer autolayout

extension BottomContainerView {

    func setupConstraints() {
        let screenSize = Helper.screenSizeForOrientation()
        
        // Center pickerButton and borderPickerButton
        for attribute in [.centerX, .centerY] as [NSLayoutConstraint.Attribute] {
            addConstraint(NSLayoutConstraint(item: pickerButton, attribute: attribute,
                                             relatedBy: .equal, toItem: self, attribute: attribute,
                                             multiplier: 1, constant: 0))
            
            addConstraint(NSLayoutConstraint(item: borderPickerButton, attribute: attribute,
                                             relatedBy: .equal, toItem: self, attribute: attribute,
                                             multiplier: 1, constant: 0))
        }

        // Set dimensions for pickerButton, borderPickerButton, and stackView
        for attribute in [.width, .height] as [NSLayoutConstraint.Attribute] {
            addConstraint(NSLayoutConstraint(item: pickerButton, attribute: attribute,
                                             relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                             multiplier: 1, constant: ButtonPicker.Dimensions.buttonSize))
            
            addConstraint(NSLayoutConstraint(item: borderPickerButton, attribute: attribute,
                                             relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                             multiplier: 1, constant: ButtonPicker.Dimensions.buttonBorderSize))
            
            addConstraint(NSLayoutConstraint(item: stackView, attribute: attribute,
                                             relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                             multiplier: 1, constant: ImageStackView.Dimensions.imageSize))
        }

        // Align topSeparator on the top, left, and full width of BottomContainerView
        for attribute in [.width, .left, .top] as [NSLayoutConstraint.Attribute] {
            addConstraint(NSLayoutConstraint(item: topSeparator, attribute: attribute,
                                             relatedBy: .equal, toItem: self, attribute: attribute,
                                             multiplier: 1, constant: 0))
        }
        
        // Center doneButton vertically in the view
        addConstraint(NSLayoutConstraint(item: doneButton, attribute: .centerY,
                                         relatedBy: .equal, toItem: self, attribute: .centerY,
                                         multiplier: 1, constant: 0))
        
        // Center stackView vertically in the view with a slight offset
        addConstraint(NSLayoutConstraint(item: stackView, attribute: .centerY,
                                         relatedBy: .equal, toItem: self, attribute: .centerY,
                                         multiplier: 1, constant: -2))
        
        // Position doneButton on the right side, with a calculated horizontal offset
        addConstraint(NSLayoutConstraint(item: doneButton, attribute: .centerX,
                                         relatedBy: .equal, toItem: self, attribute: .right,
                                         multiplier: 1, constant: -(screenSize.width - (ButtonPicker.Dimensions.buttonBorderSize + screenSize.width) / 2) / 2))

        // Position stackView on the left side, with a calculated horizontal offset
        addConstraint(NSLayoutConstraint(item: stackView, attribute: .centerX,
                                         relatedBy: .equal, toItem: self, attribute: .left,
                                         multiplier: 1, constant: screenSize.width / 4 - ButtonPicker.Dimensions.buttonBorderSize / 3))
        
        // Set the height of the topSeparator
        addConstraint(NSLayoutConstraint(item: topSeparator, attribute: .height,
                                         relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                         multiplier: 1, constant: 1))

        // Hide stackView and borderPickerButton if `cameraOnly` mode is active
        if configuration.cameraOnly {
            stackView.isHidden = true
            borderPickerButton.isHidden = true
        }
    }
}

// MARK: - TopView autolayout

extension TopView {

  func setupConstraints() {
    addConstraint(NSLayoutConstraint(item: flashButton, attribute: .left,
      relatedBy: .equal, toItem: self, attribute: .left,
      multiplier: 1, constant: Dimensions.leftOffset))

    addConstraint(NSLayoutConstraint(item: flashButton, attribute: .centerY,
      relatedBy: .equal, toItem: self, attribute: .centerY,
      multiplier: 1, constant: 0))

    addConstraint(NSLayoutConstraint(item: flashButton, attribute: .width,
      relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
      multiplier: 1, constant: 55))

    if configuration.canRotateCamera {
      addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .right,
        relatedBy: .equal, toItem: self, attribute: .right,
        multiplier: 1, constant: Dimensions.rightOffset))

      addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .centerY,
        relatedBy: .equal, toItem: self, attribute: .centerY,
        multiplier: 1, constant: 0))

      addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .width,
        relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
        multiplier: 1, constant: 55))

      addConstraint(NSLayoutConstraint(item: rotateCamera, attribute: .height,
        relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
        multiplier: 1, constant: 55))
    }
  }
}

// MARK: - Controller autolayout

extension ImagePickerController {
    
    func setupConstraints() {
        let addConstraint: (UIView, NSLayoutConstraint.Attribute, Any, NSLayoutConstraint.Attribute, CGFloat) -> Void = { view1, attribute1, view2, attribute2, constant in
            self.view.addConstraint(NSLayoutConstraint(item: view1, attribute: attribute1,
                                                       relatedBy: .equal, toItem: view2, attribute: attribute2,
                                                       multiplier: 1, constant: constant))
        }

        if configuration.cameraOnly {
            // Only show camera view and top view
            cameraController.view.translatesAutoresizingMaskIntoConstraints = false
            topView.translatesAutoresizingMaskIntoConstraints = false

            addConstraint(cameraController.view!, .leading, view, .leading, 0)
            addConstraint(cameraController.view!, .trailing, view, .trailing, 0)
            view.addConstraint(NSLayoutConstraint(item: cameraController.view!, attribute: .top,
                                                  relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                                                  attribute: .top, multiplier: 1, constant: 0))
            addConstraint(cameraController.view!, .bottom, view, .bottom, 0)

            addConstraint(topView, .leading, view, .leading, 0)
            addConstraint(topView, .trailing, view, .trailing, 0)
            view.addConstraint(NSLayoutConstraint(item: topView, attribute: .top,
                                                  relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                                                  attribute: .top, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: topView, attribute: .height,
                                                  relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
                                                  multiplier: 1, constant: TopView.Dimensions.height))

        } else if configuration.galleryOnly {
            // Only show gallery view
            galleryView.translatesAutoresizingMaskIntoConstraints = false

            addConstraint(galleryView, .leading, view, .leading, 0)
            addConstraint(galleryView, .trailing, view, .trailing, 0)
            view.addConstraint(NSLayoutConstraint(item: galleryView, attribute: .top,
                                                  relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                                                  attribute: .top, multiplier: 1, constant: 0))

            var bottomPadding: CGFloat = 0
            if let windowScene = UIApplication.shared.connectedScenes
                .compactMap({ $0 as? UIWindowScene })
                .first(where: { $0.activationState == .foregroundActive }),
               let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
                bottomPadding = window.safeAreaInsets.bottom
            }

            view.addConstraint(NSLayoutConstraint(item: galleryView, attribute: .height,
                                                  relatedBy: .equal, toItem: view, attribute: .height,
                                                  multiplier: 1, constant: -(BottomContainerView.Dimensions.height + bottomPadding)))
        } else {
            // Default mode (Camera, Gallery, and Bottom Container)
            cameraController.view.translatesAutoresizingMaskIntoConstraints = false
            galleryView.translatesAutoresizingMaskIntoConstraints = false
            topView.translatesAutoresizingMaskIntoConstraints = false
            bottomContainer.translatesAutoresizingMaskIntoConstraints = false

            // Camera constraints
            addConstraint(cameraController.view!, .leading, view, .leading, 0)
            addConstraint(cameraController.view!, .trailing, view, .trailing, 0)
            view.addConstraint(NSLayoutConstraint(item: cameraController.view!, attribute: .top,
                                                  relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                                                  attribute: .top, multiplier: 1, constant: 0))
            addConstraint(cameraController.view!, .bottom, bottomContainer, .top, 0)

            // Gallery constraints
            addConstraint(galleryView, .leading, view, .leading, 0)
            addConstraint(galleryView, .trailing, view, .trailing, 0)
            addConstraint(galleryView, .bottom, bottomContainer, .top, 0)
            view.addConstraint(NSLayoutConstraint(item: galleryView, attribute: .height,
                                                  relatedBy: .equal, toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1, constant: GestureConstants.minimumHeight))

            // Bottom Container constraints
            addConstraint(bottomContainer, .leading, view, .leading, 0)
            addConstraint(bottomContainer, .trailing, view, .trailing, 0)
            view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: .bottom,
                                                  relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                                                  attribute: .bottom, multiplier: 1, constant: 0))
            view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: .height,
                                                  relatedBy: .equal, toItem: nil,
                                                  attribute: .notAnAttribute,
                                                  multiplier: 1, constant: BottomContainerView.Dimensions.height))
        }
    }

  func setupConstraintsOld() {
    let attributes: [NSLayoutConstraint.Attribute] = [.bottom, .right, .width]
    let topViewAttributes: [NSLayoutConstraint.Attribute] = [.left, .width]

    for attribute in attributes {
      view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: attribute,
        relatedBy: .equal, toItem: view, attribute: attribute,
        multiplier: 1, constant: 0))
    }
    
    if configuration.galleryOnly {
      
      for attribute: NSLayoutConstraint.Attribute in [.left, .right] {
        view.addConstraint(NSLayoutConstraint(item: galleryView, attribute: attribute,
          relatedBy: .equal, toItem: view, attribute: attribute,
          multiplier: 1, constant: 0))
      }
      var bottomHeightPadding: CGFloat = 0
     
        view.addConstraint(NSLayoutConstraint(item: galleryView, attribute: .top,
                                              relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                                              attribute: .top,
                                              multiplier: 1, constant: 0))
          if let windowScene = UIApplication.shared.connectedScenes
              .compactMap({ $0 as? UIWindowScene })
              .first(where: { $0.activationState == .foregroundActive }),
              let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
              bottomHeightPadding = window.safeAreaInsets.bottom
          }
      
      view.addConstraint(NSLayoutConstraint(item: galleryView, attribute: .height,
        relatedBy: .equal, toItem: view, attribute: .height,
        multiplier: 1, constant: -(BottomContainerView.Dimensions.height + bottomHeightPadding)))
      
    } else {
      
      for attribute: NSLayoutConstraint.Attribute in [.left, .top, .width] {
        view.addConstraint(NSLayoutConstraint(item: cameraController.view!, attribute: attribute,
          relatedBy: .equal, toItem: view, attribute: attribute,
          multiplier: 1, constant: 0))
      }

      for attribute in topViewAttributes {
        view.addConstraint(NSLayoutConstraint(item: topView, attribute: attribute,
          relatedBy: .equal, toItem: self.view, attribute: attribute,
          multiplier: 1, constant: 0))
      }
      
        view.addConstraint(NSLayoutConstraint(item: topView, attribute: .top,
                                              relatedBy: .equal, toItem: view.safeAreaLayoutGuide,
                                              attribute: .top,
                                              multiplier: 1, constant: 0))
      
      view.addConstraint(NSLayoutConstraint(item: topView, attribute: .height,
        relatedBy: .equal, toItem: nil, attribute: .notAnAttribute,
        multiplier: 1, constant: TopView.Dimensions.height))

      view.addConstraint(NSLayoutConstraint(item: cameraController.view!, attribute: .height,
        relatedBy: .equal, toItem: view, attribute: .height,
        multiplier: 1, constant: -BottomContainerView.Dimensions.height))
    }
      var heightPadding:CGFloat = 0
      if let windowScene = UIApplication.shared.connectedScenes
          .compactMap({ $0 as? UIWindowScene })
          .first(where: { $0.activationState == .foregroundActive }),
          let window = windowScene.windows.first(where: { $0.isKeyWindow }) {
          heightPadding = window.safeAreaInsets.bottom
      }

      view.addConstraint(NSLayoutConstraint(item: bottomContainer, attribute: .height,
                                            relatedBy: .equal, toItem: nil,
                                            attribute: .notAnAttribute,
                                            multiplier: 1,
                                            constant: BottomContainerView.Dimensions.height + heightPadding))
    
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
    }
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
