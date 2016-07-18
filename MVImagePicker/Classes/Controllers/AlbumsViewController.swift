//
//  AlbumsViewController.swift
//  MVImagePicker
//
//  Created by Mikhail Vetoshkin on 22/06/16.
//  Copyright (c) 2016 Mikhail Vetoshkin. All rights reserved.
//

import Photos
import UIKit


class ImagePickerAlbumsViewController: UIViewController, PHPhotoLibraryChangeObserver, UITableViewDelegate {

    weak var delegate: ImagePickerPhotosViewControllerDelegate?
    weak var scrollDelegate: ImagePickerViewControllerScrollDelegate?

    private let albumsDataSource = ImagePickerAlbumsDataSource()
    private let photosDataSource: ImagePickerPhotosDataSource

    var multipleSelection: Bool = false

    // MARK: Lazy init

    lazy private var tableView: UITableView = {
        let el = UITableView(frame: CGRectZero)

        el.alwaysBounceVertical = true
        el.backgroundColor = UIColor.clearColor()
        el.dataSource = self.albumsDataSource
        el.delegate = self
        el.rowHeight = 60
        el.separatorStyle = UITableViewCellSeparatorStyle.None

        self.albumsDataSource.registerReusableViews(el)

        return el
    }()

    // MARK: Class init

    init(photosDataSource: ImagePickerPhotosDataSource) {
        self.photosDataSource = photosDataSource
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }

    // MARK: View Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.ipLightGrayColor()

        self.view.addSubview(self.tableView)
        self.setupConstraints()

        self.albumsDataSource.fetchData()
        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)

        let fetchResult = self.albumsDataSource.fetchResults[0]
        let album = fetchResult[0] as! PHAssetCollection
        self.openAlbum(album, animated: false)
    }

    // MARK: Layout

    private func setupConstraints() {
        self.tableView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
    }

    // MARK: PHPhotoLibraryChangeObserver

    func photoLibraryDidChange(changeInstance: PHChange) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.albumsDataSource.fetchData()
            self.tableView.reloadData()
        })
    }

    // MARK: UITableViewDelegate

    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)

        let fetchResult = self.albumsDataSource.fetchResults[indexPath.section]
        let album = fetchResult[indexPath.item] as! PHAssetCollection
        self.openAlbum(album, animated: true)
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

    // MARK: Private methods

    func openAlbum(album: PHAssetCollection, animated: Bool) {
        let vc = ImagePickerPhotosViewController(photosDataSource: self.photosDataSource, album: album)
        vc.delegate = self.delegate
        vc.multipleSelection = self.multipleSelection
        vc.scrollDelegate = self.scrollDelegate
        
        self.navigationController?.pushViewController(vc, animated: animated)
    }
}
