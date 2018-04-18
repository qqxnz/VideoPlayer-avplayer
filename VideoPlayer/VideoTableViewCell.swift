//
//  VideoTableViewCell.swift
//  VideoPlayer
//
//  Created by lvfm on 2018/4/18.
//  Copyright © 2018年 lvfm. All rights reserved.
//

import UIKit
import SnapKit

class VideoTableViewCell: UITableViewCell {

    var img:UIImageView = UIImageView()
    
    var videoUrl:String = ""
    
    var controller:UIViewController!
    
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(self.img)
        
        self.img.snp.makeConstraints { (make) in
            make.left.top.right.bottom.equalTo(self)
        }
        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.imgdidClicked))
        tap.numberOfTapsRequired = 1
        self.img.addGestureRecognizer(tap)
        self.img.isUserInteractionEnabled =  true
    }
    
    @objc func imgdidClicked(){
        print("图片点击")
        
        let player = IOTIMVideoPlayer.shared
        
        self.img.addSubview(player.view)

        player.view.frame = self.img.bounds

        ///视频第一帧视频截图
        player.videoCaptureCallBack = { (img) in

        }

        ///全屏从哪个页面跳过去
        player.fullScreenCallBack = {
            return self.controller
        }
        
        ///退出全屏，要将视图重新加载显示
        player.exitFullScreenCallBack = {
            player.view.frame = self.img.bounds
            self.addSubview(player.view)
        }
        
        ////播放状态回调
        player.stateCallBack = { (state) in
            print("-----状态--\(state)----")
            
            
        }
        
        
        
        player.play(videoUrl: self.videoUrl)
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
