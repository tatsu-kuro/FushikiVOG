//
//  ETTcViewController.swift
//  Fushiki
//
//  Created by Fushiki tatsuaki on 2018/08/05.
//  Copyright © 2018年 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import AVFoundation
class ETTViewController: UIViewController {
    
    var cirDiameter:CGFloat = 0
    var startTime=CFAbsoluteTimeGetCurrent()
    var displayLinkF:Bool=false
    var displayLink:CADisplayLink?
    var tcount: Int = 0
    var ettWidth:Int = 50
    var ettMode:Int = 0
    var targetMode:Int = 0
    var ettW:CGFloat = 0
    
    //    @IBOutlet var doubleRec:UITapGestureRecognizer!
    //    @IBOutlet var singleRec:UITapGestureRecognizer!
    //
    //
    //    @IBOutlet weak var furi2Button: UIButton!
    //    @IBOutlet weak var furi3Button: UIButton!
    
    var tapInterval=CFAbsoluteTimeGetCurrent()
    func stopDisplaylink(){
        if displayLinkF==true{
            displayLink?.invalidate()
            displayLinkF=false
        }
    }
    @IBAction func doubleTap(_ sender: Any) {
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        //        mainView.ettWidth=ettWidth
        //        mainView.oknSpeed=oknSpeed
        //        mainView.oknDirection=oknDirection
        mainView.targetMode=targetMode
        stopDisplaylink()
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
                    print("doubleTap")
                    doubleTap(0)
                    //                    self.dismiss(animated: true, completion: nil)
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            case .remoteControlNextTrack:
                ettWidth = 2
                setETTwidth(width: 2)
                tcount=1
            case .remoteControlPreviousTrack:
                ettWidth = 1
                setETTwidth(width: 1)
                tcount=1
            default:
                print("Others")
            }
        }
    }
    func setETTwidth(width:Int){
        if width == 1{
            ettW = view.bounds.width/4
        }else{
            ettW = view.bounds.width/2 - view.bounds.width/18
        }
    }
    //    @IBAction func furi2Action(_ sender: Any) {
    //        ettWidth = 1
    //        setETTwidth(width: 1)
    //        tcount=1
    //    }
    //    @IBAction func furi3Action(_ sender: Any) {
    //        ettWidth = 2
    //        setETTwidth(width: 2)
    //        tcount=1
    //    }
    
    //    func hideButtons(hide:Bool){
    //        furi2Button.isHidden=hide
    //        furi3Button.isHidden=hide
    //     }
    override func viewDidAppear(_ animated: Bool) {
        if ettWidth == 0{
            ettWidth = 2
        }
        setETTwidth(width: ettWidth)
    }
    func getUserDefault(str:String,ret:Int) -> Int{//getUserDefault_one
        if (UserDefaults.standard.object(forKey: str) != nil){//keyが設定してなければretをセット
            return UserDefaults.standard.integer(forKey:str)
        }else{
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        ettMode = getUserDefault(str: "ettMode", ret: 100)
        ettWidth = getUserDefault(str: "ettWidth", ret: 60)
        if ettWidth == 0{
            ettWidth = 2
        }
        setETTwidth(width: ettWidth)
        cirDiameter=view.bounds.width/26
        displayLink = CADisplayLink(target: self, selector: #selector(self.update))
        displayLink!.preferredFramesPerSecond = 120
        displayLink!.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        displayLinkF=true
        
        tcount=0
        //       ETTbutton.isEnabled=false
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
        //          hideButtons(hide: true)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        tapInterval=CFAbsoluteTimeGetCurrent()-1
        self.setNeedsStatusBarAppearanceUpdate()
        prefersHomeIndicatorAutoHidden()
        //        prefersStatusBarHidden
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    @objc func update() {
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
                    self.setETTwidth(width: self.ettWidth)
                }
        }
        )
    }
    //    @IBAction func tapGes(_ sender: UITapGestureRecognizer) {
    //            if furi2Button.isHidden == true{
    //                hideButtons(hide: false)
    //            }else{
    //                hideButtons(hide: true)
    //            }
    //    }
    //    @IBAction func panGes(_ sender: UIPanGestureRecognizer) {
    //
    //
    //    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopDisplaylink()
    }
}
