//
//  ZSMediaBrowserModel.swift
//  Pods-ZSViewUtil_Example
//
//  Created by 张森 on 2020/4/8.
//

import UIKit

@objc public enum ZSMediaType: Int {
    case undefine = 0, image = 1, video = 2, audio = 3
}

@objcMembers open class ZSMediaBrowserModel: NSObject {
    
    /// 缩略（封面）图片（URL、UIImage）
    public var thumbImage: Any?
    
    /// 媒体类型
    public var mediaType: ZSMediaType { return .undefine }
    
    /// 媒体的文件大小，单位Btye
    public var mediaBtye: Float = 0
}



@objcMembers open class ZSImageBrowserModel: ZSMediaBrowserModel {
    
    /// 媒体文件（URL、UIImage）
    public var originImage: Any?
    
    /// 媒体类型
    public override var mediaType: ZSMediaType { return .image }
    
    /// 媒体cellClass
    public var cellClass: ZSImageBrowserCell.Type { return ZSImageBrowserCell.self }
}



@objcMembers open class ZSAudioBrowserModel: ZSMediaBrowserModel {
    
    /// 媒体URL
    public var URLString: String?

    /// 媒体类型
    public override var mediaType: ZSMediaType { return .audio }
    
    /// 媒体cellClass
    public var cellClass: ZSPlayerBrowserCell.Type { return ZSPlayerBrowserCell.self }
}



@objcMembers open class ZSVideoBrowserModel: ZSMediaBrowserModel {
    
    /// 媒体URL
    public var URLString: String?
    
    /// 媒体类型
    public override var mediaType: ZSMediaType { return .video }
    
    /// 媒体cellClass
    public var cellClass: ZSPlayerBrowserCell.Type { return ZSPlayerBrowserCell.self }
}
