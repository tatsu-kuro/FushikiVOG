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
class PlayViewController: UIViewController {

    var videoPlayer: AVPlayer!
    var duration:Float=0
    var currTime:UILabel?
    lazy var seekBar = UISlider()
    var timer:Timer?
    var videoURL:URL?
    
    @objc func update(tm: Timer) {
        let min=Int(seekBar.value/60)
        let sec=Int(seekBar.value)%60
        let min1=Int(duration/60)
        let sec1=Int(duration)%60
        currTime?.text=String(format:"%d:%02d/%d:%02d",min,sec,min1,sec1)

    }
   
    func killTimer(){
        if timer?.isValid == true {
            timer!.invalidate()
        }
    }
   /*
    @IBAction func eraseVideo(_ sender: Any) {
 //       videoAsset[videoCurrent]
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.isNetworkAccessAllowed = false
        requestOptions.deliveryMode = .highQualityFormat //これでもicloud上のvideoを取ってしまう
        //アルバムをフェッチ
        let assetFetchOptions = PHFetchOptions()
        
        assetFetchOptions.predicate = NSPredicate(format: "title == %@", albumName)
        
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .smartAlbumVideos, options: assetFetchOptions)
//        print("asset:",assetCollections.count)
        //アルバムが存在しない事もある？
        var dialogStatus:Int=0
        if (assetCollections.count > 0) {
            //同じ名前のアルバムは一つしかないはずなので最初のオブジェクトを使用
            let assetCollection = assetCollections.object(at:0)
            // creationDate降順でアルバム内のアセットをフェッチ
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let assets = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            var eraseAssetDate=assets[0].creationDate
//            var eraseAssetPngNumber=0
            for i in 0..<assets.count{
                let date_sub=assets[i].creationDate
                let date = formatter.string(from:date_sub!)
//                eraseAssetPngNumber=i+1
                if videoDate[videoCurrent].contains(date){
                    if !assets[i].canPerform(.delete) {
                        return
                    }
                    var delAssets=Array<PHAsset>()
                    delAssets.append(assets[i])
                    if assets[i+1].duration==0{//pngが無くて、videoが選択されてない事を確認
                        delAssets.append(assets[i+1])//pngはその次に入っているはず
                    }
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.deleteAssets(NSArray(array: delAssets))
                    }, completionHandler: { success,error in//[self] _, _ in
                        if success==true{
                            dialogStatus = 1//YES
                        }else{
                            dialogStatus = -1//NO
                        }
                        // 削除後の処理
                    })
//                    break
                }
            }
        }
        while dialogStatus == 0{//dialogから抜けるまでは0
            sleep(UInt32(0.2))
        }
        if dialogStatus == 1{//yesで抜けた時
//            removeFile(delFile: videoDate[videoCurrent] + "-gyro.csv")
            videoDate.remove(at: videoCurrent)
            videoURL.remove(at: videoCurrent)
            videoImg.remove(at: videoCurrent)
            videoDura.remove(at: videoCurrent)
            videoArrayCount -= 1
            videoCurrent -= 1
            showVideoIroiro(num: 0)
            if videoImg.count==0{
                playButton.isEnabled=false
            }
        }
    }
    */
    override func viewDidLoad() {
        super.viewDidLoad()
        let avAsset = AVURLAsset(url: videoURL!)
//        print(avAsset.tracks.first.f description)
        let ww:CGFloat=view.bounds.width
        let wh:CGFloat=view.bounds.height
        let dw=ww/50//間隙
        let bw=(ww-dw*5)/4//ボタン幅
        let bh=bw/4//ボタン厚さ
        let by=wh - dw - bh//ボタンy
        let seeky=by - bh - dw/2//バーy
        
        duration=Float(CMTimeGetSeconds(avAsset.duration))
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
        seekBar.maximumValue = duration
        seekBar.addTarget(self, action: #selector(onSliderValueChange), for: UIControl.Event.valueChanged)
        view.addSubview(seekBar)
        // Set SeekBar Interval
        let interval : Double = Double(0.5 * seekBar.maximumValue) / Double(seekBar.bounds.maxX)
        // ConvertCMTime
        let time : CMTime = CMTimeMakeWithSeconds(interval, Int32(NSEC_PER_SEC))
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
    }

    // Start Button Tapped
    @objc func onStartButtonTapped(){
        if (videoPlayer.rate != 0) && (videoPlayer.error == nil) {//playing
            return//videoPlayer.pause()
        }else{//stoped
            if seekBar.value>seekBar.maximumValue-0.5{
            seekBar.value=0
            }
            videoPlayer.seek(to: CMTimeMakeWithSeconds(Float64(seekBar.value), Int32(NSEC_PER_SEC)))
            videoPlayer.play()
        }
    }
    @objc func onStopButtonTapped(){
        if (videoPlayer.rate != 0) && (videoPlayer.error == nil) {//playing
            videoPlayer.pause()
        }
//        }else{//stoped
//            if seekBar.value>seekBar.maximumValue-0.5{
//            seekBar.value=0
//            }
//            videoPlayer.seek(to: CMTimeMakeWithSeconds(Float64(seekBar.value), Int32(NSEC_PER_SEC)))
//            videoPlayer.play()
//        }
    }
    // SeekBar Value Changed
    @objc func onSliderValueChange(){
        videoPlayer.seek(to: CMTimeMakeWithSeconds(Float64(seekBar.value), Int32(NSEC_PER_SEC)))
        videoPlayer.pause()
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
