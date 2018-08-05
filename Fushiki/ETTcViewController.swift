//
//  ETTcViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2018/08/05.
//  Copyright © 2018年 tatsuaki.kuroda. All rights reserved.
//

import UIKit
import AVFoundation
class ETTcViewController: UIViewController {
    var previewLayer:AVCaptureVideoPreviewLayer!
    var device: AVCaptureDevice!
    var session: AVCaptureSession!
    var cirDiameter:CGFloat = 0
    var backMode:Int = 0
    var timer: Timer!
    var tcount: Int = 0
    var panFlag:Bool = false
    var ettWidth:CGFloat = 200.0
    var ettSpeed:CGFloat = 0.3

    @IBOutlet weak var checkerView: UIImageView!
    
    @IBOutlet weak var cameraView: UIImageView!
      @IBOutlet weak var textIroiro: UITextField!
    func setBack(){
        if backMode==0{
            checkerView.isHidden=true
            cameraView.isHidden=true
        }else if backMode==1{
            checkerView.isHidden=false
            cameraView.isHidden=true
        }else{
            checkerView.isHidden=true
            cameraView.isHidden=false
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        session = AVCaptureSession()
        //       if view.bounds.width>view.bounds.height{
        cirDiameter=view.bounds.width/26
        //       }else{
        //           cirDiameter = view.bounds.height/26
        //       }
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
        setBack()
        
        
        //        @IBAction func startETTC(_ sender: //Any) {
        textIroiro.isHidden=true
        
           timer = Timer.scheduledTimer(timeInterval: 1.0/100.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        tcount=0
        //       ETTbutton.isEnabled=false
        UIApplication.shared.isIdleTimerDisabled = true//スリープしない

        // Do any additional setup after loading the view.
    }
    @objc func update(tm: Timer) {
        if panFlag == false{
            if tcount > 0{
                view.layer.sublayers?.removeLast()
            }
            tcount += 1
            //3.1415*5 -> 100回で１周、100回ps
            let cPoint = CGPoint(x:view.bounds.width/2 + sin(CGFloat(tcount)*ettSpeed/(3.1415*5.0))*ettWidth, y: view.bounds.height/2)
            drawCircle(cPoint:cPoint)
        }
        
            if tcount > 100*60*5 {
                if UIApplication.shared.isIdleTimerDisabled == true{
                    UIApplication.shared.isIdleTimerDisabled = false//5分たったら監視する
                }
            }

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
        //circleLayer.strokeColor =
        // 円の中の色
        circleLayer.fillColor = UIColor.red.cgColor
        // 輪郭の太さ
        //circleLayer.lineWidth = 0.5
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
                if let orientation = self.convertUIOrientation2VideoOrientation(f: {return self.appOrientation()}) {
                    self.previewLayer?.connection?.videoOrientation = orientation
                }
        }
        )
    }
    @IBAction func tapGes(_ sender: UITapGestureRecognizer) {
        //     print("tap")
        backMode += 1
        if backMode>2{
            backMode=0
        }
        setBack()
    }
    @IBAction func panGes(_ sender: UIPanGestureRecognizer) {
     
 
            if sender.state == .began {
                textIroiro.isHidden=false
                panFlag=true
            } else if sender.state == .changed {
                if sender.location(in: self.view).y>self.view.bounds.height/2{
                    
                    //               if timer?.isValid != true{
                    var pos = sender.location(in: self.view)
                    view.layer.sublayers?.removeLast()
                    pos.y = self.view.bounds.height/2
                    drawCircle(cPoint: pos)
                    ettWidth = abs(pos.x - self.view.bounds.width/2)
                    textIroiro.text = "\(ettSpeed)Hz"
                    
                }else{
                    let speed = sender.location(in: self.view).x*10/self.view.bounds.width
                    ettSpeed = CGFloat(Int(speed+2))/10.0
                    textIroiro.text = "\(ettSpeed)Hz"
                }
            }else if sender.state == .ended{
                //                if timer?.isValid != true{
                //                    view.layer.sublayers?.removeLast()
                //                    startETT(0)
                //                }
                textIroiro.text = " "
                panFlag=false
                //               setUserDefaults()
                textIroiro.isHidden=true
            }
        }

}
