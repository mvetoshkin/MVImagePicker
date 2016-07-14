//
//  UIView+Extension.swift
//  MVImagePicker
//
//  Created by Mikhail Vetoshkin on 06/07/16.
//  Copyright (c) 2016 Mikhail Vetoshkin. All rights reserved.
//

import UIKit


extension UIView {

    // MARK: Private methods

    private func addBorder(color: UIColor, opacity: CGFloat) -> UIView {
        let border = UIView()

        border.alpha = opacity
        border.backgroundColor = color

        self.addSubview(border)
        return border
    }

    // MARK: Public methods

    public func addLeftBorder(color: UIColor, width: CGFloat, opacity: CGFloat = 1) {
        let border = self.addBorder(color, opacity: opacity)
        border.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.bottom.equalTo(0)

            make.width.equalTo(width)
        }
    }

    public func addTopBorder(color: UIColor, width: CGFloat, opacity: CGFloat = 1) {
        let border = self.addBorder(color, opacity: opacity)
        border.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(0)
            make.top.equalTo(0)
            make.right.equalTo(0)

            make.height.equalTo(width)
        }
    }

    public func addRightBorder(color: UIColor, width: CGFloat, opacity: CGFloat = 1) {
        let border = self.addBorder(color, opacity: opacity)
        border.snp_makeConstraints { (make) -> Void in
            make.top.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)

            make.width.equalTo(width)
        }
    }

    public func addBottomBorder(color: UIColor, width: CGFloat, opacity: CGFloat = 1) {
        let border = self.addBorder(color, opacity: opacity)
        border.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(0)
            make.right.equalTo(0)
            make.bottom.equalTo(0)

            make.height.equalTo(width)
        }
    }
}