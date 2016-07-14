//
//  NoPhotosView.swift
//  MVImagePicker
//
//  Created by Mikhail Vetoshkin on 22/06/16.
//  Copyright (c) 2016 Mikhail Vetoshkin. All rights reserved.
//

import UIKit


class ImagePickerNoPhotosView: UICollectionViewCell {

    // MARK: Lazy init
    
    lazy private var headerView: UILabel = {
        let el = UILabel(frame: CGRectZero)
        
        el.font = UIFont.systemFontOfSize(20)
        el.numberOfLines = 0
        el.text = "No Photos"
        el.textAlignment = NSTextAlignment.Center
        el.textColor = UIColor.ipDarkGrayColor()
        
        return el
    }()
    
    // MARK: Class init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        
        self.addSubview(self.headerView)

        self.setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    func setupConstraints() {
        self.headerView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self)
        }
    }
}