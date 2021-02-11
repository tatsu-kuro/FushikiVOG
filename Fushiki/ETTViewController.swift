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
//    let camera = RecordController()
    let camera = CameraAlbumEtc(name:"Fushiki")
    var cirDiameter:CGFloat = 0
    var startTime=CFAbsoluteTimeGetCurrent()
    var lastTime=CFAbsoluteTimeGetCurrent()
    var timerREC:Timer?
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
    @IBAction func doubleTap(_ sender: Any) {
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
        if cntREC==5{
            camera.recordStart()//ここだと暗くならない
        }
//        if cntREC==6{
//            camera.setFocus(focus: 0.1)
//        }else if cntREC==20{
//            camera.setFocus(focus: 0.9)
//        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        camera.makeAlbum()
        let cameraMode = camera.getUserDefault(str: "cameraMode", ret: 0)
        camera.initSession(camera: Int(cameraMode), bounds:CGRect(x:0,y:0,width:0,height: 0), cameraView: recClarification)
      
        let zoomValue=camera.getUserDefault(str: "zoomValue", ret:0)
        camera.setZoom(level: zoomValue)
        let focusValue=camera.getUserDefault(str: "focusValue", ret: 0)
        camera.setFocus(focus: focusValue)
        
        ettMode=UserDefaults.standard.integer(forKey: "ettMode")
        ettWidth=UserDefaults.standard.integer(forKey: "ettWidth")
//        let w=view.bounds.width/2
        ettW = (view.bounds.width/2)*CGFloat(ettWidth)/100.0
        ettH = (view.bounds.height/2)*CGFloat(ettWidth)/100.0
        cirDiameter=view.bounds.width/26
        if ettMode==0{//pursuit
            displayLink = CADisplayLink(target: self, selector: #selector(self.update0))
            displayLink!.preferredFramesPerSecond = 120
        }else if ettMode==1{//vert-horizon saccade
            displayLink = CADisplayLink(target: self, selector: #selector(self.update1))
            displayLink!.preferredFramesPerSecond = 120
        }else if ettMode==2{//vert-horizon saccade
            displayLink = CADisplayLink(target: self, selector: #selector(self.update2))
            displayLink!.preferredFramesPerSecond = 1
        }else{//pursuit->saccade->random
            displayLink = CADisplayLink(target: self, selector: #selector(self.update3))
            displayLink!.preferredFramesPerSecond = 120
        }
//        displayLink = CADisplayLink(target: self,
//           selector: #selector(updateAnimation))
         displayLink?.add(to: RunLoop.main, forMode: .common)
//        displayLink!.add(to: RunLoop.current, forMode: RunLoop.Mode.RunLoop.Mode.common)
        displayLinkF=true
        tcount=0
        recClarification.frame=camera.getRecClarificationRct(width:view.bounds.width,height:view.bounds.height)
        timerREC = Timer.scheduledTimer(timeInterval: 0.05, target: self, selector: #selector(self.updateRecClarification), userInfo: nil, repeats: true)

        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
        //          hideButtons(hide: true)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        tapInterval=CFAbsoluteTimeGetCurrent()-1
        self.setNeedsStatusBarAppearanceUpdate()
//        camera.sessionRecStart(fps:30)
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
 
    var initf:Bool=false
    @objc func update3() {
        if initf {
            view.layer.sublayers?.removeLast()
        }
        initf=true
        tcount += 1
        let elapset=CFAbsoluteTimeGetCurrent()-startTime
        if elapset<20.0 {//}(tcount<60*20){
            let sinV=sin(CGFloat(elapset)*3.1415*0.6)
            //let sinV=sin(CGFloat(tcount)*0.03183)//0.3Hz
            let cPoint:CGPoint = CGPoint(x:view.bounds.width/2 + sinV*ettW, y: view.bounds.height/2)
            drawCircle(cPoint:cPoint)
        }else if elapset<40.0 {//}(tcount<60*20*2){
            //    if Int(elapset) != Int(lastTime){
            if Int(elapset)%2 == 0{// }(tcount/60)%2==0){
                let cPoint:CGPoint = CGPoint(x:view.bounds.width/2 + ettW, y: view.bounds.height/2)
                drawCircle(cPoint:cPoint)
            }else{
                let cPoint:CGPoint = CGPoint(x:view.bounds.width/2 - ettW, y: view.bounds.height/2)
                drawCircle(cPoint:cPoint)
            }
            //  }
        }else if elapset<60 {//}(tcount<60*20*3){
            
            if Int(elapset) != Int(lastTime){
                rand = Int.random(in: 0..<5) - 2
                if(lastrand==rand){
                    rand += 1
                    if(rand > 2){
                        rand = -2
                    }
                }
            }
            let cg=CGFloat(rand)/2.0
            lastrand=rand
            let cPoint:CGPoint = CGPoint(x:view.bounds.width/2 - cg*ettW, y: view.bounds.height/2)
            drawCircle(cPoint:cPoint)
        }else if elapset<65{
            let cPoint:CGPoint = CGPoint(x:view.bounds.width/2, y: view.bounds.height/2)
            drawCircle(cPoint:cPoint)
            //self.dismiss(animated: true, completion: nil)
        }else{
            //             delTimer()
            doubleTap(0)
        }
        lastTime=elapset
    }
    
    @objc func update2() {
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
        let xd=CGFloat(ettWidth)*x0/100
        let y0=view.bounds.height/2
        var yd=xd
        if CGFloat(ettWidth)*x0/100>(y0-cirDiameter/2){
            yd=y0-cirDiameter/2
        }
        let cPoint:CGPoint = CGPoint(x:x0 + CGFloat(xn)*xd, y: y0 + CGFloat(yn)*yd)
        drawCircle(cPoint:cPoint)
    }
    @objc func update1() {//pursuit
        if tcount > 0{
            view.layer.sublayers?.removeLast()
        }
        tcount += 1
        let elapset=CFAbsoluteTimeGetCurrent()-startTime
        if(tcount>60*30 && elapset>29 || tcount>120*30){
            doubleTap(0)
        }
        
        let sinV=sin(CGFloat(elapset)*3.1415*0.6)
        
        let cPoint:CGPoint = CGPoint(x:view.bounds.width/2 , y: view.bounds.height/2 + sinV*ettH)
        drawCircle(cPoint:cPoint)
    }
    @objc func update0() {//pursuit
        if tcount > 0{
            view.layer.sublayers?.removeLast()
        }
        tcount += 1
        let elapset=CFAbsoluteTimeGetCurrent()-startTime
        if(tcount>60*30 && elapset>29 || tcount>120*30){
            doubleTap(0)
        }
        
        let sinV=sin(CGFloat(elapset)*3.1415*0.6)
        
        let cPoint:CGPoint = CGPoint(x:view.bounds.width/2 + sinV*ettW, y: view.bounds.height/2)
        drawCircle(cPoint:cPoint)
    }
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
