//
//  IOTIMVideoPlayer.swift
//  KsyPlayer
//
//  Created by lvfm on 2018/4/17.
//  Copyright © 2018年 lvfm. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class IOTIMVideoPlayer:NSObject {
    
    ///单例
    @objc static let shared = IOTIMVideoPlayer()
    
    private var videoUrl:String = ""
    
    //图片地址
    let imgPath:String = Bundle.main.path(forResource: "videoPayImage", ofType: "bundle")!
    
    private var fullController:IOTIMVideoPlayerfullViewController = IOTIMVideoPlayerfullViewController()
    
    ///播放视图
    public var view:UIView = UIView()

    ///视频总时间
    private var maxTimeLab:UILabel = UILabel()
    ///视频当前时间
    private var currentTimeLab:UILabel = UILabel()
    
    private var fullButton:UIButton = UIButton()
    
    ///进度条
    private var slider:UISlider = UISlider()
    
    private var sliding:Bool = false
    ///进度条
    private var progressView:UIProgressView!
    
    ///播放与暂停
    private var playBtn:UIButton = UIButton()
    
    private var playing:Bool = false
    
    private var playerItem:AVPlayerItem!
    private var avplayer:AVPlayer!
    private var playerLayer:AVPlayerLayer!
    
    var timer : Timer!
    
    /////首帧视频截图闭包
    typealias IOTIMVideoPlayerVideoCaptureCallBack = (UIImage?)->()
    ////首帧视频截图回调
    public var videoCaptureCallBack:IOTIMVideoPlayerVideoCaptureCallBack?
    
    ///全屏按钮闭包
    typealias IOTIMVideoPlayerFullBtnClickedCallBack = (String)->(UIViewController)
    
    ///全屏按钮回调
    public var fullBtnClickedCallBack:IOTIMVideoPlayerFullBtnClickedCallBack?
    
    ///全屏闭包
    typealias IOTIMVideoPlayerFullScreenCallBack = ()->(UIViewController)
    
    ///全屏回调
    public var fullScreenCallBack:IOTIMVideoPlayerFullScreenCallBack?
    
    
    ///退出全屏闭包
    typealias IOTIMVideoPlayerExitFullScreenCallBack = ()->()
    
    ///退出全屏回调
    public var exitFullScreenCallBack:IOTIMVideoPlayerExitFullScreenCallBack?
    
    
    ///播放状态闭包
    typealias IOTIMVideoPlayerStateCallBack = (String)->()
    
    ///播放状态回调
    public var stateCallBack:IOTIMVideoPlayerStateCallBack?
    
    var fullState:Bool = false
    
    
    var btnState:Bool = false
    
    var btnStateTime:Int = 0
    
    override init() {
        super.init()
        self.view.backgroundColor = UIColor.blue
        self.view.addSubview(playBtn)
        self.view.addSubview(self.maxTimeLab)
        self.view.addSubview(self.currentTimeLab)
        self.view.addSubview(self.slider)
        self.view.addSubview(fullButton)
        
        self.maxTimeLab.textColor = UIColor.white
        self.maxTimeLab.font = UIFont.systemFont(ofSize: 12)
        self.maxTimeLab.text = "00:00"
        self.maxTimeLab.textAlignment = NSTextAlignment.center
        
        self.currentTimeLab.textColor = UIColor.white
        self.currentTimeLab.font = UIFont.systemFont(ofSize: 12)
        self.currentTimeLab.text = "00:00"
        self.currentTimeLab.textAlignment = NSTextAlignment.center
        
        //全屏
        self.fullButton.setImage(UIImage.init(named:"ic_fullscreen", in: Bundle.init(path:imgPath), compatibleWith:nil), for: UIControlState.normal)
        self.fullButton.addTarget(self, action:#selector(self.fullButtonClicked), for: UIControlEvents.touchUpInside)
        
        
        slider.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view).inset(10)
            make.left.equalTo(self.view).offset(50)
            make.right.equalTo(self.view).inset(100)
            make.height.equalTo(15)
        }
        
        self.maxTimeLab.snp.makeConstraints { (make) in
            make.left.equalTo(slider.snp.right).offset(5)
            make.bottom.equalTo(self.view).inset(10)
        }
        
        self.currentTimeLab.snp.makeConstraints { (make) in
            make.left.equalTo(self.view).offset(5)
            make.bottom.equalTo(self.view).inset(5)
        }

        fullButton.snp.makeConstraints { (make) in
            make.right.equalTo(-10)
            make.centerY.equalTo(self.slider)
            make.width.height.equalTo(35)
        }
        


        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        // 从最大值滑向最小值时杆的颜色
        slider.maximumTrackTintColor = UIColor.clear
        // 从最小值滑向最大值时杆的颜色
        slider.minimumTrackTintColor = UIColor.white
        // 在滑块圆按钮添加图片 ic_play_circle
        slider.setThumbImage(UIImage.init(named: "ic_play_circle", in: Bundle.init(path: self.imgPath), compatibleWith: nil), for: UIControlState.normal)
        
        // 按下的时候
        slider.addTarget(self, action: #selector(self.sliderTouchDown(slider:)), for: UIControlEvents.touchDown)
        // 弹起的时候
        slider.addTarget(self, action: #selector(self.sliderTouchUpOut(slider:)), for: UIControlEvents.touchUpOutside)
        slider.addTarget(self, action: #selector(self.sliderTouchUpOut(slider:)), for: UIControlEvents.touchUpInside)
        slider.addTarget(self, action: #selector(self.sliderTouchUpOut(slider:)), for: UIControlEvents.touchCancel)

        progressView = UIProgressView()
        progressView.backgroundColor = UIColor.lightGray
        self.view.insertSubview(progressView, belowSubview: slider)
        
        progressView.snp.makeConstraints { (make) in
            make.left.right.equalTo(slider)
            make.centerY.equalTo(slider)
            make.height.equalTo(2)
        }
        
        progressView.tintColor = UIColor.red
        progressView.progress = 0
        

        playBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(self.view)
            make.centerX.equalTo(self.view)
            make.width.height.equalTo(50)
        }
        
        // 设置按钮图片
        playBtn.setImage(UIImage.init(named: "ic_stop_small", in: Bundle.init(path: self.imgPath), compatibleWith: nil), for: UIControlState.normal)
        // 点击事件

        playBtn.addTarget(self, action: #selector(self.playAndPause), for: UIControlEvents.touchUpInside)

        
        let tap = UITapGestureRecognizer.init(target: self, action: #selector(self.btnShowAndHidden))
        tap.numberOfTapsRequired = 1
        self.view.addGestureRecognizer(tap)
        
        
    }
    
    deinit {
        self.playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
        self.playerItem.removeObserver(self, forKeyPath: "status")
    }
    
    
    ///全屏按钮
    @objc func fullButtonClicked(){
        if(self.fullState){
            self.fullController.dis()
            self.fullButton.setImage(UIImage.init(named:"ic_fullscreen", in: Bundle.init(path:imgPath), compatibleWith:nil), for: UIControlState.normal)
            if(self.exitFullScreenCallBack != nil){
                self.exitFullScreenCallBack!()
            }
            
        }else{
            if(self.fullScreenCallBack != nil){
                let vic = self.fullScreenCallBack!()
                self.fullController.videoUrl = self.videoUrl
                vic.present(self.fullController, animated: false, completion: nil)
                self.fullButton.setImage(UIImage.init(named:"ic_suoxiao", in: Bundle.init(path:imgPath), compatibleWith:nil), for: UIControlState.normal)
            }
        }
        
        self.fullState = !self.fullState
        playerLayer.frame = self.view.layer.bounds;

    }
    
    @objc func btnShowAndHidden(){
        
        if(btnState){
            self.slider.isHidden = false
            self.playBtn.isHidden = false
            self.progressView.isHidden = false
            self.maxTimeLab.isHidden = false
            self.currentTimeLab.isHidden = false
            self.fullButton.isHidden = false
            btnState = false
        }else{
            self.slider.isHidden = true
            self.playBtn.isHidden = true
            self.progressView.isHidden = true
            self.maxTimeLab.isHidden = true
            self.currentTimeLab.isHidden = true
            self.fullButton.isHidden = true
            btnState = true
        }
        
        btnStateTime = 0
        
        
        
    }
    
    
    public func play(videoUrl:String){
        
        if(self.videoUrl == videoUrl){
            playerLayer.frame = self.view.layer.bounds;
            return
        }
        
        if(self.playerItem != nil || self.playerLayer != nil || self.avplayer != nil){
            if(self.stateCallBack != nil){
                self.stateCallBack!("终止")
            }
            self.avplayer.currentItem?.cancelPendingSeeks()
            self.avplayer.currentItem?.asset.cancelLoading()
            self.playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
            self.playerItem.removeObserver(self, forKeyPath: "status")
            self.playerLayer.removeFromSuperlayer()
            self.videoUrl = ""
            self.avplayer.pause()
            self.playerItem = nil
            self.playerLayer = nil
            self.avplayer = nil
            if(self.timer != nil){
                self.timer.invalidate()
                self.timer = nil
            }
        }
        
        self.fullState = false;
        self.fullButton.setImage(UIImage.init(named:"ic_fullscreen", in: Bundle.init(path:imgPath), compatibleWith:nil), for: UIControlState.normal)
        
        self.videoUrl = videoUrl;
        // 检测连接是否存在 不存在报错
        let url = URL.init(string: self.videoUrl)

        self.playerItem = AVPlayerItem.init(url: url!)
        // 监听缓冲进度改变
        playerItem.addObserver(self, forKeyPath: "loadedTimeRanges", options: NSKeyValueObservingOptions.new, context: nil)
        // 监听状态改变
        playerItem.addObserver(self, forKeyPath: "status", options: NSKeyValueObservingOptions.new, context: nil)
        //添加视频播放结束通知
        NotificationCenter.default.addObserver(self, selector: #selector(self.videoPlayDidEnd(_:)), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.playerItem)
        // 将视频资源赋值给视频播放对象
        self.avplayer = AVPlayer(playerItem: playerItem)
        // 初始化视频显示layer
        playerLayer = AVPlayerLayer(player: avplayer)
        // 设置显示模式
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspect
        playerLayer.contentsScale = UIScreen.main.scale
        // 赋值给自定义的View
        //        self.playerItem.playerLayer = self.playerLayer
        // 位置放在最底下
        //        self.playerItem.layer.insertSublayer(playerLayer, atIndex: 0)

        self.view.layer.insertSublayer(playerLayer, at: 0)
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.updateTime), userInfo: nil, repeats: true)
        
        if(self.videoCaptureCallBack != nil){
            self.videoCaptureCallBack!(self.videoCaptureImage())
        }
        
        playerLayer.frame = self.view.layer.bounds;
        self.playing = true
    }
    
    
    public func stop(){
        if(self.playerItem != nil || self.playerLayer != nil || self.avplayer != nil){
            if(self.stateCallBack != nil){
                self.stateCallBack!("终止")
            }
            
            self.avplayer.currentItem?.cancelPendingSeeks()
            self.avplayer.currentItem?.asset.cancelLoading()
            self.playerItem.removeObserver(self, forKeyPath: "loadedTimeRanges")
            self.playerItem.removeObserver(self, forKeyPath: "status")
            self.playerLayer.removeFromSuperlayer()
            self.videoUrl = ""
            self.avplayer.pause()
            self.playerItem = nil
            self.playerLayer = nil
            self.avplayer = nil
            if(self.timer != nil){
                self.timer.invalidate()
                self.timer = nil
            }
        }
    }
    
    ///时间
    @objc func updateTime(){
        
        ///按钮显示记数
        if(!btnState){
            btnStateTime = btnStateTime + 1
        }
        
        ///五秒左右隐藏按钮
        if(btnStateTime > 50 && self.playing == true){
            self.btnShowAndHidden()
        }

        //暂停的时候
        if !self.playing{
            return
        }
        
        // 当前播放到的时间
        let currentTime = CMTimeGetSeconds(self.avplayer.currentTime())
        // 总时间
        let totalTime   = TimeInterval(playerItem.duration.value) / TimeInterval(playerItem.duration.timescale)
        // timescale 这里表示压缩比例
        self.currentTimeLab.text = self.formatPlayTime(secounds: currentTime)
        self.maxTimeLab.text = self.formatPlayTime(secounds: totalTime)
        // TODO: 播放进度
        // 滑动不在滑动的时候
        if !self.sliding{
            // 播放进度
            self.slider.value = Float(currentTime/totalTime)
        }
        
    }
    
    ///时间转字符串
    func formatPlayTime(secounds:TimeInterval)->String{
        if secounds.isNaN{
            return "00:00"
        }
        let Min = Int(secounds / 60)
        let Sec = Int(secounds.truncatingRemainder(dividingBy: 60))
        return String(format: "%02d:%02d", Min, Sec)
    }
    
    ////视频第一帧视频截图
    func videoCaptureImage()->UIImage?{
        let url = URL.init(string: self.videoUrl)
        let avAsset = AVAsset.init(url: url!)
        let generator = AVAssetImageGenerator(asset: avAsset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0,600)
        var actualTime:CMTime = CMTimeMake(0,0)
        
        do {
            let imageRef:CGImage = try generator.copyCGImage(at: time, actualTime: &actualTime)
            let frameImg = UIImage.init(cgImage: imageRef)
            return frameImg
        }catch{
            return nil
        }

    }
    
    //播放完成
    @objc func videoPlayDidEnd(_ notification:Notification) {
        if(stateCallBack != nil){
            self.stateCallBack!("完成")
        }
    }
    
    
    ///进度条点击
    @objc func sliderTouchDown(slider:UISlider){
        self.sliding = true
    }
    
    ///调整播放进度
    @objc func sliderTouchUpOut(slider:UISlider){
        // TODO: -代理处理
        //当视频状态为AVPlayerStatusReadyToPlay时才处理
        if self.avplayer.status == AVPlayerStatus.readyToPlay{
            let duration = slider.value * Float(CMTimeGetSeconds(self.avplayer.currentItem!.duration))
            let seekTime = CMTimeMake(Int64(duration), 1)
            // 指定视频位置
            self.avplayer.seek(to: seekTime, completionHandler: { (b) in
                // 别忘记改状态
                self.sliding = false
            })
        }

    }
    
    
    ///计算当前的缓冲进度
    func avalableDurationWithplayerItem()->TimeInterval{
        guard let loadedTimeRanges = avplayer?.currentItem?.loadedTimeRanges,let first = loadedTimeRanges.first else {fatalError()}
        let timeRange = first.timeRangeValue
        let startSeconds = CMTimeGetSeconds(timeRange.start)
        let durationSecound = CMTimeGetSeconds(timeRange.duration)
        let result = startSeconds + durationSecound
        return result
    }
    
    ///播放与暂停
    @objc func playAndPause(){
        let tmp = !playing
        playing = tmp // 改变状态
        
        // 根据状态设定图片
        if playing {
            playBtn.setImage(UIImage.init(named: "ic_stop_small", in: Bundle.init(path: self.imgPath), compatibleWith: nil), for: UIControlState.normal)
        }else{
            playBtn.setImage(UIImage.init(named: "ic_play_small", in: Bundle.init(path: self.imgPath), compatibleWith: nil), for: UIControlState.normal)
        }
        
        if !self.playing{
            self.avplayer.pause()
        }else{
            if self.avplayer.status == AVPlayerStatus.readyToPlay{
                self.avplayer.play()
            }
        }
        
        
    }

    
    ///播放监听
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        guard let playerItem = object as? AVPlayerItem else { return }
        if keyPath == "loadedTimeRanges"{
            // 缓冲进度 暂时不处理
            // 通过监听AVPlayerItem的"loadedTimeRanges"，可以实时知道当前视频的进度缓冲
            let loadedTime = avalableDurationWithplayerItem()
            let totalTime = CMTimeGetSeconds(playerItem.duration)
            let percent = loadedTime/totalTime // 计算出比例
            // 改变进度条
            self.progressView.progress = Float(percent)

        }else if keyPath == "status"{
            // 监听状态改变
            print("监听状态改变")
            if playerItem.status == AVPlayerItemStatus.readyToPlay{
                // 只有在这个状态下才能播放
                print("只有在这个状态下才能播放")
                self.avplayer.play()
                self.playing = true
                playBtn.setImage(UIImage.init(named: "ic_stop_small", in: Bundle.init(path: self.imgPath), compatibleWith: nil), for: UIControlState.normal)
                if(self.stateCallBack != nil){
                    self.stateCallBack!("播放")
                }
                if(self.videoCaptureCallBack != nil){
                    self.videoCaptureCallBack!(self.videoCaptureImage())
                }
                
            }else{
                print("加载异常")
                playBtn.setImage(UIImage.init(named: "ic_stop_small", in: Bundle.init(path: self.imgPath), compatibleWith: nil), for: UIControlState.normal)
                self.playing = false
                if(self.stateCallBack != nil){
                    self.stateCallBack!("异常")
                }
            }
        }
    }
    
    
}

class IOTIMVideoPlayerfullViewController: UIViewController {
    
    public var videoUrl:String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.orange


    
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        IOTIMVideoPlayer.shared.view.frame = CGRect.init(x: 0, y: 0, width: self.view.frame.height, height: self.view.frame.width )
        self.view.addSubview(IOTIMVideoPlayer.shared.view)
        
        IOTIMVideoPlayer.shared.play(videoUrl: self.videoUrl)
    }
    
    @objc func dis(){
        self.dismiss(animated: false, completion: nil)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //支持旋转
    override var shouldAutorotate: Bool {
        return true
    }
    
    //支持的方向
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return UIInterfaceOrientationMask.landscapeRight
    }
    
    
}

