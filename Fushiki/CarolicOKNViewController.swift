//
//  CarolicOKNViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2019/05/10.
//  Copyright © 2019 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
class CarolicOKNViewController: UIViewController{
    let camera = CameraAlbumEtc(name:"Fushiki")
    var oknSpeed:Int = 0
    var oknMode:Int=0
    var targetMode:Int = 0
    var cirDia:CGFloat = 0
    var timer: Timer!
    var tierREC:Timer?
    var timer1Interval:Int = 2
    var startTime=CFAbsoluteTimeGetCurrent()
     var lastTime=CFAbsoluteTimeGetCurrent()

    @IBOutlet weak var recClarification: UIImageView!
    //    var tcount: Int = 0
    var displayLink:CADisplayLink?
    var displayLinkF:Bool=false

    var tcnt:Int = 0
    var epTim = Array<Int>()
    var tapInterval=CFAbsoluteTimeGetCurrent()
    func stopDisplaylink(){
          if displayLinkF==true{
              displayLink?.invalidate()
              displayLinkF=false
          }
      }
    @IBAction func doubleTap(_ sender: Any) {
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        mainView.targetMode=targetMode
        delTimer()
        camera.recordStop()
        performSegue(withIdentifier: "fromCarolicOKN", sender: self)
    }
    
    func delTimer(){
        if timer?.isValid == true {
            timer.invalidate()
        }
        stopDisplaylink()
        if tierREC?.isValid == true {
            tierREC!.invalidate()
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
//                    self.dismiss(animated: true, completion: nil)
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            case .remoteControlTogglePlayPause:
                print("TogglePlayPause")
                if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                    print("doubleTap")
                    doubleTap(0)
  //                 self.dismiss(animated: true, completion: nil)
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            default:
                print("Others")
            }
        }
    }
    
    @IBAction func panRecognizer(_ sender:
        UIPanGestureRecognizer) {
        if sender.state == .ended{
            let move = sender.translation(in: self.view)
            if (move.x < -150 || move.x > 150)
            {
                if tcnt < epTim[0] {
                    tcnt = epTim[0]-1
                }else if tcnt < epTim[1]{
                    if tcnt > epTim[0]+1{
                        tcnt = epTim[1]-1
                    }
                }else if tcnt < epTim[2]{
                    tcnt = epTim[2]-1
                }else if tcnt < epTim[3]{
                    tcnt = epTim[3]-1
                }else if tcnt < epTim[4]{
                    tcnt = epTim[4]-1
                }else if tcnt < epTim[5]{
                    tcnt = epTim[5]-1
                }
            }
        }
    }

    var ww:CGFloat=0
    var wh:CGFloat=0
    var bandB=CAShapeLayer()
    var bandW=CAShapeLayer()
    func drawBand(rectB: CGRect) {
        let rectLayer = CAShapeLayer.init()
        rectLayer.strokeColor = UIColor.black.cgColor
        rectLayer.fillColor = UIColor.black.cgColor
        rectLayer.lineWidth = 0
        rectLayer.path = UIBezierPath(rect:rectB).cgPath
        self.view.layer.addSublayer(rectLayer)
    }
    private func drawWrect() {
        let rectLayer = CAShapeLayer.init()
        let rect1 = CGRect(x:0,y:0,width:view.bounds.width,height:view.bounds.height)
        rectLayer.strokeColor = UIColor.black.cgColor
        rectLayer.fillColor = UIColor.white.cgColor
        rectLayer.lineWidth = 0
        rectLayer.path = UIBezierPath(rect:rect1).cgPath
        self.view.layer.addSublayer(rectLayer)
    }
    func drawBrect() {
        let rectLayer = CAShapeLayer.init()
        let rect1 = CGRect(x:0,y:0,width:view.bounds.width,height:view.bounds.height)
        rectLayer.strokeColor = UIColor.black.cgColor
        rectLayer.fillColor = UIColor.black.cgColor
        rectLayer.lineWidth = 0
        rectLayer.path = UIBezierPath(rect:rect1).cgPath
        self.view.layer.addSublayer(rectLayer)
    }
//    func drawW(rectB:CGRect) {
//        bandW.path = UIBezierPath(rect:rectB).cgPath
//        self.view.layer.addSublayer(bandW)
//    }
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        ww=view.bounds.width
        wh=view.bounds.height
        coordinator.animate(
            alongsideTransition: nil,
            completion: {(UIViewControllerTransitionCoordinatorContext) in
                self.ww=self.view.bounds.width
                self.wh=self.view.bounds.height
        }
        )
    }
//    func setBackcolor(color c:CGColor){
//         let boximage  = makeBox(width: self.view.bounds.width, height:self.view.bounds.height,color:c)
//         cameraView.image=boximage
//     }
    var cntREC:Int=0
    @objc func updateRecClarification(tm: Timer) {
        cntREC += 1
        recClarification.alpha=camera.updateRecClarification(tm: cntREC)
        if cntREC==5{
            camera.recordStart()//ここだと暗くならない
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        camera.makeAlbum()
//        camera.initSession(camera: 0, bounds:CGRect(x:0,y:0,width:0,height: 0), cameraView: recClarification)
        
        let cameraMode = camera.getUserDefault(str: "cameraMode", ret: 0)
        camera.initSession(camera: Int(cameraMode), bounds:CGRect(x:0,y:0,width:0,height: 0), cameraView: recClarification)
      
        let zoomValue=camera.getUserDefault(str: "zoomValue", ret:0)
        camera.setZoom(level: zoomValue)
        let focusValue=camera.getUserDefault(str: "focusValue", ret: 0)
        camera.setFocus(focus: focusValue)
        
        

        ww=view.bounds.width
        wh=view.bounds.height
        oknSpeed = UserDefaults.standard.integer(forKey:"oknSpeed")
        oknMode = UserDefaults.standard.integer(forKey:"oknMode")
        epTim.append(10)
        epTim.append(100)
        epTim.append(110)
        epTim.append(115)
        epTim.append(130)
        epTim.append(135)
        bandB.strokeColor = UIColor.black.cgColor
        bandB.fillColor = UIColor.black.cgColor
        bandB.lineWidth = 0
        bandW.strokeColor = UIColor.black.cgColor
        bandW.fillColor = UIColor.black.cgColor
        bandW.lineWidth = 0
        startTime=CFAbsoluteTimeGetCurrent()
        
        print("carolicOKN")
        drawBrect()
//        setBackcolor(color:UIColor.black.cgColor)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        tierREC = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.updateRecClarification), userInfo: nil, repeats: true)
        recClarification.frame=camera.getRecClarificationRct(width: view.bounds.width, height: view.bounds.height)

        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
        // Do any additional setup after loading the view.
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        tapInterval=CFAbsoluteTimeGetCurrent()-1
        self.setNeedsStatusBarAppearanceUpdate()
//        prefersHomeIndicatorAutoHidden()
//        camera.sessionRecStart(fps:30)
        view.bringSubviewToFront(recClarification)
    }
    
//    override func prefersHomeIndicatorAutoHidden() -> Bool {
//        return true
//    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }

    @objc func update() {
        tcnt += 1
        cirDia=view.bounds.width/25.0
//        timerCnt.text = "\(tcnt)"
//        ww=view.bounds.width
//        wh=view.bounds.height

        if tcnt == epTim[0]{
            drawCircle(cPoint: CGPoint(x:view.bounds.width/2,y:view.bounds.height/2), cirDiameter: cirDia, color1: UIColor.red.cgColor , color2:UIColor.red.cgColor)
        }
        if tcnt == epTim[0]+1{
            view.layer.sublayers?.removeLast()
            view.bringSubviewToFront(recClarification)
        }
        if tcnt == epTim[1]{
            drawWrect()
               //setBackcolor(color:UIColor.white.cgColor)
            drawCircle(cPoint: CGPoint(x:view.bounds.width/2,y:view.bounds.height/2), cirDiameter: cirDia, color1: UIColor.black.cgColor , color2:UIColor.black.cgColor)
            view.bringSubviewToFront(recClarification)
        }
        if tcnt == epTim[2]{
            drawBrect()
            //setBackcolor(color:UIColor.black.cgColor)
        }
//        timerCnt.text = "\(tcnt)"
        if tcnt == epTim[3]{
            drawWrect()
            //setBackcolor(color:UIColor.white.cgColor)
            displayLink = CADisplayLink(target: self, selector: #selector(self.update2))
            displayLink!.preferredFramesPerSecond = 120
            displayLink?.add(to: RunLoop.main, forMode: .common)
//            displayLink!.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
            displayLinkF=true
        }
        if tcnt == epTim[4]{
            stopDisplaylink()
            drawBrect()
        }
        if tcnt == epTim[5]{
            if UIApplication.shared.isIdleTimerDisabled == true{
                UIApplication.shared.isIdleTimerDisabled = false//監視する
            }
            delTimer()
            self.dismiss(animated: true, completion: nil)
        }
    }
    func drawCircle(cPoint:CGPoint,cirDiameter:CGFloat,color1:CGColor,color2:CGColor){
        /* --- 円を描画 --- */
        let circleLayer = CAShapeLayer.init()
        let circleFrame = CGRect.init(x:cPoint.x-cirDiameter/2,y:cPoint.y-cirDiameter/2,width:cirDiameter,height:cirDiameter)
        circleLayer.frame = circleFrame
        // 輪郭の色
        circleLayer.strokeColor = color1//UIColor.white.cgColor
        // 円の中の色
        circleLayer.fillColor = color2//UIColor.red.cgColor
        // 輪郭の太さ
        circleLayer.lineWidth = 0.5
        // 円形を描画
        circleLayer.path = UIBezierPath.init(ovalIn: CGRect.init(x: 0, y: 0, width: circleFrame.size.width, height: circleFrame.size.height)).cgPath
        self.view.layer.addSublayer(circleLayer)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopDisplaylink()
    }
 
    var lastx:CGFloat=0
     var currentSpeed:Double = 0
     var initf:Bool=false
     @objc func update2() {
//         tcnt2 += 1
         let x0=ww/5
         if initf {
             for _ in 0..<6{
                 view.layer.sublayers?.removeLast()
             }
         }
         initf=true
         let currentTime=CFAbsoluteTimeGetCurrent()
         let dTime = currentTime - lastTime
         lastTime = currentTime

         if oknMode == 0 || oknMode == 2{
             currentSpeed = Double(oknSpeed*15)
         }else{
             currentSpeed = -Double(oknSpeed*15)
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
     }
//    view.bringSubview(toFront: recClarification)
}
