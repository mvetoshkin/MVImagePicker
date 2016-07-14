//
//  PhotoCellView.swift
//  MVImagePicker
//
//  Created by Mikhail Vetoshkin on 22/06/16.
//  Copyright (c) 2016 Mikhail Vetoshkin. All rights reserved.
//

import UIKit


public class ImagePickerPhotoCell: UICollectionViewCell {

    // MARK: Overridden variables

    override public var selected: Bool {
        didSet {
            self.checkmarkView.hidden = !self.selected
            self.overlay.opacity = self.selected ? 0.3 : 0

            if (self.selected) {
                let scaleAnimation = CABasicAnimation(keyPath: "transform.scale")

                scaleAnimation.duration = 0.1
                scaleAnimation.repeatCount = 1
                scaleAnimation.autoreverses = true
                scaleAnimation.fromValue = 1
                scaleAnimation.toValue = 1.1

                self.checkmarkView.layer.addAnimation(scaleAnimation, forKey: "scale")
            }
        }
    }

    // MARK: Lazy init

    lazy private var overlay: CALayer = {
        let el = CALayer()

        el.backgroundColor = UIColor.whiteColor().CGColor
        el.opacity = 0

        return el
    }()

    lazy private var thumbnailView: UIImageView = {
        let el = UIImageView(frame: CGRectZero)

        el.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        el.clipsToBounds = true
        el.contentMode = UIViewContentMode.ScaleAspectFill

        el.layer.addSublayer(self.overlay)

        return el
    }()

    lazy private var checkmarkView: UIImageView = {
        let image = UIImage.fromBundle("imagepicker-checkmark")
        let el = UIImageView(image: image)
        el.hidden = true

        return el
    }()

    lazy private var progressBarView: UIView = {
        let el = UIView(frame: CGRectZero)
        el.backgroundColor = UIColor.ipGreenColor()

        return el
    }()

    // MARK: Class init

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.clearColor()

        self.addSubview(self.thumbnailView)
        self.addSubview(self.checkmarkView)
        self.addSubview(self.progressBarView)

        self.setupConstraints()
        self.updateProgressBar(0)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout

    private func setupConstraints() {
        self.thumbnailView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }

        self.checkmarkView.snp_makeConstraints { (make) -> Void in
            make.right.equalTo(-5)
            make.bottom.equalTo(-5)

            make.height.equalTo(20)
            make.width.equalTo(20)
        }
    }

    override public func layoutSubviews() {
        self.overlay.frame = self.thumbnailView.bounds
        super.layoutSubviews()
    }

    // MARK: Public methods

    func setThumbnail(image: UIImage) {
        self.thumbnailView.image = image
    }

    func updateProgressBar(progress: Double) {
        let windowHeight = CGRectGetHeight(self.bounds)
        let windowWidth = CGRectGetHeight(self.bounds)
        let barHeight: CGFloat = 2

        self.progressBarView.frame = CGRectMake(0, windowHeight - barHeight, windowWidth * CGFloat(progress), barHeight)
    }
}
