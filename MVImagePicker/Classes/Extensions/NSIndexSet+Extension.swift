//
//  NSIndexSet+Extension.swift
//  MVImagePicker
//
//  Created by Mikhail Vetoshkin on 06/07/16.
//  Copyright (c) 2016 Mikhail Vetoshkin. All rights reserved.
//

import UIKit


extension NSIndexSet {
    
    public func indexPathsFromIndexesWithSection(section: Int) -> [NSIndexPath] {
        var indexPaths = [NSIndexPath]()

        self.enumerateIndexesUsingBlock { (idx, stop) -> Void in
            let ip = NSIndexPath(forItem: idx, inSection: section)
            indexPaths.append(ip)
        }

        return indexPaths
    }
}
