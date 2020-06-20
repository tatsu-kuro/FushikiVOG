//
//  OKNrotateViewController.swift
//  Fushiki
//
//  Created by Fushiki tatsuaki on 2018/08/27.
//  Copyright © 2018年 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import CoreMotion

class OKNrotateViewController: UIViewController {
    var ettWidth:Int = 0//1:narrow,2:wide
    var oknSpeed:Int = 2
    var oknDirection:Int = 0
    var targetMode:Int = 0
    
    var timer:Timer!
    var startTime=CFAbsoluteTimeGetCurrent()
//    var timerokp:Timer!
    var cnt:Int = 0
 //   var cntOkp:Int = 0
    var motionManager: CMMotionManager?
 //   var oknSpeed:Int = 2
    var oknSpeedsub:Int = 3
//    var okpSpeedsub:Int = 2
    var oknSp:Int = 3
 //   var oknDirection:Int = 0
    var oknWidth:CGFloat = 1.0
    var panFlag:Bool = false
    @IBOutlet weak var timerPara: UILabel!
 //   @IBOutlet weak var bandsView2: UIImageView!
  //  @IBOutlet weak var bandsView: UIImageView!
    @IBOutlet weak var speed1Button: UIButton!
    @IBOutlet weak var speed2Button: UIButton!
    @IBOutlet weak var speed3Button: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    
    @IBOutlet var doubleRec:UITapGestureRecognizer!
    @IBOutlet var singleRec:UITapGestureRecognizer!
    var tapInterval=CFAbsoluteTimeGetCurrent()
    
    @IBAction func doubleTap(_ sender: Any) {
        let mainView = storyboard?.instantiateViewController(withIdentifier: "mainView") as! ViewController
        mainView.ettWidth=ettWidth
        mainView.oknSpeed=oknSpeed
        mainView.oknDirection=oknDirection
        mainView.targetMode=targetMode
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
                stopTimer()
                oknSpeed += 1
                if(oknSpeed>3){
                    oknSpeed=1
                }
                oknDirection=0
                setTimer()
            case .remoteControlPreviousTrack:
                stopTimer()
                oknSpeed += 1
                if(oknSpeed>3){
                    oknSpeed=1
                }
                oknDirection=1
                setTimer()
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
    
    //       iPhone iPad
    //oowaru:40     61
    //chwaru:42     64
    //kowaru:52     53
    @IBAction func tapGes(_ sender: UITapGestureRecognizer) {

                if leftButton.isHidden == true{
                    hideButtons(hide: false)
                }else{
                    hideButtons(hide: true)
                }
    }
    @IBAction func speed3Action(_ sender: Any) {
        stopTimer()
        oknSpeed=3
        setTimer()
    }
    @IBAction func speed2Action(_ sender: Any) {
         stopTimer()
        oknSpeed=2
        setTimer()
    }
    @IBAction func speed1Action(_ sender: Any) {
        stopTimer()
        oknSpeed=1
        setTimer()
    }
    @IBAction func rightAction(_ sender: Any) {
        stopTimer()
        oknDirection=0
        setTimer()
    }
    @IBAction func leftAction(_ sender: Any) {
        stopTimer()
        oknDirection=1
        setTimer()
    }
    
    var pitch:CGFloat=0
 
    func stopTimer(){
        if timer?.isValid == true {
            timer.invalidate()
        }
        cnt=0
        lastMove=0
        initFlag=false
    }
    func setTimer(){
        startTime=CFAbsoluteTimeGetCurrent()
        ww=view.bounds.width
        wh=view.bounds.height

        timer = Timer.scheduledTimer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
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
    @objc func update(tm: Timer) {
        cnt += 1
        if initf {
            for _ in 0..<6{
                view.layer.sublayers?.removeLast()
            }
        }
        initf=true
        let elapset=CFAbsoluteTimeGetCurrent()-startTime
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
/*        cnt += 1
        moveBandDir(move:lastMove+oknSpeed*(oknSpeedsub+1),dir:oknDirection,gyro:0)
        lastMove += oknSpeed*(oknSpeedsub+1)
        if lastMove > modoru{
            lastMove -= modoru
        }*/
        if(cnt>60*30){//finish
            doubleTap(0)
        }
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
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
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


