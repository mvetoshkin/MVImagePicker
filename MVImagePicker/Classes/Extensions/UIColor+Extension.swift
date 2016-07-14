//
//  UIColor+Extension.swift
//  MVImagePicker
//
//  Created by Mikhail Vetoshkin on 01/07/16.
//  Copyright (c) 2016 Mikhail Vetoshkin. All rights reserved.
//

import UIKit


extension UIColor {

    public class func colorWithHex(hexString: String) -> UIColor {
        return colorWithHex(hexString, alpha: 1.0)
    }

    public class func colorWithHex(hexString: String, alpha: CGFloat) -> UIColor {
        var rgbValue: UInt32 = 0

        let scanner = NSScanner(string: hexString)
        scanner.scanLocation = 1
        scanner.scanHexInt(&rgbValue)

        let red = CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgbValue & 0xFF00) >> 8) / 255.0
        let blue = CGFloat((rgbValue & 0xFF) ) / 255.0

        return UIColor(red: red, green: green, blue: blue, alpha: alpha)
    }

    class func ipGreenColor() -> UIColor {
        return UIColor.colorWithHex("#33aca2")
    }

    class func ipLightGrayColor() -> UIColor {
        return UIColor.colorWithHex("#f2f2f2")
    }

    class func ipMediumGrayColor() -> UIColor {
        return UIColor.colorWithHex("#868686")
    }

    class func ipDarkGrayColor() -> UIColor {
        return UIColor.colorWithHex("#828587")
    }
}
