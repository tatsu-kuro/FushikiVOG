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
    let camera = CameraAlbumEtc()//name:"Fushiki")
    var cirDiameter:CGFloat = 0
    var startTime=CFAbsoluteTimeGetCurrent()
    var lastTime=CFAbsoluteTimeGetCurrent()
    var timerREC:Timer?
//    var mainBrightness:CGFloat?
    @IBOutlet weak var recClarification: UIImageView!
    var displayLinkF:Bool=false
    var displayLink:CADisplayLink?
    var tcount: Int = 0
    var ettWidth:Int = 50
    var ettMode:Int = 0
    var targetMode:Int = 0
    var ettW:CGFloat = 0
    var ettH:CGFloat = 0
    var recordedF:Bool = false

    var tapInterval=CFAbsoluteTimeGetCurrent()
    func stopDisplaylink(){
        if displayLinkF==true{
            displayLink?.invalidate()
            displayLinkF=false
        }
    }
    
    /*
     func exit4OKN(){
         let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
         mainView.targetMode=targetMode
 //        UIScreen.main.brightness=mainBrightness!
         delTimer()
         camera.recordStop()//fileOutput.stopRecording()
         performSegue(withIdentifier: "fromOKN", sender: self)
     }
     */
    
    
    @IBAction func doubleTap(_ sender: Any) {
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        mainView.targetMode=targetMode
        delTimer()
        camera.recordStop()
//        UIScreen.main.brightness=mainBrightness!
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
            case .remoteControlNextTrack:
//                ettWidth = 2
//                setETTwidth(width: 2)
                tcount=1
            case .remoteControlPreviousTrack:
//                ettWidth = 1
//                setETTwidth(width: 1)
                tcount=1
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
    @objc func updateRecClarification(tm: Timer) {//録画していることを明確に示す必要がある
        cntREC += 1
        recClarification.alpha=camera.updateRecClarification(tm: cntREC)
        if cntREC==20{
            camera.recordStart()//ここだと暗くならない
        }
//        if cntREC==6{
//            camera.setFocus(focus: 0.1)
//        }else if cntREC==20{
//            camera.setFocus(focus: 0.9)
//        }
    }
    var ettType = Array<Int>()
    var ettSpeed = Array<Int>()
    var ettSec = Array<Double>()
    var currentEttNum:Int = 0
    var centerX:CGFloat=0
    var centerY:CGFloat=0

    override func viewDidLoad() {
        super.viewDidLoad()
   
        camera.makeAlbum()
//        mainBrightness=UIScreen.main.brightness//明るさを保持、終了時に戻す
        print(UIScreen.main.brightness)
        UIScreen.main.brightness = CGFloat(camera.getUserDefaultFloat(str: "screenBrightness", ret:1.0))
        let cameraType = camera.getUserDefaultInt(str: "cameraType", ret: 0)
        camera.initSession(camera: Int(cameraType), bounds:CGRect(x:0,y:0,width:0,height: 0), cameraView: recClarification)
      
        let zoomValue=camera.getUserDefaultFloat(str: "zoomValue", ret:0)
        camera.setZoom(level: zoomValue)
        let focusValue=camera.getUserDefaultFloat(str: "focusValue", ret: 0)
        camera.setFocus(focus: focusValue)
        camera.setLedLevel(level:camera.getUserDefaultFloat(str: "ledValue", ret:0))

        ettMode=UserDefaults.standard.integer(forKey: "ettMode")
        ettWidth=UserDefaults.standard.integer(forKey: "ettWidth")
//        let w=view.bounds.width/2
        
//        ettMode=UserDefaults.standard.integer(forKey: "ettMode")
//        ettWidth=UserDefaults.standard.integer(forKey: "ettWidth")
        ettType.removeAll()
        ettSpeed.removeAll()
        ettSec.removeAll()
        currentEttNum=0
        startTime=CFAbsoluteTimeGetCurrent()
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
    
        let ww=view.bounds.width-CGFloat(left+right)
        let wh=view.bounds.height-CGFloat(top+bottom)
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

        tcount=0
        displayLink?.add(to: RunLoop.main, forMode: .common)
        displayLinkF=true
 
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
            timerREC = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.updateRecClarification), userInfo: nil, repeats: true)
            recClarification.frame=camera.getRecClarificationRct(width:view.bounds.width,height:view.bounds.height)
        }
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
        //          hideButtons(hide: true)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        // ファーストレスポンダにする（その結果、キーボードが表示される）
//        self.becomeFirstResponder()
        tapInterval=CFAbsoluteTimeGetCurrent()-1
        self.setNeedsStatusBarAppearanceUpdate()
//        camera.sessionRect(fps:30)
    
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
    @objc func update() {//pursuit
        if tcount > 0{
            view.layer.sublayers?.removeLast()
        }
        tcount += 1
        let elapset=CFAbsoluteTimeGetCurrent()-startTime
        if elapset<ettSec[currentEttNum]{
            let etttype=ettType[currentEttNum]
            if etttype == 1{//振り子横
                let ettspeed=CGFloat(ettSpeed[currentEttNum])
                let sinV=sin(CGFloat(elapset)*3.1415*0.3*ettspeed)
                let cPoint:CGPoint = CGPoint(x:centerX + sinV*ettW, y: centerY)
                drawCircle(cPoint:cPoint)
            }else if etttype==2{//振り子縦
                let ettspeed=CGFloat(ettSpeed[currentEttNum])
                let sinV=sin(CGFloat(elapset)*3.1415*0.3*ettspeed)
                let cPoint:CGPoint = CGPoint(x:centerX , y: centerY + sinV*ettH)
                drawCircle(cPoint:cPoint)
            }else if etttype==3{//衝動横
                let ettspeed=Double(ettSpeed[currentEttNum])
                let sec=Int(elapset*ettspeed/2)
                if ettspeed==0{
                    drawCircle(cPoint: CGPoint(x:centerX,y:centerY))
                }else{
                    if sec%2==0{
                        let cPoint=CGPoint(x:centerX+ettW,y:centerY)
                        drawCircle(cPoint: cPoint)
                    }else{
                        let cPoint=CGPoint(x:centerX-ettW,y:centerY)
                        drawCircle(cPoint: cPoint)
                    }
                }
            }else if etttype==4{//衝動縦
                let ettspeed=Double(ettSpeed[currentEttNum])
                let sec=Int(elapset*ettspeed/2)
                if ettspeed==0{
                    drawCircle(cPoint: CGPoint(x:centerX,y:centerY))
                }else{
                    if sec%2==0{
                        let cPoint=CGPoint(x:centerX,y:centerY+ettH)
                        drawCircle(cPoint: cPoint)
                    }else{
                        let cPoint=CGPoint(x:centerX,y:centerY-ettH)
                        drawCircle(cPoint: cPoint)
                    }
                }
//            }else if etttype==5{
            }else{
                let ettspeed=Double(ettSpeed[currentEttNum])
                let sec=Int(elapset*ettspeed/2)
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
                if tcount%100==0{
                    print("owari!!")
                    doubleTap(0)
                }
                currentEttNum -= 1
            }else{
                startTime=CFAbsoluteTimeGetCurrent()
            }
            drawCircle(cPoint: CGPoint(x:-200,y:-200))//damy
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
