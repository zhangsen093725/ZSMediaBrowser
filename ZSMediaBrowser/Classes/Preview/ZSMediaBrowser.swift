//
//  ZSMediaBrowser.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/4/8.
//

import UIKit
import ZSViewUtil

/// preview 交互
@objc public protocol ZSMediaBrowserDelegate: class {
    
    /// 长按的回调，用于处理长按事件，开启长按事件时有效
    /// - Parameters:
    ///   - model: 媒体的model
    ///   - image: 加载完的图片 thumbImage，若 type = image 且 没有 thumbImage，则为 originImage
    @objc optional func zs_mediaBrowserwLongPress(from model: ZSMediaBrowserModel, image: UIImage?)
    
    /// 视图滚动的回调
    /// - Parameter index: 滚动视图的索引
    /// - 返回当前预览对应的View，主要用于做关闭预览时的对应回归动画
    @objc optional func zs_mediaBrowserwDidScroll(to index: Int) -> UIView?
}


/// preview 资源加载
@objc public protocol ZSMediaBrowserLoadDelegate: class {
    
    /// 加载 image URL
    /// - Parameters:
    ///   - imageView: 展示的imageView
    ///   - imageURL: image URL
    func zs_imageView(_ imageView: UIImageView, load imageURL: URL)
    
    /// 媒体加载失败
    /// - Parameter error: 错误信息
    @objc optional func zs_mediaBrowserwMediaLoadFail(_ error: Error)
}

@objcMembers open class ZSMediaBrowser: NSObject, UIScrollViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, ZSMediaPreviewCellDelegate {
    
    public weak var delegate: ZSMediaBrowserDelegate?
    public weak var loadDelegate: ZSMediaBrowserLoadDelegate?
    
    public var mediaBrowserView: ZSMediaBrowserView? {
        
        guard _mediaBrowserView_ == nil else { return _mediaBrowserView_ }
        
        let mediaBrowserView = getMediaPreview()
        
        mediaBrowserView.collectionView.register(imageCellClass, forCellWithReuseIdentifier: imageCellClass.zs_identifier)
        mediaBrowserView.collectionView.register(videoCellClass, forCellWithReuseIdentifier: videoCellClass.zs_identifier)
        mediaBrowserView.collectionView.register(audioCellClass, forCellWithReuseIdentifier: audioCellClass.zs_identifier)
        
        mediaBrowserView.collectionView.delegate = self
        mediaBrowserView.collectionView.dataSource = self
        
        mediaBrowserView.minimumSpacing = minimumSpacing
        mediaBrowserView.zs_didEndPreview = { [weak self] in
            self?.zs_didEndPreview()
        }
        
        _mediaBrowserView_ = mediaBrowserView
        
        return mediaBrowserView
    }
    
    var _mediaBrowserView_: ZSMediaBrowserView?
    
    /// medias 为 ZSMediaBrowserModel
    public var medias: [ZSMediaBrowserModel] = []
    
    /// 是否开启长按事件，默认为 false
    public var longPressEnable: Bool = false
    
    /// 当前选择的 preview 索引
    public var currentIndex: Int {
        return _currentIndex_
    }
    
    /// 当前选择的 preview 索引
    var _currentIndex_: Int = 0
    
    /// 媒体放大的最大倍数
    public var maximumZoomScale: CGFloat = 3
    
    /// 媒体缩小的最小倍数
    public var minimumZoomScale: CGFloat = 1
    
    /// 自定义 imageCellClass
    public var imageCellClass: ZSImageBrowserCell.Type = ZSImageBrowserCell.self
    
    /// 自定义 audioCellClass
    public var audioCellClass: ZSAudioBrowserCell.Type = ZSAudioBrowserCell.self
    
    /// 自定义 videoCellClass
    public var videoCellClass: ZSVideoBrowserCell.Type = ZSVideoBrowserCell.self
    
    /// preview 之间的间隙
    public var minimumSpacing: CGFloat = 20 {
        didSet {
            mediaBrowserView?.minimumSpacing = minimumSpacing
        }
    }
    
    /// preview insert
    public var sectionInset: UIEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0) {
        didSet {
            mediaBrowserView?.collectionView.reloadData()
        }
    }
    
    public func zs_didEndPreview() {
        mediaBrowserView?.removeFromSuperview()
        _mediaBrowserView_ = nil
    }
    
    func zs_configCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let model = medias[indexPath.item]
        
        var cell: ZSMediaBrowserCell?
        
        switch model.mediaType {
        case .image:
            cell = zs_configImageCell(collectionView, cellForItemAt: indexPath, model: model as! ZSImageBrowserModel)
            break
        case .video:
            cell = zs_configVideoCell(collectionView, cellForItemAt: indexPath, model: model as! ZSVideoBrowserModel)
            break
        case .audio:
            cell = zs_configAudioCell(collectionView, cellForItemAt: indexPath, model: model as! ZSAudioBrowserModel)
            break
        default:
            break
        }
        
        cell?.isExclusiveTouch = true
        cell?.zoomScrollView.minimumZoomScale = minimumZoomScale
        cell?.zoomScrollView.maximumZoomScale = maximumZoomScale
        cell?.minimumSpacing = minimumSpacing
        cell?.delegate = self
        
        return cell!
    }
}



/**
 * 1. ZSMediaBrowser 提供外部重写的方法
 * 2. 需要自定义每个Preview的样式，可重新以下的方法达到目的
 */
@objc extension ZSMediaBrowser {
    
    open func getMediaPreview() -> ZSMediaBrowserView {
        
        let mediaPreview = ZSMediaBrowserView()
        
        return mediaPreview
    }
    
    open func zs_configImageCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, model: ZSImageBrowserModel) -> ZSMediaBrowserCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZSImageBrowserCell.zs_identifier, for: indexPath) as! ZSImageBrowserCell
        
        if let image = model.originImage as? UIImage {
            cell.imageView.image = image
        }
        
        if let URLString = model.originImage as? String {
            if let url = URL(string: URLString) {
                loadDelegate?.zs_imageView(cell.imageView, load: url)
            }
        }
        
        let error: NSError = NSError.init(domain: NSURLErrorDomain, code: 10500, userInfo: [NSLocalizedDescriptionKey : "\(String(describing: model.originImage))\n无法识别的URL"])
        
        loadDelegate?.zs_mediaBrowserwMediaLoadFail?(error)
        
        return cell
    }
    
    open func zs_configAudioCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, model: ZSAudioBrowserModel) -> ZSMediaBrowserCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZSAudioBrowserCell.zs_identifier, for: indexPath) as! ZSAudioBrowserCell
        cell.playerView.urlString = model.URLString
        return cell
    }
    
    open func zs_configVideoCell(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath, model: ZSVideoBrowserModel) -> ZSMediaBrowserCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ZSVideoBrowserCell.zs_identifier, for: indexPath) as! ZSVideoBrowserCell
        
        if let image = model.thumbImage as? UIImage {
            cell.imageView.image = image
        }
        
        if let mediaFile = model.thumbImage as? String {
            if let url = URL(string: mediaFile) {
                loadDelegate?.zs_imageView(cell.imageView, load: url)
            }
        }
        
        cell.playerView.urlString = model.URLString
        
        return cell
    }
}



/**
 * 1. UICollectionView 的代理
 * 2. 可根据需求进行重写
 */
@objc extension ZSMediaBrowser {
    
    // TODO: UIScrollViewDelegate
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        var page = Int(scrollView.contentOffset.x / scrollView.frame.width + 0.5)
        
        page = page > medias.count ? medias.count - 1 : page
        
        guard currentIndex != page else { return }
        
        let cell = mediaBrowserView?.collectionView.cellForItem(at: IndexPath(item: currentIndex, section: 0)) as? ZSMediaBrowserCell

        cell?.zoomToOrigin()
        
        let model = medias[currentIndex]
        
        if model.mediaType != .image {
            let playerCell = cell as? ZSPlayerBrowserCell
            playerCell?.stop()
        }
        
        let next = mediaBrowserView?.collectionView.cellForItem(at: IndexPath(item: page, section: 0)) as? ZSMediaBrowserCell
        
        let shouldPanGesture = !((next?.zoomScrollView.contentOffset.y ?? 0) > 0)
        
        mediaBrowserView?.shouldPanGesture = shouldPanGesture
        
        _currentIndex_ = page
        mediaBrowserView?.updateFrame(from: delegate?.zs_mediaBrowserwDidScroll?(to: page))
    }
    
    // TODO: UICollectionViewDataSource
    open func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return medias.count
    }
    
    open func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        return zs_configCell(collectionView, cellForItemAt: indexPath)
    }
    
    // TODO: UICollectionViewDelegateFlowLayout
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return collectionView.bounds.size
    }
    
    open func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        
        return sectionInset
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        
        return 0
    }
}



// TODO:
@objc extension ZSMediaBrowser {
    
    open func zs_mediaBrowserCellScrollViewDidSingleTap() {
        mediaBrowserView?.endPreview()
    }
    
    open func zs_mediaBrowserCellScrollViewShouldPanGestureRecognizer(_ enable: Bool) {
        
        guard mediaBrowserView?.shouldPanGesture != enable else { return }
        
        if enable == false {
            mediaBrowserView?.endPanGestureRecognizer({ [weak self] in
                self?.mediaBrowserView?.shouldPanGesture = enable
            })
        } else {
            mediaBrowserView?.shouldPanGesture = enable
        }
    }
    
    open func zs_mediaBrowserCellMediaLoadFail(_ error: Error) {
        loadDelegate?.zs_mediaBrowserwMediaLoadFail?(error)
    }
    
    open func zs_mediaBrowserCellScrollViewDidLongPress(_ collectionCell: UICollectionViewCell) {
        
        guard let indexPath = mediaBrowserView?.collectionView.indexPath(for: collectionCell) else { return }
        
        let model = medias[indexPath.item]
        
        var image: UIImage?
        
        switch model.mediaType {
        case .image:
            
            guard let imageCell = collectionCell as? ZSImageBrowserCell else { break }
            image = imageCell.imageView.image
            break
        case .video:
            
            guard let videoCell = collectionCell as? ZSVideoBrowserCell else { break }
            image = videoCell.imageView.image
            break
        case .audio:
            break
        default:
            break
        }
        
        delegate?.zs_mediaBrowserwLongPress?(from: model, image: image)
    }
    
    open func zs_mediaBrowserCellMediaDidChangePlay(status: ZSPlayerStatus) {
        
        
    }
    
    open func zs_mediaBrowserCellMediaDidiChangePlayTime(second: TimeInterval) {
        
    }
    
    open func zs_mediaBrowserCellMediaLoadingView() -> UIView? {
        
        return nil
    }
}
