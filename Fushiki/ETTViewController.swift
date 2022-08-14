//
//  ETTcViewController.swift
//  Fushiki
//
//  Created by Fushiki tatsuaki on 2018/08/05.
//  Copyright © 2018年 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import Photos
import AVFoundation
class ETTViewController: UIViewController{// AVCaptureFileOutputRecordingDelegate {
    let camera = myFunctions()//name:"Fushiki")
    var cirDiameter:CGFloat = 0
//    var startTime=CFAbsoluteTimeGetCurrent()
    var lastTime=CFAbsoluteTimeGetCurrent()
    var timerREC:Timer?
    @IBOutlet weak var recClarification: UIImageView!
    var displayLinkF:Bool=false
    var displayLink:CADisplayLink?
//    var tcount: Int = 0
    var ettWidth:Int = 50
    var ettMode:Int = 0
    var targetMode:Int = 0
    var ettW:CGFloat = 0
    var ettH:CGFloat = 0
    var recordedF:Bool = false

    @IBOutlet weak var blackRightImageView: UIImageView!
    @IBOutlet weak var blackLeftImageView: UIImageView!
    var tapInterval=CFAbsoluteTimeGetCurrent()
    func stopDisplaylink(){
        if displayLinkF==true{
            displayLink?.invalidate()
            displayLinkF=false
        }
    }
    
    @IBAction func doubleTap(_ sender: Any) {
        if displayLinkF==false{//録画が始まっていない時は帰る
            return
        }
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        mainView.targetMode=targetMode
        delTimer()
        camera.recordStop()
        performSegue(withIdentifier: "fromETT", sender: self)
    }
    func delTimer(){
        if displayLinkF==true{
            displayLink?.invalidate()
        }
        if timerREC?.isValid == true {
            timerREC!.invalidate()
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
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            case .remoteControlTogglePlayPause:
                print("TogglePlayPause")
                if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                    print("doubleTap")
                    doubleTap(0)
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
//            case .remoteControlNextTrack:
//                ettWidth = 2
//                setETTwidth(width: 2)
//                tcount=1
//            case .remoteControlPreviousTrack:
//                ettWidth = 1
//                setETTwidth(width: 1)
//                tcount=1
            default:
                print("Others")
            }
        }
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override func viewDidAppear(_ animated: Bool) {

    }
 
    var cntREC:Int=0
    @objc func updateRecClarification(tm: Timer) {//録画していることを明確に示す必要がある 0.02
        cntREC += 1
        recClarification.alpha=camera.updateRecClarification(tm: cntREC)
        if cntREC==150{//ここはカメラOFF時は通らない 3sec待って録画開始
            camera.recordStart()//ここだと暗くならない
            //実際に録画スタートした時にcamera.recordStartTimeが設定される
        }
        if camera.recordStartTime>0 && displayLinkF==false{//実際に録画がスタートしたら視標表示を開始
            displayLink?.add(to: RunLoop.main, forMode: .common)
            displayLinkF=true
        }
    }
    var ettType = Array<Int>()
    var ettSpeed = Array<Int>()
    var ettSec = Array<Double>()
    var currentEttNum:Int = 0
    var centerX:CGFloat=0
    var centerY:CGFloat=0
    var soundIdx:SystemSoundID = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        
        camera.makeAlbum()
        print(UIScreen.main.brightness)
        UIScreen.main.brightness = CGFloat(1)//camera.getUserDefaultFloat(str: "screenBrightness", ret:1.0))
        
        let cameraType = camera.getUserDefaultInt(str: "cameraType", ret: 0)
        camera.initSession(camera: Int(cameraType), bounds:CGRect(x:0,y:0,width:0,height: 0), cameraView: recClarification)
      
//        if cameraType==0{
//        camera.setZoom(level:0.03)
//        }else{
//            camera.setZoom(level: 0)
//        }
//focudは最短
        camera.setZoom(level:camera.getUserDefaultFloat(str: "zoomValue", ret: 0))
        camera.setFocus(focus: camera.getUserDefaultFloat(str: "focusValue", ret: 0))
        if cameraType != 0{
            camera.setLedLevel(camera.getUserDefaultFloat(str: "ledValue", ret:0))
        }
        ettMode=UserDefaults.standard.integer(forKey: "ettMode")
        ettWidth=UserDefaults.standard.integer(forKey: "ettWidth")
        ettType.removeAll()
        ettSpeed.removeAll()
        ettSec.removeAll()
        currentEttNum=0

        var ettTxt:String = ""
        if ettMode==0{
            ettTxt = UserDefaults.standard.string(forKey: "ettModeText0")!
        }else if ettMode==1{
            ettTxt = UserDefaults.standard.string(forKey: "ettModeText1")!
        }else if ettMode==2{
            ettTxt = UserDefaults.standard.string(forKey: "ettModeText2")!
        }else{
            ettTxt = UserDefaults.standard.string(forKey: "ettModeText3")!
        }
        let ettTxtComponents = ettTxt.components(separatedBy: ",")

        var ettWidthX = Int(ettTxtComponents[0])!//横幅:1-5
        for i in 1...ettTxtComponents.count-1{
            let str = ettTxtComponents[i].components(separatedBy: ":")
            if str.count == 3{
                ettType.append(Int(str[0])!)
                ettSpeed.append(Int(str[1])!)
                ettSec.append(Double(str[2])!)
            }else{
                break
            }
        }
        let top=UserDefaults.standard.float(forKey: "top")
        let bottom=UserDefaults.standard.float(forKey: "bottom")
        let left=UserDefaults.standard.float(forKey: "left")
        let right=UserDefaults.standard.float(forKey: "right")
//    print("top,bottom,left,right",top,bottom,left,right)
        
        let ww=view.bounds.width-CGFloat(left+right)
        let wh=view.bounds.height//-CGFloat(top+bottom)
        blackLeftImageView.frame=CGRect(x:0,y:0,width: view.bounds.width/4,height: view.bounds.height)
        blackRightImageView.frame=CGRect(x:view.bounds.width*3/4,y:0,width: view.bounds.width/4,height: view.bounds.height)
        blackLeftImageView.alpha=0
        blackRightImageView.alpha=0
        centerX=ww/2+CGFloat(left)
        centerY=wh/2+CGFloat(top)
        cirDiameter=ww/26

        ettW = (ww/2)-cirDiameter// *CGFloat(ettWidth)/100.0
        ettH = (wh/2)-cirDiameter// *CGFloat(ettWidth)/100.0
        if ettWidthX>5{
            ettWidthX=5
        }else if ettWidthX<0{
            ettWidthX=0
        }
        ettW=ettH+(ettW-ettH)*CGFloat(ettWidthX)/5
        displayLink = CADisplayLink(target: self, selector: #selector(self.update))
        displayLink!.preferredFramesPerSecond = 120
         //まず見えないところに円を表示
        drawCircle(cPoint: CGPoint(x:-100,y:-100))//damy
  
        if UserDefaults.standard.bool(forKey: "cameraON")==false{
            //非録画モードなら、ここでdisplayLinkスタート
            displayLink?.add(to: RunLoop.main, forMode: .common)
            displayLinkF=true
        }else{
            //録画モードでは、timerRecで録画スタートさせて、実際に録画が始まるところをチェックしてdisplayLinkをスタート
//            if let soundUrl = URL(string:
//                                    "/System/Library/Audio/UISounds/end_record.caf"/*photoShutter.caf*/){
//                let speakerOnOff=UserDefaults.standard.integer(forKey: "speakerOnOff")
//                if speakerOnOff==1{
//
//                AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundIdx)
//                AudioServicesPlaySystemSound(soundIdx)
//                }
//            }
            camera.recordStartTime=0
        }
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
    
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        tapInterval=CFAbsoluteTimeGetCurrent()-1
        self.setNeedsStatusBarAppearanceUpdate()

        if !UserDefaults.standard.bool(forKey: "cameraON"){
            recClarification.isHidden=true
        }else{
            timerREC = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.updateRecClarification), userInfo: nil, repeats: true)
            recClarification.frame=camera.getRecClarificationRct(width:view.bounds.width,height:view.bounds.height)
            //録画モードでは、timerRecで録画スタートさせて、実際に録画が始まる時間を取得
        }
       
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
        UIApplication.shared.beginReceivingRemoteControlEvents()
        // ファーストレスポンダにする（その結果、キーボードが表示される）
        tapInterval=CFAbsoluteTimeGetCurrent()-1
        self.setNeedsStatusBarAppearanceUpdate()
      
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopDisplaylink()
    }
//    override func prefersHomeIndicatorAutoHidden() -> Bool {
//        return true
//    }
    var lastrand:Int=1
    var rand:Int=0
    var lastSec:Int = -1
    var lastRandPoint:CGPoint = CGPoint(x:-200,y:-200)
    func getRandPointX()->CGPoint{
        var rand = Int.random(in: 0..<5) - 2
        if(lastrand==rand){
            rand += 1
            if(rand > 2){
                rand = -2
            }
        }
        lastrand=rand
        let xd=CGFloat(rand)*ettW/2
        return CGPoint(x:centerX+xd, y: centerY)
    }
    func getRandPointXY()->CGPoint {
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
        lastrand=rand
        var xn:Int=0
        var yn:Int=0
        if(rand%3==0){xn = -1}
        else if(rand%3==1){xn=0}
        else {xn=1}
        if(rand/3==0){yn = -1}
        else if(rand/3==1){yn = 0}
        else {yn=1}
        let x0=centerX
        let xd=ettH
        let y0=centerY
        let yd=ettH
        return CGPoint(x:x0 + CGFloat(xn)*xd, y: y0 + CGFloat(yn)*yd)
    }
    func getSumEttSec(num:Int)->Double{
        var sumEttSec:Double=0
        for i in 0...num{
            sumEttSec += ettSec[i]
        }
        return sumEttSec
    }
    func leftRightSetBlack(amari:CGFloat){
        if amari<0.1 {
            blackLeftImageView.alpha=1
            blackRightImageView.alpha=1
        }else{
            blackLeftImageView.alpha=0
            blackRightImageView.alpha=0
        }
    }
    @objc func update() {//pursuit
        view.layer.sublayers?.removeLast()
        //実際に録画が開始した時間を基準にする。(10-20msec程度はずれてしまうと思われる）
        //+0.1(100ms)で縦線と表示の同期が取れるようだ。
        let elapset=CFAbsoluteTimeGetCurrent()-camera.recordStartTime+0.1// recordstartTime
        if elapset<getSumEttSec(num:currentEttNum){

            let etttype=ettType[currentEttNum]
            var ettspeed=CGFloat(ettSpeed[currentEttNum])
            if ettspeed==0{//静止モードは別に作ったので、0の時は１の半分のスピードとした。
                ettspeed=0.5
            }
            let sec=Int(elapset*ettspeed/2)
            let sinV=sin(CGFloat(elapset)*3.1415*0.3*ettspeed)
            if etttype==0{//静止モードではspeedで位置指定する
                if ettspeed==0.5{//視標なし
                    drawCircle(cPoint: CGPoint(x:-100,y:-100))//damy
                }else if ettspeed==1 || ettspeed>5{
                    drawCircle(cPoint: CGPoint(x:centerX,y:centerY))
                    if ettspeed>5{
                        let amari=elapset-Double(Int(elapset)/1*1)//every 10sec
                        leftRightSetBlack(amari:amari)//1秒ごとに100msec画面を縮小表示
                    }
                }else if ettspeed==2{
                    drawCircle(cPoint: CGPoint(x:centerX-ettW,y:centerY))
                }else if ettspeed==3{
                    drawCircle(cPoint: CGPoint(x:centerX+ettW,y:centerY))
                }else if ettspeed==4{
                    drawCircle(cPoint: CGPoint(x:centerX,y:centerY-ettH))
                }else if ettspeed==5{
                    drawCircle(cPoint: CGPoint(x:centerX,y:centerY+ettH))
                }
            }else if etttype == 1{//振り子横
                drawCircle(cPoint:CGPoint(x:centerX + sinV*ettW, y: centerY))
            }else if etttype==2{//振り子縦
                drawCircle(cPoint:CGPoint(x:centerX , y: centerY + sinV*ettH))
            }else if etttype==3{//衝動横
                if ettspeed==0{
                    drawCircle(cPoint: CGPoint(x:centerX,y:centerY))
                }else{
                    if sec%2==0{
                        drawCircle(cPoint:CGPoint(x:centerX+ettW,y:centerY))
                    }else{
                        drawCircle(cPoint: CGPoint(x:centerX-ettW,y:centerY))
                    }
                }
            }else if etttype==4{//衝動縦
                if ettspeed==0{
                    drawCircle(cPoint: CGPoint(x:centerX,y:centerY))
                }else{
                    if sec%2==0{
                        drawCircle(cPoint: CGPoint(x:centerX,y:centerY+ettH))
                    }else{
                        drawCircle(cPoint: CGPoint(x:centerX,y:centerY-ettH))
                    }
                }
            }else{
                if sec != lastSec{
                    if etttype==6{//ランダム縦横
                        lastRandPoint=getRandPointXY()
                    }else{//5:ランダム横
                        lastRandPoint=getRandPointX()
                    }
                    print("time:",elapset)
                }
                drawCircle(cPoint: lastRandPoint)
                lastSec=sec
            }
            
        }else{
            currentEttNum += 1
            if ettType.count-1<currentEttNum{
                doubleTap(0)
//            }else{
//                camera.recordStartTime=CFAbsoluteTimeGetCurrent()
            }
            drawCircle(cPoint: CGPoint(x:-200,y:-200))
            //damy
        }
    }
 
    var initf:Bool=false
  
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
    func appOrientation() -> UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
    
    func convertUIOrientation2VideoOrientation(f: () -> UIInterfaceOrientation) -> AVCaptureVideoOrientation? {
        let v = f()
        switch v {
        case UIInterfaceOrientation.unknown:
            return nil
        default:
            return ([
                UIInterfaceOrientation.portrait: AVCaptureVideoOrientation.portrait,
                UIInterfaceOrientation.portraitUpsideDown: AVCaptureVideoOrientation.portraitUpsideDown,
                UIInterfaceOrientation.landscapeLeft: AVCaptureVideoOrientation.landscapeLeft,
                UIInterfaceOrientation.landscapeRight: AVCaptureVideoOrientation.landscapeRight
            ])[v]
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        coordinator.animate(
            alongsideTransition: nil,
            completion: {(UIViewControllerTransitionCoordinatorContext) in
                //画面の回転後に向きを教える。
                if self.convertUIOrientation2VideoOrientation(f: {return self.appOrientation()}) != nil {
                    //                    self.setETTwidth(width: self.ettWidth)
                }
            }
        )
    }
}
