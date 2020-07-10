//
//  ZSMediaBrowserCustomView.swift
//  KBPreview
//
//  Created by 张森 on 2020/4/21.
//

import Foundation
import ZSViewUtil
import ZSMediaBrowser

@objcMembers open class ZSMediaBrowserCustomView: ZSMediaBrowserView {
    
    public lazy var pageLabel: UILabel = {
        
        let label = UILabel()
        label.textColor = .white
        if #available(iOS 8.2, *) {
            label.font = KFont(15, weight: .bold)
        } else {
            label.font = KBoldFont(15)
        }
        label.textAlignment = .left
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = .zero
        label.layer.shadowOpacity = 1
        label.isUserInteractionEnabled = false
        addSubview(label)
        return label
    }()
    
    public lazy var downloadButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.setTitleColor(.white, for: .normal)
        button.setTitle("保存", for: .normal)
        button.titleLabel?.layer.shadowColor = UIColor.black.cgColor
        button.titleLabel?.layer.shadowOffset = .zero
        button.titleLabel?.layer.shadowOpacity = 1
        if #available(iOS 8.2, *) {
            button.titleLabel?.font = KFont(15, weight: .bold)
        } else {
            button.titleLabel?.font = KBoldFont(15)
        }
        addSubview(button)
        return button
    }()
    
    override open func layoutSubviews() {
        super.layoutSubviews()

        downloadButton.frame = CGRect(x: frame.width - 60 * KWidthUnit, y: frame.height - 30 * KHeightUnit - KDevice.homeHeight, width: 60 * KWidthUnit, height: 30 * KHeightUnit)
        pageLabel.frame = CGRect(x: 10 * KWidthUnit, y: downloadButton.zs_y, width: downloadButton.zs_x, height: downloadButton.zs_h)
    }
}
