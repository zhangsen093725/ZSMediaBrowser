//
//  ZSMediaBrowserCustome.swift
//  ZSMediaBrowser
//
//  Created by 张森 on 2020/4/21.
//

import ZSViewUtil
import ZSMediaBrowser

@objc public protocol KBPreviewServeDelegate: ZSMediaBrowserDelegate {
    
    @objc optional func zs_saveSource(_ source: Any, didFinishWith error: Error?)
}

@objc public protocol KBPreviewLoadServeDelegate: ZSMediaBrowserLoadDelegate {
    
    
}

@objcMembers open class ZSMediaBrowserCustome: ZSMediaBrowser {
    
    public weak var kb_delegate: KBPreviewServeDelegate? {
        didSet {
            delegate = kb_delegate
        }
    }
    
    public weak var kb_loadDelegate: KBPreviewLoadServeDelegate? {
        didSet {
            loadDelegate = kb_loadDelegate
        }
    }
    
    public lazy var loadingView: ZSLoadingView = {
        
        let loadingView = ZSLoadingView()
        loadingView.configLoadView()
        loadingView.startAnimation()
        loadingView.backgroundColor = .clear
        return loadingView
    }()
    
    var customView: ZSMediaBrowserCustomView? {
        return mediaBrowserView as? ZSMediaBrowserCustomView
    }
    
    open override func getMediaPreview() -> ZSMediaBrowserView {
        
        let mediaBrowserView = ZSMediaBrowserCustomView()
        mediaBrowserView.pageLabel.text = "\(currentIndex + 1)/\(medias.count)"
        return mediaBrowserView
    }
}



@objc extension ZSMediaBrowserCustome {
    
    open override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        super.scrollViewDidScroll(scrollView)
        customView?.pageLabel.text = "\(currentIndex + 1)/\(medias.count)"
    }
    
    open override func zs_mediaBrowserCellMediaDidChangePlay(status: ZSPlayerStatus) {
        
    }
    
    open override func zs_mediaBrowserCellMediaDidiChangePlayTime(second: TimeInterval) {
        
    }
    
    open override func zs_mediaBrowserCellMediaLoadingView() -> UIView? {
        
        return loadingView
    }
}



@objc extension ZSMediaBrowserCustome {
    
    open func saveImage(from image: UIImage?) {
        
        guard image != nil else { return }
        
        UIImageWriteToSavedPhotosAlbum(image!, self, #selector(saveSource(_:didFinishWith:contentInfo:)), nil)
    }
    
    open func saveVideo(from path: String) {
        
        UISaveVideoAtPathToSavedPhotosAlbum(path, self, #selector(saveSource(_:didFinishWith:contentInfo:)), nil)
    }
    
    @objc open func saveSource(_ source: Any, didFinishWith error: Error?, contentInfo: AnyObject) {
        kb_delegate?.zs_saveSource?(source, didFinishWith: error)
    }
}
