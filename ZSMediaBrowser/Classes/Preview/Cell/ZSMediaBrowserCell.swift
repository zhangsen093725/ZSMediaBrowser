//
//  ZSMediaBrowserCell.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/4/8.
//

import UIKit
import ZSViewUtil

@objc public protocol ZSMediaPreviewCellDelegate: class {
    
    /// 单击事件回调
    func zs_mediaBrowserCellScrollViewDidSingleTap()
    
    /// 长按事件回调
    /// - Parameter collectionCell: collectionCell
    func zs_mediaBrowserCellScrollViewDidLongPress(_ collectionCell: UICollectionViewCell)
    
    /// 是否触发拖动手势回调
    /// - Parameter enable: 是否可以触发
    func zs_mediaBrowserCellScrollViewShouldPanGestureRecognizer(_ enable: Bool)
    
    /// 资源加载失败
    /// - Parameter error: 错误信息
    func zs_mediaBrowserCellMediaLoadFail(_ error: Error)
    
    /// 播放器状态改变
    /// - Parameter status: 状态
    func zs_mediaBrowserCellMediaDidChangePlay(status: ZSPlayerStatus)
    
    /// 当前播放时长改变
    /// - Parameter second: 播放时长，单位秒
    func zs_mediaBrowserCellMediaDidiChangePlayTime(second: TimeInterval)
    
    /// 资源加载的Loading View
    func zs_mediaBrowserCellMediaLoadingView() -> UIView?
}

@objcMembers open class ZSMediaBrowserCell: UICollectionViewCell, UIScrollViewDelegate {
    
    var minimumSpacing: CGFloat = 0
    
    var isBeginDecelerating: Bool = false
    
    var scrollLimit: CGFloat {
        return zoomScrollView.contentSize.height <= zoomScrollView.frame.height ?
            (zoomScrollView.contentSize.height - zoomScrollView.frame.height) :
            zoomScrollView.frame.height * 0.15
    }
    
    weak var delegate: ZSMediaPreviewCellDelegate? {
        didSet {
            getCustomLoadingView()
        }
    }
    
    open class var zs_identifier: String { return NSStringFromClass(self) }
    
    public lazy var zoomScrollView: ZSMediaPreviewScrollView = {
        
        let scrollView = ZSMediaPreviewScrollView()
        scrollView.showsVerticalScrollIndicator = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.delegate = self
        scrollView.backgroundColor = .clear
        
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        }
        
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(longPress(_:)))
        longPress.minimumPressDuration = 0.5
        contentView.addGestureRecognizer(longPress)
        contentView.insertSubview(scrollView, at: 0)
        
        return scrollView
    }()
    
    var customLoadingView: UIView?
    
    open override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = CGRect(x: 0, y: 0, width: bounds.width - minimumSpacing, height: bounds.height)
        zoomScrollView.frame = contentView.bounds
        customLoadingView?.frame = CGRect(x: (contentView.frame.width - 75) * 0.5, y: (contentView.frame.height - 75) * 0.5, width: 75, height: 75)
    }
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        delegate = nil
    }
    
    func getCustomLoadingView() {
        
        guard delegate != nil else { return }
        
        let customLoadingView = delegate?.zs_mediaBrowserCellMediaLoadingView()
                
        if customLoadingView != self.customLoadingView {
            self.customLoadingView?.removeFromSuperview()
        }
            
        if customLoadingView != nil {
            contentView.addSubview(customLoadingView!)
        }
        
        self.customLoadingView = customLoadingView
    }
}


// TODO: Event
@objc extension ZSMediaBrowserCell {
    
    open override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        let touch = touches.first
        let touchPoint = touch?.location(in: self)
        
        if touch?.tapCount == 1 {
            perform(#selector(singleTap), with: touchPoint, afterDelay: 0.3)
        }
        
        if touch?.tapCount == 2 {
            enlargeImage(from: touchPoint ?? .zero)
        }
    }
    
    @objc open func singleTap() {
        delegate?.zs_mediaBrowserCellScrollViewDidSingleTap()
    }
    
    @objc open func longPress(_ longPressGesture: UILongPressGestureRecognizer) {
        delegate?.zs_mediaBrowserCellScrollViewDidLongPress(self)
    }
}



// TODO: 缩放方法
@objc extension ZSMediaBrowserCell {
    
    open func zoomToOrigin() {
        guard zoomScrollView.zoomScale != 1 else { return }
        zoomScrollView.setZoomScale(1, animated: true)
    }
    
    open func enlargeImage(from point: CGPoint) {
        
        guard viewForZooming(in: zoomScrollView)?.frame.contains(point) ?? false else { return }
        
        if zoomScrollView.zoomScale > zoomScrollView.minimumZoomScale {
            zoomScrollView.setZoomScale(zoomScrollView.minimumZoomScale, animated: true)
            return
        }
        
        let zoomScale = zoomScrollView.maximumZoomScale
        let x = self.frame.width / zoomScale
        let y = self.frame.height / zoomScale
        zoomScrollView.zoom(to: CGRect(x: point.x - x * 0.5, y: point.y - y * 0.5, width: x, height: y), animated: true)
    }
    
    open func refreshMediaViewCenter(from point: CGPoint) {
        viewForZooming(in: zoomScrollView)?.center = point
    }
}



// TODO: UIScrollViewDelegate
@objc extension ZSMediaBrowserCell {
    
    open func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        guard scrollView.contentSize != .zero else { return }
        
        guard scrollView.zoomScale == 1 else {
            delegate?.zs_mediaBrowserCellScrollViewShouldPanGestureRecognizer(false)
            return
        }
        
        if scrollView.contentOffset.y > 0 {
            delegate?.zs_mediaBrowserCellScrollViewShouldPanGestureRecognizer(false)
        }
        
        guard isBeginDecelerating == false else { return }
        
        let shouldPanGesture = scrollView.contentOffset.y < -scrollLimit
        
        guard shouldPanGesture else { return }
        
        delegate?.zs_mediaBrowserCellScrollViewShouldPanGestureRecognizer(shouldPanGesture)
        
        scrollView.contentOffset = CGPoint(x: 0, y: 0)
        return
    }
    
    open func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    open func scrollViewDidZoom(_ scrollView: UIScrollView) {
        
        let offsetX = (scrollView.frame.width > scrollView.contentSize.width) ? (scrollView.frame.width - scrollView.contentSize.width) * 0.5 : 0
        let offsetY = (scrollView.frame.height > scrollView.contentSize.height) ? (scrollView.frame.height - scrollView.contentSize.height) * 0.5 : 0
        refreshMediaViewCenter(from: CGPoint(x: scrollView.contentSize.width * 0.5 + offsetX, y: scrollView.contentSize.height * 0.5 + offsetY))
    }
    
    open func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        isBeginDecelerating = true
    }
    
    open func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        isBeginDecelerating = false
    }
}




@objcMembers open class ZSMediaPreviewScrollView: UIScrollView, UIGestureRecognizerDelegate {
    
    override public func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        next?.next?.touchesEnded(touches, with: event)
        super.touchesEnded(touches, with: event)
    }
    
    // TODO: UIGestureRecognizerDelegate
    open func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
                
        if otherGestureRecognizer.view is UICollectionView {
            return false
        }
        
        return zoomScale == 1
    }
}
