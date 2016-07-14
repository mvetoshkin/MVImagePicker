//
//  ImagePickerViewController.swift
//  MVImagePicker
//
//  Created by Mikhail Vetoshkin on 22/06/16.
//  Copyright (c) 2016 Mikhail Vetoshkin. All rights reserved.
//

import MobileCoreServices
import Photos
import SnapKit
import UIKit


@objc public protocol ImagePickerViewControllerDelegate {

    optional func imagePickerViewControllerBeforeAssetChanged(viewController: ImagePickerViewController)
    optional func imagePickerViewControllerAfterAssetChanged(viewController: ImagePickerViewController)

    optional func imagePickerViewControllerLibraryDidSelect(viewController: ImagePickerViewController)
    optional func imagePickerViewControllerDidEnabled(viewController: ImagePickerViewController, isAuthorized: Bool)

    func imagePickerViewControllerAssetDidCreate(viewController: ImagePickerViewController, asset: PHAsset, locally: Bool)
    func imagePickerViewControllerAssetDidRemove(viewController: ImagePickerViewController, asset: PHAsset)

    func imagePickerViewControllerAssetDidSelect(viewController: ImagePickerViewController, asset: PHAsset, cell: ImagePickerPhotoCell)
    func imagePickerViewControllerAssetDidDeselect(viewController: ImagePickerViewController, asset: PHAsset, cell: ImagePickerPhotoCell)
    optional func imagePickerViewControllerAssetDidLongTap(viewController: ImagePickerViewController, asset: PHAsset, cell: ImagePickerPhotoCell)
}

@objc public protocol ImagePickerViewControllerScrollDelegate {
    
    optional func imagePickerViewControllerWillBeginDragging(scrollView: UIScrollView)
    optional func imagePickerViewControllerDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
    optional func imagePickerViewControllerDidScroll(scrollView: UIScrollView)
}

public class ImagePickerViewController: UIViewController, PHPhotoLibraryChangeObserver, UIImagePickerControllerDelegate,
        UINavigationControllerDelegate, ImagePickerPhotosViewControllerDelegate, ImagePickerSourcesViewDelegate {

    public static let sourcesHeight: CGFloat = 40
    public var newPhotoAlbumName: String? = nil
    public var multipleSelection: Bool = false

    public weak var delegate: ImagePickerViewControllerDelegate?
    public weak var scrollDelegate: ImagePickerViewControllerScrollDelegate?

    private var photosDataSource = ImagePickerPhotosDataSource()
    private let libraryView = UIView(frame: CGRectZero)
    private var allAssetsFetchResults: PHFetchResult?

    private var isAuthorized = false
    private var isAssetCreating = false

    // MARK: Lazy init

    lazy private var sourcesView: ImagePickerSourcesView = {
        let el = ImagePickerSourcesView(frame: CGRectZero)
        el.delegate = self

        return el
    }()

    lazy private var accessDeniedView: ImagePickerAccessDeniedView = {
        let gesture = UITapGestureRecognizer(target: self, action: #selector(ImagePickerViewController.imagePickerAccessDeniedViewDidTap(_:)))
        gesture.numberOfTapsRequired = 1

        let el = ImagePickerAccessDeniedView(frame: CGRectZero)

        el.userInteractionEnabled = true
        el.addGestureRecognizer(gesture)

        return el
    }()

    // MARK: Class init

    deinit {
        PHPhotoLibrary.sharedPhotoLibrary().unregisterChangeObserver(self)
    }

    // MARK: Life cycle

    override public func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Image Picker"
        self.view.backgroundColor = UIColor.ipLightGrayColor()

        self.addCloseButton()

        self.sourcesView.hidden = true
        self.libraryView.hidden = true
        self.accessDeniedView.hidden = true

        self.view.addSubview(self.sourcesView)
        self.view.addSubview(self.libraryView)
        self.view.addSubview(self.accessDeniedView)

        self.setupConstraints()

        self.sourcesView.showLibraryPicker()

        PHPhotoLibrary.sharedPhotoLibrary().registerChangeObserver(self)

        PHPhotoLibrary.requestAuthorization({ (status) -> Void in
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                if status == PHAuthorizationStatus.Authorized {
                    self.enableLibrary()
                } else {
                    self.disableLibrary()
                }
            })
        })
    }

    // MARK: Layout

    private func setupConstraints() {
        self.sourcesView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.top.equalTo(0)

            make.height.equalTo(ImagePickerViewController.sourcesHeight)
        }

        self.libraryView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.view)
            make.top.equalTo(self.sourcesView.snp_bottom)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)
        }

        self.accessDeniedView.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.view)
        }
    }

    // MARK: PHPhotoLibraryChangeObserver

    public func photoLibraryDidChange(changeInstance: PHChange) {
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            self.delegate?.imagePickerViewControllerAfterAssetChanged?(self)

            let locally = self.isAssetCreating
            self.isAssetCreating = false

            if self.allAssetsFetchResults == nil {
                return
            }

            if let changeDetails = changeInstance.changeDetailsForFetchResult(self.allAssetsFetchResults!) {
                self.allAssetsFetchResults = changeDetails.fetchResultAfterChanges

                for obj in changeDetails.insertedObjects {
                    let asset = obj as! PHAsset
                    self.delegate?.imagePickerViewControllerAssetDidCreate(self, asset: asset, locally: locally)
                }

                for obj in changeDetails.removedObjects {
                    let asset = obj as! PHAsset

                    if let idx = self.photosDataSource.selectedAssets.indexOf(asset) {
                        self.photosDataSource.selectedAssets.removeAtIndex(idx)
                    }

                    self.delegate?.imagePickerViewControllerAssetDidRemove(self, asset: asset)
                }
            }
        })
    }

    // MARK: UIImagePickerControllerDelegate

    public func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
        self.sourcesView.showLibraryPicker()
        self.isAssetCreating = false
    }

    public func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.delegate?.imagePickerViewControllerBeforeAssetChanged?(self)

        let mediaType = info[UIImagePickerControllerMediaType] as! String
        if CFStringCompare(mediaType, mediaType, CFStringCompareFlags()) == CFComparisonResult.CompareEqualTo {
            var imageToSave = info[UIImagePickerControllerOriginalImage] as! UIImage
            if let img = info[UIImagePickerControllerEditedImage] as? UIImage {
                imageToSave = img
            }

            self.saveAsset(imageToSave)
        }

        self.dismissViewControllerAnimated(true, completion: nil)
        self.sourcesView.showLibraryPicker()
    }

    // MARK: ImagePickerPhotosViewControllerDelegate

    func imagePickerPhotosViewControllerAssetDidSelect(viewController: ImagePickerPhotosViewController, asset: PHAsset, cell: ImagePickerPhotoCell) {
        self.delegate?.imagePickerViewControllerAssetDidSelect(self, asset: asset, cell: cell)
    }

    func imagePickerPhotosViewControllerAssetDidDeselect(viewController: ImagePickerPhotosViewController, asset: PHAsset, cell: ImagePickerPhotoCell) {
        self.delegate?.imagePickerViewControllerAssetDidDeselect(self, asset: asset, cell: cell)
    }

    func imagePickerPhotosViewControllerAssetDidLongTap(viewController: ImagePickerPhotosViewController, asset: PHAsset, cell: ImagePickerPhotoCell) {
        self.delegate?.imagePickerViewControllerAssetDidLongTap?(self, asset: asset, cell: cell)
    }

    // MARK: ImagePickerSourcesViewDelegate

    func imagePickerSourcesViewCameraDidTap(view: ImagePickerSourcesView) {
        if !UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            self.sourcesView.showLibraryPicker()
            return
        }

        let cameraUI = UIImagePickerController()

        cameraUI.allowsEditing = true
        cameraUI.delegate = self
        cameraUI.mediaTypes = [kUTTypeImage as String]
        cameraUI.modalPresentationStyle = UIModalPresentationStyle.CurrentContext
        cameraUI.sourceType = UIImagePickerControllerSourceType.Camera

        self.isAssetCreating = true

        self.presentViewController(cameraUI, animated: true, completion: nil)
    }

    func imagePickerSourcesViewLibraryDidTap(view: ImagePickerSourcesView) {
        self.delegate?.imagePickerViewControllerLibraryDidSelect?(self)
    }

    // MARK: Handlers

    @objc private func closeButtonDidTap(button: UIButton) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }

    @objc private func imagePickerAccessDeniedViewDidTap(gesture: UITapGestureRecognizer) {
        let url = NSURL(string: UIApplicationOpenSettingsURLString)
        UIApplication.sharedApplication().openURL(url!)
    }

    // MARK: Private methods

    private func addCloseButton() {
        let button = UIButton(frame: CGRectMake(0, 0, 16, 16))
        let buttonImage = UIImage(named: "close-icon")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)

        button.tintColor = UIColor.whiteColor()

        button.addTarget(self, action: #selector(ImagePickerViewController.closeButtonDidTap(_:)), forControlEvents: UIControlEvents.TouchUpInside)
        button.setBackgroundImage(buttonImage, forState: UIControlState.Normal)

        self.navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }

    private func disableLibrary() {
        self.isAuthorized = false

        self.sourcesView.hidden = true
        self.libraryView.hidden = true
        self.accessDeniedView.hidden = false

        self.delegate?.imagePickerViewControllerDidEnabled?(self, isAuthorized: false)
    }

    private func enableLibrary() {
        self.isAuthorized = true

        self.sourcesView.hidden = false
        self.libraryView.hidden = false
        self.accessDeniedView.hidden = true

        let vc = ImagePickerAlbumsViewController(photosDataSource: photosDataSource)
        vc.delegate = self
        vc.multipleSelection = self.multipleSelection
        vc.scrollDelegate = self.scrollDelegate

        let navigationController = UINavigationController(rootViewController: vc)
        navigationController.setNavigationBarHidden(true, animated: false)

        self.addChildViewController(navigationController)
        self.libraryView.addSubview(navigationController.view)

        navigationController.view.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.libraryView)
        }

        self.allAssetsFetchResults = ImagePickerPhotosDataSource.fetchAssets(nil)

        self.delegate?.imagePickerViewControllerDidEnabled?(self, isAuthorized: true)
    }

    private func imageWithText(text: String) -> UIImage {
        let initialSize = CGSizeMake(640, 640)
        var size = initialSize

        UIGraphicsBeginImageContext(size)
        let context = UIGraphicsGetCurrentContext()

        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextFillRect(context, CGRectMake(0, 0, size.width, size.height))

        size = CGSizeMake(600, 600)
        CGContextSetFillColorWithColor(context, UIColor.colorWithHex("#f2f2f2").CGColor)
        CGContextFillRect(context, CGRectMake(20, 20, size.width, size.height))

        size = CGSizeMake(560, 560)
        CGContextSetFillColorWithColor(context, UIColor.whiteColor().CGColor)
        CGContextFillRect(context, CGRectMake(40, 40, size.width, size.height))

        let fontSize: CGFloat = text.characters.count <= 30 ? 80 : 70
        let font = UIFont.systemFontOfSize(fontSize)

        let paragraphStyle: NSMutableParagraphStyle = NSParagraphStyle.defaultParagraphStyle().mutableCopy() as! NSMutableParagraphStyle
        paragraphStyle.lineBreakMode = NSLineBreakMode.ByWordWrapping
        paragraphStyle.alignment = NSTextAlignment.Center
        paragraphStyle.hyphenationFactor = 0

        let attributes = [
            NSFontAttributeName: font,
            NSForegroundColorAttributeName: UIColor.colorWithHex("#242b30"),
            NSParagraphStyleAttributeName: paragraphStyle
        ]

        size = CGSizeMake(520, 520);
        let textRect = text.boundingRectWithSize(size, options: NSStringDrawingOptions.UsesLineFragmentOrigin,
            attributes: attributes, context: nil)

        let x = (initialSize.width / 2) - (textRect.size.width / 2)
        let y = (initialSize.height / 2) - (textRect.size.height / 2)

        let rect = CGRectMake(x, y, textRect.size.width, textRect.size.height);
        text.drawInRect(rect, withAttributes: attributes)

        let newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();

        return newImage;
    }

    private func findAppAlbum() -> PHAssetCollection? {
        if let albName = self.newPhotoAlbumName {
            var appAlbum: PHAssetCollection? = nil
            let albums = PHAssetCollection.fetchAssetCollectionsWithType(PHAssetCollectionType.Album,
                    subtype: PHAssetCollectionSubtype.Any, options: nil)

            albums.enumerateObjectsUsingBlock { (album, idx, stop) -> Void in
                let alb = album as! PHAssetCollection

                if alb.localizedTitle == albName {
                    appAlbum = alb
                    stop.memory = true
                }
            }

            return appAlbum
        }

        return nil
    }

    // MARK: Public methods

    public func saveAsset(image: UIImage) {
        let library = PHPhotoLibrary.sharedPhotoLibrary()

        typealias saveImageType = (collection: PHAssetCollection?) -> Void
        let saveImage: saveImageType = { (collection: PHAssetCollection?) -> Void in
            library.performChanges({ () -> Void in
                if let coll = collection, let request = PHAssetCollectionChangeRequest(forAssetCollection: coll) {
                    let r = PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                    if let plh = r.placeholderForCreatedAsset {
                        request.addAssets([plh])
                    }
                } else {
                    PHAssetChangeRequest.creationRequestForAssetFromImage(image)
                }
            }, completionHandler: { (_, error) -> Void in
                if let err = error {
                    print("Error creating asset: \(err.description)")
                }
            })
        }

        if let albName = self.newPhotoAlbumName {
            if let ca = self.findAppAlbum() {
                saveImage(collection: ca)
            } else {
                do {
                    try library.performChangesAndWait({ () -> Void in
                        PHAssetCollectionChangeRequest.creationRequestForAssetCollectionWithTitle(albName)
                    })
                } catch let error {
                    print("Error creating collection: \(error)")
                    return
                }

                if let ca = self.findAppAlbum() {
                    saveImage(collection: ca)
                }
            }
        } else {
            saveImage(collection: nil)
        }
    }

    public func selectAsset(asset: PHAsset) {
        self.photosDataSource.selectAsset(asset)
    }

    public func deselectAsset(asset: PHAsset) {
        self.photosDataSource.deselectAsset(asset)
    }
}
