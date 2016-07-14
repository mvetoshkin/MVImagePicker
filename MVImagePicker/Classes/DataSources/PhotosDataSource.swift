//
//  PhotosDataSource.swift
//  MVImagePicker
//
//  Created by Mikhail Vetoshkin on 22/06/16.
//  Copyright (c) 2016 Mikhail Vetoshkin. All rights reserved.
//

import Photos
import UIKit


@objc protocol ImagePickerPhotosDataSourceDelegate {
    
    func imagePickerPhotosDataSourceHeaderDidTap(dataSource: ImagePickerPhotosDataSource, gesture: UITapGestureRecognizer)
    func imagePickerAssetDidSelect(dataSource: ImagePickerPhotosDataSource, asset: PHAsset)
    func imagePickerAssetDidDeselect(dataSource: ImagePickerPhotosDataSource, asset: PHAsset)
}

class ImagePickerPhotosDataSource: NSObject, UICollectionViewDataSource {

    weak var delegate: ImagePickerPhotosDataSourceDelegate?

    private var album: PHAssetCollection?

    private let noPhotosCellIdentifier = NSStringFromClass(ImagePickerNoPhotosView.self)
    private let photoCellIdentifier = NSStringFromClass(ImagePickerPhotoCell.self)
    private let headerCellIdentifier = NSStringFromClass(ImagePickerPhotosHeaderCell.self)

    var fetchResult: PHFetchResult?
    var selectedAssets = [PHAsset]()
    var multipleSelection = true

    // MARK: Lazy init

    lazy private var imageManager: PHImageManager = {
        return PHImageManager()
    }()

    // MARK: UICollectionViewDataSource

    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if let cnt = self.fetchResult?.count where cnt > 0 {
            return cnt
        }

        return 1
    }

    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if self.fetchResult?.count > 0 {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier(self.photoCellIdentifier, forIndexPath: indexPath)
                    as! ImagePickerPhotoCell

            let currentTag = cell.tag + 1
            cell.tag = currentTag

            let scale = UIScreen.mainScreen().scale
            let itemSize = (collectionView.collectionViewLayout as! UICollectionViewFlowLayout).itemSize
            let thumbSize = CGSizeMake(itemSize.width * scale, itemSize.height * scale)

            let asset = self.fetchResult![indexPath.item] as! PHAsset
            self.imageManager.requestImageForAsset(asset, targetSize: thumbSize, contentMode: PHImageContentMode.AspectFill,
                options: nil, resultHandler: { (image, _) -> Void in
                    if let img = image where cell.tag == currentTag {
                        cell.setThumbnail(img)
                    }
            })

            return cell
        }

        return collectionView.dequeueReusableCellWithReuseIdentifier(self.noPhotosCellIdentifier, forIndexPath: indexPath)
                as! ImagePickerNoPhotosView
    }

    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        if kind == UICollectionElementKindSectionHeader {
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader,
                withReuseIdentifier: self.headerCellIdentifier, forIndexPath: indexPath) as! ImagePickerPhotosHeaderCell

            let gesture = UITapGestureRecognizer(target: self, action: #selector(ImagePickerPhotosDataSource.headerDidTap(_:)))
            gesture.numberOfTapsRequired = 1

            header.addGestureRecognizer(gesture)

            if let title = self.album?.localizedTitle {
                header.setText(title)
            }

            return header
        }

        return UICollectionReusableView()
    }

    // MARK: Handlers

    @objc private func headerDidTap(gesture: UITapGestureRecognizer) {
        self.delegate?.imagePickerPhotosDataSourceHeaderDidTap(self, gesture: gesture)
    }

    // MARK: Public methods

    class func fetchAssets(album: PHAssetCollection?, fetchLimit: Int? = nil) -> PHFetchResult {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]

        if let limit = fetchLimit {
            if #available(iOS 9.0, *) {
                fetchOptions.fetchLimit = limit
            }
        }

        if let alb = album {
            fetchOptions.predicate = NSPredicate(format: "mediaType == %d", PHAssetMediaType.Image.rawValue)
            return PHAsset.fetchAssetsInAssetCollection(alb, options: fetchOptions)
        } else {
            return PHAsset.fetchAssetsWithOptions(fetchOptions)
        }
    }

    func registerReusableViews(collectionView: UICollectionView) {
        collectionView.registerClass(ImagePickerNoPhotosView.self, forCellWithReuseIdentifier: self.noPhotosCellIdentifier)
        collectionView.registerClass(ImagePickerPhotoCell.self, forCellWithReuseIdentifier: self.photoCellIdentifier)
        collectionView.registerClass(ImagePickerPhotosHeaderCell.self,
            forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: self.headerCellIdentifier)
    }

    func fetchData(album: PHAssetCollection) {
        self.album = album
        self.fetchResult = ImagePickerPhotosDataSource.fetchAssets(album)
    }

    func selectAsset(asset: PHAsset) {
        if !self.multipleSelection {
            self.selectedAssets.removeAll(keepCapacity: false)
        }

        self.selectedAssets.append(asset)
        self.delegate?.imagePickerAssetDidSelect(self, asset: asset)
    }

    func deselectAsset(asset: PHAsset) {
        if let idx = self.selectedAssets.indexOf(asset) {
            self.selectedAssets.removeAtIndex(idx)
            self.delegate?.imagePickerAssetDidDeselect(self, asset: asset)
        }
    }
}
