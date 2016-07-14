//
//  MainViewController.swift
//  MVImagePicker
//
//  Created by Mikhail Vetoshkin on 06/17/2016.
//  Copyright (c) 2016 Mikhail Vetoshkin. All rights reserved.
//

import JTSImageViewController
import MVImagePicker
import Photos
import SnapKit
import SVProgressHUD
import UIKit


class MainViewController: UIViewController, UIGestureRecognizerDelegate, ImagePickerViewControllerDelegate,
        ImagePickerViewControllerScrollDelegate {

    private var imagePickerViewTopConstraint: Constraint?
    private var selectedImageRemoveViewCenterXConstraint: Constraint?
    private var currentAsset: PHAsset?
    private let imageManager = PHImageManager()

    private let selectedImageRemoveViewTopOffset: CGFloat = 10
    private let selectedImageRemoveViewWidth: CGFloat = 20

    private let selectedImageWrapperViewHeight: CGFloat = CGRectGetHeight(UIScreen.mainScreen().bounds) / 3
    private var imagePickerViewCurrentTopOffset: CGFloat = 0
    private let imagePickerViewMinOffset: CGFloat = 50

    private var isViewLoading = true
    private var isImagePickerDragging = false
    private var isImagePickerFullscreen = false

    // MARK: Lazy init

    lazy private var selectedImageWrapperView: UIView = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.selectedImageWrapperViewDidTap(_:)))
        tap.numberOfTapsRequired = 1

        let el = UIView(frame: CGRectZero)
        el.backgroundColor = UIColor.ipLightGrayColor()
        el.userInteractionEnabled = true

        el.addGestureRecognizer(tap)

        el.addSubview(self.selectedImageViewText)
        el.addSubview(self.selectedImageView)
        el.addSubview(self.selectedImageRemoveView)

        return el
    }()

    lazy private var selectedImageViewText: UILabel = {
        let el = UILabel(frame: CGRectZero)

        el.text = "Select an image from the library"
        el.textAlignment = NSTextAlignment.Center
        el.textColor = UIColor.ipDarkGrayColor()

        return el
    }()

    lazy private var selectedImageView: UIImageView = {
        let el = UIImageView(frame: CGRectZero)

        el.alpha = 0
        el.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        el.contentMode = UIViewContentMode.ScaleAspectFit

        return el
    }()

    lazy private var selectedImageRemoveView: UIImageView = {
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.selectedImageRemoveViewDidTap(_:)))
        tap.numberOfTapsRequired = 1

        let el = UIImageView(image: UIImage(named: "selected-photo-remove"))
        el.alpha = 0
        el.userInteractionEnabled = true

        el.addGestureRecognizer(tap)

        return el
    }()

    lazy private var imagePickerView: UIView = {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(self.imagePickerViewDidSwipe(_:)))
        gesture.delegate = self

        let el = UIView(frame: CGRectZero)
        el.addGestureRecognizer(gesture)

        return el
    }()

    lazy private var imagePickerViewController: ImagePickerViewController = {
        let el = ImagePickerViewController()

        el.delegate = self
        el.multipleSelection = false
        el.scrollDelegate = self

        return el
    }()

    // MARK: Life cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "MVImagePicker"
        self.view.backgroundColor = UIColor.whiteColor()

        self.view.addSubview(self.selectedImageWrapperView)
        self.view.addSubview(self.imagePickerView)
        self.imagePickerView.addSubview(self.imagePickerViewController.view)

        self.setupConstraints()
    }

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        if self.isViewLoading {
            // Can't add this line into viewDidLoad, because of in this case child controller
            // doesn't work as expected, specifically after loading large album it's collection view
            // can't call setContentOffset correctly for hiding 'back' button
            self.addChildViewController(self.imagePickerViewController)
        }

        self.isViewLoading = false
    }

    // MARK: Layout

    private func setupConstraints() {
        self.selectedImageWrapperView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.imagePickerView.snp_top)

            make.height.equalTo(self.selectedImageWrapperViewHeight)
            make.width.equalTo(self.view)
        }

        self.selectedImageViewText.snp_makeConstraints { (make) in
            make.center.equalTo(self.selectedImageWrapperView)
        }

        self.selectedImageRemoveView.snp_makeConstraints { (make) in
            make.top.equalTo(self.selectedImageView).offset(self.selectedImageRemoveViewTopOffset)
            self.selectedImageRemoveViewCenterXConstraint = make.centerX.equalTo(self.selectedImageView).constraint

            make.height.equalTo(self.selectedImageRemoveViewWidth)
            make.width.equalTo(self.selectedImageRemoveViewWidth)
        }

        self.selectedImageView.snp_makeConstraints { (make) in
            make.edges.equalTo(self.selectedImageWrapperView).offset(UIEdgeInsetsMake(10, 10, -10, -10))
        }

        self.imagePickerView.snp_makeConstraints { (make) -> Void in
            make.left.equalTo(self.view)
            make.right.equalTo(self.view)
            make.bottom.equalTo(self.view)

            self.imagePickerViewTopConstraint = make.top.equalTo(self.view).constraint
        }

        self.imagePickerViewController.view.snp_makeConstraints { (make) -> Void in
            make.edges.equalTo(self.imagePickerView)
        }
    }

    // MARK: UIGestureRecognizerDelegate

    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWithGestureRecognizer otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }

    // MARK: ImagePickerViewControllerDelegate

    func imagePickerViewControllerBeforeAssetChanged(viewController: ImagePickerViewController) {
        SVProgressHUD.showWithMaskType(SVProgressHUDMaskType.Black)
    }

    func imagePickerViewControllerAfterAssetChanged(viewController: ImagePickerViewController) {
        SVProgressHUD.dismiss()
    }

    func imagePickerViewControllerDidEnabled(viewController: ImagePickerViewController, isAuthorized: Bool) {
        self.imagePickerViewTopConstraint?.updateOffset(isAuthorized ? self.selectedImageWrapperViewHeight : 0)
    }

    func imagePickerViewControllerAssetDidCreate(viewController: ImagePickerViewController, asset: PHAsset, locally: Bool) {
        if locally {
            self.addPhoto(asset)
            self.imagePickerViewController.selectAsset(asset)
        }
    }

    func imagePickerViewControllerAssetDidRemove(viewController: ImagePickerViewController, asset: PHAsset) {
        self.removePhoto(asset)
    }

    func imagePickerViewControllerAssetDidSelect(viewController: ImagePickerViewController, asset: PHAsset, cell: ImagePickerPhotoCell) {
        self.addPhoto(asset)
    }

    func imagePickerViewControllerAssetDidDeselect(viewController: ImagePickerViewController, asset: PHAsset, cell: ImagePickerPhotoCell) {
        self.removePhoto(asset)
    }

    func imagePickerViewControllerAssetDidLongTap(viewController: ImagePickerViewController, asset: PHAsset, cell: ImagePickerPhotoCell) {
        self.imageManager.requestImageDataForAsset(asset, options: nil, resultHandler: { (imageData, _, _, _) -> Void in
            if let data = imageData {
                let image = UIImage(data: data)
                let imageInfo = JTSImageInfo()

                imageInfo.image = image
                imageInfo.referenceRect = cell.frame
                imageInfo.referenceView = cell.superview

                let imageViewer = JTSImageViewController(imageInfo: imageInfo, mode: JTSImageViewControllerMode.Image,
                    backgroundStyle: JTSImageViewControllerBackgroundOptions.None)
                imageViewer.showFromViewController(self, transition: JTSImageViewControllerTransition.FromOriginalPosition)
            }
        })
    }

    // MARK: ImagePickerViewControllerScrollDelegate

    func imagePickerViewControllerWillBeginDragging(scrollView: UIScrollView) {
        self.isImagePickerDragging = true
    }

    func imagePickerViewControllerDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        self.isImagePickerDragging = false
    }

    func imagePickerViewControllerDidScroll(scrollView: UIScrollView) {
        if scrollView.contentOffset.y < 0 && self.isImagePickerFullscreen && self.isImagePickerDragging {
            self.toggleImagePicker()
        }
    }

    // MARK: Handlers

    @objc private func selectedImageWrapperViewDidTap(gesture: UITapGestureRecognizer) {
        if self.isImagePickerFullscreen {
            self.toggleImagePicker()
        }
    }

    @objc private func selectedImageRemoveViewDidTap(gesture: UITapGestureRecognizer) {
        if let ast = self.currentAsset {
            self.removePhoto(ast)
            self.imagePickerViewController.deselectAsset(ast)
        }
    }

    @objc private func imagePickerViewDidSwipe(gesture: UIPanGestureRecognizer) {
        struct Statics {
            static var lastYPoint: CGFloat = 0
            static var lastDelta: CGFloat = 0
            static var wasMoved = false
        }

        let location = gesture.locationInView(self.imagePickerView)
        let currentPoint = gesture.translationInView(gesture.view!)


        if gesture.state == UIGestureRecognizerState.Began {
            Statics.lastYPoint = 0
            Statics.lastDelta = 0
            Statics.wasMoved = false
            return
        }

        if gesture.state == UIGestureRecognizerState.Ended {
            if !self.isImagePickerFullscreen && Statics.lastDelta > 0 || self.isImagePickerFullscreen && Statics.lastDelta < 0 {
                self.isImagePickerFullscreen = Statics.lastDelta < 0
                self.toggleImagePicker()
            }

            return
        }

        if (location.y > ImagePickerViewController.sourcesHeight && !Statics.wasMoved) || (location.y < 0 && !Statics.wasMoved)  {
            Statics.lastYPoint = currentPoint.y
            return
        }

        let delta = Statics.lastYPoint - currentPoint.y
        let newOffset = self.imagePickerViewCurrentTopOffset - delta

        if newOffset >= self.imagePickerViewMinOffset && newOffset <= self.imagePickerViewCurrentTopOffset {
            self.setViewsOffset(newOffset, updateLayout: true, animated: false)
            Statics.wasMoved = true
        } else {
            Statics.wasMoved = false
        }

        Statics.lastYPoint = currentPoint.y
        Statics.lastDelta = delta
    }

    // MARK: Private methods

    private func setViewsOffset(newOffset: CGFloat?, updateLayout: Bool = true, animated: Bool = true) {
        self.imagePickerViewCurrentTopOffset = selectedImageWrapperViewHeight
        if let offset = newOffset {
            self.imagePickerViewCurrentTopOffset = offset
        }

        self.imagePickerViewTopConstraint?.updateOffset(self.imagePickerViewCurrentTopOffset)

        if updateLayout {
            if (animated) {
                UIView.animateWithDuration(0.3, animations: { () -> Void in
                    self.view.layoutIfNeeded()
                })
            }

            self.view.layoutIfNeeded()
        }
    }

    private func toggleImagePicker() {
        self.isImagePickerFullscreen = !self.isImagePickerFullscreen

        let offset: CGFloat? = self.isImagePickerFullscreen ? self.imagePickerViewMinOffset : nil
        self.setViewsOffset(offset, updateLayout: true, animated: true)
    }

    private func addPhoto(asset: PHAsset) {
        self.imageManager.requestImageDataForAsset(asset, options: nil, resultHandler: { (imageData, _, _, _) -> Void in
            if let data = imageData {
                self.selectedImageView.image = UIImage(data: data)
                self.currentAsset = asset

                self.selectedImageViewText.alpha = 0
                self.selectedImageView.alpha = 1
                self.selectedImageRemoveView.alpha = 1

                let height = CGRectGetHeight(self.selectedImageView.bounds)
                let ratio = height / CGFloat(asset.pixelHeight)
                let width = CGFloat(asset.pixelWidth) * ratio
                
                let offset = width / 2 - self.selectedImageRemoveViewWidth / 2 - self.selectedImageRemoveViewTopOffset
                self.selectedImageRemoveViewCenterXConstraint?.updateOffset(offset)
            }
        })
    }
    
    private func removePhoto(asset: PHAsset) {
        self.selectedImageViewText.alpha = 1
        self.selectedImageView.alpha = 0
        self.selectedImageRemoveView.alpha = 0
        
        self.selectedImageView.image = nil
        self.currentAsset = nil
    }
}

