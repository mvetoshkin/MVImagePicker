//
//  AlbumCellView.swift
//  MVImagePicker
//
//  Created by Mikhail Vetoshkin on 22/06/16.
//  Copyright (c) 2016 Mikhail Vetoshkin. All rights reserved.
//

import UIKit


class ImagePickerAlbumCell: UITableViewCell {

    // MARK: Lazy init

    lazy private var albumImage: UIImageView = {
        let el = UIImageView()

        el.autoresizingMask = [UIViewAutoresizing.FlexibleWidth, UIViewAutoresizing.FlexibleHeight]
        el.clipsToBounds = true
        el.contentMode = UIViewContentMode.ScaleAspectFill
        el.hidden = true

        return el
    }()

    lazy private var albumThumb: UILabel = {
        let el = UILabel(frame: CGRectZero)

        el.backgroundColor = UIColor.ipLightGrayColor()
        el.font = UIFont.systemFontOfSize(16)
        el.layer.borderColor = UIColor.ipDarkGrayColor().CGColor
        el.layer.borderWidth = 1
        el.text = "–"
        el.textAlignment = NSTextAlignment.Center
        el.textColor = UIColor.ipDarkGrayColor()

        return el
    }()

    lazy private var albumTitle: UILabel = {
        let el = UILabel(frame: CGRectZero)

        el.font = UIFont.systemFontOfSize(16)
        el.textColor = UIColor.ipDarkGrayColor()

        return el
    }()

    lazy private var assetsCount: UILabel = {
        let el = UILabel(frame: CGRectZero)

        el.font = UIFont.systemFontOfSize(12)
        el.textAlignment = NSTextAlignment.Right
        el.textColor = UIColor.ipDarkGrayColor()

        return el
    }()

    lazy private var nextButton: UIImageView = {
        let image = UIImage.fromBundle("imagepicker-next").imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
        let el = UIImageView(image: image)

        el.tintColor = UIColor.ipDarkGrayColor()

        return el
    }()

    // MARK: Class init

    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        self.backgroundColor = UIColor.clearColor()

        self.addBottomBorder(UIColor.ipDarkGrayColor(), width: 0.5, opacity: 0.2)
        self.addSubview(self.albumImage)
        self.addSubview(self.albumThumb)
        self.addSubview(self.albumTitle)
        self.addSubview(self.assetsCount)
        self.addSubview(self.nextButton)

        self.setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: Layout

    private func setupConstraints() {
        self.albumImage.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self)
            make.left.equalTo(10)

            make.height.equalTo(self.snp_height).offset(-10)
            make.width.equalTo(self.snp_height).offset(-10)
        }

        self.albumThumb.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.albumImage)
        }

        self.albumTitle.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self)
            make.left.equalTo(self.albumImage.snp_right).offset(10)
        }

        self.assetsCount.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self)
            make.right.equalTo(self.nextButton.snp_left).offset(-5)
        }

        self.nextButton.snp_makeConstraints { (make) -> Void in
            make.centerY.equalTo(self)
            make.right.equalTo(-10)

            make.height.equalTo(13)
            make.width.equalTo(13)
        }
    }

    // MARK: Public methods

    func setAlbumImage(image: UIImage?) {
        self.albumImage.hidden = (image == nil)
        self.albumThumb.hidden = (image != nil)
        self.albumImage.image = image
    }

    func setAlbumText(title: String, assetsCount: Int) {
        if self.albumImage.image == nil {
            self.albumThumb.hidden = false
        }

        var initials = ""
        let words = title.characters.split { $0 == " " }.map { String($0) }

        if words.count > 0 {
            for word in words[0...min(words.count - 1, 1)] {
                initials += String(word[word.startIndex])
            }
        }

        self.albumThumb.text = initials.uppercaseString
        self.albumTitle.text = title
        self.assetsCount.text = "\(assetsCount)"
    }
}
