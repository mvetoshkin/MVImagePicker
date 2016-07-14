//
//  AlbumsDataSource.swift
//  MVImagePicker
//
//  Created by Mikhail Vetoshkin on 22/06/16.
//  Copyright (c) 2016 Mikhail Vetoshkin. All rights reserved.
//

import Photos
import UIKit


class ImagePickerAlbumsDataSource: NSObject, UITableViewDataSource {

    private let albumCellIdentifier = NSStringFromClass(ImagePickerAlbumCell.self)

    var fetchResults = [PHFetchResult]()

    // MARK: Lazy init

    lazy private var imageManager: PHImageManager = {
        return PHImageManager()
    }()

    // MARK: UITableViewDataSource

    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchResults.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchResults[section].count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(self.albumCellIdentifier, forIndexPath: indexPath)
                as! ImagePickerAlbumCell

        let fetchResult = self.fetchResults[indexPath.section]
        let album = fetchResult[indexPath.item] as! PHAssetCollection
        let assetsFetchResult = ImagePickerPhotosDataSource.fetchAssets(album)

        if let title = album.localizedTitle {
            cell.setAlbumText(title, assetsCount: assetsFetchResult.count)
        }

        if let asset = assetsFetchResult.firstObject as? PHAsset {
            let scale = UIScreen.mainScreen().scale
            let height = tableView.rowHeight
            let size = CGSizeMake((height - 5) * scale, (height - 5) * scale)

            self.imageManager.requestImageForAsset(asset, targetSize: size, contentMode: PHImageContentMode.AspectFill,
                options: nil, resultHandler: { (image, _) -> Void in
                    cell.setAlbumImage(image)
            })
        } else {
            cell.setAlbumImage(nil)
        }

        return cell
    }

    // MARK: Public methods

    func registerReusableViews(tableView: UITableView) {
        tableView.registerClass(ImagePickerAlbumCell.self, forCellReuseIdentifier: self.albumCellIdentifier)
    }

    func fetchData() {
        let smartAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.SmartAlbum,
            subtype: PHAssetCollectionSubtype.SmartAlbumUserLibrary, options: nil)

        let userAlbums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album,
            subtype: PHAssetCollectionSubtype.Any, options: nil)

        self.fetchResults = [smartAlbums, userAlbums]
    }
}
