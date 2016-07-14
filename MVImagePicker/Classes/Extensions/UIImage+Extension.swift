//
//  UIImage+Extension.swift
//  MVImagePicker
//
//  Created by Mikhail Vetoshkin on 08/07/16.
//  Copyright (c) 2016 Mikhail Vetoshkin. All rights reserved.
//

import UIKit


extension UIImage {
    
    class func fromBundle(named: String, ext: String = "png") -> UIImage {
        let bundle = NSBundle(forClass: ImagePickerViewController.self)
        let imageUrl = bundle.URLForResource("MVImagePicker.bundle/\(named)", withExtension: ext)
        let data = NSData(contentsOfURL: imageUrl!)
        let cgImage = UIImage(data: data!)?.CGImage
        return UIImage(CGImage: cgImage!, scale: UIScreen.mainScreen().scale, orientation: UIImageOrientation.Up)
    }
}