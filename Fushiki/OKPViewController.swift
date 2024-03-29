//
//  SaccadeViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2019/05/10.
//  Copyright © 2019 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
class OKPViewController: UIViewController{
    let camera = myFunctions()//name:"Fushiki")
    var cameraON:Bool=false
//    var mainBrightness:CGFloat!
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet var singleRec: UITapGestureRecognizer!
    @IBOutlet var doubleRec: UITapGestureRecognizer!
    var okp4:Double=40//最高スピードに達するまでの時間
    @IBOutlet weak var dummyImage: UIImageView!
    var timerREC:Timer?
    var okpSpeed:Int=5
    var speed:Int=0
    var okpTime:Int=0
    var okpMode:Int=0
    var targetMode:Int = 0
    var displayLink:CADisplayLink?
    var displayLinkF:Bool=false
    var startTime=CFAbsoluteTimeGetCurrent()
    var lastTime=CFAbsoluteTimeGetCurrent()
    var tcnt:Int = 0
    var ww:CGFloat=0
    var wh:CGFloat=0
    var tapInterval=CFAbsoluteTimeGetCurrent()

    var startX:CGFloat?
    var startSpeed:Int?
    var leftPadding:CGFloat=0
    @IBAction func panGes(_ sender: UIPanGestureRecognizer) {

        if sender.state == .began {
            speedLabel.isHidden=false
            startSpeed=okpSpeed
            startX=sender.location(in:self.view).x//sender.location(in: self.view)
        }else if sender.state == .changed {
            okpSpeed = startSpeed! + Int(sender.location(in:self.view).x - startX!)/20
            
            if okpSpeed<1{
                okpSpeed=1
            }else if okpSpeed>200{
                okpSpeed=200
            }
            speedLabel.text="MaxSPEED:" + String(Int(okpSpeed*15)) + "pt/sec" + "  ScreenWidth(" + String(Int(view.bounds.width)) + "pt)"
            speed=15*okpSpeed
        }else if sender.state == .ended{
            UserDefaults.standard.set(okpSpeed, forKey:"okpSpeed")
            speedLabel.isHidden=true
        }
    }
    
//    @IBAction func panGes(_ sender: Any) {
//
//    }
    
    @IBAction func singleTap(_ sender: UITapGestureRecognizer) {
        okpMode = UserDefaults.standard.integer(forKey:"okpMode")
        if sender.location(in: self.view).x<view.bounds.width/2{
            if okpMode==0 || okpMode==2{
                okpMode += 1
            }
        }else{
            if okpMode==1 || okpMode==3{
                okpMode -= 1
            }
        }
        UserDefaults.standard.set(okpMode, forKey:"okpMode")
    }
        
    @IBAction func doubleTap(_ sender: Any) {
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        mainView.targetMode=targetMode
//        UIScreen.main.brightness = mainBrightness
        delTimer()
        camera.recordStop()// fileOutput.stopRecording()
        performSegue(withIdentifier: "fromOKP", sender: self)
    }
    
    func delTimer(){
        if displayLinkF==true{
            displayLink?.invalidate()
        }
        if timerREC?.isValid == true {
            timerREC!.invalidate()
        }
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
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            case .remoteControlTogglePlayPause:
                print("TogglePlayPause")
                if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                    print("doubleTap")
                    doubleTap(0)
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            case .remoteControlNextTrack:
                okpMode = UserDefaults.standard.integer(forKey:"okpMode")
                if okpMode==1 || okpMode==3{
                    okpMode -= 1
                }
                UserDefaults.standard.set(okpMode, forKey:"okpMode")
            case .remoteControlPreviousTrack:
                okpMode = UserDefaults.standard.integer(forKey:"okpMode")
                if okpMode==0 || okpMode==2{
                    okpMode += 1
                }
                UserDefaults.standard.set(okpMode, forKey:"okpMode")
            default:
                print("Others")
            }
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    }
    func drawSCircle(_ img:UIImageView){
        /* --- 円を描画 --- */
        var circleFrame:CGRect?
        let circleLayer = CAShapeLayer.init()
        if cameraON{
            circleFrame = CGRect.init(x:img.frame.minX,y:img.frame.minY,width:img.frame.width,height: img.frame.height)
        }else{
            circleFrame = CGRect.init(x:img.frame.minX,y:img.frame.minY,width:0,height: 0)
        }
          circleLayer.frame = circleFrame!
        // 輪郭の色
        circleLayer.strokeColor = UIColor.white.cgColor
        // 円の中の色
        circleLayer.fillColor = UIColor.red.cgColor
        // 輪郭の太さ
        circleLayer.lineWidth = 0
        // 円形を描画
        circleLayer.path = UIBezierPath.init(ovalIn: CGRect.init(x: 0, y: 0, width: circleFrame!.size.width, height: circleFrame!.size.height)).cgPath
        self.view.layer.addSublayer(circleLayer)
    }
//    var cntREC:Int=0
    @objc func updateRecStart(tm: Timer) {
//        cntREC += 1
//        recClarification.alpha=camera.updateRecClarification(tm: cntREC)
//        if cntREC==20{
            camera.recordStart()//ここだと暗くならない
//        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        camera.makeAlbum()
        cameraON=UserDefaults.standard.bool(forKey: "cameraON")
        leftPadding=CGFloat(UserDefaults.standard.float(forKey: "left")) + view.bounds.width/10

        let cameraType = camera.getUserDefaultInt(str: "cameraType", ret: 0)
        camera.initSession(camera: Int(cameraType),dummyImage)//, cameraView: recClarification)
        
        camera.setZoom(level:camera.getUserDefaultFloat(str: "zoomValue", ret: 0.01))
        camera.setFocus(focus: camera.getUserDefaultFloat(str: "focusValue", ret: 0))
        if cameraType != 0{
            camera.setLedLevel(camera.getUserDefaultFloat(str: "ledValue", ret:0))
        }
 
        ww=view.bounds.width
        wh=view.bounds.height
        okpSpeed = UserDefaults.standard.integer(forKey: "okpSpeed")
        okpTime = UserDefaults.standard.integer(forKey:"okpTime")
        okpMode = UserDefaults.standard.integer(forKey:"okpMode")
        startTime=CFAbsoluteTimeGetCurrent()
        speedLabel.isHidden=true
        speed = okpSpeed*15
        displayLink = CADisplayLink(target: self, selector: #selector(self.update))
        displayLink!.preferredFramesPerSecond = 120
        displayLink?.add(to: RunLoop.main, forMode: .common)        
//        displayLink!.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        displayLinkF=true

        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }

        dummyImage.frame=camera.getRecClarificationRct(view.bounds.width,view.bounds.height)
        if cameraON{
            timerREC = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateRecStart), userInfo: nil, repeats: false)
        }
        // Do any additional setup after loading the view.
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        tapInterval=CFAbsoluteTimeGetCurrent()-1
        self.setNeedsStatusBarAppearanceUpdate()
//        prefersHomeIndicatorAutoHidden()
            //        prefersStatusBarHidden
        //        initSession(fps: 30)
//        try? FileManager.default.removeItem(atPath: TempFilePath)
//        let fileURL = NSURL(fileURLWithPath: TempFilePath)
//        fileOutput.startRecording(to: fileURL as URL, recordingDelegate: self)
        }
        
//        override func prefersHomeIndicatorAutoHidden() -> Bool {
//            return true
//        }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
        override var prefersStatusBarHidden: Bool {
            return true
        }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        delTimer()
    }
    
    func drawBand(rectB: CGRect) {
        let rectLayer = CAShapeLayer.init()
        rectLayer.strokeColor = UIColor.black.cgColor
        rectLayer.fillColor = UIColor.black.cgColor
        rectLayer.lineWidth = 0
        rectLayer.path = UIBezierPath(rect:rectB).cgPath
        self.view.layer.addSublayer(rectLayer)
    }
    func drawWhiteBand(rectB: CGRect) {
        let rectLayer = CAShapeLayer.init()
        rectLayer.strokeColor = UIColor.white.cgColor
        rectLayer.fillColor = UIColor.white.cgColor
        rectLayer.lineWidth = 0
        rectLayer.path = UIBezierPath(rect:rectB).cgPath
        self.view.layer.addSublayer(rectLayer)
    }
    var initf:Bool=false
    var lastx:CGFloat=0
    var currentSpeed:Double = 0
    
    @objc func update(tm: Timer) {
        let x0=ww/5
        if initf {
            for _ in 0..<7{
                view.layer.sublayers?.removeLast()
            }
        }
        initf=true
        let currentTime=CFAbsoluteTimeGetCurrent()
        let elapsed = currentTime - startTime
        let dTime = currentTime - lastTime
        lastTime = currentTime
        var okp4Speed=Double(speed)/okp4
        if okpMode==1 || okpMode==3{
            okp4Speed = -okp4Speed
        }
        if elapsed < okp4  {
            currentSpeed = elapsed * okp4Speed
        } else if elapsed < okp4 * 2.0 {
            currentSpeed = (okp4 * 2.0 - elapsed) * okp4Speed
        } else if elapsed < okp4*2.0 + Double(okpTime){
            currentSpeed=0
            if okpMode > 1{
                for i in 0..<6 {
                    drawBand(rectB:CGRect(x:CGFloat(i-1)*x0+lastx,y:0,width:ww/10,height:wh))
                }
                return
            }
        } else if elapsed < okp4 * 3.0 + Double(okpTime) {
            currentSpeed = -(elapsed - okp4 * 2.0 - Double(okpTime)) * okp4Speed
        } else if elapsed < okp4 * 4.0 + Double(okpTime) {
            currentSpeed = -(okp4 * 4.0 - elapsed + Double(okpTime)) * okp4Speed
        } else {
            currentSpeed = 0
            if UIApplication.shared.isIdleTimerDisabled == true{
                UIApplication.shared.isIdleTimerDisabled = false//スリープする
            }
        }
        
        var x = lastx + CGFloat(currentSpeed * dTime)
        
        //if (x>x0) {
        while x>x0 {
            x -= x0
        }
        //if (x < 0) {
        while x<0 {
            x += x0
        }
        
        for i in 0..<6 {
            drawBand(rectB:CGRect(x:CGFloat(i-1)*x0+x,y:0,width:ww/10,height:wh))
        }
        lastx=x
//        drawWhiteBand(rectB: CGRect(x:0,y:0,width:leftPadding,height: view.bounds.height))
//        self.view.bringSubviewToFront(recClarification)
        drawSCircle(dummyImage)
    }

}
