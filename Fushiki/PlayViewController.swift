//
//  PlayViewController.swift
//  Fushiki
//
//  Created by 黒田建彰 on 2021/01/16.
//  Copyright © 2021 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
@available(iOS 11.0, *)
class PlayViewController: UIViewController {
    var videoURL:URL?
    var videoSize:CGSize!
    var videoFps:Float!
    var videoPlayer: AVPlayer!
    var videoDuration:Float=0
    var screenSize:CGSize!
    var currTime:UILabel?
    var currFrameNumber:Int=0
    lazy var seekBar = UISlider()
    var timer:Timer?

    @IBOutlet weak var eyeWaku_image: UIImageView!
    @IBOutlet weak var faceWaku_image: UIImageView!

    @IBOutlet weak var faceWakuL_image: UIImageView!
    @IBOutlet weak var eyeWakuL_image: UIImageView!
    
    var eyeCenter = CGPoint(x:300.0,y:100.0)
    var faceCenter = CGPoint(x:300.0,y:200.0)
    var wakuLength:CGFloat=6
    var eyeRect:CGRect!//= CGRect(x:300.0,y:100.0,width:5.0,height:5.0)
    var faceRect:CGRect!//(x:300.0,y:200.0,width:5.0,height:5.0)
    func getRect(pnt:CGPoint,len:CGFloat)->CGRect{
        return(CGRect(x:pnt.x-len/2,y:pnt.y-len/2,width:len,height: len))
    }
    func resizeR2(_ targetRect:CGRect, viewRect:CGRect, image:CIImage) -> CGRect {
        //view.frameとtargetRectとimageをもらうことでその場で縦横の比率を計算してtargetRectのimage上の位置を返す関数
        //view.frameとtargetRectは画面上の位置だが、返すのはimage上の位置なので、そこをうまく考慮する必要がある。
        //getRealrectの代わり
        
        let vw = viewRect.width
        let vh = viewRect.height
        
        let iw = CGFloat(image.extent.width)
        let ih = CGFloat(image.extent.height)
        
        //　viewRect.originを引く事でtargetRectがview.bounds起点となる (xは0なのでやる必要はないが・・・）
        let tx = CGFloat(targetRect.origin.x) - CGFloat(viewRect.origin.x)
        let ty = CGFloat(targetRect.origin.y) - CGFloat(viewRect.origin.y)
        
        let tw = CGFloat(targetRect.width)
        let th = CGFloat(targetRect.height)
        
        // ここで返されるCGRectはCIImage/CGImage上の座標なので全て整数である必要がある
        // 端数があるまま渡すとmatchingが誤動作した
        return CGRect(x: (tx * iw / vw).rounded(),
                      y: ((vh - ty - th) * ih / vh).rounded(),
                      width: (tw * iw / vw).rounded(),
                      height: (th * ih / vh).rounded())
    }
    
    func resolutionSizeOfVideo(url:URL) -> CGSize? {
        guard let track = AVAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    func showWakuImages(){//結果が表示されていない時、画面上部1/4をタップするとWaku表示
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let avAsset = AVURLAsset(url: videoURL!, options: options)
        var reader: AVAssetReader! = nil
        do {
            reader = try AVAssetReader(asset: avAsset)
        } catch {
            #if DEBUG
            print("could not initialize reader.")
            #endif
            return
        }
        guard let videoTrack = avAsset.tracks(withMediaType: AVMediaType.video).last else {
            #if DEBUG
            print("could not retrieve the video track.")
            #endif
            return
        }
        
        let readerOutputSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerOutputSettings)
        
        reader.add(readerOutput)
        let frameRate = videoTrack.nominalFrameRate
    
        let startTime = CMTime(value: CMTimeValue(currFrameNumber), timescale: CMTimeScale(frameRate))
        let timeRange = CMTimeRange(start: startTime, end:CMTime.positiveInfinity)
        //print("time",timeRange)
        reader.timeRange = timeRange //読み込む範囲を`timeRange`で指定
        reader.startReading()
        
        let CGeye:CGImage!//eye
        let UIeye:UIImage!
        var CGface:CGImage!//face
        var UIface:UIImage!
        let context:CIContext = CIContext.init(options: nil)
        let orientation = UIImage.Orientation.up//right
        var sample:CMSampleBuffer!
        sample = readerOutput.copyNextSampleBuffer()
        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sample!)!
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(CGImagePropertyOrientation.right)
        print("video_w:", ciImage.extent.width,"h:",ciImage.extent.height,"fps:",getFPS(url:videoURL!))
        //起動時表示が一巡？するまでは　slowImage.frame はちょっと違う値を示す
//        let rect = CGRect(x:0,y:0,width:view.bounds.width/20,height:view.bounds.height/20)
        let eyeRectResized = resizeR2(eyeRect, viewRect:view.frame,image:ciImage)
        CGeye = context.createCGImage(ciImage, from: eyeRectResized)!
        UIeye = UIImage.init(cgImage: CGeye, scale:1.0, orientation:orientation)
        eyeWakuL_image.frame=CGRect(x:5,y:5,width: eyeRectResized.size.width*5,height: eyeRectResized.size.height*5)
        eyeWakuL_image.layer.borderColor = UIColor.black.cgColor
        eyeWakuL_image.layer.borderWidth = 1.0
        eyeWakuL_image.backgroundColor = UIColor.clear
        eyeWakuL_image.layer.cornerRadius = 3
        eyeWakuL_image.image=UIeye
        view.bringSubviewToFront(eyeWakuL_image)

        let faceRectResized = resizeR2(faceRect, viewRect:view.frame, image: ciImage)
        CGface = context.createCGImage(ciImage, from: faceRectResized)!
        UIface = UIImage.init(cgImage: CGface, scale:1.0, orientation:orientation)
        faceWakuL_image.frame=CGRect(x:view.bounds.width - faceRectResized.size.width*5 - 5,y:5,width: faceRectResized.size.width*5,height: faceRectResized.size.height*5)
        faceWakuL_image.layer.borderColor = UIColor.black.cgColor
        faceWakuL_image.layer.borderWidth = 1.0
        faceWakuL_image.backgroundColor = UIColor.clear
        faceWakuL_image.layer.cornerRadius = 3
        faceWakuL_image.image=UIface
        view.bringSubviewToFront(faceWakuL_image)
    }

    func dispWakus(){
        let nullRect:CGRect = CGRect(x:0,y:0,width:0,height:0)
        eyeWaku_image.frame=CGRect(x:(eyeRect.origin.x)-15,y:eyeRect.origin.y-15,width:(eyeRect.size.width)+30,height: eyeRect.size.height+30)
        faceWaku_image.frame=CGRect(x:(faceRect.origin.x)-15,y:faceRect.origin.y-15,width:faceRect.size.width+30,height: faceRect.size.height+30)
        
        eyeWaku_image.layer.borderColor = UIColor.green.cgColor
        eyeWaku_image.backgroundColor = UIColor.clear
        eyeWaku_image.layer.cornerRadius = 4
        faceWaku_image.layer.borderColor = UIColor.green.cgColor
        faceWaku_image.backgroundColor = UIColor.clear
        faceWaku_image.layer.cornerRadius = 4
        if wakuType==0{
            eyeWaku_image.layer.borderWidth = 2
            faceWaku_image.layer.borderWidth = 1
        }else{
            eyeWaku_image.layer.borderWidth = 1
            faceWaku_image.layer.borderWidth = 2
        }
        view.bringSubviewToFront(faceWaku_image)
        view.bringSubviewToFront(eyeWaku_image)
    }
    func moveWakus
        (rect:CGRect,stRect:CGRect,stPo:CGPoint,movePo:CGPoint,hani:CGRect) -> CGRect{
        var r:CGRect
        r = rect//2種類の枠を代入、変更してreturnで返す
        let dx:CGFloat = movePo.x
        let dy:CGFloat = movePo.y
        r.origin.x = stRect.origin.x + dx;
        r.origin.y = stRect.origin.y + dy;
        //r.size.width = stRect.size
        if r.origin.x < hani.origin.x{
            r.origin.x = hani.origin.x
        }else if r.origin.x > hani.origin.x+hani.width{
            r.origin.x = hani.origin.x+hani.width
        }
        if r.origin.y < hani.origin.y{
            r.origin.y = hani.origin.y
        }
        if r.origin.y > hani.origin.y+hani.height{
            r.origin.y = hani.origin.y+hani.height
        }
        return r
    }

    var wakuType:Int = 0//0:eye 1:face 2:outer -1:何も選択されていない
    var startPoint:CGPoint = CGPoint(x:0,y:0)//stRect.origin tapした位置
    var startEyeRect:CGRect = CGRect(x:0,y:0,width:0,height:0)//tapしたrectのtapした時のrect
    var startFaceRect:CGRect = CGRect(x:0,y:0,width:0,height:0)
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        let move:CGPoint = sender.translation(in: self.view)
        if sender.state == .began {
            startPoint = sender.location(in: self.view)
            startEyeRect=eyeRect
            startFaceRect=faceRect
        } else if sender.state == .changed {
            
            let ww=view.bounds.width
            let wh=view.bounds.height
            
            let et=CGRect(x:ww/10,y:wh/20,width: ww*4/5,height:wh*3/4)
            if wakuType==0{
                eyeRect = moveWakus(rect:faceRect,stRect:startEyeRect, stPo: startPoint,movePo: move,hani:et)
            }else{
                faceRect = moveWakus(rect:faceRect,stRect:startFaceRect, stPo: startPoint,movePo: move,hani:et)
            }
            dispWakus()
            showWakuImages()
        }else if sender.state == .ended{
        }
    }
    
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        print("tap")
        if wakuType==0{//eye
            wakuType=1
        }else{
            wakuType=0
        }
        dispWakus()
    }

    
    @objc func update(tm: Timer) {
        currTime?.text=String(format:"%.1f/%.1f",seekBar.value,videoDuration)
    }
    
    func killTimer(){
        if timer?.isValid == true {
            timer!.invalidate()
        }
    }
    func getFPS(url:URL) -> Float{
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let avAsset = AVURLAsset(url: url, options: options)
        return avAsset.tracks.first!.nominalFrameRate
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        eyeRect=getRect(pnt: eyeCenter, len: 6)
        faceRect=getRect(pnt:faceCenter,len: 6)
        let avAsset = AVURLAsset(url: videoURL!)
        let ww:CGFloat=view.bounds.width
        let wh:CGFloat=view.bounds.height
        let dw=ww/50//間隙
        let bw=(ww-dw*5)/4//ボタン幅
        let bh=bw/4//ボタン厚さ
        let by=wh - dw - bh//ボタンy
        let seeky=by - bh - dw/2//バーy
        
        videoDuration=Float(CMTimeGetSeconds(avAsset.duration))
        let playerItem: AVPlayerItem = AVPlayerItem(asset: avAsset)
        // Create AVPlayer
        videoPlayer = AVPlayer(playerItem: playerItem)
        // Add AVPlayer
        let layer = AVPlayerLayer()
        layer.videoGravity = AVLayerVideoGravity.resizeAspect
        layer.player = videoPlayer
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        // Create Movie SeekBar
        seekBar.frame = CGRect(x: dw, y:seeky, width: ww - 2*dw, height: bh)
        //        seekBar.layer.position = CGPoint(x: view.bounds.midX, y: by1)
        seekBar.minimumValue = 0
        seekBar.maximumValue = videoDuration
        seekBar.addTarget(self, action: #selector(onSliderValueChange), for: UIControl.Event.valueChanged)
        view.addSubview(seekBar)
        // Set SeekBar Interval
        let interval : Double = Double(0.5 * seekBar.maximumValue) / Double(seekBar.bounds.maxX)
        // ConvertCMTime
        let time : CMTime = CMTimeMakeWithSeconds(interval, preferredTimescale: Int32(NSEC_PER_SEC))
        // Observer
        videoPlayer.addPeriodicTimeObserver(forInterval: time, queue: nil, using: {time in
            // Change SeekBar Position
            let duration = CMTimeGetSeconds(self.videoPlayer.currentItem!.duration)
            let time = CMTimeGetSeconds(self.videoPlayer.currentTime())
            let value = Float(self.seekBar.maximumValue - self.seekBar.minimumValue) * Float(time) / Float(duration) + Float(self.seekBar.minimumValue)
            self.seekBar.value = value
        })
        
        currTime = UILabel(frame:CGRect(x: dw, y: by, width: bw, height: bh))
        currTime!.backgroundColor = UIColor.white
        currTime!.layer.masksToBounds = true
        currTime!.layer.cornerRadius = 5
        currTime!.textColor = UIColor.black
        currTime!.textAlignment = .center
        currTime!.font=UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .medium)
        currTime!.layer.borderColor = UIColor.black.cgColor
        currTime!.layer.borderWidth = 1.0
        view.addSubview(currTime!)
        
        let stopButton = UIButton(frame: CGRect(x: dw*2+bw*1, y: by, width: bw, height: bh))
        stopButton.layer.masksToBounds = true
        stopButton.layer.cornerRadius = 5.0
        stopButton.backgroundColor = UIColor.orange
        stopButton.setTitle("停止", for: UIControl.State.normal)
        stopButton.layer.borderColor = UIColor.black.cgColor
        stopButton.layer.borderWidth = 1.0
        stopButton.addTarget(self, action: #selector(onStopButtonTapped), for: UIControl.Event.touchUpInside)
        view.addSubview(stopButton)
        
        // Create Movie Start Button
        let startButton = UIButton(frame:CGRect(x: dw*3+bw*2, y: by, width: bw, height: bh))
        startButton.layer.masksToBounds = true
        startButton.layer.cornerRadius = 5.0
        startButton.backgroundColor = UIColor.orange
        startButton.setTitle("再生", for: UIControl.State.normal)
        startButton.layer.borderColor = UIColor.black.cgColor
        startButton.layer.borderWidth = 1.0
        startButton.addTarget(self, action: #selector(onStartButtonTapped), for: UIControl.Event.touchUpInside)
        view.addSubview(startButton)
        
        let exitButton = UIButton(frame:CGRect(x: dw*4+bw*3, y: by, width: bw, height: bh))
        exitButton.layer.masksToBounds = true
        exitButton.layer.cornerRadius = 5.0
        exitButton.backgroundColor = UIColor.darkGray
        exitButton.setTitle("戻る", for:UIControl.State.normal)
        exitButton.isEnabled=true
        exitButton.layer.borderColor = UIColor.black.cgColor
        exitButton.layer.borderWidth = 1.0
        exitButton.addTarget(self, action: #selector(onExitButtonTapped), for: UIControl.Event.touchUpInside)
        view.addSubview(exitButton)
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        videoPlayer.play()
        dispWakus()
        showWakuImages()
        videoSize=resolutionSizeOfVideo(url:videoURL!)
        screenSize=view.bounds.size
        videoFps=getFPS(url: videoURL!)
//        print("screen_w:",view.bounds.width,view.bounds.size.width,"h:",view.bounds.height,view.bounds.size.height)
        //まずは表示だけ、まだちゃんとwakuを捉えていない
//        faceWakuL_image.isHidden=true
//        eyeWakuL_image.isHidden=true
//        faceWaku_image.isHidden=true
//        eyeWaku_image.isHidden=true
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }

    // Start Button Tapped
    @objc func onStartButtonTapped(){
        if (videoPlayer.rate != 0) && (videoPlayer.error == nil) {//playing
            return//videoPlayer.pause()
        }else{//stoped
            if seekBar.value>seekBar.maximumValue-0.5{
            seekBar.value=0
            }
            videoPlayer.seek(to: CMTimeMakeWithSeconds(Float64(seekBar.value), preferredTimescale: Int32(NSEC_PER_SEC)))
            videoPlayer.play()
        }
    }
    @objc func onStopButtonTapped(){
        if (videoPlayer.rate != 0) && (videoPlayer.error == nil) {//playing
            videoPlayer.pause()
            currFrameNumber=Int(seekBar.value*videoFps)
            print("curr:",currFrameNumber)
        }
    }
    // SeekBar Value Changed
    @objc func onSliderValueChange(){
        videoPlayer.pause()
        let newTime = CMTime(seconds: Double(seekBar.value), preferredTimescale: 600)
        videoPlayer.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        currFrameNumber=Int(seekBar.value*videoFps)
        print("curr:",currFrameNumber)
    }
    func onNextButtonTapped(){//このようなボタンを作ってみれば良さそう。無くてもいいか？
        var seekBarValue=seekBar.value+0.01
        if seekBarValue>videoDuration-0.1{
            seekBarValue = videoDuration-0.1
         }
         let newTime = CMTime(seconds: Double(seekBarValue), preferredTimescale: 600)
         currTime!.text = String(format:"%.1f/%.1f",seekBarValue,videoDuration)
         videoPlayer.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    @objc func onExitButtonTapped(){//このボタンのところにsegueでunwindへ行く
        killTimer()
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        if UIApplication.shared.isIdleTimerDisabled == true{
            UIApplication.shared.isIdleTimerDisabled = false//スリープする
        }
        self.present(mainView, animated: false, completion: nil)
    }
}
