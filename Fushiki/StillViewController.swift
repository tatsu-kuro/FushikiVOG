//
//  StillViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2018/08/03.
//  Copyright © 2018年 tatsuaki.kuroda. All rights reserved.
//

import UIKit
import AVFoundation
class StillViewController: UIViewController{
    var previewLayer:AVCaptureVideoPreviewLayer!
    var device: AVCaptureDevice!
    var session: AVCaptureSession!
    var cirDiameter:CGFloat = 0
    var backMode:Int = 0
    var ballSize:Int = 2
    var ballColor:Int = 0
 //   var timer: Timer!
    @IBOutlet var doubleRec:UITapGestureRecognizer!
    @IBOutlet var singleRec:UITapGestureRecognizer!
    @IBOutlet weak var checkerView: UIImageView!
    @IBOutlet weak var checknView: UIImageView!
    @IBOutlet weak var dotsView: UIImageView!
    @IBOutlet weak var dotsWideView: UIImageView!
    @IBOutlet weak var halfButton: UIButton!
    @IBOutlet weak var sameButton: UIButton!
    @IBOutlet weak var twiceButton: UIButton!
    @IBOutlet weak var redButton: UIButton!
    @IBOutlet weak var blackButton: UIButton!
    @IBOutlet weak var cameraView: UIImageView!
    @IBAction func halfAction(_ sender: Any) {
        ballSize=1
        view.layer.sublayers?.removeLast()
        drawCircle(cPoint: CGPoint(x:view.bounds.width/2,y:view.bounds.height/2))
    }
    @IBAction func sameAction(_ sender: Any) {
        ballSize=2
        view.layer.sublayers?.removeLast()
        drawCircle(cPoint: CGPoint(x:view.bounds.width/2,y:view.bounds.height/2))
    }
    @IBAction func twiceAction(_ sender: Any) {
        ballSize=4
        view.layer.sublayers?.removeLast()
        drawCircle(cPoint: CGPoint(x:view.bounds.width/2,y:view.bounds.height/2))
   }
    @IBAction func redAction(_ sender: Any) {
        ballColor=1
//        cirDiameter=view.bounds.width*CGFloat(ballSize)/52
        view.layer.sublayers?.removeLast()
        drawCircle(cPoint: CGPoint(x:view.bounds.width/2,y:view.bounds.height/2))
    }
    @IBAction func blackAction(_ sender: Any) {
        ballColor=2
//        cirDiameter=view.bounds.width*CGFloat(ballSize)/52
        view.layer.sublayers?.removeLast()
        drawCircle(cPoint: CGPoint(x:view.bounds.width/2,y:view.bounds.height/2))

    }
    override func viewDidAppear(_ animated: Bool) {
        initViews()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = AVCaptureSession()
        halfButton.isHidden=true
        sameButton.isHidden=true
        twiceButton.isHidden=true
        redButton.isHidden=true
        blackButton.isHidden=true

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
        session.startRunning()
        setBack()
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
            
        }
        singleRec.require(toFail: doubleRec)
        drawCircle(cPoint: CGPoint(x:view.bounds.width/2,y:view.bounds.height/2))
     }

    func setBack(){
         if backMode==0{
            checkerView.isHidden=true
            checknView.isHidden=true
            dotsView.isHidden=true
            dotsWideView.isHidden=true
            cameraView.isHidden=true
        }else if backMode==1{
            if view.bounds.height/view.bounds.width>0.65{//iPad
                checkerView.isHidden=true
                checknView.isHidden=false
            }else{
                checkerView.isHidden=false
                checknView.isHidden=true
            }
            dotsView.isHidden=true
            dotsWideView.isHidden=true
            cameraView.isHidden=true
        }else if backMode==2{
            checkerView.isHidden=true
            checknView.isHidden=true
            if view.bounds.height/view.bounds.width>0.65{
                dotsView.isHidden=false
                dotsWideView.isHidden=true
            }else{//iPhone
                dotsView.isHidden=true
                dotsWideView.isHidden=false
            }
            cameraView.isHidden=true
        }else{
            checknView.isHidden=true
            checkerView.isHidden=true
            dotsView.isHidden=true
            dotsWideView.isHidden=true
            cameraView.isHidden=false
        }
     }
    func drawCircle(cPoint:CGPoint){
        /* --- 円を描画 --- */
        let cirDiameter=view.bounds.width*CGFloat(ballSize)/52.0
        let circleLayer = CAShapeLayer.init()
        let circleFrame = CGRect.init(x:cPoint.x-cirDiameter/2,y:cPoint.y-cirDiameter/2,width:cirDiameter,height:cirDiameter)
        circleLayer.frame = circleFrame
        // 輪郭の色
        circleLayer.strokeColor = UIColor.white.cgColor
        // 円の中の色
        if ballColor==2{
        circleLayer.fillColor = UIColor.black.cgColor
        }else{
            circleLayer.fillColor = UIColor.red.cgColor

        }
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
        dotsView.frame.origin.x=0
        dotsView.frame.origin.y=0
        dotsView.frame.size.width=view.bounds.width
        dotsView.frame.size.height=view.bounds.height
        dotsWideView.frame.origin.x=0
        dotsWideView.frame.origin.y=0
        dotsWideView.frame.size.width=view.bounds.width
        dotsWideView.frame.size.height=view.bounds.height
    }
    @IBAction func tapGes(_ sender: UITapGestureRecognizer) {
   //     print("tap")
        let pos = sender.location(in: self.view)
        if pos.y < view.bounds.height/2{
            backMode += 1
            if backMode>3{
                backMode=0
            }
            setBack()
        }else{
            if halfButton.isHidden == true{
                halfButton.isHidden=false
                sameButton.isHidden=false
                twiceButton.isHidden=false
                redButton.isHidden=false
                blackButton.isHidden=false
            }else{
                halfButton.isHidden=true
                sameButton.isHidden=true
                twiceButton.isHidden=true
                redButton.isHidden=true
                blackButton.isHidden=true
            }
            
        }
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
}
