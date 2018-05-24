//
//  ViewController.swift
//  VideoPlayer
//
//  Created by lvfm on 2018/4/18.
//  Copyright © 2018年 lvfm. All rights reserved.
//

import UIKit
import SDWebImage
import MBProgressHUD

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    var tableView:UITableView!
    
    var imgDatas:[String] = []
    var videoUrls:[String] = []
    
    var playIndexPath:IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        self.title = "AVPLAYER演示"
        
        self.tableView = UITableView.init(frame: self.view.bounds, style: UITableViewStyle.plain)
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.tableFooterView = UIView.init(frame: CGRect.zero)
        self.tableView.register(VideoTableViewCell.classForCoder(), forCellReuseIdentifier: "VideoTableViewCell")
        self.view.addSubview(self.tableView)
        
        self.imgDatas.append("http://news.yule.com.cn/uploadfile/2017/0515/20170515060930189.png")
        self.imgDatas.append("http://news.yule.com.cn/uploadfile/2017/0515/20170515060932976.png")
        self.imgDatas.append("http://news.yule.com.cn/uploadfile/2017/0515/20170515060933913.png")
        self.imgDatas.append("http://news.yule.com.cn/uploadfile/2017/0515/20170515060934602.png")
        self.imgDatas.append("http://news.yule.com.cn/uploadfile/2017/0515/20170515060936399.png")
        
        self.videoUrls.append("http://ysj-like.oss-cn-shenzhen.aliyuncs.com/ysj-like/ysj2018041709590412.mp4")
        self.videoUrls.append("http://bos.nj.bpc.baidu.com/tieba-smallvideo/11772_3c435014fb2dd9a5fd56a57cc369f6a0.mp4")
        self.videoUrls.append("http://ysj-like.oss-cn-shenzhen.aliyuncs.com/ysj-like/ysj2018041709590412.mp4")
        self.videoUrls.append("http://ysj-like.oss-cn-shenzhen.aliyuncs.com/ysj-like/ysj2018041709434176.mp4")
        self.videoUrls.append("http://ysj-like.oss-cn-shenzhen.aliyuncs.com/ysj-like/ysj2018041709425830.mp4")
        
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem.init(title: "停止", style: UIBarButtonItemStyle.plain, target: self, action: #selector(self.stopPlayer))
        
        
    }
    
    @objc func stopPlayer(){
        IOTIMVideoPlayer.shared.stop()
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return self.view.frame.width * 0.6
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell:VideoTableViewCell = VideoTableViewCell.init(style: UITableViewCellStyle.default, reuseIdentifier: "VideoTableViewCell")
        cell.img.sd_setImage(with: URL.init(string: self.imgDatas[indexPath.row]))
        cell.videoUrl = self.videoUrls[indexPath.row]
        
        cell.callBack = {
            print("AAAAAAA")
            self.player(view: cell.img, url: cell.videoUrl, indexPath: indexPath)
        }
        
        return cell
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        

    }
    
    func player(view:UIView,url:String,indexPath: IndexPath){
        

        
        self.playIndexPath = indexPath
        let player = IOTIMVideoPlayer.shared
        ///视频第一帧视频截图
        player.videoCaptureCallBack = { (img) in
            print("图片")
        }
        
        ///全屏从哪个页面跳过去
        player.fullScreenCallBack = {
            let rectInTableView = self.tableView.rectForRow(at: indexPath)
            let rectInSuperview = self.tableView.convert(rectInTableView, to: self.tableView.superview)
            return (controller:self,frame:rectInSuperview)
        }
        
        ///退出全屏，要将视图重新加载显示
        player.exitFullScreenCallBack = {
            print("退出全屏")
        }
        
        ////播放状态回调
        player.stateCallBack = { (state) in
            print("-----状态--\(state)----")
            if(state == "创建"){
                MBProgressHUD.showAdded(to: view, animated: true)
            }
            
            if(state == "播放" || state == "终止"){
               MBProgressHUD.hide(for: view, animated: true)
            }
            
        }
        
        
        
        player.play(videoUrl: url, showView: view, frame: view.frame)
        
        
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
       
        if(self.playIndexPath != nil){
            let rectInTableView = self.tableView.rectForRow(at: self.playIndexPath!)
            let rectInSuperview = self.tableView.convert(rectInTableView, to: self.tableView.superview)
            
            if(rectInSuperview.origin.y >= self.view.frame.size.height || rectInSuperview.size.height + rectInSuperview.origin.y < 0){
                print("超出屏幕")
                IOTIMVideoPlayer.shared.stop()
                self.playIndexPath = nil
            }
            
        }
        
    }

    //支持旋转
    override var shouldAutorotate: Bool {
        return true
    }
    
    //支持的方向 因为界面A我们只需要支持竖屏
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.portrait
    }
    
 
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

