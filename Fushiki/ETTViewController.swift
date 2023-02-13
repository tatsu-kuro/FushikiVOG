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
import CoreMotion
class ETTViewController: UIViewController{// AVCaptureFileOutputRecordingDelegate {
    var blackLeftFrame0:CGRect=CGRect(x:0,y:0,width:0,height:0)
    var blackRightFrame0:CGRect=CGRect(x:0,y:0,width:0,height:0)
    var blackLeftFrame:CGRect=CGRect(x:0,y:0,width:0,height:0)
    var blackRightFrame:CGRect=CGRect(x:0,y:0,width: 0,height: 0)
    
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
    //motionsensor*******
    //motion sensor*************************

    var motionInterval=CFAbsoluteTimeGetCurrent()
    var lastTapLeft:Bool=false
    var tapLeft:Bool=false
    let motionManager = CMMotionManager()
    var isStarted = false

    var deltay = Array<Int>()

    var kalmandata = Array<CGFloat>()
    var kalVs:[CGFloat]=[0.0001 ,0.001 ,0,0,0]
    func KalmanS(Q:CGFloat,R:CGFloat){
        kalVs[4] = (kalVs[3] + Q) / (kalVs[3] + Q + R)
        kalVs[3] = R * (kalVs[3] + Q) / (R + kalVs[3] + Q)
    }
    func Kalman(value:CGFloat)->CGFloat{
        KalmanS(Q:kalVs[0],R:kalVs[1])
        let result = kalVs[2] + (value - kalVs[2]) * kalVs[4]
        kalVs[2] = result
        return result
    }
    func KalmanInit(){
            kalVs[2]=0
            kalVs[3]=0
            kalVs[4]=0
    }
    func checkDelta(cnt:Int)->Int{//
        var ret:Int=0
        if deltay[cnt]==0 && deltay[cnt+1]==0 && deltay[cnt+2]<0 && deltay[cnt+3]>0{
            ret=deltay[cnt+2]-deltay[cnt+3]
        }
        if deltay[cnt]==0 && deltay[cnt+1]==0 && deltay[cnt+2]<0 && deltay[cnt+3]<0 && deltay[cnt+4]>0{
            ret=deltay[cnt+2]+deltay[cnt+3]-deltay[cnt+4]
        }
        if deltay[cnt]==0 && deltay[cnt+1]==0 && deltay[cnt+2]<0 && deltay[cnt+3]==0 && deltay[cnt+4]>0{
            ret=deltay[cnt+2]-deltay[cnt+4]
        }
        if deltay[cnt]==0 && deltay[cnt+1]==0 && deltay[cnt+2]>0 && deltay[cnt+3]<0{
            ret=deltay[cnt+2]-deltay[cnt+3]
        }
        if deltay[cnt]==0 && deltay[cnt+1]==0 && deltay[cnt+2]>0 && deltay[cnt+3]>0 && deltay[cnt+4]<0{
            ret=deltay[cnt+2]+deltay[cnt+3]-deltay[cnt+4]
        }
        if deltay[cnt]==0 && deltay[cnt+1]==0 && deltay[cnt+2]>0 && deltay[cnt+3]==0 && deltay[cnt+4]<0{
            ret=deltay[cnt+2]-deltay[cnt+4]
        }
        return ret
    }
  
    
    func checkTap(cnt:Int)->Bool{
        let ave=checkDelta(cnt: cnt)
        if ave>3{
            tapLeft=false
            return true
        }else if ave < -3{
            tapLeft=true
            return true
        }
        return false
    }
    var cnt:Int=0
    private func updateMotionData(deviceMotion:CMDeviceMotion) {
        let ay=deviceMotion.userAcceleration.y
        kalmandata.append(Kalman(value: ay*25))
        let arrayCnt=kalmandata.count
        if arrayCnt>5{
            deltay.append(Int(kalmandata[arrayCnt-2]-kalmandata[arrayCnt-1]))
        }else{
            deltay.append(0)
        }
        if deltay.count>10{
            cnt += 1
            deltay.remove(at: 0)
            kalmandata.remove(at: 0)
            
            if checkTap(cnt: 0){
                if (CFAbsoluteTimeGetCurrent()-motionInterval)>0.3 && (CFAbsoluteTimeGetCurrent()-motionInterval)<0.5{
                    doubleTap(0)
                }
                lastTapLeft=tapLeft
                motionInterval=CFAbsoluteTimeGetCurrent()
            }
        }
    }
    
    func stopMotion() {
        isStarted = false
        motionManager.stopDeviceMotionUpdates()
    }
    func startMotion(){
        KalmanInit()
        deltay.removeAll()
        kalmandata.removeAll()
        cnt=0
        // start monitoring sensor data
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motion:CMDeviceMotion?, error:Error?) in
                self.updateMotionData(deviceMotion: motion!)
            })
        }
        isStarted = true
    }

    //motionsensor******
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
//        print(recClarification.alpha)
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
//        print(UIScreen.main.brightness)
//        UIScreen.main.brightness = CGFloat(1)//camera.getUserDefaultFloat(str: "screenBrightness", ret:1.0))
        
        let cameraType = camera.getUserDefaultInt(str: "cameraType", ret: 0)
        camera.initSession(camera: Int(cameraType), bounds:CGRect(x:0,y:0,width:0,height: 0), cameraView: recClarification)
        
        //        if cameraType==0{
        //        camera.setZoom(level:0.03)
        //        }else{
        //            camera.setZoom(level: 0)
        //        }
        //focudは最短
        camera.setZoom(level:camera.getUserDefaultFloat(str: "zoomValue", ret: 0.01))
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
        blackLeftFrame0=CGRect(x:0,y:0,width:CGFloat(left),height: view.bounds.height)
        blackRightFrame0=CGRect(x:view.bounds.width-CGFloat(right),y:0,width:CGFloat(right),height: view.bounds.height)
        blackLeftFrame=CGRect(x:0,y:0,width: view.bounds.width/6,height: view.bounds.height)
        blackRightFrame=CGRect(x:view.bounds.width*5/6,y:0,width: view.bounds.width/6,height: view.bounds.height)
        blackLeftImageView.frame=blackLeftFrame0
        blackRightImageView.frame=blackRightFrame0
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
        startMotion()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopDisplaylink()
    }
    //    override func prefersHomeIndicatorAutoHidden() -> Bool {
    //        return true
    //    }
    var lastSec:Int = -1
    var lastRandPoint:CGPoint = CGPoint(x:-200,y:-200)
    /*
    var lastrand:Int=1
     var lastRepeat:Int=1
    var lastX:Int=1
    var lastXY:Int=1
    func getRandPointX2()->CGPoint{
        if lastRepeat==1{
            let x = getLastRandom(last: lastX)
            lastRepeat=Int.random(in: 1..<4)
            lastX=x
        }else{
            lastRepeat -= 1
        }
        return CGPoint(x:centerX+CGFloat(lastX-2)*ettW,y:centerY)
    }*/
    /*   func getRandPointXY()->CGPoint {
     let xy=getRandom9()
     let x=xy/3
     let y=xy%3
     print("xy,x,y:",xy,x,y)
     return CGPoint(x:centerX+CGFloat(x-1)*ettW,y:centerY+CGFloat(y-1)*ettH)
 }*/
    func getRandPointX()->CGPoint{
        let x=getRandom3()%3
        return CGPoint(x:centerX+CGFloat(x-1)*ettW,y:centerY)
    }
    /*
    func getLastRandom(last:Int)->Int{
        var rand=Int.random(in: 1..<3)+last
        if rand>3{
            rand -= 3
        }
        return rand
    }*/
    let piStr="314159265358979323846264"
    let pi3Str="12123121231323123131321"
    var randCnt:Int=0
    func getRandom3()->Int{
        let cnt=randCnt%21+1
        let sub1 = String(pi3Str.prefix(cnt))
        let sub2 = String(sub1.suffix(1))
        randCnt += 1
//        print("cnt:",cnt,sub1,sub2)
        return Int(sub2)! - 1
    }
    func getRandom9()->Int{
        let cnt=randCnt%20+1
        let sub1 = String(piStr.prefix(cnt))
        let sub2 = String(sub1.suffix(1))
        randCnt += 1
//        print("cnt:",cnt,sub1,sub2)
        return Int(sub2)! - 1
    }
    func getRandPointXY()->CGPoint {
        let xy=getRandom9()
        let x=xy/3
        let y=xy%3
        print("xy,x,y:",xy,x,y)
        return CGPoint(x:centerX+CGFloat(x-1)*ettW,y:centerY+CGFloat(y-1)*ettH)
    }
    /*
    func getRandPointXY1()->CGPoint {
        if lastRepeat==1{
            let xy = getLastRandom8(last: lastXY)
            lastRepeat=Int.random(in: 1..<4)
            lastXY=xy
        }else{
            lastRepeat -= 1
        }
        let x=(lastXY-1)/3
        let y=(lastXY-1)%3
        print("xy,x,y:",lastRepeat,lastXY,x,y)
        return CGPoint(x:centerX+CGFloat(x-1)*ettW,y:centerY+CGFloat(y-1)*ettH)
    }
    func getLastRandom8(last:Int)->Int{
        var rand=Int.random(in: 1..<9)+last
        if rand>9{
            rand -= 9
        }
        return rand
    }
    func getRandPointX_5()->CGPoint{
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
    
    func getRandPointXY2()->CGPoint {
        var xyPoint=getRandPointX()
        let randY=Int.random(in: -1..<2)
        xyPoint.y=centerY+ettH*CGFloat(randY)
        return xyPoint
    }*/
    //        var rand = Int.random(in: 0..<9)
    //        if (rand==9){
    //            rand=4
    //        }
    //        if (lastrand==rand){
    //            rand += 1
    //            if(rand==9){
    //                rand=0
    //            }
    //        }
    //        if repeat2==1{
    //            rand=lastrand
    //        }
    //        lastrand=rand
    //        var xn:Int=0
    //        var yn:Int=0
    //        if(rand%3==0){xn = -1}
    //        else if(rand%3==1){xn=0}
    //        else {xn=1}
    //        if(rand/3==0){yn = -1}
    //        else if(rand/3==1){yn = 0}
    //        else {yn=1}
    //        let x0=centerX
    //        let xd=ettH
    //        let y0=centerY
    //        let yd=ettH
    //        return CGPoint(x:x0 + CGFloat(xn)*xd, y: y0 + CGFloat(yn)*yd)
    //    }
    /*
    func getRandPointXY25()->CGPoint {
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
    }*/
    func getSumEttSec(num:Int)->Double{
        var sumEttSec:Double=0
        for i in 0...num{
            sumEttSec += ettSec[i]
        }
        return sumEttSec
    }
    func leftRightSetBlack(amari:CGFloat){
        if amari<0.03 {
            blackLeftImageView.frame=blackLeftFrame
            blackRightImageView.frame=blackRightFrame
        }else{
            blackLeftImageView.frame=blackLeftFrame0
            blackRightImageView.frame=blackRightFrame0
        }
    }
    func leftRightSetBlack(flag:Bool){//120hzのスクリーンでは設定を変更する必要があるかもしれない
        if flag==true {
            blackLeftImageView.frame=blackLeftFrame
            blackRightImageView.frame=blackRightFrame
        }else{
            blackLeftImageView.frame=blackLeftFrame0
            blackRightImageView.frame=blackRightFrame0
        }
    }
    var leftRightBlackImageFlag:Bool=false
    func leftRightSetBlack(sec:Double,flag:Bool){//120hzのスクリーンでは設定を変更する必要があるかもしれない
        let amari=sec-Double(Int(sec))//every 10sec
        if leftRightBlackImageFlag==false && amari<0.02{
            leftRightBlackImageFlag=true
        }else{
            leftRightBlackImageFlag=false
        }
        if leftRightBlackImageFlag==true {
            blackLeftImageView.frame=blackLeftFrame
            blackRightImageView.frame=blackRightFrame
        }else{
            blackLeftImageView.frame=blackLeftFrame0
            blackRightImageView.frame=blackRightFrame0
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
                }else if ettspeed==1 || ettspeed>5{//etttype:0 ettspeed:6 ->
                    drawCircle(cPoint: CGPoint(x:centerX,y:centerY))
                    if ettspeed>5{
                        leftRightSetBlack(sec:elapset,flag: leftRightBlackImageFlag)//1秒ごとに画面を縮小表示
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
                //                leftRightSetBlack(sec:elapset,flag: leftRightBlackImageFlag)//1秒ごとに画面を縮小表示
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
