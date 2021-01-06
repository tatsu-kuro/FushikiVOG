//
//  ETTcViewController.swift
//  Fushiki
//
//  Created by Fushiki tatsuaki on 2018/08/05.
//  Copyright © 2018年 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
class ETTViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    var videoDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession!
    var cirDiameter:CGFloat = 0
    var startTime=CFAbsoluteTimeGetCurrent()
    var lastTime=CFAbsoluteTimeGetCurrent()
    let TempFilePath: String = "\(NSTemporaryDirectory())temp.mp4"
    var fushikiAlbum: PHAssetCollection? // アルバムをオブジェクト化
    var fileOutput = AVCaptureMovieFileOutput()

    var displayLinkF:Bool=false
    var displayLink:CADisplayLink?
    var tcount: Int = 0
    var ettWidth:Int = 50
    var ettMode:Int = 0
    var targetMode:Int = 0
    var ettW:CGFloat = 0
    var ettH:CGFloat = 0
    
    @IBOutlet weak var cameraView: UIImageView!
    func setVideoFormat(desiredFps: Double)->Bool {
        var retF:Bool=false
        // 取得したフォーマットを格納する変数
        var selectedFormat: AVCaptureDevice.Format! = nil
        // そのフレームレートの中で一番大きい解像度を取得する
        var maxWidth: Int32 = 0
        // フォーマットを探る
//        var getDesiedformat:Bool=false
        for format in videoDevice!.formats {
            // フォーマット内の情報を抜き出す (for in と書いているが1つの format につき1つの range しかない)
//            if getDesiedformat==true{
//                break
//            }
            for range: AVFrameRateRange in format.videoSupportedFrameRateRanges {
                let description = format.formatDescription as CMFormatDescription    // フォーマットの説明
                let dimensions = CMVideoFormatDescriptionGetDimensions(description)  // 幅・高さ情報を抜き出す
                let width = dimensions.width
//                print(dimensions.width,dimensions.height)
                if desiredFps == range.maxFrameRate && width == 1280{//}>= maxWidth {
                    selectedFormat = format
                    maxWidth = width
 //                   getDesiedformat=true
                    print(range.maxFrameRate,dimensions.width,dimensions.height)
 //                   break
                }
            }
        }
//ipod touch 1280x720 1440*1080
//SE 960x540 1280x720 1920x1080
//11 192x144 352x288 480x360 640x480 1024x768 1280x720 1440x1080 1920x1080 3840x2160
//1280に設定すると上手く行く。合成のところには1920x1080で飛んでくるようだ。？
        // フォーマットが取得できていれば設定する
        if selectedFormat != nil {
            do {
                try videoDevice!.lockForConfiguration()
                videoDevice!.activeFormat = selectedFormat
                videoDevice!.activeVideoMaxFrameDuration = CMTimeMake(1, Int32(desiredFps))
                videoDevice!.unlockForConfiguration()
                
                let description = selectedFormat.formatDescription as CMFormatDescription    // フォーマットの説明
                let dimensions = CMVideoFormatDescriptionGetDimensions(description)  // 幅・高さ情報を抜き出す
                let iCapNYSWidth = dimensions.width
                let iCapNYSHeight = dimensions.height
                print("フォーマット・フレームレートを設定 : \(desiredFps) fps・\(iCapNYSWidth) px x \(iCapNYSHeight) px")
                
                retF=true
            }
            catch {
                print("フォーマット・フレームレートが指定できなかった")
                retF=false
            }
        }
        else {
            print("指定のフォーマットが取得できなかった")
            retF=false
        }
        return retF
    }
    func initSession(fps:Double) {
        // カメラ入力 : 背面カメラ
        videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        let videoInput = try! AVCaptureDeviceInput.init(device: videoDevice!)

        if setVideoFormat(desiredFps: fps)==false{
            print("error******")
        }
        // AVCaptureSession生成
        captureSession = AVCaptureSession()
        captureSession.addInput(videoInput)
 
        // ファイル出力設定
        fileOutput = AVCaptureMovieFileOutput()
        captureSession.addOutput(fileOutput)
        
        let videoDataOuputConnection = fileOutput.connection(with: .video)
        let orientation = UIDevice.current.orientation
        videoDataOuputConnection!.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue)!
        // セッションを開始する (録画開始とは別)
        captureSession.startRunning()
    }
    var tapInterval=CFAbsoluteTimeGetCurrent()
    func stopDisplaylink(){
        if displayLinkF==true{
            displayLink?.invalidate()
            displayLinkF=false
        }
    }
    @IBAction func doubleTap(_ sender: Any) {
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        //        mainView.ettWidth=ettWidth
        //        mainView.oknSpeed=oknSpeed
        //        mainView.oknDirection=oknDirection
        mainView.targetMode=targetMode
        stopDisplaylink()
        fileOutput.stopRecording()
        self.present(mainView, animated: false, completion: nil)
    }
    override func remoteControlReceived(with event: UIEvent?) {
        guard event?.type == .remoteControl else { return }
        
        if let event = event {
            
            switch event.subtype {
            case .remoteControlPlay:
                print("Play")
                if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                    print("doubleTapPlay")
                    doubleTap(0)
                    //                    self.dismiss(animated: true, completion: nil)
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            case .remoteControlTogglePlayPause:
                print("TogglePlayPause")
                if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                    print("doubleTap")
                    doubleTap(0)
                    //                    self.dismiss(animated: true, completion: nil)
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            case .remoteControlNextTrack:
//                ettWidth = 2
//                setETTwidth(width: 2)
                tcount=1
            case .remoteControlPreviousTrack:
//                ettWidth = 1
//                setETTwidth(width: 1)
                tcount=1
            default:
                print("Others")
            }
        }
    }
//    func setETTwidth(width:Int){
//        if width == 1{
//            ettW = view.bounds.width/4
//        }else{
//            ettW = view.bounds.width/2 - view.bounds.width/18
//        }
//    }
    //    @IBAction func furi2Action(_ sender: Any) {
    //        ettWidth = 1
    //        setETTwidth(width: 1)
    //        tcount=1
    //    }
    //    @IBAction func furi3Action(_ sender: Any) {
    //        ettWidth = 2
    //        setETTwidth(width: 2)
    //        tcount=1
    //    }
    
    //    func hideButtons(hide:Bool){
    //        furi2Button.isHidden=hide
    //        furi3Button.isHidden=hide
    //     }
    override func viewDidAppear(_ animated: Bool) {
//        if ettWidth == 0{
//            ettWidth = 2
//        }
//        setETTwidth(width: ettWidth)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        ettMode=UserDefaults.standard.integer(forKey: "ettMode")
        ettWidth=UserDefaults.standard.integer(forKey: "ettWidth")
//        let w=view.bounds.width/2
        ettW = (view.bounds.width/2)*CGFloat(ettWidth)/100.0
        ettH = (view.bounds.height/2)*CGFloat(ettWidth)/100.0
        cirDiameter=view.bounds.width/26
        if ettMode==0{//pursuit
            displayLink = CADisplayLink(target: self, selector: #selector(self.update0))
            displayLink!.preferredFramesPerSecond = 120
        }else if ettMode==1{//vert-horizon saccade
            displayLink = CADisplayLink(target: self, selector: #selector(self.update1))
            displayLink!.preferredFramesPerSecond = 120
        }else if ettMode==2{//vert-horizon saccade
            displayLink = CADisplayLink(target: self, selector: #selector(self.update2))
            displayLink!.preferredFramesPerSecond = 1
        }else{//pursuit->saccade->random
            displayLink = CADisplayLink(target: self, selector: #selector(self.update3))
            displayLink!.preferredFramesPerSecond = 120
        }
        displayLink!.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        displayLinkF=true
        
        tcount=0
        //       ETTbutton.isEnabled=false
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
        //          hideButtons(hide: true)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        tapInterval=CFAbsoluteTimeGetCurrent()-1
        self.setNeedsStatusBarAppearanceUpdate()
//        prefersHomeIndicatorAutoHidden()
        //        prefersStatusBarHidden
        initSession(fps: 30)
        albumCheck(album: "fushiki")
        try? FileManager.default.removeItem(atPath: TempFilePath)
        let fileURL = NSURL(fileURLWithPath: TempFilePath)
        fileOutput.startRecording(to: fileURL as URL, recordingDelegate: self)
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    var lastrand:Int=1
    var rand:Int=0
 
     var initf:Bool=false
     @objc func update3() {
         if initf {
             view.layer.sublayers?.removeLast()
         }
         initf=true
         tcount += 1
         let elapset=CFAbsoluteTimeGetCurrent()-startTime
         if elapset<20.0 {//}(tcount<60*20){
             let sinV=sin(CGFloat(elapset)*3.1415*0.6)
             //let sinV=sin(CGFloat(tcount)*0.03183)//0.3Hz
             let cPoint:CGPoint = CGPoint(x:view.bounds.width/2 + sinV*ettW, y: view.bounds.height/2)
             drawCircle(cPoint:cPoint)
         }else if elapset<40.0 {//}(tcount<60*20*2){
             //    if Int(elapset) != Int(lastTime){
             if Int(elapset)%2 == 0{// }(tcount/60)%2==0){
                 let cPoint:CGPoint = CGPoint(x:view.bounds.width/2 + ettW, y: view.bounds.height/2)
                 drawCircle(cPoint:cPoint)
             }else{
                 let cPoint:CGPoint = CGPoint(x:view.bounds.width/2 - ettW, y: view.bounds.height/2)
                 drawCircle(cPoint:cPoint)
             }
             //  }
         }else if elapset<60 {//}(tcount<60*20*3){
             
             if Int(elapset) != Int(lastTime){
                 rand = Int.random(in: 0..<5) - 2
                 if(lastrand==rand){
                     rand += 1
                     if(rand > 2){
                         rand = -2
                     }
                 }
             }
             let cg=CGFloat(rand)/2.0
             lastrand=rand
             let cPoint:CGPoint = CGPoint(x:view.bounds.width/2 - cg*ettW, y: view.bounds.height/2)
             drawCircle(cPoint:cPoint)
         }else if elapset<65{
             let cPoint:CGPoint = CGPoint(x:view.bounds.width/2, y: view.bounds.height/2)
             drawCircle(cPoint:cPoint)
             //self.dismiss(animated: true, completion: nil)
         }else{
//             delTimer()
             doubleTap(0)
         }
         lastTime=elapset
     }
     
    @objc func update2() {
         if tcount > 0{
             view.layer.sublayers?.removeLast()
         }
         tcount += 1
         var rand = Int.random(in: 0..<10)
         if (rand==9){
             rand=4
         }
         if (lastrand==rand){
             rand += 1
             if(rand==9){
                 rand=0
             }
         }
         if(tcount>30){//finish
             doubleTap(0)
         }
         lastrand=rand
         var xn:Int=0
         var yn:Int=0
         if(rand%3==0){xn = -1}
         else if(rand%3==1){xn=0}
         else {xn=1}
         if(rand/3==0){yn = -1}
         else if(rand/3==1){yn = 0}
         else {yn=1}
         let x0=view.bounds.width/2
         let y0=view.bounds.height/2
         let cPoint:CGPoint = CGPoint(x:x0 + CGFloat(xn*ettWidth)*x0/100, y: y0 + CGFloat(yn*ettWidth)*y0/100)
         drawCircle(cPoint:cPoint)
     }
    @objc func update1() {//pursuit
           if tcount > 0{
               view.layer.sublayers?.removeLast()
           }
           tcount += 1
           let elapset=CFAbsoluteTimeGetCurrent()-startTime
           if(tcount>60*30 && elapset>29 || tcount>120*30){
               doubleTap(0)
           }
           
           let sinV=sin(CGFloat(elapset)*3.1415*0.6)
           
           let cPoint:CGPoint = CGPoint(x:view.bounds.width/2 , y: view.bounds.height/2 + sinV*ettH)
           drawCircle(cPoint:cPoint)
       }
    @objc func update0() {//pursuit
        if tcount > 0{
            view.layer.sublayers?.removeLast()
        }
        tcount += 1
        let elapset=CFAbsoluteTimeGetCurrent()-startTime
        if(tcount>60*30 && elapset>29 || tcount>120*30){
            doubleTap(0)
        }
        
        let sinV=sin(CGFloat(elapset)*3.1415*0.6)
        
        let cPoint:CGPoint = CGPoint(x:view.bounds.width/2 + sinV*ettW, y: view.bounds.height/2)
        drawCircle(cPoint:cPoint)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func drawCircle(cPoint:CGPoint){
        /* --- 円を描画 --- */
        let circleLayer = CAShapeLayer.init()
        let circleFrame = CGRect.init(x:cPoint.x-cirDiameter/2,y:cPoint.y-cirDiameter/2,width:cirDiameter,height:cirDiameter)
        circleLayer.frame = circleFrame
        // 輪郭の色
        circleLayer.strokeColor = UIColor.white.cgColor
        // 円の中の色
        circleLayer.fillColor = UIColor.red.cgColor
        // 輪郭の太さ
        circleLayer.lineWidth = 0.5
        // 円形を描画
        circleLayer.path = UIBezierPath.init(ovalIn: CGRect.init(x: 0, y: 0, width: circleFrame.size.width, height: circleFrame.size.height)).cgPath
        self.view.layer.addSublayer(circleLayer)
    }
    func appOrientation() -> UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
    
    func convertUIOrientation2VideoOrientation(f: () -> UIInterfaceOrientation) -> AVCaptureVideoOrientation? {
        let v = f()
        switch v {
        case UIInterfaceOrientation.unknown:
            return nil
        default:
            return ([
                UIInterfaceOrientation.portrait: AVCaptureVideoOrientation.portrait,
                UIInterfaceOrientation.portraitUpsideDown: AVCaptureVideoOrientation.portraitUpsideDown,
                UIInterfaceOrientation.landscapeLeft: AVCaptureVideoOrientation.landscapeLeft,
                UIInterfaceOrientation.landscapeRight: AVCaptureVideoOrientation.landscapeRight
            ])[v]
        }
    }
    // アルバムが既にあるか確認し、iCapNYSAlbumに代入
    func albumExists(albumTitle: String) -> Bool {
        // ここで以下のようなエラーが出るが、なぜか問題なくアルバムが取得できている
        // [core] "Error returned from daemon: Error Domain=com.apple.accounts Code=7 "(null)""
        let albums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype:
                                                                PHAssetCollectionSubtype.albumRegular, options: nil)
        for i in 0 ..< albums.count {
            let album = albums.object(at: i)
            if album.localizedTitle != nil && album.localizedTitle == albumTitle {
                fushikiAlbum = album
                return true
            }
        }
        return false
    }
    func albumCheck(album:String){//ここでもチェックしないとダメのよう
        if albumExists(albumTitle: album)==false{
            createNewAlbum(albumTitle: album) { (isSuccess) in
                if isSuccess{
                    print("album can be made,")
                } else{
                    print("album can't be made.")
                }
            }
        }else{
            print("album exist already.")
        }
    }
    //何も返していないが、ここで見つけたor作成したalbumを返したい。そうすればグローバル変数にアクセスせずに済む
    func createNewAlbum(albumTitle: String, callback: @escaping (Bool) -> Void) {
        if self.albumExists(albumTitle: albumTitle) {
            callback(true)
        } else {
            PHPhotoLibrary.shared().performChanges({
                let createAlbumRequest = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumTitle)
            }) { (isSuccess, error) in
                callback(isSuccess)
            }
        }
    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(
            alongsideTransition: nil,
            completion: {(UIViewControllerTransitionCoordinatorContext) in
                //画面の回転後に向きを教える。
                if self.convertUIOrientation2VideoOrientation(f: {return self.appOrientation()}) != nil {
//                    self.setETTwidth(width: self.ettWidth)
                }
        }
        )
    }
    //    @IBAction func tapGes(_ sender: UITapGestureRecognizer) {
    //            if furi2Button.isHidden == true{
    //                hideButtons(hide: false)
    //            }else{
    //                hideButtons(hide: true)
    //            }
    //    }
    //    @IBAction func panGes(_ sender: UIPanGestureRecognizer) {
    //
    //
    //    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopDisplaylink()
    }
    var soundIdx:SystemSoundID = 0
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
//        if let soundUrl = CFBundleCopyResourceURL(CFBundleGetMainBundle(), nil, nil, nil){
//            AudioServicesCreateSystemSoundID(soundUrl, &soundIdstop)
//            AudioServicesPlaySystemSound(soundIdstop)
//        }
        if let soundUrl = URL(string:
                          "/System/Library/Audio/UISounds/end_record.caf"/*photoShutter.caf*/){
            AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundIdx)
            AudioServicesPlaySystemSound(soundIdx)
        }

        print("終了ボタン、最大を超えた時もここを通る")
       
//        recordedFlag=true
//        if timer?.isValid == true {
//            timer!.invalidate()
//        }
        
        PHPhotoLibrary.shared().performChanges({
            //let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: avAsset)
            let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)!
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: (self.fushikiAlbum)!)
            let placeHolder = assetRequest.placeholderForCreatedAsset
            albumChangeRequest?.addAssets([placeHolder!] as NSArray)
            //imageID = assetRequest.placeholderForCreatedAsset?.localIdentifier
            print("file add to album")
        }) { [self] (isSuccess, error) in
            if isSuccess {
                // 保存した画像にアクセスする為のimageIDを返却
                //completionBlock(imageID)
                print("success")
//                self.saved2album=true
            } else {
                //failureBlock(error)
                print("fail")
                //                print(error)
//                self.saved2album=true
            }
            //            _ = try? FileManager.default.removeItem(atPath: self.TempFilePath)
        }
        
//        performSegue(withIdentifier: "fromRecordToMain", sender: self)
    }
}
