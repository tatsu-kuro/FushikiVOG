//
//  OKNrotateViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2018/08/27.
//  Copyright © 2018年 tatsuaki.kuroda. All rights reserved.
//

import UIKit
import CoreMotion

class OKNrotateViewController: UIViewController {
    var timer:Timer!
    var timerokp:Timer!
    var tcount:Int = 0
    var motionManager: CMMotionManager?
    var oknrSpeed:Int = 1
    var oknrDirection:Int = 0
    var oknrWidth:CGFloat = 1.0
    var oknrMode:Int = 0
    @IBOutlet weak var timerPara: UILabel!
    @IBOutlet weak var bandsView3: UIImageView!
    @IBOutlet weak var bandsView2: UIImageView!
    @IBOutlet weak var bandsView1: UIImageView!
    @IBOutlet weak var bandsView: UIImageView!
    @IBOutlet weak var gyroButton: UIButton!
    @IBOutlet weak var gyrooffButton: UIButton!
    @IBOutlet weak var width1Button: UIButton!
    @IBOutlet weak var width2Button: UIButton!
    @IBOutlet weak var width3Button: UIButton!
    @IBOutlet weak var speed1Button: UIButton!
    @IBOutlet weak var speed2Button: UIButton!
    @IBOutlet weak var speed3Button: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var okpButton: UIButton!
    @IBOutlet var doubleRec:UITapGestureRecognizer!
    @IBOutlet var singleRec:UITapGestureRecognizer!
  
    func hideButtons(hide:Bool){
        gyroButton.isHidden=hide
        gyrooffButton.isHidden=hide
        width1Button.isHidden=hide
        width2Button.isHidden=hide
        width3Button.isHidden=hide
        rightButton.isHidden=hide
        leftButton.isHidden=hide
        speed1Button.isHidden=hide
        speed2Button.isHidden=hide
        speed3Button.isHidden=hide
        okpButton.isHidden=hide
    }
    
    //       iPhone iPad
    //oowaru:40     61
    //chwaru:42     64
    //kowaru:52     53
    @IBAction func tapGes(_ sender: UITapGestureRecognizer) {
        let pos = sender.location(in: self.view)
        if pos.y < view.bounds.height/2{
            if pos.x < 50{
                warutemp += 1
            }else if pos.x<100{
                warutemp += 10
            }else{
                if gyroButton.isHidden == true{
                    hideButtons(hide: false)
                }else{
                    hideButtons(hide: true)
                }
            }
            if warutemp>100{
                warutemp=100
            }
            
        }else{
            if pos.x < 50{
                warutemp -= 1
            }else if pos.x < 100{
                warutemp -= 10
            }else{
                if gyroButton.isHidden == true{
                    hideButtons(hide: false)
                }else{
                    hideButtons(hide: true)
                }
            }
            if warutemp<30{
                warutemp=30
            }
        }
    }
    @IBAction func gyrooffAction(_ sender: Any) {
        stopTimer()
        oknrMode=0
        setTimer()
    }
    @IBAction func okpAction(_ sender: Any) {
        stopTimer()
        setTimerokp()
    }
    @IBAction func gyroAction(_ sender: Any) {
        stopTimer()
        oknrMode=1
        setTimer()
    }
    @IBAction func width3Action(_ sender: Any) {
        stopTimer()
        oknrWidth=3
        getDevice()
        setBand()
        setTimer()
    }
    @IBAction func width2Action(_ sender: Any) {
        stopTimer()
        oknrWidth=2
        getDevice()
        setBand()
        setTimer()
    }
    @IBAction func width1Action(_ sender: Any) {
        stopTimer()
        oknrWidth=1
        getDevice()
        setBand()
        setTimer()
    }
    @IBAction func speed3Action(_ sender: Any) {
        stopTimer()
        oknrSpeed=3
        setBand()
        setTimer()
    }
    @IBAction func speed2Action(_ sender: Any) {
        stopTimer()
        oknrSpeed=2
        setBand()
        setTimer()
    }
    @IBAction func speed1Action(_ sender: Any) {
        stopTimer()
        oknrSpeed=1
        setBand()
        setTimer()
    }
    @IBAction func rightAction(_ sender: Any) {
        stopTimer()
        oknrDirection=0
        setBand()
        setTimer()
    }
    @IBAction func leftAction(_ sender: Any) {
        stopTimer()
        oknrDirection=1
        setBand()
        setTimer()
    }
    
    var pitch:CGFloat=0
    func attitude() {
        guard let _ = motionManager?.isDeviceMotionAvailable,
            let operationQueue = OperationQueue.current
            else {
                return
        }
        
        motionManager?.startDeviceMotionUpdates(to: operationQueue, withHandler: { motion, _ in
            if let attitude = motion?.attitude {
                if attitude.roll<0{
                    self.pitch=CGFloat(attitude.pitch)
                }else{
                    self.pitch = -CGFloat(attitude.pitch)
                }
            }
        })
    }

    func stopTimer(){
        if timer?.isValid == true {
            timer.invalidate()
        }
        if timerokp?.isValid == true{
            timerokp.invalidate()
        }
        tcount=0
    }
    func setTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        tcount=0
    }
    func setTimerokp(){
        timerokp = Timer.scheduledTimer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.updateokp), userInfo: nil, repeats: true)
        tcount=0
    }
    var waru:Int = 0
    var warutemp:Int=80
    var devNum:Int = 0
    func getDevice(){
        var w=view.bounds.width
        var h=view.bounds.height
        if h>w{
            h=view.bounds.width
            w=view.bounds.height
        }
         if h/w > 0.7{//ipadは0.75の様
            if w>1020 && w<1030{
                devNum=10
            }else if w>1110 && w<1120{
                devNum=11
            }else if w>1360 && w<1370{
                devNum=12
            }
        }else{//iPhone
            if w>660 && w<670{//667 6s 7 9
                devNum=1
            }else if w>730 && w<740{//736 6sPlus 7plus 8plus
                devNum=2
            }else if w>560 && w<570{//568 se
                devNum=3
            }else if w>810 && w<820{//X 812
                devNum=4
            }
//            print(devNum)
        }
        //       print(view.bounds.width,view.bounds.height)
        if devNum==10{//iPad
            if oknrWidth==3{
                waru=61
            }else if oknrWidth==2{
                waru=64
            }else{
                waru=53
            }
        }else if devNum==11{//10.5inch
            if oknrWidth==3{
                waru=66
            }else if oknrWidth==2{
                waru=35
            }else{
                waru=43
            }
        }else if devNum==12{//12inch
            if oknrWidth==3{
                waru=81
            }else if oknrWidth==2{
                waru=43
            }else{
                waru=53
            }
        }else if devNum==1{//6s 7 8
            if oknrWidth==3{
                waru=40
            }else if oknrWidth==2{
                waru=42
            }else{
                waru=52
            }
        }else if devNum==2{//6splus 7plus 8plus
            if oknrWidth==3{
                waru=44
            }else if oknrWidth==2{
                waru=46
            }else{
                waru=38
            }
        }else if devNum==4{//X
            if oknrWidth==3{
                waru=49
            }else if oknrWidth==2{
                waru=51
            }else{
                waru=53
            }
        }else if devNum==3{//se
            if oknrWidth==3{
                waru=34
            }else if oknrWidth==2{
                waru=53
            }else{
                waru=44
            }
        }
    }
    //0.75(ipad)
    //0.5622
    //x 0.46
    //       6s iPad 7plus
    //oowaru:40     61   44
    //chwaru:42     64   69(46)
    //kowaru:52     53   57(38)
    //ipad 1024*768縦横は向きでかわる(ipad air,ipad air2,9.7inch)
    //ipad 10.5inch 1112*834
    //ipad 12.9inch 1366*1024(2nd generation)
    //6s 667*375
    //6 plus 736*414(7plus,8plus)
    //x 812*375
    //se 568*320
    @objc func updateokp(tm: Timer){
        
    }
    @objc func update(tm: Timer) {
        var dist:CGFloat=0
         tcount += 1
        //未登録のdeviceならpanで変更できるwarutempを設定する
        if devNum == 0{
            waru = warutemp
            timerPara.isHidden=false
            timerPara.text="\(waru)"
        }
        if oknrDirection==0{
            dist=CGFloat(tcount*oknrSpeed%waru)*6
        }else{
            dist = -CGFloat(tcount*oknrSpeed%waru)*6
        }
        if oknrMode == 1{
            attitude()
        }else{
            pitch=0
        }
        let t1:CGAffineTransform = CGAffineTransform(rotationAngle: -pitch)
        let t2:CGAffineTransform = CGAffineTransform(translationX: dist*cos(-pitch),y: dist*sin(-pitch))
        let t:CGAffineTransform = t1.concatenating(t2)
        bandsView.transform=t
   //     bandsView.setNeedsDisplay()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        motionManager = CMMotionManager()
        motionManager?.deviceMotionUpdateInterval = 0.03
//        initBands()
//        setBand()
//        getDevice()
        timerPara.isHidden=true
        singleRec.require(toFail: doubleRec)
//        waru=80
 //       setTimer()
        hideButtons(hide: true)
        // Do any additional setup after loading the view.
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
        
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    func setBand(){
        if oknrWidth == 1{
            bandsView.image=bandsView1.image
        }else if oknrWidth == 2 {
            bandsView.image=bandsView2.image
        }else{
            bandsView.image=bandsView3.image
        }
    }
    func initBands(){
        bandsView.frame.origin.x = 0 - view.bounds.width/2
        bandsView.frame.origin.y = 0 - view.bounds.height*2
        bandsView.frame.size.width=view.bounds.width*2
        bandsView.frame.size.height=view.bounds.height*5
        bandsView1.frame.origin.x = 0 - view.bounds.width/2
        bandsView1.frame.origin.y = 0 - view.bounds.height*2
        bandsView1.frame.size.width=view.bounds.width*2
        bandsView1.frame.size.height=view.bounds.height*5
        bandsView2.frame.origin.x = 0 - view.bounds.width/2
        bandsView2.frame.origin.y = 0 - view.bounds.height*2
        bandsView2.frame.size.width=view.bounds.width*2
        bandsView2.frame.size.height=view.bounds.height*5
        bandsView3.frame.origin.x = 0 - view.bounds.width/2
        bandsView3.frame.origin.y = 0 - view.bounds.height*2
        bandsView3.frame.size.width=view.bounds.width*2
        bandsView3.frame.size.height=view.bounds.height*5
        bandsView1.isHidden=true
        bandsView2.isHidden=true
        bandsView3.isHidden=true
        bandsView.isHidden=false
    }
    override func viewDidAppear(_ animated: Bool) {
        initBands()//3viewsのサイズをセット
        getDevice()
  //      initViews()
        setBand()//
        setTimer()
    }
    func initViews(){
        //bandview1 - orig3
        drawBands(widthNum: 1, bandV: bandsView1)
        drawBands(widthNum: 2, bandV: bandsView2)
        drawBands(widthNum: 3, bandV: bandsView3)
    }
    func drawBands(widthNum:Int,bandV:UIImageView){
        var width:CGFloat=0
        let vwidth:CGFloat = getBig(w: bandV.bounds.width, h: bandV.bounds.height)
   
        if widthNum == 1{
            width=vwidth/30
            for i  in 0..<30 {
                drawBand1(bandS:width*CGFloat(i),bandW:width/2,bandV:bandV)
  //              print(width*CGFloat(i),width/2)
            }
        }else if widthNum == 2{
            width=vwidth/20
            for i  in 0..<30 {
                drawBand1(bandS:width*CGFloat(i),bandW:width/2,bandV:bandV)
            }
        }else{//} if widthNum == 3{
            width=vwidth/10
            for i  in 0..<30 {
                drawBand1(bandS:width*CGFloat(i),bandW:width/2,bandV:bandV)
            }
        }
    }
    func drawBand1(bandS:CGFloat,bandW:CGFloat,bandV:UIImageView){
        let rectangleLayer = CAShapeLayer.init()
        let rectangleFrame = CGRect.init(x: bandS, y: 0, width: bandW , height: bandV.bounds.height)
        rectangleLayer.frame = rectangleFrame
        
        // 輪郭の色
        rectangleLayer.strokeColor = UIColor.black.cgColor
        // 四角形の中の色
        rectangleLayer.fillColor = UIColor.black.cgColor
        // 輪郭の太さ
        // rectangleLayer.lineWidth = 2.5
        
        // 四角形を描画
        rectangleLayer.path = UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: rectangleFrame.size.width, height: rectangleFrame.size.height)).cgPath
        
        //self.view.layer.addSublayer(rectangleLayer)
        //bandV.layer.addSublayer(rectangleLayer)
        //bandV.layer.addSublayer(rectangleLayer)
        //bandV.image=self.view.image
//        bandV.viewWithTag(0)?.layer.addSublayer(rectangleLayer)
        //
        bandV.superview?.layer.addSublayer(rectangleLayer)
    }
    func getBig(w:CGFloat,h:CGFloat)->CGFloat{
        if w>h{
            return w
        }
        return h
    }
    /*
     import UIKit
     
     class OKNViewController: UIViewController {
     var timer: Timer!
     var tcount: Int = 0
     var oknSpeed:CGFloat = 5.0
     var bandWidth:CGFloat = 0
     var panFlag:Bool = false
     @IBOutlet weak var textIroiro: UITextField!
     override func viewDidLoad() {
     super.viewDidLoad()
     bandWidth = self.view.bounds.width/10
     textIroiro.isHidden=false
     timer = Timer.scheduledTimer(timeInterval: 1.0/100.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
     tcount=0
     if UIApplication.shared.isIdleTimerDisabled == false{
     UIApplication.shared.isIdleTimerDisabled = true//スリープしない
     }
     
     }
     @IBAction func tapGes(_ sender: UITapGestureRecognizer) {
     print("tap")
     
     }
     @IBAction func panGes(_ sender: UIPanGestureRecognizer) {
     if sender.state == .began{
     //               textIroiro.isHidden=false
     panFlag=true
     for _ in 0..<7{
     view.layer.sublayers?.removeLast()
     }
     drawBands(startP: bandWidth)
     }else if sender.state == .changed{
     textIroiro.isHidden=false
     //       checkerView.isHidden=true
     let speed = sender.location(in:self.view).x*20/self.view.bounds.width
     if speed > 10 {
     oknSpeed = speed - 10 + 1
     textIroiro.text = "\(Int(oknSpeed))"
     }else{
     oknSpeed = speed - 10 - 1
     textIroiro.text = "\(Int(abs(oknSpeed)))"
     }
     }else if sender.state == .ended{
     panFlag=false
     textIroiro.text = " "
     //                setUserDefaults()
     }
     
     }
     
     @objc func update(tm: Timer) {
     if panFlag==true{
     return
     }
     if tcount > 0{
     for _ in 0..<7{
     view.layer.sublayers?.removeLast()
     }
     }
     tcount += 1
     let sp:CGFloat = CGFloat(tcount)*oknSpeed
     drawBands(startP: CGFloat(Int(sp) % (2*Int(bandWidth))))
     //        if tcount > 100*60*5 {
     //    //        if UIApplication.shared.isIdleTimerDisabled == true{
     //                UIApplication.shared.isIdleTimerDisabled = false//5分たったら監視する
     //    //        }
     //        }
     }
     override func didReceiveMemoryWarning() {
     super.didReceiveMemoryWarning()
     // Dispose of any resources that can be recreated.
     }
     func drawBands(startP:CGFloat){
     for i  in 0..<7 {
     drawBand1(bandS: startP + bandWidth*2.0*CGFloat(i),bandW:bandWidth)
     }
     if startP>bandWidth{
     view.layer.sublayers?.removeLast()
     drawBand1(bandS:0,bandW:startP-bandWidth)
     }
     }
     func drawBand1(bandS:CGFloat,bandW:CGFloat){
     /* --- 四角形を描画 --- */
     let rectangleLayer = CAShapeLayer.init()
     let rectangleFrame = CGRect.init(x: bandS, y: 0, width: bandW , height: self.view.bounds.height)
     rectangleLayer.frame = rectangleFrame
     
     // 輪郭の色
     rectangleLayer.strokeColor = UIColor.black.cgColor
     // 四角形の中の色
     rectangleLayer.fillColor = UIColor.black.cgColor
     // 輪郭の太さ
     // rectangleLayer.lineWidth = 2.5
     
     // 四角形を描画
     rectangleLayer.path = UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: rectangleFrame.size.width, height: rectangleFrame.size.height)).cgPath
     
     self.view.layer.addSublayer(rectangleLayer)
     }
     }
     

     */
//    func drawBands(startP:CGFloat){
//        for i  in 0..<7 {
//            drawBand1(bandS: startP + bandWidth*2.0*CGFloat(i),bandW:bandWidth)
//        }
//        if startP>bandWidth{
//            view.layer.sublayers?.removeLast()
//            drawBand1(bandS:0,bandW:startP-bandWidth)
//        }
//    }

//    func drawBand1(bandS:CGFloat,bandW:CGFloat){
//        /* --- 四角形を描画 --- */
//        let rectangleLayer = CAShapeLayer.init()
//        let rectangleFrame = CGRect.init(x: bandS, y: 0, width: bandW , height: self.view.bounds.height)
//        rectangleLayer.frame = rectangleFrame
//
//        // 輪郭の色
//        rectangleLayer.strokeColor = UIColor.black.cgColor
//        // 四角形の中の色
//        rectangleLayer.fillColor = UIColor.black.cgColor
//        // 輪郭の太さ
//        // rectangleLayer.lineWidth = 2.5
//
//        // 四角形を描画
//        rectangleLayer.path = UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: rectangleFrame.size.width, height: rectangleFrame.size.height)).cgPath
//
//        //self.view.layer.addSublayer(rectangleLayer)
//        bandsView1.layer.addSublayer(rectangleLayer)
//    }
}


