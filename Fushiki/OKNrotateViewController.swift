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
    var cnt:Int = 0
    var cntOkp:Int = 0
    var motionManager: CMMotionManager?
    var oknSpeed:Int = 1
    var oknSpeedsub:Int = 2
    var okpSpeedsub:Int = 2
    var oknSp:Int = 3
    var oknDirection:Int = 0
    var oknWidth:CGFloat = 1.0
    var gyroMode:Int = 0//gyro off:0 on:1
    var okpMode:Int = 0//notOKP:0 OKP:1
    var panFlag:Bool = false
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
    
    @IBOutlet weak var speedText: UITextField!
    @IBOutlet weak var okpLButton: UIButton!
    @IBOutlet weak var okpRButton: UIButton!
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
        okpRButton.isHidden=hide
        okpLButton.isHidden=hide
        speedText.isHidden=true
    }
    
    //       iPhone iPad
    //oowaru:40     61
    //chwaru:42     64
    //kowaru:52     53
    @IBAction func tapGes(_ sender: UITapGestureRecognizer) {

        let pos = sender.location(in: self.view)
        if pos.y < view.bounds.height/2{
            if pos.x < 150{
                modoru += 1
                print("modoru",modoru)
            }else{
                if gyroButton.isHidden == true{
                    hideButtons(hide: false)
                }else{
                    hideButtons(hide: true)
                }
            }
        }else{
           if pos.x < 150{
                modoru -= 1
            print("modoru",modoru)
           }else{
                if gyroButton.isHidden == true{
                    hideButtons(hide: false)
                }else{
                    hideButtons(hide: true)
                }
            }
        }
    }
    @IBAction func okpRAction(_ sender: Any) {
        stopTimer()
        oknWidth=3
        //oknrSpeed=2
        okpMode=1
        oknDirection=0
        getDevice()
        setBand()
        setTimerokp()
    }
    @IBAction func okpLAction(_ sender: Any) {
        stopTimer()
        oknWidth=3
        //oknrSpeed=2
        okpMode=1
        oknDirection=1
        getDevice()
        setBand()
        setTimerokp()
    }
    @IBAction func gyrooffAction(_ sender: Any) {
        okpMode=0
        stopTimer()
        gyroMode=0
        setTimer()
    }
     @IBAction func gyroAction(_ sender: Any) {
        okpMode=0
        stopTimer()
        gyroMode=1
        setTimer()
    }
    @IBAction func width3Action(_ sender: Any) {
        okpMode=0
        stopTimer()
        oknWidth=3
        getDevice()
        setBand()
        setTimer()
    }
    @IBAction func width2Action(_ sender: Any) {
        okpMode=0
        stopTimer()
        oknWidth=2
        getDevice()
        setBand()
        setTimer()
    }
    @IBAction func width1Action(_ sender: Any) {
        okpMode=0
        stopTimer()
        oknWidth=1
        getDevice()
        setBand()
        setTimer()
    }
    @IBAction func speed3Action(_ sender: Any) {
        okpMode=0
        stopTimer()
        oknSpeed=3
        setBand()
        setTimer()
    }
    @IBAction func speed2Action(_ sender: Any) {
        okpMode=0
        stopTimer()
        oknSpeed=2
        setBand()
        setTimer()
    }
    @IBAction func speed1Action(_ sender: Any) {
        okpMode=0
        stopTimer()
        oknSpeed=1
        setBand()
        setTimer()
    }
    @IBAction func rightAction(_ sender: Any) {
        okpMode=0
        stopTimer()
        oknDirection=0
        setBand()
        setTimer()
    }
    @IBAction func leftAction(_ sender: Any) {
        okpMode=0
        stopTimer()
        oknDirection=1
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
        cnt=0
        cntOkp=0
        lastMove=0
        initFlag=false
    }
    func setTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        cnt=0
    }
    func setTimerokp(){
        timerokp = Timer.scheduledTimer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.updateokp), userInfo: nil, repeats: true)
        cntOkp=0
        cnt = -60*2//no action for 2sec
    }
  //  var waru:Int = 0
    var modoru:Int = 0
 //   var warutemp:Int=380
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
             if oknWidth==3{
                modoru=362
            }else if oknWidth==2{
                modoru=383
            }else{
                modoru=318
            }
        }else if devNum==11{//10.5inch
            if oknWidth==3{
                modoru = 394
            }else if oknWidth==2{
                modoru=209
            }else{
                modoru=258
            }
        }else if devNum==12{//12inch
            if oknWidth==3{
                modoru = 488
            }else if oknWidth==2{
                modoru=259
            }else{
                modoru=321
            }
        }else if devNum==1{//6s 7 8
            if oknWidth==3{
                modoru=238
            }else if oknWidth==2{
                modoru=250
            }else{
                modoru=309
            }
        }else if devNum==2{//6splus 7plus 8plus
            if oknWidth==3{
                modoru=261
            }else if oknWidth==2{
                modoru=274
            }else{
                modoru=228
            }
        }else if devNum==4{//X
            if oknWidth==3{
                modoru = 286
            }else if oknWidth==2{
                modoru=300
            }else{
                modoru=315
            }
        }else if devNum==3{//se
             if oknWidth==3{
                modoru = 202
            }else if oknWidth==2{
                modoru = 319
            }else{
                modoru=266
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
//    func moveBand(move:Int){
//        cntOkp += 1
//        var dist:CGFloat=0
//        if oknrDirection==0{
//            dist = CGFloat(move)
//        }else{
//            dist = -CGFloat(move)
//        }
//        let t:CGAffineTransform = CGAffineTransform(translationX: dist,y:0)
//        bandsView.transform=t
//    }
    func moveBandDir(move:Int,dir:Int,gyro:Int){
        cntOkp += 1
        var dist:CGFloat=0
        if dir==0{
            dist = CGFloat(move)
        }else{
            dist = -CGFloat(move)
        }
        if gyro==0{
            let t:CGAffineTransform = CGAffineTransform(translationX: dist,y:0)
            bandsView.transform=t
        }else{
            attitude()
            let t1:CGAffineTransform = CGAffineTransform(rotationAngle: -pitch)
            let t2:CGAffineTransform = CGAffineTransform(translationX: dist*cos(-pitch),y: dist*sin(-pitch))
            let t:CGAffineTransform = t1.concatenating(t2)
            bandsView.transform=t
        }
    }
    var lastMove:Int = 0
    var lastCnt:Int = 0
    var initFlag:Bool = false
    @objc func updateokp(tm: Timer){
        let wa:Int = 85 - okpSpeedsub*3
        cnt += 1
        if cnt < 0{//timer startでcnt=-60*2としている
            moveBandDir(move:0,dir:0,gyro:0)
            return
        }
        if cnt < 60*40{
            moveBandDir(move:lastMove+cnt/wa,dir:oknDirection,gyro:0)
            lastMove += cnt/wa
        }else if cnt < 60*40*2{
            if initFlag == false{
                lastCnt = cnt
                initFlag = true
            }
            moveBandDir(move:lastMove+(lastCnt+(lastCnt-cnt))/wa,dir:oknDirection,gyro:0)
            lastMove += (lastCnt+(lastCnt-cnt))/wa
        }
        if lastMove > modoru{
            lastMove -= modoru
        }
        if cnt > 60*40*2+60{
            speedText.text="OKP DONE"
            speedText.isHidden=false
            stopTimer()
        }
     }
    @objc func update(tm: Timer) {
        cnt += 1
        moveBandDir(move:lastMove+oknSpeed*(oknSpeedsub+1),dir:oknDirection,gyro:gyroMode)
        lastMove += oknSpeed*(oknSpeedsub+1)
        if lastMove > modoru{
            lastMove -= modoru
        }
    }

//    @objc func update2(tm: Timer) {
//        var dist:CGFloat=0
//         cnt += 1
//        //未登録のdeviceならpanで変更できるwarutempを設定する
//        if devNum == 0{
//            waru = warutemp
//            timerPara.isHidden=false
//            timerPara.text="\(waru)"
//        }
//        if oknDirection==0{
//            dist = CGFloat(cnt*oknSpeed%waru)*1
//        }else{
//            dist = -CGFloat(cnt*oknSpeed%waru)*1
//        }
//        if gyroMode == 1{
//            attitude()
//            let t1:CGAffineTransform = CGAffineTransform(rotationAngle: -pitch)
//            let t2:CGAffineTransform = CGAffineTransform(translationX: dist*cos(-pitch),y: dist*sin(-pitch))
//            let t:CGAffineTransform = t1.concatenating(t2)
//            bandsView.transform=t
//        }else{
//            let t:CGAffineTransform = CGAffineTransform(translationX: dist,y:0)
//            bandsView.transform=t
//        }
//   //     bandsView.setNeedsDisplay()
//    }
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
        if oknWidth == 1{
            bandsView.image=bandsView1.image
        }else if oknWidth == 2 {
            bandsView.image=bandsView2.image
        }else{
            bandsView.image=bandsView3.image
        }
    }
    var startX:CGFloat = 0
    var startSp:Int = 0
    var tempSp:Int = 0
    @IBAction func panGes(_ sender: UIPanGestureRecognizer) {
       
        if sender.state == .began {
            if sender.location(in: self.view).y<self.view.bounds.height/10{
           speedText.isHidden=false
            panFlag=true
            startX=sender.location(in: self.view).x
             if okpMode==1 {
                startSp=okpSpeedsub
             }else{
                startSp=oknSpeedsub
            }
            }
        } else if sender.state == .changed {
            if sender.location(in: self.view).y<self.view.bounds.height/10{
            tempSp = startSp + Int(sender.location(in: self.view).x - startX)/20
            print(tempSp)
            if tempSp<1{
                tempSp=1
                startX=sender.location(in: self.view).x
                startSp=tempSp
            }else if tempSp>5{
                tempSp=5
                startX=sender.location(in: self.view).x
                startSp=tempSp
            }
            if okpMode==1{
                speedText.text = "OKP Top Speed : " + "\(tempSp)"
                okpSpeedsub=tempSp
            }else{
                speedText.text = "OKN Speed : " + "\(tempSp)"
                oknSpeedsub=tempSp
            }
            }
        }else if sender.state == .ended{
            panFlag=false
            speedText.isHidden=true
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
        setBand()
        if okpMode == 1{
            if oknDirection == 0{
                okpRAction(0)
            }else{
                okpLAction(0)
            }
        }else{
            setTimer()
        }
    }
/*
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
        
        bandV.superview?.layer.addSublayer(rectangleLayer)
    }
    func getBig(w:CGFloat,h:CGFloat)->CGFloat{
        if w>h{
            return w
        }
        return h
    }
*/
}


