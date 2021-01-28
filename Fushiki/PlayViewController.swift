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
    let openCV = OpenCVManager()
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

    
     @IBOutlet weak var wakuEye: UIImageView!
     @IBOutlet weak var wakuEyeb: UIImageView!
     @IBOutlet weak var wakuFac: UIImageView!
     @IBOutlet weak var wakuFacb: UIImageView!
    
    @IBOutlet weak var eyeWaku_image: UIImageView!
    @IBOutlet weak var faceWaku_image: UIImageView!
    @IBOutlet weak var faceWakuL_image: UIImageView!
    @IBOutlet weak var eyeWakuL_image: UIImageView!
    
    var eyeCenter = CGPoint(x:300.0,y:100.0)
    var faceCenter = CGPoint(x:300.0,y:200.0)
    var wakuLength:CGFloat=6//square length
    func getRectFromCenter(center:CGPoint,len:CGFloat)->CGRect{
        return(CGRect(x:center.x-len/2,y:center.y-len/2,width:len,height: len))
    }

    func getVideoRectOnScreen(videoImage:CIImage)->CGRect{
        let sw=view.frame.width
        let sh=view.frame.height
        let vw=CGFloat(videoImage.extent.width)
        let vh=CGFloat(videoImage.extent.height)
        
        var d=(sw-vw*sh/vh)/2
        print(sw,sh,vh,vw,d)
        if d>0{
            return CGRect(x:d,y:0,width:sw-2*d,height:sh)
        }else{//ここがうまく行っていないようだ
            d=(sh-sw*vh/vw)/2
            return CGRect(x:0,y:d,width:sw,height:sh-2*d)
        }
    }
    //targetRect=eyeRect,viewRect=view.frame
    func resizeR2(_ targetRect:CGRect, viewRect:CGRect, image:CIImage) -> CGRect {
        //view.frameとtargetRectとimageをもらうことでその場で縦横の比率を計算してtargetRectのimage上の位置を返す関数
        //view.frameとtargetRectは画面上の位置だが、返すのはimage上の位置なので、そこをうまく考慮する必要がある。
        //getRealrectの代わり
        
        let vw = viewRect.width
        let vh = viewRect.height
        
        let iw = CGFloat(image.extent.width)
        let ih = CGFloat(image.extent.height)
        
        //　viewRect.originを引く事でtargetRectがview.bounds起点となる
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
    //iPhone11ではScreenSize=896*414 VideoImageSize=1920*1080
    func checkRect(rect:CGRect,image:CIImage)->CGRect{
        //範囲をチェックしたつもりだが、バグがありそう
        var returnRect=rect
        if rect.origin.x<0{
            returnRect.origin.x=0
        }
        if rect.origin.y<0{
            returnRect.origin.y=0
        }
        if rect.width>image.extent.width{
            returnRect.size.width=image.extent.width
        }
        if rect.height>image.extent.height{
            returnRect.size.height=image.extent.height
        }
        return returnRect
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
        reader.timeRange = timeRange //読み込む範囲を`timeRange`で指定
        reader.startReading()
        let CGeye:CGImage!//eye
        let UIeye:UIImage!
        var CGface:CGImage!//face
        var UIface:UIImage!
        let context:CIContext = CIContext.init(options: nil)
        let orientation = UIImage.Orientation.up
        var sample:CMSampleBuffer!
        sample = readerOutput.copyNextSampleBuffer()
        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sample!)!
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(CGImagePropertyOrientation.up)//4行上ともupで良いような？
        //起動時表示が一巡？するまでは　slowImage.frame はちょっと違う値を示す
//        eyeCenter=transPoint(point: eyeCenter, videoImage: ciImage)
        let eyeRect=getRectFromCenter(center: eyeCenter, len: wakuLength)
        let eyeRectResized = resizeR2(eyeRect, viewRect:getVideoRectOnScreen(videoImage: ciImage),image:ciImage)
//        eyeRectResized = checkRect(rect:eyeRectResized,image:ciImage)
        CGeye = context.createCGImage(ciImage, from: eyeRectResized)
        UIeye = UIImage.init(cgImage: CGeye, scale:1.0, orientation:orientation)
        eyeWakuL_image.frame=CGRect(x:view.bounds.width/4+10,y:5,width: eyeRectResized.size.width*4,height: eyeRectResized.size.height*4)
        eyeWakuL_image.layer.borderColor = UIColor.black.cgColor
        eyeWakuL_image.layer.borderWidth = 1.0
        eyeWakuL_image.backgroundColor = UIColor.clear
        eyeWakuL_image.layer.cornerRadius = 3
        eyeWakuL_image.image=UIeye
        view.bringSubviewToFront(eyeWakuL_image)
//        faceCenter=transPoint(point: faceCenter,videoImage: ciImage)
        let faceRect=getRectFromCenter(center: faceCenter, len: wakuLength)
        let faceRectResized = resizeR2(faceRect, viewRect:getVideoRectOnScreen(videoImage: ciImage), image: ciImage)
//        faceRectResized = checkRect(rect:faceRectResized,image:ciImage)
        CGface = context.createCGImage(ciImage, from: faceRectResized)
        UIface = UIImage.init(cgImage: CGface, scale:1.0, orientation:orientation)
        faceWakuL_image.frame=CGRect(x:view.bounds.width/4 - faceRectResized.size.width*4 - 10,y:5,width: faceRectResized.size.width*4,height: faceRectResized.size.height*4)
        faceWakuL_image.layer.borderColor = UIColor.black.cgColor
        faceWakuL_image.layer.borderWidth = 1.0
        faceWakuL_image.backgroundColor = UIColor.clear
        faceWakuL_image.layer.cornerRadius = 3
        faceWakuL_image.image=UIface
//        let grayFace=openCV.grayScale(UIface)
//        faceWakuL_image.image=grayFace
        view.bringSubviewToFront(faceWakuL_image)
    }

    func dispWakus(){
        let d=(wakuLength+20)/2//matchingArea(center,wakuLength)
        eyeWaku_image.frame=CGRect(x:eyeCenter.x-d,y:eyeCenter.y-d,width:2*d,height:2*d)
        faceWaku_image.frame=CGRect(x:faceCenter.x-d,y:faceCenter.y-d,width:2*d,height:2*d)
        eyeWaku_image.layer.borderColor = UIColor.green.cgColor
        eyeWaku_image.backgroundColor = UIColor.clear
        eyeWaku_image.layer.cornerRadius = 4
        faceWaku_image.layer.borderColor = UIColor.green.cgColor
        faceWaku_image.backgroundColor = UIColor.clear
        faceWaku_image.layer.cornerRadius = 4
        if eyeORface==0{
            eyeWaku_image.layer.borderWidth = 2
            faceWaku_image.layer.borderWidth = 1
        }else{
            eyeWaku_image.layer.borderWidth = 1
            faceWaku_image.layer.borderWidth = 2
        }
        view.bringSubviewToFront(faceWaku_image)
        view.bringSubviewToFront(eyeWaku_image)
    }

    func moveCenter(start:CGPoint,move:CGPoint,hani:CGRect)-> CGPoint{
        var returnPoint:CGPoint=CGPoint(x:0,y:0)//2種類の枠を代入、変更してreturnで返す
        returnPoint.x = start.x + move.x
        returnPoint.y = start.y + move.y
        if returnPoint.x < hani.origin.x{
            returnPoint.x = hani.origin.x
        }else if returnPoint.x > hani.origin.x+hani.width{
            returnPoint.x = hani.origin.x+hani.width
        }
        if returnPoint.y < hani.origin.y{
            returnPoint.y = hani.origin.y
        }else if returnPoint.y > hani.origin.y+hani.height{
            returnPoint.y = hani.origin.y+hani.height
        }
        return returnPoint
    }
    var eyeORface:Int = 0//0:eye 1:face 2:outer -1:何も選択されていない
    var startEyeCenter:CGPoint!//tapした時のCenter
    var startFaceCenter:CGPoint!
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        let move:CGPoint = sender.translation(in: self.view)
        if sender.state == .began {
            startEyeCenter=eyeCenter
            startFaceCenter=faceCenter
        } else if sender.state == .changed {
            
            let ww=view.bounds.width
            let wh=view.bounds.height
            
            let et=CGRect(x:ww/10,y:wh/20,width: ww*4/5,height:wh*3/4)
            if eyeORface==0{
                eyeCenter=moveCenter(start:startEyeCenter,move:move,hani:et)
            }else{
                faceCenter=moveCenter(start:startFaceCenter,move:move,hani:et)
            }
            dispWakus()
            showWakuImages()
        }else if sender.state == .ended{
        }
    }
    
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        print("tap")
        if eyeORface==0{//eye
            eyeORface=1
        }else{
            eyeORface=0
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
        
        let calcButton = UIButton(frame:CGRect(x: dw*4+bw*3, y: by, width: bw, height: bh))
        calcButton.layer.masksToBounds = true
        calcButton.layer.cornerRadius = 5.0
        calcButton.backgroundColor = UIColor.darkGray
        calcButton.setTitle("戻る", for:UIControl.State.normal)
        calcButton.isEnabled=true
        calcButton.layer.borderColor = UIColor.black.cgColor
        calcButton.layer.borderWidth = 1.0
        calcButton.addTarget(self, action: #selector(onCalcButtonTapped), for: UIControl.Event.touchUpInside)
        view.addSubview(exitButton)
        
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        videoPlayer.play()
        dispWakus()
        showWakuImages()
        videoSize=resolutionSizeOfVideo(url:videoURL!)
        screenSize=view.bounds.size
        videoFps=getFPS(url: videoURL!)
        print("video",videoSize,"screen",screenSize)
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
 /*   @IBAction func vHITcalc(_ sender: Any) {
        if videoImg.count==0{
            return
        }
        setUserDefaults()
        if nonsavedFlag == true && (waveTuple.count > 0 || eyePosFiltered.count > 0){
            setButtons(mode: false)
            var alert = UIAlertController(
                title: "You are erasing vHIT Data.",
                message: "OK ?",
                preferredStyle: .alert)
            if isVHIT==false{
                alert = UIAlertController(
                    title: "You are erasing VOG Data.",
                    message: "OK ?",
                    preferredStyle: .alert)
            }
            // アラートにボタンをつける
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                self.setButtons(mode: false)
                self.vHITcalc()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel,handler:{ action in
                self.setButtons(mode: true)
                //         print("****cancel")
            }))
            // アラート表示
            self.present(alert, animated: true, completion: nil)
            //１：直ぐここと２を通る
        }else{
            setButtons(mode: false)
            vHITcalc()
        }
        //２：直ぐここを通る
    }
 */
    var kalVs:[[CGFloat]]=[[0.0001,0.001,0,1,2],[0.0001,0.001,3,4,5],[0.0001,0.001,6,7,8],[0.0001,0.001,10,11,12],[0.0001,0.001,13,14,15]]
    func KalmanS(Q:CGFloat,R:CGFloat,num:Int){
        kalVs[num][4] = (kalVs[num][3] + Q) / (kalVs[num][3] + Q + R);
        kalVs[num][3] = R * (kalVs[num][3] + Q) / (R + kalVs[num][3] + Q);
    }
    func Kalman(value:CGFloat,num:Int)->CGFloat{
        KalmanS(Q:kalVs[num][0],R:kalVs[num][1],num:num);
        let result = kalVs[num][2] + (value - kalVs[num][2]) * kalVs[num][4];
        kalVs[num][2] = result;
        return result;
    }
    func KalmanInit(){
        for i in 0...4{
            kalVs[i][2]=0
            kalVs[i][3]=0
            kalVs[i][4]=0
        }
    }
    func expandRectWithBorderWide(rect:CGRect, border:CGFloat) -> CGRect {
        //左右には border 、上下には border/2 を広げる
        //この関数も上と同じようにroundした方がいいかもしれないが、
        //現状ではscreen座標のみで使っているのでfloatのまま。
        return CGRect(x:rect.origin.x - border,
                      y:rect.origin.y - border,
                      width:rect.size.width + border * 2,
                      height:rect.size.height + border * 2)
    }
    func expandRectWithBorder(rect:CGRect, border:CGFloat) -> CGRect {
        //左右には border 、上下には border/2 を広げる
        //この関数も上と同じようにroundした方がいいかもしれないが、
        //現状ではscreen座標のみで使っているのでfloatのまま。
        return CGRect(x:rect.origin.x - border,
                      y:rect.origin.y - border / 4,
                      width:rect.size.width + border * 2,
                      height:rect.size.height + border / 2)
    }
    func expandRectError(rect:CGRect, border:CGFloat) -> CGRect {
        //左右には border 、上下には border/2 を広げる
        //この関数も上と同じようにroundした方がいいかもしれないが、
        //現状ではscreen座標のみで使っているのでfloatのまま。
        return CGRect(x:rect.origin.x - border,
                      y:rect.origin.y - border ,
                      width:rect.size.width + border * 2,
                      height:rect.size.height + border * 2)
    }
    
    func startTimer() {
        if timer?.isValid == true {
            timer!.invalidate()
        }
//        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update_vog), userInfo: nil, repeats: true)
    }
    var calcFlag:Bool=false
    var openCVstopFlag:Bool=false
    var eyeBorder:Int = 20
    var posRatio:Int = 100//vog
    var veloRatio:Int = 100//vog
    var faceF:Int = 0
    var calcDate:String = ""
    var eyePosOrig = Array<CGFloat>()//eyePosOrig
    var eyePosFiltered = Array<CGFloat>()//eyePosFiltered
    var eyeVeloOrig = Array<CGFloat>()//eyeVeloOrig
    var eyeVeloFiltered = Array<CGFloat>()//eyeVeloFiltered
    var faceVeloOrig = Array<CGFloat>()//faceVeloOrig
    var faceVeloFiltered = Array<CGFloat>()//faceVeloFiltered

    @objc func onCalcButtonTapped(){
        var cvError:Int = 0
        calcFlag = true
        eyeVeloOrig.removeAll()
        eyeVeloFiltered.removeAll()
        faceVeloOrig.removeAll()
        faceVeloFiltered.removeAll()
        eyePosOrig.removeAll()
        eyePosFiltered.removeAll()
      
        KalmanInit()
//        showBoxies(f: true)
//        vogImage = drawWakulines(width:mailWidth*18,height:mailHeight)//枠だけ
        
        openCVstopFlag = false
        UIApplication.shared.isIdleTimerDisabled = true
        let eyeborder:CGFloat = CGFloat(eyeBorder)
        //        print("eyeborder:",eyeBorder,faceF)
        startTimer()//resizerectのチェックの時はここをコメントアウト*********************
        //       let fileURL = URL(fileURLWithPath: vidPath[vidCurrent])

//         let fileURL = getfileURL(path: vidPath[vidCurrent])
         let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
         let avAsset = AVURLAsset(url: videoURL!, options: options)
        calcDate = avAsset.creationDate!.description
//        print("calcdate:",calcDate)
        var fpsIs120:Bool=false
//        if getFPS(url: videoURL!)<200.0{
//            fpsIs120=true
//        }
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
        reader.timeRange = timeRange //読み込む範囲を`timeRange`で指定
        reader.startReading()
 
        // UnsafeとMutableはまあ調べてもらうとして、eX, eY等は<Int32>が一つ格納されている場所へのポインタとして宣言される。
        let eX = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        let eY = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        let fX = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        let fY = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        var eyeCGImage:CGImage!
        let eyeUIImage:UIImage!
        var eyeWithBorderCGImage:CGImage!
        var eyeWithBorderUIImage:UIImage!
        var faceCGImage:CGImage!
        var faceUIImage:UIImage!
        var faceWithBorderCGImage:CGImage!
        var faceWithBorderUIImage:UIImage!
        let wakuE=getRectFromCenter(center: eyeCenter, len: wakuLength)
        let eyeRectOnScreen=CGRect(x:wakuE.origin.x, y:wakuE.origin.y, width: wakuE.width, height: wakuE.height)
        let eyeWithBorderRectOnScreen = expandRectWithBorderWide(rect: eyeRectOnScreen, border: eyeborder)
        let wakuF=getRectFromCenter(center: faceCenter, len: wakuLength)
        let faceRectOnScreen=CGRect(x:wakuF.origin.x,y:wakuF.origin.y,width: wakuF.width,height: wakuF.height)
        let faceWithBorderRectOnScreen = expandRectWithBorderWide(rect: faceRectOnScreen, border: eyeborder)
 
        let context:CIContext = CIContext.init(options: nil)
        //            let up = UIImage.Orientation.right
        var sample:CMSampleBuffer!
//        stopButton.isEnabled = true
        sample = readerOutput.copyNextSampleBuffer()
        
        let pixelBuffer:CVPixelBuffer = CMSampleBufferGetImageBuffer(sample!)!
        let ciImage:CIImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(CGImagePropertyOrientation.right)
        let maxWidth=ciImage.extent.size.width
        let maxHeight=ciImage.extent.size.height
        let eyeRect = resizeR2(eyeRectOnScreen, viewRect:view.frame, image:ciImage)
        var eyeWithBorderRect = resizeR2(eyeWithBorderRectOnScreen, viewRect:view.frame, image:ciImage)
 
        let maxWidthWithBorder=maxWidth-eyeWithBorderRect.width-5
        let maxHeightWithBorder=maxHeight-eyeWithBorderRect.height-5
        let faceRect = resizeR2(faceRectOnScreen, viewRect: view.frame, image:ciImage)
        var faceWithBorderRect = resizeR2(faceWithBorderRectOnScreen, viewRect:view.frame, image:ciImage)
        
        let eyebR0 = eyeWithBorderRect
        let facbR0 = faceWithBorderRect
        
        eyeCGImage = context.createCGImage(ciImage, from: eyeRect)!
 
        eyeUIImage = UIImage.init(cgImage: eyeCGImage)
        faceCGImage = context.createCGImage(ciImage, from: faceRect)!
 
        faceUIImage = UIImage.init(cgImage:faceCGImage)
        
        
        let osEyeX:CGFloat = (eyeWithBorderRect.size.width - eyeRect.size.width) / 2.0//上下方向
        let osEyeY:CGFloat = (eyeWithBorderRect.size.height - eyeRect.size.height) / 2.0//左右方向
        let osFacX:CGFloat = (faceWithBorderRect.size.width - faceRect.size.width) / 2.0//上下方向
        let osFacY:CGFloat = (faceWithBorderRect.size.height - faceRect.size.height) / 2.0//左右方向
 
        var maxV:Double = 0
        var maxVf:Double = 0
        while reader.status != AVAssetReader.Status.reading {
            sleep(UInt32(0.1))
        }
        DispatchQueue.global(qos: .default).async {//resizerectのチェックの時はここをコメントアウト下がいいかな？
            while let sample = readerOutput.copyNextSampleBuffer(), self.calcFlag != false {
                var ex:CGFloat = 0
                var ey:CGFloat = 0
                var eyePos:CGFloat = 0
                var fx:CGFloat = 0
                var fy:CGFloat = 0
                
                //for test display
                #if DEBUG
                var x:CGFloat = 0.0
                let y:CGFloat = 500.0
                #endif
                autoreleasepool{
                    let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sample)!//27sec:10sec
                    cvError -= 1
                    if cvError < 0{
                        //orientation.upとrightは所要時間同じ
                        let ciImage: CIImage =
                            CIImage(cvPixelBuffer: pixelBuffer).oriented(CGImagePropertyOrientation.right)
                        eyeWithBorderCGImage = context.createCGImage(ciImage, from: eyeWithBorderRect)!
                        eyeWithBorderUIImage = UIImage.init(cgImage: eyeWithBorderCGImage)
                        
                        #if DEBUG
                        //                        画面表示はmain threadで行う
                        
                        let eye0CGImage = context.createCGImage(ciImage, from:eyebR0)!
                        //                        let eye0CGImage = context.createCGImage(ciImage, from:eyeErrorRect)!
                        let eye0UIImage = UIImage.init(cgImage: eye0CGImage)
                        
                        DispatchQueue.main.async {
                            self.wakuEye.frame=CGRect(x:x,y:y,width:eyeRect.size.width*2,height:eyeRect.size.height*2)
                            self.wakuEye.image=eyeUIImage
                            x += eyeRect.size.width*2
                            
                            self.wakuEyeb.frame=CGRect(x:x,y:y,width:eyeWithBorderRect.size.width*2,height:eyeWithBorderRect.size.height*2)
                            self.wakuEyeb.image=eyeWithBorderUIImage
                            x += eyeWithBorderRect.size.width*2
//                            if self.faceF==0 || self.isVHIT==false{
                                self.wakuFacb.frame=CGRect(x:x,y:y,width:eyebR0.size.width*2,height:eyebR0.size.height*2)
                                self.wakuFacb.image=eye0UIImage
//                            }
                        }
                        #endif
                        maxV=self.openCV.matching(eyeWithBorderUIImage,
                                                  narrow: eyeUIImage,
                                                  x: eX,
                                                  y: eY)
                        while self.openCVstopFlag == true{//vHITeyeを使用中なら待つ
                            usleep(1)
                        }
                        
                        if maxV < 0.7{//errorもここに来るぞ!!　ey=0で戻ってくる
                            cvError=5//10/240secはcontinue
                            eyeWithBorderRect=eyebR0//初期位置に戻す
                            faceWithBorderRect=facbR0
                        }else{//検出できた時
                            //eXはポインタなので、".pointee"でそのポインタの内容が取り出せる。Cでいうところの"*"
                            //上で宣言しているとおりInt32が返ってくるのでCGFloatに変換して代入
                            ex = CGFloat(eX.pointee) - osEyeX
                            ey = eyeWithBorderRect.height - CGFloat(eY.pointee) - eyeRect.height - osEyeY
                            eyeWithBorderRect.origin.x += ex
                            eyeWithBorderRect.origin.y += ey
                            eyePos = eyeWithBorderRect.origin.x - eyebR0.origin.x + ex
                            
                            if self.faceF==1{
                                faceWithBorderCGImage = context.createCGImage(ciImage, from:faceWithBorderRect)!
                                faceWithBorderUIImage = UIImage.init(cgImage: faceWithBorderCGImage)
                                #if DEBUG
                                DispatchQueue.main.async {
                                    if self.faceF==1{
                                        self.wakuFac.frame=CGRect(x:x,y:y,width:faceRect.size.width*2,height:faceRect.size.height*2)
                                        self.wakuFac.image=faceUIImage
                                        x += faceRect.size.width*2
                                        self.wakuFacb.frame=CGRect(x:x,y:y,width:faceWithBorderRect.size.width*2,height:faceWithBorderRect.size.height*2)
                                        self.wakuFacb.image=faceWithBorderUIImage
                                    }
                                }
                                #endif
                                
                                maxVf=self.openCV.matching(faceWithBorderUIImage, narrow: faceUIImage, x: fX, y: fY)
                                while self.openCVstopFlag == true{//vHITeyeを使用中なら待つ
                                    usleep(1)
                                }
                                if maxVf<0.7{
                                    cvError=5
                                    faceWithBorderRect=facbR0
                                    eyeWithBorderRect=eyebR0
                                }else{
                                    fx = CGFloat(fX.pointee) - osFacX
                                    fy = faceWithBorderRect.height - CGFloat(fY.pointee) - faceRect.height - osFacY
                                    faceWithBorderRect.origin.x += fx
                                    faceWithBorderRect.origin.y += fy
                                }
                            }
                        }
                        context.clearCaches()
                    }
                    
//                    if self.faceF==1{
                        self.faceVeloOrig.append(fx)
                        self.faceVeloFiltered.append(-12.0*self.Kalman(value: fx,num: 0))
//                    }else{
//                        self.faceVeloOrig.append(0)
//                        self.faceVeloFiltered.append(0)
//                    }
                    // eyePos, ey, fyをそれぞれ配列に追加
                    // vogをkalmanにかけ配列に追加
                    self.eyePosOrig.append(eyePos)
                    self.eyePosFiltered.append( -1.0*self.Kalman(value:eyePos,num:1))
                    
                    self.eyeVeloOrig.append(ex)
                    let eye5 = -12.0*self.Kalman(value: ex,num:2)//そのままではずれる
                    self.eyeVeloFiltered.append(eye5-self.faceVeloFiltered.last!)
                    
        
                    while reader.status != AVAssetReader.Status.reading {
                        sleep(UInt32(0.1))
                    }
//                    self.fps120(is120: fpsIs120)
                    //eyeのみでチェックしているが。。。。
                    if eyeWithBorderRect.origin.x < 5 ||
                        eyeWithBorderRect.origin.x > maxWidthWithBorder ||
                        eyeWithBorderRect.origin.y < 5 ||
                        eyeWithBorderRect.origin.y > maxHeightWithBorder
                    {
                        self.calcFlag=false//quit
                    }
                    
                }
                //マッチングデバッグ用スリープ、デバッグが終わったら削除
                #if DEBUG
                usleep(200)
                #endif
            }
            //            print("time:",CFAbsoluteTimeGetCurrent()-st)
            self.calcFlag = false
//            if self.waveTuple.count > 0{
//                self.nonsavedFlag = true
//            }
        }
    }
}
