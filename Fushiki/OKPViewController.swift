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
    var ettWidth:Int = 0//1:narrow,2:wide
    var oknSpeed:Int = 2
    var oknDirection:Int = 0
    var targetMode:Int = 0
    var cirDiameter:CGFloat = 0
    var timer: Timer!
    var timer1Interval:Int = 2//未使用？
//    var ettWidth:Int = 0//1:narrow,2:wide
    var ettW:CGFloat = 0
    var lastrand:Int=0
    var tcount: Int = 0
    var tapInterval=CFAbsoluteTimeGetCurrent()
    @IBAction func doubleTap(_ sender: Any) {
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        mainView.ettWidth=ettWidth
        mainView.oknSpeed=oknSpeed
        mainView.oknDirection=oknDirection
        mainView.targetMode=targetMode
//        displayLink.invalidate()
        if timer?.isValid == true {
              timer.invalidate()
          }
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
                    //self.dismiss(animated: true, completion: nil)
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
            default:
                print("Others")
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        cirDiameter=view.bounds.width/26
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        tcount=0
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        tapInterval=CFAbsoluteTimeGetCurrent()-1
        self.setNeedsStatusBarAppearanceUpdate()
         prefersHomeIndicatorAutoHidden()
        }
        
        override func prefersHomeIndicatorAutoHidden() -> Bool {
            return true
        }

    override var prefersStatusBarHidden: Bool {
        return true
    }
    @objc func update(tm: Timer) {
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
        let cPoint:CGPoint = CGPoint(x:x0 + CGFloat(xn)*x0*9/10, y: y0 + CGFloat(yn)*y0*5.0/6.0)
        drawCircle(cPoint:cPoint)
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
}
