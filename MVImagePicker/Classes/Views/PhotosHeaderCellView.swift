//
//  PhotosHeaderCellView.swift
//  MVImagePicker
//
//  Created by Mikhail Vetoshkin on 22/06/16.
//  Copyright (c) 2016 Mikhail Vetoshkin. All rights reserved.
//

import UIKit


class ImagePickerPhotosHeaderCell: UICollectionReusableView {

    // MARK: Lazy init

    lazy private var backButton: UIImageView = {
        let image = UIImage.fromBundle("imagepicker-back").imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let el = UIImageView(image: image)

        el.tintColor = UIColor.ipDarkGrayColor()

        return el
    }()

    lazy private var titleLabel: UILabel = {
        let el = UILabel(frame: CGRectZero)

        el.font = UIFont.systemFontOfSize(14)
        el.textColor = UIColor.ipDarkGrayColor()

        return el
    }()

    // MARK: Class init

    override init(frame: CGRect) {
        super.init(frame: frame)

        self.backgroundColor = UIColor.clearColor()

        self.addSubview(self.backButton)
        self.addSubview(self.titleLabel)

        self.setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout

    private func setupConstraints() {
        self.backButton.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self)
            make.left.equalTo(10)

            make.height.equalTo(12)
            make.width.equalTo(12)
        }

        self.titleLabel.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self)
            make.left.equalTo(self.backButton.snp_right).offset(5)
        }
    }

    // MARK: Public methods

    func setText(text: String) {
        self.titleLabel.text = text.uppercaseString
    }
}
