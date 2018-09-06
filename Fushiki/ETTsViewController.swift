//
//  ETTsViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2018/08/05.
//  Copyright © 2018年 tatsuaki.kuroda. All rights reserved.
//

import UIKit
import AVFoundation
class ETTsViewController: UIViewController {
    var previewLayer:AVCaptureVideoPreviewLayer!
    var device: AVCaptureDevice!
    var session: AVCaptureSession!
    var cirDiameter:CGFloat = 0
    var backMode:Int = 0
    var saccadeMode:Int = 0
    var timer: Timer!
    var timer1Interval:Int = 2

    var tcount: Int = 0
    @IBOutlet var doubleRec:UITapGestureRecognizer!
    @IBOutlet var singleRec:UITapGestureRecognizer!

    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var bothButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var left1Button: UIButton!
    @IBOutlet weak var both1Button: UIButton!
    @IBOutlet weak var right1Button: UIButton!
    @IBOutlet weak var left2Button: UIButton!
    @IBOutlet weak var both2Button: UIButton!
    @IBOutlet weak var right2Button: UIButton!
    @IBOutlet weak var time05Button: UIButton!
    @IBOutlet weak var time10Button: UIButton!
    @IBOutlet weak var checkerView: UIImageView!
    @IBOutlet weak var checker4View: UIImageView!
    @IBOutlet weak var checknView: UIImageView!
    @IBOutlet weak var checkn4View: UIImageView!
    @IBOutlet weak var cameraView: UIImageView!
 
    @IBAction func bothETT(_ sender: Any) {
        saccadeMode=12
        tcount=1
    }
    @IBAction func both1ETT(_ sender: Any) {
        saccadeMode=11
        tcount=1
    }
    @IBAction func both2ETT(_ sender: Any) {
        saccadeMode=10
        tcount=1
    }
    @IBAction func rightETT(_ sender: Any) {
        saccadeMode=20
        tcount=1
    }
    @IBAction func right1ETT(_ sender: Any) {
        saccadeMode=21
        tcount=1
    }

    @IBAction func right2ETT(_ sender: Any) {
        saccadeMode=22
        tcount=1
    }
    @IBAction func leftETT(_ sender: Any) {
        saccadeMode=02
        tcount=1
    }
    @IBAction func left1ETT(_ sender: Any) {
        saccadeMode=01
        tcount=1
    }
    @IBAction func left2ETT(_ sender: Any) {
        saccadeMode=0
        tcount=1
    }
 
     @IBAction func setTimer05(_ sender: Any) {
        timer1Interval=1
    }
    
    @IBAction func setTimer10(_ sender: Any) {
        timer1Interval=2
    }

    @IBAction func tapGes(_ sender: UITapGestureRecognizer) {
 //       print("tap")
        let pos = sender.location(in: self.view)
        if pos.y < view.bounds.height/2{
            backMode += 1
            if backMode>3{
                backMode=0
            }
            setBack()
        }else{
            if leftButton.isHidden == true{
                leftButton.isHidden=false
                bothButton.isHidden=false
                rightButton.isHidden=false
                left1Button.isHidden=false
                both1Button.isHidden=false
                right1Button.isHidden=false
                left2Button.isHidden=false
                both2Button.isHidden=false
                right2Button.isHidden=false
                time05Button.isHidden=false
                time10Button.isHidden=false
            }else{
                leftButton.isHidden=true
                bothButton.isHidden=true
                rightButton.isHidden=true
                left1Button.isHidden=true
                both1Button.isHidden=true
                right1Button.isHidden=true
                left2Button.isHidden=true
                both2Button.isHidden=true
                right2Button.isHidden=true
               time05Button.isHidden=true
                time10Button.isHidden=true
            }
        }
    }
    
    func setBack(){
        if backMode==0{
            checkerView.isHidden=true
            checker4View.isHidden=true
            checknView.isHidden=true
            checkn4View.isHidden=true
            cameraView.isHidden=true
        }else if backMode==1{//checker
            checker4View.isHidden=true
            checkn4View.isHidden=true
            if view.bounds.height/view.bounds.width>0.65{//iPad
                checknView.isHidden=false
                checkerView.isHidden=true
            }else{//iPhone
                checkerView.isHidden=false
                checknView.isHidden=true
            }
            cameraView.isHidden=true
        }else if backMode==2{//checker 1/4 random
            checkerView.isHidden=true
            checknView.isHidden=true
            if view.bounds.height/view.bounds.width>0.65{//iPad
                checkn4View.isHidden=false
                checker4View.isHidden=true
            }else{
                checkn4View.isHidden=true
                checker4View.isHidden=false
            }
            cameraView.isHidden=true
        }else{
            checkerView.isHidden=true
            checker4View.isHidden=true
            checknView.isHidden=true
            checkn4View.isHidden=true
            cameraView.isHidden=false
        }
    }
    func initViews(){
        checknView.frame.origin.x=0
        checknView.frame.origin.y=0
        checknView.frame.size.width=view.bounds.width
        checknView.frame.size.height=view.bounds.height
        checkerView.frame.origin.x=0
        checkerView.frame.origin.y=0
        checkerView.frame.size.width=view.bounds.width
        checkerView.frame.size.height=view.bounds.height
        cameraView.frame.origin.x=0
        cameraView.frame.origin.y=0
        cameraView.frame.size.width=view.bounds.width
        cameraView.frame.size.height=view.bounds.height
    }
    override func viewDidAppear(_ animated: Bool) {
        initViews()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        session = AVCaptureSession()
        //       if view.bounds.width>view.bounds.height{
        cirDiameter=view.bounds.width/26
        //       }else{
        //           cirDiameter = view.bounds.height/26
        //       }
        checker4View.frame.size.width=view.bounds.width/2
        checker4View.frame.size.height=view.bounds.height/2

        for d in AVCaptureDevice.devices() {
            if (d as AnyObject).position == AVCaptureDevice.Position.back {
                device = d as AVCaptureDevice
                print("\(device!.localizedName) found.")
            }
        }
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            print("Caught exception!")
            return
        }
        session.addInput(input)
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.frame = view.bounds
        previewLayer.videoGravity=AVLayerVideoGravity.resizeAspectFill
        //■■■向きを教える。
        if let orientation = self.convertUIOrientation2VideoOrientation(f: {return self.appOrientation()}) {
            previewLayer.connection?.videoOrientation = orientation
        }
        cameraView.layer.addSublayer(previewLayer)
        //     view.layer.addSublayer(previewLayer)
        session.startRunning()
        initViews()//見える前にも
        setBack()
        singleRec.require(toFail: doubleRec)
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        tcount=0
        
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
        leftButton.isHidden=true
        bothButton.isHidden=true
        rightButton.isHidden=true
        left1Button.isHidden=true
        both1Button.isHidden=true
        right1Button.isHidden=true
        left2Button.isHidden=true
        both2Button.isHidden=true
        right2Button.isHidden=true

        time05Button.isHidden=true
        time10Button.isHidden=true
    }
    var tcnt:Int = 0
    var lastRandom:Int = 0
    @objc func update(tm: Timer) {
        tcnt += 1
        if timer1Interval==2{
            if tcnt%2 == 0 {
                return
            }
        }
        var cPoint = CGPoint(x:0,y:0)
        if tcount > 0{
            view.layer.sublayers?.removeLast()
        }
        tcount += 1
        let sm = CGFloat(saccadeMode%10-1)
        let tc = CGFloat((tcount%5)*2-4)
        if saccadeMode/10 == 1{
            cPoint = CGPoint(x:view.bounds.width/10,y:view.bounds.height/2)
            if tcount%4 == 1 || tcount%4 == 3{
                cPoint = CGPoint(x:view.bounds.width/2,y:view.bounds.height/2)
                
            }else if tcount%4 == 2{
                cPoint = CGPoint(x:view.bounds.width*9/10,y:view.bounds.height*(5-sm*4)/10)
            }else if tcount%4 == 0{
                cPoint = CGPoint(x:view.bounds.width/10,y:view.bounds.height*(5+sm*4)/10)

            }
        }else if saccadeMode/10 == 2{
            cPoint = CGPoint(x:view.bounds.width*CGFloat((tcount%5)*2+1)/10,y:view.bounds.height*(5.0+sm*tc)/10)
        }else{
            cPoint = CGPoint(x:view.bounds.width*CGFloat(9 - (tcount%5)*2)/10,y:view.bounds.height*(5.0+sm*tc)/10)
        }
        drawCircle(cPoint:cPoint)
        var random = Int(arc4random_uniform(4))
        if random == lastRandom{
            random += 1//Int(arc4random_uniform(4))
            if random>3{
                random=0
            }
        }
        lastRandom = random
        checker4View.frame.size.width=view.bounds.width/2
        checker4View.frame.size.height=view.bounds.height/2
        checkn4View.frame.size.width=view.bounds.width/2
        checkn4View.frame.size.height=view.bounds.height/2
       if random == 0{
            checker4View.frame.origin.x=0
            checker4View.frame.origin.y=0
            checkn4View.frame.origin.x=0
            checkn4View.frame.origin.y=0

        }else if random == 1{
            checker4View.frame.origin.x=view.bounds.width/2
            checker4View.frame.origin.y=0
            checkn4View.frame.origin.x=view.bounds.width/2
            checkn4View.frame.origin.y=0
       }else if random == 2{
            checker4View.frame.origin.x=view.bounds.width/2
            checker4View.frame.origin.y=view.bounds.height/2
            checkn4View.frame.origin.x=view.bounds.width/2
            checkn4View.frame.origin.y=view.bounds.height/2
       }else{
            checker4View.frame.origin.x=0
            checker4View.frame.origin.y=view.bounds.height/2
            checkn4View.frame.origin.x=0
            checkn4View.frame.origin.y=view.bounds.height/2
        }
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
                if let orientation = self.convertUIOrientation2VideoOrientation(f: {return self.appOrientation()}) {
                    self.previewLayer?.connection?.videoOrientation = orientation
                }
        }
        )
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if timer?.isValid == true {
            timer.invalidate()
        }
    }
}
