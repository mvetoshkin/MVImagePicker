//
//  AccessDeniedView.swift
//  MVImagePicker
//
//  Created by Mikhail Vetoshkin on 22/06/16.
//  Copyright (c) 2016 Mikhail Vetoshkin. All rights reserved.
//

import UIKit


class ImagePickerAccessDeniedView: UIView {

    private let appName: String = NSBundle.mainBundle().infoDictionary?["CFBundleName"] as? String ?? "Your app"

    // MARK: Lazy init
    
    lazy private var headerView: UILabel = {
        let el = UILabel(frame: CGRectZero)
        
        el.font = UIFont.systemFontOfSize(20)
        el.numberOfLines = 0
        el.text = "Photos Library"
        el.textAlignment = NSTextAlignment.Center
        el.textColor = UIColor.ipDarkGrayColor()
        
        return el
    }()
    
    lazy private var titleView: UILabel = {
        let el = UILabel(frame: CGRectZero)
        
        el.font = UIFont.systemFontOfSize(15)
        el.numberOfLines = 0
        el.text = "Allow \(self.appName) access to your photos"
        el.textAlignment = NSTextAlignment.Center
        el.textColor = UIColor.ipMediumGrayColor()
        
        return el
    }()
    
    lazy private var detailsView: UILabel = {
        let el = UILabel(frame: CGRectZero)
        
        el.font = UIFont.systemFontOfSize(15)
        el.numberOfLines = 0
        el.text = "Tap here or go to Settings > \(self.appName)\nand switch Photos to ON"
        el.textAlignment = NSTextAlignment.Center
        el.textColor = UIColor.ipMediumGrayColor()
        
        return el
    }()
    
    // MARK: Class init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
        
        self.addSubview(self.headerView)
        self.addSubview(self.titleView)
        self.addSubview(self.detailsView)
        
        self.setupConstraints()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Layout
    
    func setupConstraints() {
        self.headerView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self)
            make.bottom.equalTo(self.titleView.snp_top).offset(-20)
        }
        
        self.titleView.snp_makeConstraints { (make) -> Void in
            make.center.equalTo(self).offset(CGPointMake(0, -20))
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
        }
        
        self.detailsView.snp_makeConstraints { (make) -> Void in
            make.centerX.equalTo(self)
            make.top.equalTo(self.titleView.snp_bottom).offset(20)
            make.left.equalTo(self).offset(10)
            make.right.equalTo(self).offset(-10)
        }
    }
}
