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
    @IBOutlet var doubleRec:UITapGestureRecognizer!
    @IBOutlet var singleRec:UITapGestureRecognizer!

    @IBOutlet weak var checkerView: UIImageView!
    @IBOutlet weak var checknView: UIImageView!
    
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var textIroiro: UITextField!
    @IBOutlet weak var furi1Button: UIButton!
    @IBOutlet weak var furi2Button: UIButton!
    @IBOutlet weak var furi3Button: UIButton!
    @IBOutlet weak var herz1Button: UIButton!
    @IBOutlet weak var herz2Button: UIButton!
    @IBOutlet weak var herz3Button: UIButton!
    
    @IBAction func furi1Action(_ sender: Any) {
        ettWidth=view.bounds.width/8
    }
    @IBAction func furi2Action(_ sender: Any) {
        ettWidth=view.bounds.width/4
    }
    @IBAction func furi3Action(_ sender: Any) {
        ettWidth=view.bounds.width/2 - 30
    }
    @IBAction func herz1Action(_ sender: Any) {
        ettSpeed=0.3
    }
    @IBAction func herz2Action(_ sender: Any) {
        ettSpeed=0.6
    }
    @IBAction func herz3Action(_ sender: Any) {
        ettSpeed=0.9
    }

    func hideButtons(hide:Bool){
        furi1Button.isHidden=hide
        furi2Button.isHidden=hide
        furi3Button.isHidden=hide
        herz1Button.isHidden=hide
        herz2Button.isHidden=hide
        herz3Button.isHidden=hide
     }
    func setBack(){
        if backMode==0{
            checkerView.isHidden=true
            checknView.isHidden=true
            cameraView.isHidden=true
        }else if backMode==1{
            
            if view.bounds.height/view.bounds.width>0.65{//iPad
                checknView.isHidden=false
                   checkerView.isHidden=true
            }else{//iPhone
                checkerView.isHidden=false
                  checknView.isHidden=true
            }
            //checkerView.isHidden=false
            cameraView.isHidden=true
        }else{
            checkerView.isHidden=true
            checknView.isHidden=true
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
 //       initViews()
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
        singleRec.require(toFail: doubleRec)

        
        //        @IBAction func startETTC(_ sender: //Any) {
        textIroiro.isHidden=true
        
           timer = Timer.scheduledTimer(timeInterval: 1.0/100.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        tcount=0
        //       ETTbutton.isEnabled=false
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
        // Do any additional setup after loading the view.
        hideButtons(hide: true)
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
  //      print("timer",tcount)
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
                if let orientation = self.convertUIOrientation2VideoOrientation(f: {return self.appOrientation()}) {
                    self.previewLayer?.connection?.videoOrientation = orientation
                }
        }
        )
    }
    @IBAction func tapGes(_ sender: UITapGestureRecognizer) {
        //     print("tap")
        let pos = sender.location(in: self.view)
        if pos.y < view.bounds.height/2{
        backMode += 1
        if backMode>2{
            backMode=0
        }
        setBack()
        }else{
            if furi1Button.isHidden == true{
                hideButtons(hide: false)
            }else{
                hideButtons(hide: true)
            }
        }
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
            //print(ettSpeed,ettWidth,view.bounds.width)
            //79,200,343/width=736
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
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if timer?.isValid == true {
            timer.invalidate()
        }
    }
}
