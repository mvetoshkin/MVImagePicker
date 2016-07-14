//
//  PhotosViewController.swift
//  MVImagePicker
//
//  Created by Mikhail Vetoshkin on 22/06/16.
//  Copyright (c) 2016 Mikhail Vetoshkin. All rights reserved.
//

import Photos
import UIKit


@objc protocol ImagePickerPhotosViewControllerDelegate {
    
    func imagePickerPhotosViewControllerAssetDidSelect(viewController: ImagePickerPhotosViewController, asset: PHAsset, cell: ImagePickerPhotoCell)
    func imagePickerPhotosViewControllerAssetDidDeselect(viewController: ImagePickerPhotosViewController, asset: PHAsset, cell: ImagePickerPhotoCell)
    func imagePickerPhotosViewControllerAssetDidLongTap(viewController: ImagePickerPhotosViewController, asset: PHAsset, cell: ImagePickerPhotoCell)
}

class ImagePickerPhotosViewController: UIViewController, PHPhotoLibraryChangeObserver, UICollectionViewDelegate,
        UICollectionViewDelegateFlowLayout, ImagePickerPhotosDataSourceDelegate {

    weak var delegate: ImagePickerPhotosViewControllerDelegate?
    weak var scrollDelegate: ImagePickerViewControllerScrollDelegate?

    private let album: PHAssetCollection
    private let photosDataSource: ImagePickerPhotosDataSource

    private var forceSetupOffset = false
    private let imageManager = PHImageManager()

    public var multipleSelection: Bool = false

    // MARK: Lazy init

    lazy private var collectionView: UICollectionView = {
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(ImagePickerPhotosViewController.collectionViewDidLongTap(_:)))
        gesture.minimumPressDuration = 0.3
        gesture.delaysTouchesBegan = true

        let el = UICollectionView(frame: CGRectZero, collectionViewLayout: self.collectionViewFlowLayout)

        el.allowsMultipleSelection = true
        el.alwaysBounceVertical = true
        el.backgroundColor = UIColor.clearColor()
        el.dataSource = self.photosDataSource
        el.delegate = self
        el.showsVerticalScrollIndicator = false

        el.addGestureRecognizer(gesture)

        self.photosDataSource.registerReusableViews(el)

        return el
    }()

    lazy private var collectionViewFlowLayout: UICollectionViewFlowLayout = {
        let el = UICollectionViewFlowLayout()

        el.minimumLineSpacing = 1
        el.minimumInteritemSpacing = 1
        el.scrollDirection = UICollectionViewScrollDirection.Vertical
        el.sectionInset = UIEdgeInsetsZero

        return el
    }()

    // MARK: Class init

    init(photosDataSource: ImagePickerPhotosDataSource, album: PHAssetCollection) {
        self.album = album
        self.photosDataSource = photosDataSource

        super.init(nibName: nil, bundle: nil)

        self.photosDataSource.delegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        self.photosDataSource.delegate = nil
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.ipLightGrayColor()

        self.view.addSubview(self.collectionView)
        self.setupConstraints()

        self.collectionView.allowsMultipleSelection = self.multipleSelection

        self.photosDataSource.fetchData(self.album)
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)
        self.collectionView.reloadData()
        self.selectAssets()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.forceSetupOffset = true
    }

    // MARK: Layout

    private func setupConstraints() {
        self.collectionView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        if self.forceSetupOffset && self.collectionView.contentSize.height - ImagePickerViewController.sourcesHeight > CGRectGetHeight(self.view.bounds) {
            self.forceSetupOffset = false
            let offset = CGPointMake(0, ImagePickerViewController.sourcesHeight)
            self.collectionView.setContentOffset(offset, animated: false)
        }
    }

    // MARK: PHPhotoLibraryChangeObserver

    func photoLibraryDidChange(changeInstance: PHChange) {
        typealias restoreSelectedType = () -> Void
        let restoreSelected: restoreSelectedType = { () -> Void in

            if let cnt = self.photosDataSource.fetchResult?.count where cnt > 0 {
                for idx in 0...cnt - 1 {
                    let ip = NSIndexPath(forItem: idx, inSection: 0)
                    self.collectionView.deselectItemAtIndexPath(ip, animated: false)
                }
            }

            self.selectAssets()
        }

        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            if self.photosDataSource.fetchResult == nil {
                return
            }

            if let changeDetails = changeInstance.changeDetailsForFetchResult(self.photosDataSource.fetchResult!) {
                let noPhotosBeforeUpdate = changeDetails.fetchResultBeforeChanges.count == 0
                let noPhotosAfterUpdate = changeDetails.fetchResultAfterChanges.count == 0

                self.photosDataSource.fetchResult = changeDetails.fetchResultAfterChanges

                if !changeDetails.hasIncrementalChanges || changeDetails.hasMoves || noPhotosBeforeUpdate || noPhotosAfterUpdate {
                    self.collectionView.reloadData()
                    restoreSelected()
                } else {
                    self.collectionView.performBatchUpdates({ () -> Void in
                        if let removedIndexes = changeDetails.removedIndexes {
                            self.collectionView.deleteItemsAtIndexPaths(removedIndexes.indexPathsFromIndexesWithSection(0))
                        }

                        if let insertedIndexes = changeDetails.insertedIndexes {
                            self.collectionView.insertItemsAtIndexPaths(insertedIndexes.indexPathsFromIndexesWithSection(0))
                        }
                    }, completion: { (_) -> Void in
                        if let changedIndexes = changeDetails.changedIndexes {
                            self.collectionView.reloadItemsAtIndexPaths(changedIndexes.indexPathsFromIndexesWithSection(0))
                        }

                        restoreSelected()
                    })
                }
            }
        })
    }

    // MARK: UICollectionViewDelegate

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        self.collectionView.deselectItemAtIndexPath(indexPath, animated: true)

        let asset = self.photosDataSource.fetchResult![indexPath.item] as! PHAsset
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! ImagePickerPhotoCell

        let options = PHImageRequestOptions()
        options.networkAccessAllowed = true

        options.progressHandler = { (progress, _, _, _) in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                cell.updateProgressBar(progress < 1 ? progress : 0)
            })
        }

        self.imageManager.requestImageDataForAsset(asset, options: options, resultHandler: { (_, _, _, _) -> Void in
            self.collectionView.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
            self.photosDataSource.selectedAssets.append(asset)
            self.delegate?.imagePickerPhotosViewControllerAssetDidSelect(self, asset: asset, cell: cell)
        })
    }

    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let asset = self.photosDataSource.fetchResult![indexPath.item] as! PHAsset
        let cell = self.collectionView.cellForItemAtIndexPath(indexPath) as! ImagePickerPhotoCell

        if let idx = self.photosDataSource.selectedAssets.indexOf(asset) {
            self.photosDataSource.selectedAssets.removeAtIndex(idx)
        }

        self.delegate?.imagePickerPhotosViewControllerAssetDidDeselect(self, asset: asset, cell: cell)
    }

    // MARK: UICollectionViewDelegateFlowLayout

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        var width: CGFloat = CGRectGetWidth(self.view.bounds)
        var height: CGFloat = CGRectGetHeight(self.view.bounds) - ImagePickerViewController.sourcesHeight

        if self.photosDataSource.fetchResult?.count > 0 {
            width = (CGRectGetWidth(self.view.bounds) - 3) / 4
            height = width
        }

        return CGSizeMake(width, height)
    }

    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSizeMake(CGRectGetWidth(self.view.bounds), ImagePickerViewController.sourcesHeight)
    }

    // MARK: ImagePickerPhotosDataSourceDelegate

    func imagePickerPhotosDataSourceHeaderDidTap(dataSource: ImagePickerPhotosDataSource, gesture: UITapGestureRecognizer) {
        self.navigationController?.popViewControllerAnimated(true)
    }

    func imagePickerAssetDidSelect(dataSource: ImagePickerPhotosDataSource, asset: PHAsset) {
        self.photosDataSource.fetchResult?.enumerateObjectsUsingBlock({ (ast, index, _) -> Void in
            if (ast as! PHAsset) == asset {
                let ip = NSIndexPath(forItem: index, inSection: 0)
                self.collectionView.selectItemAtIndexPath(ip, animated: true, scrollPosition: UICollectionViewScrollPosition.None)
            }
        })
    }

    func imagePickerAssetDidDeselect(dataSource: ImagePickerPhotosDataSource, asset: PHAsset) {
        self.photosDataSource.fetchResult?.enumerateObjectsUsingBlock({ (ast, index, _) -> Void in
            if (ast as! PHAsset) == asset {
                let ip = NSIndexPath(forItem: index, inSection: 0)
                self.collectionView.deselectItemAtIndexPath(ip, animated: true)
            }
        })
    }

    // MARK: ImagePickerViewControllerScrollDelegate

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        self.scrollDelegate?.imagePickerViewControllerWillBeginDragging?(scrollView)
    }

    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.scrollDelegate?.imagePickerViewControllerDidEndDragging?(scrollView, willDecelerate: decelerate)
    }

    func scrollViewDidScroll(scrollView: UIScrollView) {
        self.scrollDelegate?.imagePickerViewControllerDidScroll?(scrollView)
    }

    // MARK: Handlers

    @objc private func collectionViewDidLongTap(gesture: UILongPressGestureRecognizer) {
        if self.photosDataSource.fetchResult?.count == 0 {
            return
        }

        if gesture.state == UIGestureRecognizerState.Began {
            let p = gesture.locationInView(self.collectionView)
            if let ip = self.collectionView.indexPathForItemAtPoint(p) {
                let cell = self.collectionView.cellForItemAtIndexPath(ip) as! ImagePickerPhotoCell
                let asset = self.photosDataSource.fetchResult![ip.item] as! PHAsset

                let options = PHImageRequestOptions()
                options.networkAccessAllowed = true

                options.progressHandler = { (progress, _, _, _) in
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        cell.updateProgressBar(progress < 1 ? progress : 0)
                    })
                }

                self.imageManager.requestImageDataForAsset(asset, options: options, resultHandler: { (_, _, _, _) -> Void in
                    self.delegate?.imagePickerPhotosViewControllerAssetDidLongTap(self, asset: asset, cell: cell)
                })
            }
        }
    }

    // MARK: Private methods

    private func selectAssets() {
        self.photosDataSource.fetchResult?.enumerateObjectsUsingBlock({ (asset, index, _) -> Void in
            if let _ = self.photosDataSource.selectedAssets.indexOf(asset as! PHAsset) {
                let ip = NSIndexPath(forItem: index, inSection: 0)
                self.collectionView.selectItemAtIndexPath(ip, animated: false, scrollPosition: UICollectionViewScrollPosition.None)
            }
        })
    }
}
