//
//  ETTsViewController.swift
//  Fushiki
//
//  Created by Fushiki tatsuaki on 2018/08/05.
//  Copyright © 2018年 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import AVFoundation
class ETTsViewController: UIViewController {
    var ettWidth:Int = 0//1:narrow,2:wide
    var oknSpeed:Int = 0
    var oknDirection:Int = 0
    var targetMode:Int = 0
    var cirDia:CGFloat = 0
    var timer: Timer!
 //   var timer1Interval:Int = 2
    var epTim = Array<Int>()
    var tcount: Int = 0
    var startTime=CFAbsoluteTimeGetCurrent()
 //   @IBOutlet var doubleRec:UITapGestureRecognizer!
 //   @IBOutlet var singleRec:UITapGestureRecognizer!

    @IBOutlet weak var cameraView: UIImageView!
 //   @IBAction func tapGes(_ sender: UITapGestureRecognizer) {
 //   }
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
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if timer?.isValid == true {
            timer.invalidate()
        }
        displayLink?.invalidate()
//        if timer2?.isValid == true {
//            timer2.invalidate()
//        }
    }
//    var timer: Timer!
//    var timer2: Timer!
    var tcnt:Int = 0
    var tcnt2:Int = 0
    

    
    @IBOutlet weak var timerCnt: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        epTim.append(10)
        epTim.append(100)
        epTim.append(110)
        epTim.append(115)
        epTim.append(138)
        epTim.append(148)
        print("ETTsView")
        setBackcolor(color:UIColor.black.cgColor)
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        tapInterval=CFAbsoluteTimeGetCurrent()-1
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
//    @IBAction func tapGes(_ sender: UITapGestureRecognizer) {
//        print("singletap")
//    }
    var displayLink:CADisplayLink?
    @objc func update(tm: Timer) {
        tcnt += 1
        cirDia=view.bounds.width/26
        //let cirDia=view.bounds.width/26
        timerCnt.text = "\(tcnt)"
        
        if tcnt == epTim[0]{
            drawCircle(cPoint: CGPoint(x:view.bounds.width/2,y:view.bounds.height/2), cirDiameter: cirDia, color1: UIColor.red.cgColor , color2:UIColor.red.cgColor)
        }
        if tcnt == epTim[0]+1{
            view.layer.sublayers?.removeLast()
        }
        if tcnt == epTim[1]{
            setBackcolor(color:UIColor.white.cgColor)
            drawCircle(cPoint: CGPoint(x:view.bounds.width/2,y:view.bounds.height/2), cirDiameter: cirDia, color1: UIColor.black.cgColor , color2:UIColor.black.cgColor)
        }
        if tcnt == epTim[2]{
            setBackcolor(color:UIColor.black.cgColor)
        }
        
        if tcnt == epTim[3]{
            setBackcolor(color:UIColor.white.cgColor)
            startTime=CFAbsoluteTimeGetCurrent()
            displayLink = CADisplayLink(target: self, selector: #selector(self.update2))   //#selector部分については後述
            displayLink!.preferredFramesPerSecond = 120  // FPS設定  //この場合は1秒間に20回
            displayLink!.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
//            timer2 = Timer.scheduledTimer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.update2), userInfo: nil, repeats: true)
        }
        if tcnt == epTim[4]{
            setBackcolor(color:UIColor.black.cgColor)
            displayLink?.invalidate()
//            if timer2.isValid==true{
//                timer2.invalidate()
//            }
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
        displayLink!.invalidate()
//        if timer2?.isValid == true {
//            timer2.invalidate()
//        }
    }
    func setBackcolor(color c:CGColor){
        let boximage  = makeBox(width: self.view.bounds.width, height:self.view.bounds.height,color:c)
        cameraView.image=boximage
    }
    func makeBox(width w:CGFloat,height h:CGFloat,color c:CGColor) -> UIImage{
        let size = CGSize(width:w, height:h)
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        let drawRect = CGRect(x:0, y:0, width:w, height:h)
        let drawPath = UIBezierPath(rect:drawRect)
        context?.setFillColor(c)
        drawPath.fill()
        context?.setStrokeColor(c)
        drawPath.stroke()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
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
        let elapset=CFAbsoluteTimeGetCurrent()-startTime
        if tcnt2 == 1 {
            setBackcolor(color:UIColor.white.cgColor)
        }
        if elapset < 7/0.3{
            let ettWidth=view.bounds.width/2 - view.bounds.width/18
            //let ettSpeed:CGFloat = 0.3
            //3.1415*5 -> 100回で１周、100回ps
            
            let sinV=sin(CGFloat(elapset)*3.1415*0.6)
            var cPoint:CGPoint
            cPoint = CGPoint(x:view.bounds.width/2 + sinV*ettWidth, y: view.bounds.height/2)
            view.layer.sublayers?.removeLast()
            
            drawCircle(cPoint:cPoint,cirDiameter: cirDia,color1: UIColor.black.cgColor,color2:UIColor.black.cgColor)
        }
    }
}
