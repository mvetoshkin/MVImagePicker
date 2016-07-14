//
//  BaseNavigationController.swift
//  MVImagePicker
//
//  Created by Mikhail Vetoshkin on 23/06/16.
//  Copyright (c) 2016 Mikhail Vetoshkin. All rights reserved.
//

import UIKit


class BaseNavigationController: UINavigationController {
    class func initWithRootViewController(rootViewController: UIViewController) -> BaseNavigationController {
        let navCtrl = BaseNavigationController(rootViewController: rootViewController)

        navCtrl.navigationBar.barTintColor = UIColor.ipGreenColor()
        navCtrl.navigationBar.tintColor = UIColor.whiteColor()
        navCtrl.navigationBar.translucent = false

        navCtrl.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]

        return navCtrl
    }
}