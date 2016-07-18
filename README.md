# MVImagePicker

[![CI Status](http://img.shields.io/travis/Mikhail Vetoshkin/MVImagePicker.svg?style=flat)](https://travis-ci.org/Mikhail Vetoshkin/MVImagePicker)
[![Version](https://img.shields.io/cocoapods/v/MVImagePicker.svg?style=flat)](http://cocoapods.org/pods/MVImagePicker)
[![License](https://img.shields.io/cocoapods/l/MVImagePicker.svg?style=flat)](http://cocoapods.org/pods/MVImagePicker)
[![Platform](https://img.shields.io/cocoapods/p/MVImagePicker.svg?style=flat)](http://cocoapods.org/pods/MVImagePicker)

![1](https://cloud.githubusercontent.com/assets/882141/16874775/578cd18e-4aac-11e6-802e-dc614d92a52e.PNG)
![2](https://cloud.githubusercontent.com/assets/882141/16874806/7c261190-4aac-11e6-9103-19fb6d21965a.PNG)

## Features

- Multiple selection
- Switching between albums
- Taking photos

## Usage

You can do the next steps to use MVImagePicker:

```swift
let ctrl = ImagePickerViewController()

ctrl.delegate = self
ctrl.multipleSelection = false
ctrl.scrollDelegate = self

self.view.addSubview(ctrl.view)
self.addChildViewController(ctrl)
```

MVImagePicker has several delegate methods:

#### 1. ImagePickerViewControllerDelegate protocol

```swift
optional func imagePickerViewControllerDidEnabled(viewController: ImagePickerViewController, isAuthorized: Bool)
```
This delegate is used when user permits access to the photos on the device

```swift
optional func imagePickerViewControllerLibraryDidSelect(viewController: ImagePickerViewController)
```
This delegate is used when user clicks on the library icon in the top of the MVImagePicker controller

```swift
optional func imagePickerViewControllerAlbumOpened(viewController: ImagePickerViewController, album: PHAssetCollection)
```
This delegate method is used when user opens a library

```swift
optional func imagePickerViewControllerBeforeAssetChanged(viewController: ImagePickerViewController)
optional func imagePickerViewControllerAfterAssetChanged(viewController: ImagePickerViewController)
```
These 2 delegate methods are used before and after user adds a new asset into the library

```swift
func imagePickerViewControllerAssetDidCreate(viewController: ImagePickerViewController, asset: PHAsset, locally: Bool)
func imagePickerViewControllerAssetDidRemove(viewController: ImagePickerViewController, asset: PHAsset)
```
These 2 delegate methods are used when an asset is created or removed from the library (even using Photos or some another app)

```swift
func imagePickerViewControllerAssetDidSelect(viewController: ImagePickerViewController, asset: PHAsset, cell: ImagePickerPhotoCell)
func imagePickerViewControllerAssetDidDeselect(viewController: ImagePickerViewController, asset: PHAsset, cell: ImagePickerPhotoCell)
```
These 2 delegate methods are used when user selects or deselects an asset in the library

```swift
optional func imagePickerViewControllerAssetDidLongTap(viewController: ImagePickerViewController, asset: PHAsset, cell: ImagePickerPhotoCell)
```
This delegate method is used when user does a long tap on any asset in the library

#### 2. ImagePickerViewControllerScrollDelegate protocol

```swift
optional func imagePickerViewControllerWillBeginDragging(scrollView: UIScrollView)
optional func imagePickerViewControllerDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool)
optional func imagePickerViewControllerDidScroll(scrollView: UIScrollView)
```
These 3 delegates are just wrappers for standard scrollViewWillBeginDragging, scrollViewDidEndDragging and 
scrollViewDidScroll, and they are used for photos collection view

## Requirements

iOS 8 or above

## Installation

MVImagePicker is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod "MVImagePicker"
```

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Author

Mikhail Vetoshkin, mvetoshkin@gmail.com

## License

MVImagePicker is available under the MIT license. See the LICENSE file for more info.
