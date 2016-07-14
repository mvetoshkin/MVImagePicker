//
//  SourcesView.swift
//  MVImagePicker
//
//  Created by Mikhail Vetoshkin on 22/06/16.
//  Copyright (c) 2016 Mikhail Vetoshkin. All rights reserved.
//

import UIKit


@objc protocol ImagePickerSourcesViewDelegate {
    
    func imagePickerSourcesViewCameraDidTap(view: ImagePickerSourcesView)
    func imagePickerSourcesViewLibraryDidTap(view: ImagePickerSourcesView)
}

class ImagePickerSourcesView: UIView, UITabBarDelegate {

    weak var delegate: ImagePickerSourcesViewDelegate?

    // MARK: Lazy init

    lazy private var tabBar: UITabBar = {
        let el = UITabBar(frame: CGRectZero)

        el.barTintColor = UIColor.ipLightGrayColor()
        el.delegate = self
        el.tintColor = UIColor.ipGreenColor()

        el.setItems([self.cameraButton, self.libraryButton], animated: false)

        return el
    }()

    lazy private var cameraButton: UITabBarItem = {
        let el = UITabBarItem(title: nil, image: UIImage.fromBundle("imagepicker-camera"), selectedImage: nil)
        el.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)

        return el
    }()

    lazy private var libraryButton: UITabBarItem = {
        let el = UITabBarItem(title: nil, image: UIImage.fromBundle("imagepicker-library"), selectedImage: nil)
        el.imageInsets = UIEdgeInsetsMake(5, 0, -5, 0)

        return el
    }()

    // MARK: Class init

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)

        self.addSubview(self.tabBar)
        self.setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout

    private func setupConstraints() {
        self.tabBar.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }
    }

    // MARK: UITabBarDelegate

    func tabBar(tabBar: UITabBar, didSelectItem item: UITabBarItem) {
        switch item {
        case self.cameraButton:
            self.showCameraPicker()

        case self.libraryButton:
            self.showLibraryPicker()

        default:
            break
        }
    }

    // MARK: Public methods

    func showCameraPicker() {
        self.tabBar.selectedItem = self.cameraButton
        self.delegate?.imagePickerSourcesViewCameraDidTap(self)
    }

    func showLibraryPicker() {
        self.tabBar.selectedItem = self.libraryButton
        self.delegate?.imagePickerSourcesViewLibraryDidTap(self)
    }
}
