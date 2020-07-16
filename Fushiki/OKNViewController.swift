//
//  OKNrotateViewController.swift
//  Fushiki
//
//  Created by Fushiki tatsuaki on 2018/08/27.
//  Copyright © 2018年 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import CoreMotion

class OKNViewController: UIViewController {
    var ettWidth:Int = 0//1:narrow,2:wide
    var oknSpeed:Int = 2
    var oknDirection:Int = 0
    var targetMode:Int = 0
    var startTime=CFAbsoluteTimeGetCurrent()
    var cnt:Int = 0
    var motionManager: CMMotionManager?
    var oknSpeedsub:Int = 3
    var oknSp:Int = 3
    var oknWidth:CGFloat = 1.0
    var panFlag:Bool = false
    var displayLink:CADisplayLink?
    var displayLinkF:Bool=false
    func stopDisplaylink(){
        if displayLinkF==true{
            displayLink?.invalidate()
            displayLinkF=false
        }
    }
    @IBOutlet weak var timerPara: UILabel!
    @IBOutlet weak var speed1Button: UIButton!
    @IBOutlet weak var speed2Button: UIButton!
    @IBOutlet weak var speed3Button: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    
    @IBOutlet var doubleRec:UITapGestureRecognizer!
    @IBOutlet var singleRec:UITapGestureRecognizer!
    var tapInterval=CFAbsoluteTimeGetCurrent()
    
    @IBAction func doubleTap(_ sender: Any) {
        stopDisplaylink()
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        mainView.ettWidth=ettWidth
        mainView.oknSpeed=oknSpeed
        mainView.oknDirection=oknDirection
        mainView.targetMode=targetMode
        self.present(mainView, animated: false, completion: nil)
    }
    
    override func remoteControlReceived(with event: UIEvent?) {
        guard event?.type == .remoteControl else { return }
        
        if let event = event {
            
            switch event.subtype {
            case .remoteControlPlay:
                print("Play")
                if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                    doubleTap(0)
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            case .remoteControlTogglePlayPause:
                print("TogglePlayPause")
                if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                    doubleTap(0)
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            case .remoteControlNextTrack:
                //                stopTimer()
                oknSpeed += 1
                if(oknSpeed>3){
                    oknSpeed=1
                }
                oknDirection=0
            //                setTimer()
            case .remoteControlPreviousTrack:
                //                stopTimer()
                oknSpeed += 1
                if(oknSpeed>3){
                    oknSpeed=1
                }
                oknDirection=1
            //                setTimer()
            default:
                print("Others")
            }
        }
    }
    func hideButtons(hide:Bool){
        rightButton.isHidden=hide
        leftButton.isHidden=hide
        speed1Button.isHidden=hide
        speed2Button.isHidden=hide
        speed3Button.isHidden=hide
    }
    
    @IBAction func tapGes(_ sender: UITapGestureRecognizer) {

                if leftButton.isHidden == true{
                    hideButtons(hide: false)
                }else{
                    hideButtons(hide: true)
                }
    }
    @IBAction func speed3Action(_ sender: Any) {
//        stopTimer()
        oknSpeed=3
//        setTimer()
    }
    @IBAction func speed2Action(_ sender: Any) {
//        stopTimer()
        oknSpeed=2
//        setTimer()
    }
    @IBAction func speed1Action(_ sender: Any) {
//        stopTimer()
        oknSpeed=1
//        setTimer()
    }
    @IBAction func rightAction(_ sender: Any) {
//        stopTimer()
        oknDirection=0
//        setTimer()
    }
    @IBAction func leftAction(_ sender: Any) {
//        stopTimer()
        oknDirection=1
//        setTimer()
    }
    
    var pitch:CGFloat=0
 
 
    func setTimer(){
        startTime=CFAbsoluteTimeGetCurrent()
        ww=view.bounds.width
        wh=view.bounds.height
        displayLink = CADisplayLink(target: self, selector: #selector(self.update))
        displayLink!.preferredFramesPerSecond = 120
        displayLink!.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        displayLinkF=true
        cnt=0
    }

    var lastMove:Int = 0
    var lastCnt:Int = 0
    var initFlag:Bool = false

    func drawBand(rectB: CGRect) {
        let rectLayer = CAShapeLayer.init()
        rectLayer.strokeColor = UIColor.black.cgColor
        rectLayer.fillColor = UIColor.black.cgColor
        rectLayer.lineWidth = 0
        rectLayer.path = UIBezierPath(rect:rectB).cgPath
        self.view.layer.addSublayer(rectLayer)
    }
    var ww:CGFloat=0
    var wh:CGFloat=0
    var initf:Bool=false
    var endF=false
    var maxtime:Double=0
    @objc func update() {
        cnt += 1
        let time0=CFAbsoluteTimeGetCurrent()
        if endF==true{
            return
        }
        if initf {
            for _ in 0..<6{
                view.layer.sublayers?.removeLast()
            }
        }
        initf=true
        let elapset=CFAbsoluteTimeGetCurrent()-startTime
        
        if(elapset>30){
            doubleTap(0)
            endF=true
        }

        if(oknDirection==0){
            var xd=ww*CGFloat(elapset)/3.2*CGFloat(oknSpeed)
            let x0=ww/5.0
            while xd>0 {
                xd -= ww/5
            }
            for i in 0..<6 {
                drawBand(rectB:CGRect(x:CGFloat(i)*x0+xd,y:0,width:ww/10,height:wh))
            }
        }else{
            var xd = -ww*CGFloat(elapset)/3.2*CGFloat(oknSpeed)
            let x0=ww/5.0
            while xd<0 {
                xd += ww/5
            }
            for i in 0..<6 {
                drawBand(rectB:CGRect(x:CGFloat(i-1)*x0+xd,y:0,width:ww/10,height:wh))
            }
        }
        let dtime=CFAbsoluteTimeGetCurrent()-time0
        if dtime>maxtime{
            maxtime=dtime
        }
        print("t:",maxtime,dtime)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        motionManager = CMMotionManager()
        motionManager?.deviceMotionUpdateInterval = 0.03
        timerPara.isHidden=true
        singleRec.require(toFail: doubleRec)
        hideButtons(hide: true)
        oknWidth = 2.0
        startSp = 5
        oknSpeedsub = 3
 //       startTime=CFAbsoluteTimeGetCurrent()
        // Do any additional setup after loading the view.
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
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
//        stopTimer()
    }
 
    var startX:CGFloat = 0
    var startSp:Int = 5
    var tempSp:Int = 0
    @IBAction func panGes(_ sender: UIPanGestureRecognizer) {
    }
 
    override func viewDidAppear(_ animated: Bool) {
        setTimer()
    }
}


