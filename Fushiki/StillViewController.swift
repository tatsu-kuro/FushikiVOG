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
 //   var timer: Timer!
    @IBOutlet var doubleRec:UITapGestureRecognizer!
    @IBOutlet var singleRec:UITapGestureRecognizer!
    @IBOutlet weak var checkerView: UIImageView!
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var redButton: UIButton!
    override func viewDidAppear(_ animated: Bool) {
        redButton.frame.size.width=cirDiameter
        redButton.frame.size.height=cirDiameter
        redButton.frame.origin.x=view.bounds.width/2-cirDiameter/2
        redButton.frame.origin.y=view.bounds.height/2-cirDiameter/2
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
        session.startRunning()
        setBack()
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
            
        }
        singleRec.require(toFail: doubleRec)
//        timer = Timer.scheduledTimer(timeInterval: 60*5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
//        UIApplication.shared.isIdleTimerDisabled = true//スリープしない

     }
//    @objc func update(tm: Timer) {
//        if UIApplication.shared.isIdleTimerDisabled == true{
//            UIApplication.shared.isIdleTimerDisabled = false//5分たったら監視する
//        }
//  //      print("****still timer")
//    }
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
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func doSomething(_ sender: Any) {
     }
    @IBAction func tapGes(_ sender: UITapGestureRecognizer) {
   //     print("tap")
        backMode += 1
        if backMode>2{
            backMode=0
        }
        setBack()
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
