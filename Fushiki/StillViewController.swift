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
    var previewLayer:AVCaptureVideoPreviewLayer!//(session: session)
    var device: AVCaptureDevice!
    var session: AVCaptureSession!
    var output: AVCapturePhotoOutput!
    @IBOutlet weak var cameraView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        session = AVCaptureSession()
        // バックカメラを選択
//        for d in AVCaptureDevice.DiscoverySession{
            
//        }
        for d in AVCaptureDevice.devices() {
            // Swift 3まで
            // if (d as AnyObject).position == AVCaptureDevicePosition.back {
            if (d as AnyObject).position == AVCaptureDevice.Position.back {
                // Swift 3まで
                // device = d as? AVCaptureDevice
                device = d as AVCaptureDevice
                print("\(device!.localizedName) found.")
            }
        }
        // バックカメラからキャプチャ入力生成
        // Swift 3まで
        // let input: AVCaptureDeviceInput?
        guard let input = try? AVCaptureDeviceInput(device: device) else {
            print("Caught exception!")
            return
        }
        session.addInput(input)
//        output = AVCapturePhotoOutput()
//        session.addOutput(output)
        // Swift 3まで
        // session.sessionPreset = AVCaptureSessionPresetPhoto
        session.sessionPreset = .photo
        // プレビューレイヤを生成
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        // Swift 3まで
         previewLayer.frame = view.bounds
        previewLayer.videoGravity=AVLayerVideoGravity.resizeAspectFill
        // view.layer.addSublayer(previewLayer!)
 //       previewLayer.frame = cameraView.bounds
//        previewLayer.frame.origin.x=0
//        previewLayer.frame.origin.y=0
//        previewLayer.frame.size.width=200
//        previewLayer.frame.size.height=200
        
        
        //■■■向きを教える。
        if let orientation = self.convertUIOrientation2VideoOrientation(f: {return self.appOrientation()}) {
            previewLayer.connection?.videoOrientation = orientation
        }
        
        view.layer.addSublayer(previewLayer)

        
        
        
        cameraView.layer.addSublayer(previewLayer)
        // セッションを開始
        session.startRunning()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    @IBAction func doSomething(_ sender: Any) {
     }
    @IBAction func tapGes(_ sender: UITapGestureRecognizer) {
        print("tap")
        self.dismiss(animated:true,completion:nil)
    }
    
    func appOrientation() -> UIInterfaceOrientation {
        return UIApplication.shared.statusBarOrientation
    }
    
    // UIInterfaceOrientation -> AVCaptureVideoOrientationにConvert
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
    
    func initilize() {
//        //カメラ周りの初期化など…
//
//        //■■■向きを教える。
//        if let orientation = self.convertUIOrientation2VideoOrientation(f: {return self.appOrientation()}) {
//            videoPreviewLayer?.connection.videoOrientation = orientation
//        }
//
//        view.layer.addSublayer(videoPreviewLayer)
    }
        //画面の回転にも対応したい時は viewWillTransitionToSize で同じく向きを教える。
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
    
        coordinator.animate(
            alongsideTransition: nil,
                completion: {(UIViewControllerTransitionCoordinatorContext) in
                    //画面の回転後に向きを教える。
                    if let orientation = self.convertUIOrientation2VideoOrientation(f: {return self.appOrientation()}) {
                        self.previewLayer?.connection?.videoOrientation = orientation
 //                       orientation
                    }
            }
            )
        }

    
//    //画面の回転にも対応したい時は viewWillTransitionToSize で同じく向きを教える。
//    override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
//
//        coordinator.animateAlongsideTransition(
//            nil,
//            completion: {(UIViewControllerTransitionCoordinatorContext) in
//                //画面の回転後に向きを教える。
//                if let orientation = self.convertUIOrientation2VideoOrientation({return self.appOrientation()}) {
//                    videoPreviewLayer?.connection.videoOrientation = orientation
//                }
//        }
//        )
//    }

}
