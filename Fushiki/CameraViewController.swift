//
//  CameraViewController.swift
//  Fushiki
//
//  Created by 黒田建彰 on 2021/02/10.
//  Copyright © 2021 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import AVFoundation
import GLKit
import Photos
import CoreMotion
class CameraViewController: UIViewController {
//    let TempFilePath: String = "\(NSTemporaryDirectory())temp.mp4"
//    let albumName:String = "vHIT_VOG"
//    var recordedFlag:Bool = false
//    let motionManager = CMMotionManager()
    var session: AVCaptureSession!
    var videoDevice: AVCaptureDevice?
//    var filePath:String?
    var timer:Timer?
    var cameraMode:Int=0
    var fpsCurrent:Double=0
   
//    var vHIT96daAlbum: PHAssetCollection? // アルバムをオブジェクト化
    var fpsMax:Int?
    var fps_non_120_240:Int=2
    var maxFps:Double=240
//    var saved2album:Bool=false//albumに保存終了（エラーの時も）
    var fileOutput = AVCaptureMovieFileOutput()
//    var gyro = Array<Double>()
//    var recStart:Double=0// = CFAbsoluteTimeGetCurrent()
    
//    @IBOutlet weak var focusNear: UILabel!
//
    //    @IBOutlet weak var focusFar: UILabel!
    //
    @IBAction func onCameraChan(_ sender: UISegmentedControl) {
        cameraMode=cameraChan.selectedSegmentIndex
        UserDefaults.standard.set(cameraMode, forKey: "cameraMode")
        session.stopRunning()
        initSession(fps: 120,camera:cameraMode)
        print("cameraMode:",cameraMode)
        fpsLabel.text = String(format:"fps:%.0f" ,fpsCurrent)
        print("cameraMode:",cameraMode)
    }
    @IBOutlet weak var cameraChan: UISegmentedControl!
    @IBOutlet weak var zoomBar: UISlider!
    @IBOutlet weak var focusBar: UISlider!
    @IBOutlet weak var zoomLabel: UILabel!
    @IBOutlet weak var focusLabel: UILabel!
     @IBOutlet weak var exitButton: UIButton!
    // 指定の FPS のフォーマットに切り替える (その FPS で最大解像度のフォーマットを選ぶ)
    //
    // - Parameters:
    //   - desiredFps: 切り替えたい FPS (AVFrameRateRange.maxFrameRate が Double なので合わせる)
    func switchFormat(desiredFps: Double)->Bool {
        // セッションが始動しているかどうか
        var retF:Bool=false
        let isRunning = session.isRunning
        
        // セッションが始動中なら止める
        if isRunning {
            print("isrunning")
            session.stopRunning()
        }
        
        // 取得したフォーマットを格納する変数
        var selectedFormat: AVCaptureDevice.Format! = nil
        // そのフレームレートの中で一番大きい解像度を取得する
        var maxWidth: Int32 = 0
        
        // フォーマットを探る
        for format in videoDevice!.formats {
            // フォーマット内の情報を抜き出す (for in と書いているが1つの format につき1つの range しかない)
            for range: AVFrameRateRange in format.videoSupportedFrameRateRanges {
                let description = format.formatDescription as CMFormatDescription    // フォーマットの説明
                let dimensions = CMVideoFormatDescriptionGetDimensions(description)  // 幅・高さ情報を抜き出す
                let width = dimensions.width
                if desiredFps == range.maxFrameRate && width >= maxWidth {
                    selectedFormat = format
                    maxWidth = width
                }
            }
        }
        fpsCurrent=0
        // フォーマットが取得できていれば設定する
        if selectedFormat != nil {
            do {
                try videoDevice!.lockForConfiguration()
                videoDevice!.activeFormat = selectedFormat
                videoDevice!.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(desiredFps))
                videoDevice!.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(desiredFps))
                videoDevice!.unlockForConfiguration()
                print("フォーマット・フレームレートを設定 : \(desiredFps) fps・\(maxWidth) px")
                retF=true
                fpsCurrent=desiredFps
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
        
        // セッションが始動中だったら再開する
        if isRunning {
            session.startRunning()
        }
        return retF
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setButtons()
        cameraMode = Int(getUserDefault(str: "cameraMode", ret: 0))
        cameraChan.selectedSegmentIndex = cameraMode
        initSession(fps: 120,camera:cameraMode)
        fpsLabel.text = String(format:"fps:%.0f" ,fpsCurrent)
        zoomBar.minimumValue = 0
        zoomBar.maximumValue = 0.1
        zoomBar.addTarget(self, action: #selector(onZoomValueChange), for: UIControl.Event.valueChanged)
        zoomBar.value=getUserDefault(str: "zoomValue", ret:0)
        setZoom(level: zoomBar.value)
        focusBar.minimumValue = 0
        focusBar.maximumValue = 1.0
        focusBar.addTarget(self, action: #selector(onFocusValueChange), for: UIControl.Event.valueChanged)
        focusBar.value=getUserDefault(str: "focusValue", ret: 0)
        setFocus(focus: focusBar.value)
 
//        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    @objc func onZoomValueChange(){
        setZoom(level:zoomBar.value)
        UserDefaults.standard.set(zoomBar.value, forKey: "zoomValue")
    }
    @objc func onFocusValueChange(){
        print("bar:",focusBar.value*100)
        setFocus(focus:focusBar.value)
        UserDefaults.standard.set(focusBar.value, forKey: "focusValue")
    }
    func setZoom(level:Float){//ledとなっているので要変更！！！
        do {
                try self.videoDevice?.lockForConfiguration()
                self.videoDevice?.ramp(
                    toVideoZoomFactor: (self.videoDevice?.minAvailableVideoZoomFactor)! + CGFloat(zoomBar.value) * ((self.videoDevice?.maxAvailableVideoZoomFactor)! - (self.videoDevice?.minAvailableVideoZoomFactor)!),
                    withRate: 30.0)
                self.videoDevice?.unlockForConfiguration()
            } catch {
                print("Failed to change zoom.")
            }
    }
    
    func getUserDefault(str:String,ret:Float) -> Float{
        if (UserDefaults.standard.object(forKey: str) != nil){
            return UserDefaults.standard.float(forKey: str)
        }else{//keyが設定してなければretをセット
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }
    override func viewDidAppear(_ animated: Bool) {

    }

    @IBOutlet weak var fpsLabel: UILabel!
    
    func setButtons(){//type:Bool){
        // recording button
        let ww=view.bounds.width
        let wh=view.bounds.height
        let bw=ww*0.9/7
        let bh=bw*170/440
        let sp=ww*0.1/10
        let by=wh-bh-sp
        setButtonProperty(button:exitButton,x:bw*6+sp*8,y:by,w:bw,h:bh)
        setLabelProperty(label: fpsLabel,x:bw*5+sp*7,y:by-bh-sp/3,w:bw,h:bh)
        setLabelProperty(label: zoomLabel,x:bw*4.5+sp*6,y:by-bh-sp/3,w:bw/2,h:bh)
        setLabelProperty(label:focusLabel,x:bw*4.5+sp*6,y:by,w:bw/2,h:bh)
        focusBar.frame=CGRect(x:sp,y:by,width:bw*4.5+sp*4,height:bh)
        zoomBar.frame=CGRect(x:sp,y:by-sp/3-bh,width:bw*4.5+sp*4,height:bh)
        cameraChan.frame=CGRect(x:bw*5+sp*7,y:by,width:bw,height:bh)
     }
    func setLabelProperty(label:UILabel,x:CGFloat,y:CGFloat,w:CGFloat,h:CGFloat){
        label.frame = CGRect(x:x, y:y, width: w, height: h)
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1.0
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
    }
    func setButtonProperty(button:UIButton,x:CGFloat,y:CGFloat,w:CGFloat,h:CGFloat){
        button.frame   = CGRect(x:x, y:y, width: w, height: h)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 5
    }
//    func setVideoFormat(desiredFps: Double)->Bool {
//        var retF:Bool=false
//        var fps:Double = 0
//        // 取得したフォーマットを格納する変数
//        var selectedFormat: AVCaptureDevice.Format! = nil
//        // そのフレームレートの中で一番大きい解像度を取得する
//        var maxWidth: Int32 = 0
//        var maxFPS:Double=0
//        // フォーマットを探る
////        var getDesiedformat:Bool=false
//        for format in videoDevice!.formats {
//            // フォーマット内の情報を抜き出す (for in と書いているが1つの format につき1つの range しかない)
////            if getDesiedformat==true{
////                break
////            }
//            for range: AVFrameRateRange in format.videoSupportedFrameRateRanges {
//                let description = format.formatDescription as CMFormatDescription    // フォーマットの説明
//                let dimensions = CMVideoFormatDescriptionGetDimensions(description)  // 幅・高さ情報を抜き出す
//                let width = dimensions.width
//                fps = range.maxFrameRate
//                if fps <= desiredFps && fps >= maxFPS && width >= maxWidth {
////                if fps == desiredFps && width >= maxWidth {
//                    selectedFormat = format
//                    maxWidth = width
//                    maxFPS = fps
//                    print(dimensions.width,dimensions.height,maxFPS)
//                }//指定のFPS以下で、最高解像度
//            }
//        }
//        print("selected:",selectedFormat.videoSupportedFrameRateRanges)
//         // フォーマットが取得できていれば設定する
//        if selectedFormat != nil {
//            do {
//                try videoDevice!.lockForConfiguration()
//                videoDevice!.activeFormat = selectedFormat
//                videoDevice!.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(maxFPS))
//                videoDevice!.unlockForConfiguration()
//
//                let description = selectedFormat.formatDescription as CMFormatDescription    // フォーマットの説明
//                let dimensions = CMVideoFormatDescriptionGetDimensions(description)  // 幅・高さ情報を抜き出す
//                let iCapNYSWidth = dimensions.width
//                let iCapNYSHeight = dimensions.height
//                print("フォーマット・フレームレートを設定 : \(maxFPS) fps・\(iCapNYSWidth) px x \(iCapNYSHeight) px")
//                fpsCurrent=fps
//
//                retF=true
//            }
//            catch {
////                print("フォーマット・フレームレートが指定できなかった")
//                retF=false
//            }
//        }
//        else {
////            print("指定のフォーマットが取得できなかった")
//            retF=false
//        }
//        return retF
//    }

    func initSession(fps:Int,camera:Int) {
        // セッション生成
        session = AVCaptureSession()
        // 入力 : 背面カメラ
        if camera == 0{
        videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        }else{
            videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        }
        let videoInput = try! AVCaptureDeviceInput.init(device: videoDevice!)
        session.addInput(videoInput)
//        if setVideoFormat(desiredFps: Double(fps))==false{
//            print("fps set error")
//        }else{
//            print("fps set error")
//        }

        if switchFormat(desiredFps: 240.0)==false{
            if switchFormat(desiredFps: 120.0)==false{
                if switchFormat(desiredFps: 60.0)==false{
                    if switchFormat(desiredFps: 30.0)==false{
                        print("set fps error")
                    }
                }
            }
        }
        let videoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: session)
        videoLayer.frame = self.view.bounds
        videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill//無くても同じ
        videoLayer.connection!.videoOrientation = .landscapeRight//　orientation
        cameraView.layer.addSublayer(videoLayer)
        // セッションを開始する (録画開始とは別)
        session.startRunning()
    }
    
    @IBOutlet weak var cameraView: UIImageView!
 
    var timerCnt:Int=0
    @objc func update(tm: Timer) {
        timerCnt += 1

//        UserDefaults.standard.set(videoDevice?.lensPosition, forKey: "focusValue")
//        focusBar.value=videoDevice!.lensPosition

    }
    func setFocus(focus:Float){//focus 0:最接近　0-1.0
        if let device = videoDevice {
            do {
                try! device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported{
                    //Add Focus on Point
                    device.focusMode = .locked
                    device.setFocusModeLocked(lensPosition: focus, completionHandler: { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                            device.unlockForConfiguration()
                        })
                    })
                }
                device.unlockForConfiguration()
            }
        }
    }
}

