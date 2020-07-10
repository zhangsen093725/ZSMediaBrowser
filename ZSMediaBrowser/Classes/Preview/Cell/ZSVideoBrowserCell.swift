//
//  ZSVideoBrowserCell.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/4/8.
//

import UIKit
import ZSViewUtil

@objcMembers open class ZSVideoBrowserCell: ZSPlayerBrowserCell {
    
    public var isZoomEnable: Bool = false
    
    public lazy var imageView: UIImageView = {
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        playerView.insertSubview(imageView, at: 0)
        return imageView
    }()
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = playerView.bounds
    }
}


@objc extension ZSVideoBrowserCell {

    open override func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return isZoomEnable ? playerView : nil
    }
}



@objc extension ZSVideoBrowserCell {
    
    open override func zs_player(_ playerView: ZSPlayerView, didChangePaly status: ZSPlayerStatus) {
     
        super.zs_player(playerView, didChangePaly: status)
        
        if status == .playing {
            imageView.isHidden = true
        }
        
        if status == .stop {
            imageView.isHidden = false
        }
    }
}

