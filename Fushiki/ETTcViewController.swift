//
//  ETTcViewController.swift
//  Fushiki
//
//  Created by Fushiki tatsuaki on 2018/08/05.
//  Copyright © 2018年 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import AVFoundation
class ETTcViewController: UIViewController {
 //   var previewLayer:AVCaptureVideoPreviewLayer!
 //   var device: AVCaptureDevice!
 //   var session: AVCaptureSession!
    var cirDiameter:CGFloat = 0
    var startTime=CFAbsoluteTimeGetCurrent()

 //   var backMode:Int = 0
    var timer: Timer!
    var tcount: Int = 0
//    var panFlag:Bool = false
 //   var ettWidth:CGFloat = 0
    var ettWidth:Int = 0//1:narrow,2:wide
    var oknSpeed:Int = 0
    var oknDirection:Int = 0
    var targetMode:Int = 0
    var ettW:CGFloat = 0
//    var ettSpeed:CGFloat = 0.3
//   var ettSnd:Int = 0
//    var ettMode:Int = 0
    @IBOutlet var doubleRec:UITapGestureRecognizer!
    @IBOutlet var singleRec:UITapGestureRecognizer!

//    @IBOutlet weak var checkerView: UIImageView!
//    @IBOutlet weak var checknView: UIImageView!
    
//    @IBOutlet weak var cameraView: UIImageView!
//    @IBOutlet weak var textIroiro: UITextField!
//    @IBOutlet weak var furi1Button: UIButton!
    @IBOutlet weak var furi2Button: UIButton!
    @IBOutlet weak var furi3Button: UIButton!
//    @IBOutlet weak var herz1Button: UIButton!
//    @IBOutlet weak var herz2Button: UIButton!
//    @IBOutlet weak var herz3Button: UIButton!
//    @IBOutlet weak var sndButton: UIButton!
//    @IBOutlet weak var sndoffButton: UIButton!
//    @IBOutlet weak var pur0Button: UIButton!
//    @IBOutlet weak var pur1Button: UIButton!
//    @IBOutlet weak var pur2Button: UIButton!

//   @IBAction func furi1Action(_ sender: Any) {
//        ettWidth=view.bounds.width/8
//    }
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
    @IBAction func furi2Action(_ sender: Any) {
        ettWidth = 1
        setETTwidth(width: 1)
        tcount=1
    }
    @IBAction func furi3Action(_ sender: Any) {
        ettWidth = 2
        setETTwidth(width: 2)
        tcount=1
    }

    func hideButtons(hide:Bool){
        furi2Button.isHidden=hide
        furi3Button.isHidden=hide
     }
    override func viewDidAppear(_ animated: Bool) {
         if ettWidth == 0{
            ettWidth = 2
         }
        setETTwidth(width: ettWidth)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        print("ETTcView")
        if ettWidth == 0{
            ettWidth = 2
        }
        setETTwidth(width: ettWidth)
        cirDiameter=view.bounds.width/26
        singleRec.require(toFail: doubleRec)

 //       lastX = view.bounds.height/2

        timer = Timer.scheduledTimer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        tcount=0
        //       ETTbutton.isEnabled=false
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
          hideButtons(hide: true)
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        tapInterval=CFAbsoluteTimeGetCurrent()-1
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
 @objc func update(tm: Timer) {
    
    if tcount > 0{
        view.layer.sublayers?.removeLast()
    }
    tcount += 1
    if(tcount>60*30){
     doubleTap(0)
    }
    let elapset=CFAbsoluteTimeGetCurrent()-startTime
         
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
    @IBAction func tapGes(_ sender: UITapGestureRecognizer) {
            if furi2Button.isHidden == true{
                hideButtons(hide: false)
            }else{
                hideButtons(hide: true)
            }
    }
    @IBAction func panGes(_ sender: UIPanGestureRecognizer) {
        

    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if timer?.isValid == true {
            timer.invalidate()
        }
    }
}
