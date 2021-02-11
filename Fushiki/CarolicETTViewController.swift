//
//  ETTsViewController.swift
//  Fushiki
//
//  Created by Fushiki tatsuaki on 2018/08/05.
//  Copyright © 2018年 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
class CarolicETTViewController: UIViewController{
    let camera = CameraAlbumEtc(name:"Fushiki")
    var ettWidth:Int = 0//1:narrow,2:wide
    var targetMode:Int = 0
    var cirDia:CGFloat = 0
    var timer: Timer!
    var timerREC: Timer?
    var epTim = Array<Int>()
    var tcount: Int = 0
    var startTime=CFAbsoluteTimeGetCurrent()
    @IBOutlet weak var recClarification: UIImageView!
    
    var tapInterval=CFAbsoluteTimeGetCurrent()
    
    @IBAction func doubleTap(_ sender: Any) {
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        mainView.targetMode=targetMode
        delTimer()
        camera.recordStop() //fileOutput.stopRecording()
//        self.present(mainView, animated: false, completion: nil)
        performSegue(withIdentifier: "fromCarolicETT", sender: self)
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
                    print("doubleTapTogglePlayPause")
                    doubleTap(0)
                    //                    self.dismiss(animated: true, completion: nil)
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            default:
                print("Others")
            }
        }
    }
    @IBAction func panRecognizer(_ sender: UIPanGestureRecognizer) {
        
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
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func appOrientation() -> UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
    
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        
    }
    func stopDisplaylink(){
        if displayLinkF==true{
            displayLink?.invalidate()
            displayLinkF=false
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if timer?.isValid == true {
            timer.invalidate()
        }
        if timerREC?.isValid == true{
            timerREC!.invalidate()
        }
        stopDisplaylink()
    }
    
    var tcnt:Int = 0
    var tcnt2:Int = 0
    
    //    @IBOutlet weak var timerCnt: UILabel!
    func drawBrect() {
        let rectLayer = CAShapeLayer.init()
        let rect1 = CGRect(x:0,y:0,width:view.bounds.width,height:view.bounds.height)
        rectLayer.strokeColor = UIColor.black.cgColor
        rectLayer.fillColor = UIColor.black.cgColor
        rectLayer.lineWidth = 0
        rectLayer.path = UIBezierPath(rect:rect1).cgPath
        self.view.layer.addSublayer(rectLayer)
    }
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
//        
        
        let cameraMode = camera.getUserDefault(str: "cameraMode", ret: 0)
        camera.initSession(camera: Int(cameraMode), bounds:CGRect(x:0,y:0,width:0,height: 0), cameraView: recClarification)
      
        let zoomValue=camera.getUserDefault(str: "zoomValue", ret:0)
        camera.setZoom(level: zoomValue)
        let focusValue=camera.getUserDefault(str: "focusValue", ret: 0)
        camera.setFocus(focus: focusValue)
        
        
        
        
        epTim.append(10)
        epTim.append(100)
        epTim.append(110)
        epTim.append(115)
        epTim.append(138)
        epTim.append(148)
        ettWidth = UserDefaults.standard.integer(forKey:"ettWidth")
        //        print("ETTsView/carolicETT")//carolicETT
        drawBrect()
//        setBackcolor(color:UIColor.black.cgColor)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        
        timerREC = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.updateRecClarification), userInfo: nil, repeats: true)
        recClarification.frame=camera.getRecClarificationRct(width: view.bounds.width, height: view.bounds.height)
        
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        tapInterval=CFAbsoluteTimeGetCurrent()-1
        self.setNeedsStatusBarAppearanceUpdate()
        view.bringSubviewToFront(recClarification)
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
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
 
    var displayLink:CADisplayLink?
    var displayLinkF:Bool = false
    @objc func update(tm: Timer) {
        tcnt += 1
        cirDia=view.bounds.width/26
        //let cirDia=view.bounds.width/26
        //        timerCnt.text = "\(tcnt)"
        
        if tcnt == epTim[0]{
            drawCircle(cPoint: CGPoint(x:view.bounds.width/2,y:view.bounds.height/2), cirDiameter: cirDia, color1: UIColor.red.cgColor , color2:UIColor.red.cgColor)
        }
        if tcnt == epTim[0]+1{
            view.layer.sublayers?.removeLast()
            view.bringSubviewToFront(recClarification)
        }
        if tcnt == epTim[1]{
            drawWrect()
            //            setBackcolor(color:UIColor.white.cgColor)
            drawCircle(cPoint: CGPoint(x:view.bounds.width/2,y:view.bounds.height/2), cirDiameter: cirDia, color1: UIColor.black.cgColor , color2:UIColor.black.cgColor)
            view.bringSubviewToFront(recClarification)
        }
        if tcnt == epTim[2]{
            drawBrect()
            //            setBackcolor(color:UIColor.black.cgColor)
//            view.bringSubview(toFront: recClarification)
        }
        
        if tcnt == epTim[3]{
            drawWrect()
            //            setBackcolor(color:UIColor.white.cgColor)
            startTime=CFAbsoluteTimeGetCurrent()
            displayLink = CADisplayLink(target: self, selector: #selector(self.update2))
            displayLink!.preferredFramesPerSecond = 120
            displayLink?.add(to: RunLoop.main, forMode: .common)
//            displayLink!.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
            displayLinkF=true
//            view.bringSubview(toFront: recClarification)
        }
        if tcnt == epTim[4]{
            //            drawBrect()
            //            setBackcolor(color:UIColor.black.cgColor)
            stopDisplaylink()
            drawBrect()
        }
        if tcnt==epTim[5]{
            if UIApplication.shared.isIdleTimerDisabled == true{
                UIApplication.shared.isIdleTimerDisabled = false//監視する
            }
            delTimer()
            self.dismiss(animated: true, completion: nil)
        }
    }
    func delTimer(){
        if timer?.isValid == true {
            timer.invalidate()
        }
        stopDisplaylink()
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
    var setBackf:Bool=true
    var setKnasf:Bool=true
    var setEndf:Bool=true
    @objc func update2() {
        tcnt2 += 1
        let ww2=view.bounds.width/2
        let elapset=CFAbsoluteTimeGetCurrent()-startTime
        if tcnt2 == 1 {
            drawWrect()
        }
        if elapset < 7/0.3{
            //            let ettWidth=view.bounds.width/2 - view.bounds.width/18
            //let ettSpeed:CGFloat = 0.3
            //3.1415*5 -> 100回で１周、100回ps
            
            let sinV=sin(CGFloat(elapset)*3.1415*0.6)
            var cPoint:CGPoint
            cPoint = CGPoint(x:ww2 + sinV*ww2*CGFloat(ettWidth)/100, y: view.bounds.height/2)
            view.layer.sublayers?.removeLast()
            
            drawCircle(cPoint:cPoint,cirDiameter: cirDia,color1: UIColor.black.cgColor,color2:UIColor.black.cgColor)
        }
    }
}
