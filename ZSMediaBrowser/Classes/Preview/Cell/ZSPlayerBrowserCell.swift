//
//  ZSPlayerBrowserCell.swift
//  Kingfisher
//
//  Created by 张森 on 2020/4/14.
//

import UIKit
import ZSViewUtil

@objcMembers open class ZSPlayerBrowserCell: ZSMediaBrowserCell, ZSPlayerViewDelegate {
    
    public var isPlayButtonHidden: Bool = false {
        didSet {
            playButton.isHidden = isPlayButtonHidden
        }
    }
    
    public lazy var playerView: ZSPlayerView = {
        
        let playerView = ZSPlayerView()
        playerView.backgroundColor = .clear
        playerView.delegate = self
        playerView.isAutoStartPlayEnable = true
        zoomScrollView.addSubview(playerView)
        return playerView
    }()
    
    public lazy var playButton: UIButton = {
        
        let button = UIButton(type: .system)
        button.tintColor = .clear
        button.contentMode = .scaleAspectFit
        button.imageView?.contentMode = .scaleAspectFit
        button.backgroundColor = .clear
        
        if let resouce = Bundle(for: Self.classForCoder()).url(forResource: "ZSMediaBrowser", withExtension: "bundle") {
            let image = UIImage(named: "ic_playerPreview_play", in: Bundle(url: resouce), compatibleWith: nil)?.withRenderingMode(.alwaysOriginal)
            button.setBackgroundImage(image, for: .normal)
        }
       
        button.addTarget(self, action: #selector(playButtonAction(_:)), for: .touchUpInside)
        playerView.addSubview(button)
        return button
    }()
    
    override open func layoutSubviews() {
        super.layoutSubviews()
        
        playerView.frame = zoomScrollView.bounds
        zoomScrollView.contentSize = .zero
        playButton.frame = CGRect(x: (playerView.frame.width - 75) * 0.5, y: (playerView.frame.height - 75) * 0.5, width: 75, height: 75)
        customLoadingView?.frame = playButton.frame
    }
    
    override func getCustomLoadingView() {
        super.getCustomLoadingView()
        customLoadingView?.isHidden = true
    }
    
    open func stop() {
        
        playButton.isHidden = isPlayButtonHidden
        playButton.alpha = 1
        customLoadingView?.isHidden = true
        customLoadingView?.alpha = 0
        
        playerView.stop()
    }
    
    @objc func playButtonAction(_ sender: UIButton) {
        
        play()
        
        sender.alpha = 1
        customLoadingView?.alpha = 0
        customLoadingView?.isHidden = false
        
        UIView.animate(withDuration: 0.25, animations: { [weak self] in
            sender.alpha = 0
            self?.customLoadingView?.alpha = 1
        }) { (finished) in
            
        }
    }
    
    func play() {
        
        if playerView.playStatus == .pasue {
            playerView.play()
            return
        }
        
        guard playerView.playStatus != .playing else { return }
        
        playerView.preparePlay()
    }
}



// TODO: ZSPlayerViewDelegate
@objc extension ZSPlayerBrowserCell {
    
    open func zs_palyer(_ playerView: ZSPlayerView, didOccur error: Error?) {
        
        let error: NSError = NSError.init(domain: NSURLErrorDomain, code: 10501, userInfo: [NSLocalizedDescriptionKey : "\(String(describing: error?.localizedDescription))"])
        delegate?.zs_mediaBrowserCellMediaLoadFail(error)
    }
    
    open func zs_playerUnknown(_ playerView: ZSPlayerView) {
        
        let error: NSError = NSError.init(domain: NSURLErrorDomain, code: 10502, userInfo: [NSLocalizedDescriptionKey : "URL资源加载未知错误"])
        delegate?.zs_mediaBrowserCellMediaLoadFail(error)
    }
    
    open func zs_playerToEnd(_ playerView: ZSPlayerView) {
        
    }
    
    open func zs_player(_ playerView: ZSPlayerView, currentTime second: TimeInterval) {
        
        delegate?.zs_mediaBrowserCellMediaDidiChangePlayTime(second: second)
    }
    
    open func zs_player(_ playerView: ZSPlayerView, didChangePaly status: ZSPlayerStatus) {
        
        delegate?.zs_mediaBrowserCellMediaDidChangePlay(status: status)
        
        customLoadingView?.isHidden = status != .loading
        
        guard isPlayButtonHidden == false else { return }
        
        if status == .end {
            playerView.seek(to: 0)
        }
        
        switch status {
        case .end, .stop, .pasue:
            playButton.isHidden = false
            break
        default:
            playButton.isHidden = true
            break
        }
    }
}
