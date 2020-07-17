//
//  SaccadeViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2019/05/10.
//  Copyright © 2019 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import AVFoundation

class OKPViewController: UIViewController {
    
       var okp4:Double=40//最高スピードに達するまでの時間
        var okpSpeed:Int=5
        var okpTime:Int=0
        var okpMode:Int=0
        
        var startTime=CFAbsoluteTimeGetCurrent()
        var lastTime=CFAbsoluteTimeGetCurrent()
    //    var timer: Timer!
        var tcnt:Int = 0
        var ww:CGFloat=0
        var wh:CGFloat=0
        var tapInterval=CFAbsoluteTimeGetCurrent()
//        @available(iOS 11, *)
//        override var prefersHomeIndicatorAutoHidden: Bool {
//            get {
//                return true
//            }
//        }
        
        @IBAction func doubleTap(_ sender: Any) {
            let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
            delTimer()
            if UIApplication.shared.isIdleTimerDisabled == true{
                      UIApplication.shared.isIdleTimerDisabled = false//スリープする
            }
            self.present(mainView, animated: false, completion: nil)
        }
        
        func delTimer(){
            displayLink?.invalidate()
    //        if timer?.isValid==true{
    //            timer.invalidate()
    //        }
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
        
        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            super.viewWillTransition(to: size, with: coordinator)
        }
        func getUserDefault(str:String,ret:Int) -> Int{//getUserDefault_one
             if (UserDefaults.standard.object(forKey: str) != nil){//keyが設定してなければretをセット
                 return UserDefaults.standard.integer(forKey:str)
             }else{
                 UserDefaults.standard.set(ret, forKey: str)
                 return ret
             }
         }
        var displayLink:CADisplayLink?
        override func viewDidLoad() {
            super.viewDidLoad()
            ww=view.bounds.width
            wh=view.bounds.height
            okpSpeed = getUserDefault(str: "okpSpeed", ret:100)
            okpTime = getUserDefault(str: "okpTime", ret: 5)
            okpMode = getUserDefault(str: "okpMode", ret: 0)
            startTime=CFAbsoluteTimeGetCurrent()
            okpSpeed *= 15
            if okpMode == 0 || okpMode == 2{
                displayLink = CADisplayLink(target: self, selector: #selector(self.update))   //#selector部分については後述
                displayLink!.preferredFramesPerSecond = 120  // FPS設定  //この場合は1秒間に20回
                displayLink!.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    //            timer = Timer.scheduledTimer(timeInterval: 1.0/120.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
            }else{
                displayLink = CADisplayLink(target: self, selector: #selector(self.update1))   //#selector部分については後述
                displayLink!.preferredFramesPerSecond = 120  // FPS設定  //この場合は1秒間に20回
                displayLink!.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
    //            let displayLink=CADisplayLink(target:self,selector: #selector(self.update1))
    //            timer = Timer.scheduledTimer(timeInterval: 1.0/120.0, target: self, selector: #selector(self.update1), userInfo: nil, repeats: true)
            }
            if UIApplication.shared.isIdleTimerDisabled == false{
                UIApplication.shared.isIdleTimerDisabled = true//スリープしない
            }
            // Do any additional setup after loading the view.
            UIApplication.shared.beginReceivingRemoteControlEvents()
            self.becomeFirstResponder()
            tapInterval=CFAbsoluteTimeGetCurrent()-1
            self.setNeedsStatusBarAppearanceUpdate()
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
        
        var initf:Bool=false
        var lastx:CGFloat=0
        //var lastxd:CGFloat=0
        var currentSpeed:Double = 0
        
        @objc func update(tm: Timer) {
            let x0=ww/5
            if initf {
                for _ in 0..<6{
                    view.layer.sublayers?.removeLast()
                }
            }
            initf=true
            let currentTime=CFAbsoluteTimeGetCurrent()
            let elapsed = currentTime - startTime
            let dTime = currentTime - lastTime
            lastTime = currentTime
            if elapsed < okp4  {
                currentSpeed = elapsed * (Double(okpSpeed) / okp4)
            } else if elapsed < okp4 * 2.0 {
                currentSpeed = (okp4 * 2.0 - elapsed) * (Double(okpSpeed) / okp4)
            } else if elapsed < okp4*2.0 + Double(okpTime){
                currentSpeed=0
                if okpMode > 1{
                    for i in 0..<6 {
                        drawBand(rectB:CGRect(x:CGFloat(i-1)*x0+lastx,y:0,width:ww/10,height:wh))
                    }
                    return
                }
            } else if elapsed < okp4 * 3.0 + Double(okpTime) {
                currentSpeed = -(elapsed - okp4 * 2.0 - Double(okpTime)) * (Double(okpSpeed) / okp4)
            } else if elapsed < okp4 * 4.0 + Double(okpTime) {
                currentSpeed = -(okp4 * 4.0 - elapsed + Double(okpTime)) * (Double(okpSpeed) / okp4)
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
            
        }
        @objc func update1(tm: Timer) {
            let x0=ww/5
            if initf {
                for _ in 0..<6{
                    view.layer.sublayers?.removeLast()
                }
            }
            initf=true
            let currentTime=CFAbsoluteTimeGetCurrent()
            let elapsed = currentTime - startTime
            let dTime = currentTime - lastTime
            lastTime = currentTime
            if elapsed < okp4 {
                currentSpeed = -elapsed * (Double(okpSpeed) / okp4)
            } else if elapsed < okp4 * 2.0 {
                currentSpeed = -(okp4 * 2.0 - elapsed) * (Double(okpSpeed) / okp4)
            } else if elapsed < okp4 * 2.0 + Double(okpTime){
                currentSpeed=0
                if okpMode > 1{
                    for i in 0..<6 {
                        drawBand(rectB:CGRect(x:CGFloat(i-1)*x0+lastx,y:0,width:ww/10,height:wh))
                    }
                    return
                }
            } else if elapsed < okp4 * 3.0 + Double(okpTime) {
                currentSpeed = (elapsed - okp4 * 2.0 - Double(okpTime)) * (Double(okpSpeed) / okp4)
            } else if elapsed < okp4 * 4.0 + Double(okpTime) {
                currentSpeed = (okp4 * 4.0 - elapsed + Double(okpTime)) * (Double(okpSpeed) / okp4)
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
        }
    
}
