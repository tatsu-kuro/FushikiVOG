//
//  CarolicOKNViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2019/05/10.
//  Copyright © 2019 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import AVFoundation
class CarolicOKNViewController: UIViewController {
    var ettWidth:Int = 0//1:narrow,2:wide
    var oknSpeed:Int = 0
    var oknDirection:Int = 0
    var targetMode:Int = 0
    var cirDia:CGFloat = 0
    var timer1: Timer!
    var timer1Interval:Int = 2
    var startTime=CFAbsoluteTimeGetCurrent()
    var tcount: Int = 0
    //    var timer: Timer!
    var timer2: Timer!
    var tcnt:Int = 0
    var tcnt2:Int = 0
    var epTim = Array<Int>()
    @IBOutlet weak var timerCnt: UILabel!
    var tapInterval=CFAbsoluteTimeGetCurrent()
    
    @IBAction func doubleTap(_ sender: Any) {
        let mainView = storyboard?.instantiateViewController(withIdentifier: "mainView") as! ViewController
        mainView.ettWidth=ettWidth
        mainView.oknSpeed=oknSpeed
        mainView.oknDirection=oknDirection
        mainView.targetMode=targetMode
        delTimer()
        self.present(mainView, animated: false, completion: nil)
    }
    
    func delTimer(){
         if timer1?.isValid == true {
             timer1.invalidate()
         }
         if timer2?.isValid==true{
             timer2.invalidate()
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

//    @IBOutlet weak var timerCnt: UILabel!
    /*    func setBackcolor(color c:CGColor){
        let boximage  = makeBox(width: self.view.bounds.width, height:self.view.bounds.height,color:c)
        cameraView.image=boximage
    }*/
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
    override func viewDidLoad() {
        super.viewDidLoad()
        ww=view.bounds.width
        wh=view.bounds.height
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
        drawBrect()
        timer1 = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
        // Do any additional setup after loading the view.
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        tapInterval=CFAbsoluteTimeGetCurrent()-1
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @objc func update(tm: Timer) {
        tcnt += 1
        cirDia=view.bounds.width/25.0
        timerCnt.text = "\(tcnt)"
        ww=view.bounds.width
        wh=view.bounds.height

        if tcnt == epTim[0]{
            drawCircle(cPoint: CGPoint(x:view.bounds.width/2,y:view.bounds.height/2), cirDiameter: cirDia, color1: UIColor.red.cgColor , color2:UIColor.red.cgColor)
        }
        if tcnt == epTim[0]+1{
            view.layer.sublayers?.removeLast()
        }
        if tcnt == epTim[1]{
            drawWrect()
               //setBackcolor(color:UIColor.white.cgColor)
            drawCircle(cPoint: CGPoint(x:view.bounds.width/2,y:view.bounds.height/2), cirDiameter: cirDia, color1: UIColor.black.cgColor , color2:UIColor.black.cgColor)
        }
        if tcnt == epTim[2]{
            drawBrect()
            //setBackcolor(color:UIColor.black.cgColor)
        }
        timerCnt.text = "\(tcnt)"
        if tcnt == epTim[3]{
            drawWrect()
            //setBackcolor(color:UIColor.white.cgColor)
            timer2 = Timer.scheduledTimer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.update2), userInfo: nil, repeats: true)
        }
        if tcnt == epTim[4]{
            if timer2.isValid==true{
                timer2.invalidate()
            }
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
    //    view.layer.sublayers?.removeAll()
   //     if timer?.isValid == true {
     //       timer.invalidate()
       // }
        if timer2?.isValid == true {
            timer2.invalidate()
        }
    }
    var initf:Bool=false
    @objc func update2(tm: Timer) {
        tcnt2 += 1
        if initf {
            for _ in 0..<6{
                view.layer.sublayers?.removeLast()
            }
        }
        initf=true
        let elapset=CFAbsoluteTimeGetCurrent()-startTime
        var xd=ww*CGFloat(elapset)/3.2
        let x0=ww/5.0
        while xd>0 {
            xd -= ww/5
        }
        for i in 0..<6 {
            drawBand(rectB:CGRect(x:CGFloat(i)*x0+xd,y:0,width:ww/10,height:wh))
        }
    }
}
