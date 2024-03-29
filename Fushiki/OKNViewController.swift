//
//  OKNrotateViewController.swift
//  Fushiki
//
//  Created by Fushiki tatsuaki on 2018/08/27.
//  Copyright © 2018年 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import CoreMotion
import Photos
import AVFoundation
class OKNViewController: UIViewController{
    let camera = myFunctions()//name:"Fushiki")
    var cameraON:Bool=false

    //    var mainBrightness:CGFloat!
    var startTime=CFAbsoluteTimeGetCurrent()
    var lastTime=CFAbsoluteTimeGetCurrent()
    var cnt:Int = 0
    var oknSpeed:Int = 2
    var speed:Int=0
    var oknTime:Int = 0
    var oknMode:Int=0
    var targetMode:Int=0
    var ww:CGFloat=0
    var wh:CGFloat=0
    var displayLink:CADisplayLink?
    var displayLinkF:Bool=false
    var timerREC:Timer?
    var leftPadding:CGFloat=0
    
    @IBOutlet weak var dummyImage: UIImageView!
    @IBOutlet weak var speedLabel: UILabel!
    //    @IBOutlet weak var timerPara: UILabel!
    var startX:CGFloat?
    var startSpeed:Int?
    @IBAction func panGes(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            speedLabel.isHidden=false
            startSpeed=oknSpeed
            startX=sender.location(in:self.view).x//sender.location(in: self.view)
        }else if sender.state == .changed {
            oknSpeed = startSpeed! + Int(sender.location(in:self.view).x - startX!)/20
            
            if oknSpeed<1{
                oknSpeed=1
            }else if oknSpeed>200{
                oknSpeed=200
            }
            speedLabel.text="SPEED:" + String(Int(oknSpeed*15)) + "pt/sec" + "  ScreenWidth(" + String(Int(view.bounds.width)) + "pt)"
            speed=15*oknSpeed
        }else if sender.state == .ended{
            UserDefaults.standard.set(oknSpeed, forKey:"oknSpeed")
            speedLabel.isHidden=true
        }
    }
   

    @IBOutlet var singleRec: UITapGestureRecognizer!
    func changeDirection(dir:Int){
        oknMode = UserDefaults.standard.integer(forKey:"oknMode")
        if dir==1{
            if (oknMode == 0) || (oknMode == 2){
                oknMode += 1
            }
        }else{
            if oknMode==1 || oknMode==3{
                oknMode -= 1
            }
        }
        UserDefaults.standard.set(oknMode, forKey:"oknMode")
    }
    @IBAction func singleTap(_ sender: UITapGestureRecognizer) {
//        let x=sender.location(in: self.view).x
//        if x<view.bounds.width/6{
//            oknSpeed -= 1
//            if(oknSpeed<1){
//                oknSpeed=1
//            }
//            speed=15*oknSpeed
//            UserDefaults.standard.set(oknSpeed, forKey: "oknSpeed")
//        }else if x>view.bounds.width*5/6{
//            oknSpeed += 1
//            if(oknSpeed>200){
//                oknSpeed=200
//            }
//            speed=15*oknSpeed
//            UserDefaults.standard.set(oknSpeed, forKey: "oknSpeed")
//        }else if x>view.bounds.width/2{
        if sender.location(in: self.view).x>view.bounds.width/2{
            changeDirection(dir:0)
        }else{
            changeDirection(dir:1)
        }
    }
    @IBOutlet var doubleRec: UITapGestureRecognizer!
    //    @IBOutlet var doubleRec:UITapGestureRecognizer!
    var tapInterval=CFAbsoluteTimeGetCurrent()
//    func exit4OKN(){
//        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
//        mainView.targetMode=targetMode
////        UIScreen.main.brightness=mainBrightness!
//        delTimer()
//        camera.recordStop()//fileOutput.stopRecording()
//        performSegue(withIdentifier: "fromOKN", sender: self)
//    }
    func delTimer(){
        if displayLinkF==true{
            displayLink?.invalidate()
        }
        if timerREC?.isValid == true {
            timerREC!.invalidate()
        }
    }
    
    @IBAction func doubleTap(_ sender: Any) {
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        mainView.targetMode=targetMode
//        UIScreen.main.brightness=mainBrightness!
        delTimer()
        camera.recordStop()//fileOutput.stopRecording()
        performSegue(withIdentifier: "fromOKN", sender: self)
    }

    
    override func remoteControlReceived(with event: UIEvent?) {
        guard event?.type == .remoteControl else { return }
        
        if let event = event {
            
            switch event.subtype {
            case .remoteControlPlay:
                print("Play")
                if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                    doubleTap(0)// exit4OKN()
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            case .remoteControlTogglePlayPause:
//                print("TogglePlayPause")
//                changeDirection()
//                singleTap(0)//change direction
                if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                    doubleTap(0)// exit4OKN()
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            case .remoteControlNextTrack:
                oknMode = UserDefaults.standard.integer(forKey:"oknMode")
                if oknMode==1 || oknMode==3{
                    oknMode -= 1
                }
                UserDefaults.standard.set(oknMode, forKey:"oknMode")
            case .remoteControlPreviousTrack:
                oknMode = UserDefaults.standard.integer(forKey:"oknMode")
                if oknMode==0 || oknMode==2{
                    oknMode += 1
                }
                UserDefaults.standard.set(oknMode, forKey:"oknMode")
//            case .remoteControlNextTrack:
//                oknSpeed += 1
//                if(oknSpeed>200){
//                    oknSpeed=200
//                }
//                speed=15*oknSpeed
//                UserDefaults.standard.set(oknSpeed, forKey: "oknSpeed")
//            case .remoteControlPreviousTrack:
//                //stopTimer()
//                oknSpeed -= 1
//                if(oknSpeed<1){
//                    oknSpeed=1
//                }
//                speed=15*oknSpeed
//                UserDefaults.standard.set(oknSpeed, forKey: "oknSpeed")
//            //                setTimer()
            default:
                print("Others")
            }
        }
    }
    
    func stopTimer(){
        if displayLinkF==true{
            displayLink?.invalidate()
        }
        cnt=0
    }

    func setTimer(){
        startTime=CFAbsoluteTimeGetCurrent()
        ww=view.bounds.width
        wh=view.bounds.height
        displayLink = CADisplayLink(target: self, selector: #selector(self.update))
        displayLink!.preferredFramesPerSecond = 120
        displayLink?.add(to: RunLoop.main, forMode: .common)
//        displayLink!.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        displayLinkF=true
        cnt=0
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
//    @available(iOS 11, *)
//    override var prefersHomeIndicatorAutoHidden: Bool {
//        get {
//            return true
//        }
//    }
    
    var lastx:CGFloat=0
    var currentSpeed:Double = 0
    var initf:Bool=false
    @objc func update() {
//        cnt += 1
        
        let x0=ww/5
        if initf {
            for _ in 0..<7{
                view.layer.sublayers?.removeLast()
            }
        }
        initf=true
        let currentTime=CFAbsoluteTimeGetCurrent()
        let dTime = currentTime - lastTime
        lastTime = currentTime
        if currentTime - startTime>300{
            if UIApplication.shared.isIdleTimerDisabled == true{
                UIApplication.shared.isIdleTimerDisabled = false//スリープする
            }
        }
        if oknMode<2 && Int(currentTime - startTime)>oknTime+5{
            doubleTap(0)
        }
        if oknMode<2 && Int(currentTime - startTime)>oknTime{
            //stopTimer()
            drawBand(rectB:CGRect(x:0,y:0,width:ww,height:wh))
//            doubleTap(0)
//            exit4OKN()
//            return
        }
        
        if oknMode == 0 || oknMode == 2{
            currentSpeed = Double(speed)
        }else{
            currentSpeed = -Double(speed)
        }
//        if cnt%10 == 0 {
//            //            print("dx:",currentSpeed*dTime,oknSpeed ,oknTime,oknMode)//okpSpeed, "cuSpe:",currentSpeed)
//            //            print("dt:",dTime)//okpSpeed, "cuSpe:",currentSpeed)
//            print(String(format: "dtime: %.5f %",dTime))
//        }
        
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
            drawBand(rectB:CGRect(x:CGFloat(i-1)*x0+x,y:0,width:bandWidth,height:wh))
        }
        lastx=x
//        if left==0{
//            drawWhiteBand(rectB: CGRect(x:0,y:0,width:leftPadding,height: view.bounds.height))
//        }
//        view.bringSubviewToFront(leftWhiteImage)
        drawSCircle(dummyImage)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
//    var cntREC:Int=0
    @objc func updateRecStart(tm: Timer) {
//        cntREC += 1
//        recClarification.alpha=camera.updateRecClarification(tm: cntREC)
 //       if cntREC==20{
            camera.recordStart()//ここだと暗くならない
 //       }
    }
    var bandWidth:CGFloat=0
    var bandWidthStart:CGFloat=0
    @IBAction func onPinchGesture(_ sender: UIPinchGestureRecognizer) {
        if(sender.state == UIGestureRecognizer.State.began){
            //ピンチ開始時のアフィン変換をクラス変数に保持する。
            bandWidth = CGFloat(camera.getUserDefaultFloat(str: "bandWidth", ret: Float(view.bounds.width/10)))
            bandWidthStart=bandWidth
            speedLabel.isHidden=false
        }else if sender.state == .changed{
            let maxW=view.bounds.width/5
            if sender.scale>1{
                var temp=bandWidthStart+10*sender.scale
                if temp>maxW-1{
                    temp=maxW-1
                }
                bandWidth=temp
            }else{
                var temp=bandWidthStart-10/sender.scale
                if temp<1{
                    temp=1
                }
                bandWidth=temp
            }
            speedLabel.text="bandWidth:" + String(Int(bandWidth)) + "/" + String(Int(view.bounds.width/5))
            UserDefaults.standard.set(bandWidth, forKey:"bandWidth")
        }else if sender.state == .ended{
            speedLabel.isHidden=true
        }
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
    override func viewDidLoad() {
        super.viewDidLoad()
        cameraON=UserDefaults.standard.bool(forKey: "cameraON")
//        mainBrightness = UIScreen.main.brightness
//        UIScreen.main.brightness=CGFloat(camera.getUserDefaultFloat(str: "screenBrightness",ret:1.0))
//        UIScreen.main.brightness = CGFloat(camera.getUserDefaultFloat(str: "screenBrightness", ret:0.5))
        camera.makeAlbum()
//        camera.initSession(camera: 0, bounds:CGRect(x:0,y:0,width:0,height: 0), cameraView: recClarification)
//
        bandWidth = CGFloat(camera.getUserDefaultFloat(str: "bandWidth", ret: Float(view.bounds.width/10)))
        let cameraType = camera.getUserDefaultInt(str: "cameraType", ret: 0)
        camera.initSession(camera: Int(cameraType),dummyImage)
//        if cameraType == 2{
//            recClarification.isHidden=true
//        }
//        let zoomValue=camera.getUserDefaultFloat(str: "zoomValue", ret:0)
//        if cameraType==0{
//        camera.setZoom(level:0.03)// zoomValue)0.0-0.1
//        }else{
//            camera.setZoom(level: 0)
//        }
//        let focusValue=camera.getUserDefaultFloat(str: "focusValue", ret: 0)
//        camera.setFocus(focus: 0)//focusValue)
//        camera.setLedLevel(camera.getUserDefaultFloat(str: "ledValue", ret:0))
//        camera.setLedLevel(level:0.1)//camera.getUserDefaultFloat(str: "ledValue", ret:0))

//        camera.initSession(fps: 120)
        leftPadding=CGFloat(UserDefaults.standard.float(forKey: "left")) + view.bounds.width/10

        camera.setZoom(level:camera.getUserDefaultFloat(str: "zoomValue", ret: 0.01))
        camera.setFocus(focus: camera.getUserDefaultFloat(str: "focusValue", ret: 0))
        if cameraType != 0{
            camera.setLedLevel(camera.getUserDefaultFloat(str: "ledValue", ret:0))
        }
        //       timerPara.isHidden=true
        oknSpeed = UserDefaults.standard.integer(forKey:"oknSpeed")
        oknTime = UserDefaults.standard.integer(forKey:"oknTime")
        print("oknTime:",oknTime)
        oknMode = UserDefaults.standard.integer(forKey:"oknMode")
        print("oknSpeed,time,mode:",oknSpeed,oknTime,oknMode)
        speed = oknSpeed*15
        speedLabel.isHidden=true
      //  singleRec.require(toFail: doubleRec)
        
        dummyImage.frame=camera.getRecClarificationRct(view.bounds.width,view.bounds.height)
        if cameraON{
            timerREC = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateRecStart), userInfo: nil, repeats: false)
        }
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        tapInterval=CFAbsoluteTimeGetCurrent()-1
        self.setNeedsStatusBarAppearanceUpdate()
//         prefersHomeIndicatorAutoHidden()
//        let leftPadding=UserDefaults.standard.float(forKey: "left")
    
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
  
//    override func prefersHomeIndicatorAutoHidden() -> Bool {
//        return true
//    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        setTimer()
    }

}


