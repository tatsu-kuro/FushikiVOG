//
//  CameraViewController.swift
//  Fushiki
//
//  Created by 黒田建彰 on 2021/02/10.
//  Copyright © 2021 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import AVFoundation
import GLKit
import Photos
import CoreMotion
class CameraViewController: UIViewController {
    let camera = CameraAlbumEtc()//name:"Fushiki")
    @IBOutlet weak var fpsLabel: UILabel!
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var cameraChangeButton: UIButton!
//    @IBOutlet weak var cameraChan: UISegmentedControl!
    @IBOutlet weak var zoomBar: UISlider!
    @IBOutlet weak var focusBar: UISlider!
    
    @IBOutlet weak var ledBar: UISlider!
    @IBOutlet weak var zoomLabel: UILabel!
    @IBOutlet weak var focusLabel: UILabel!
    
    @IBOutlet weak var ledLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!

    var cameraMode:Int=0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getCameras()
        print("camera:",wideAngleCamera,ultrawideCamera,telephotoCamera)
//7 true,false,true
        //12 mini true,true,false
        //se(1th) true,false,false
        setButtons()
        cameraMode = Int(camera.getUserDefaultInt(str: "cameraMode", ret: 0))
//        cameraChan.selectedSegmentIndex = cameraMode
        camera.initSession(camera: cameraMode, bounds:view.bounds, cameraView: cameraView)
        fpsLabel.text = String(format:"fps:%d %dx%d" ,camera.fpsCurrent,camera.widthCurrent,camera.heightCurrent)
 
        zoomBar.minimumValue = 0
        zoomBar.maximumValue = 0.1
        zoomBar.addTarget(self, action: #selector(onZoomValueChange), for: UIControl.Event.valueChanged)
        zoomBar.value=camera.getUserDefaultFloat(str: "zoomValue", ret:0)
        camera.setZoom(level: zoomBar.value)
        
        ledBar.minimumValue = 0
        ledBar.maximumValue = 0.1
        ledBar.addTarget(self, action: #selector(onLedValueChange), for: UIControl.Event.valueChanged)
        ledBar.value=camera.getUserDefaultFloat(str: "ledValue", ret:0)
        camera.setLedLevel(level: ledBar.value)
        
        focusBar.minimumValue = 0
        focusBar.maximumValue = 1.0
        focusBar.addTarget(self, action: #selector(onFocusValueChange), for: UIControl.Event.valueChanged)
        focusBar.value=camera.getUserDefaultFloat(str: "focusValue", ret: 0)
        camera.setFocus(focus: focusBar.value)
      
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    @IBAction func onCameraChangeButton(_ sender: Any) {
        cameraMode=camera.getUserDefaultInt(str: "cameraMode", ret: 0)
        changeCameraMode()
//        if cameraMode == 0{
//            cameraMode=1
//        }else{
//            cameraMode=0
//        }
        UserDefaults.standard.set(cameraMode, forKey: "cameraMode")
        camera.stopRunning()
        camera.initSession(camera: cameraMode, bounds:view.bounds, cameraView: cameraView)
        print("cameraMode:",cameraMode)
        fpsLabel.text = String(format:"fps:%d %dx%d" ,camera.fpsCurrent,camera.widthCurrent,camera.heightCurrent)
        camera.setLedLevel(level:camera.getUserDefaultFloat(str: "ledValue", ret:0))
        if cameraMode > 0{
            UserDefaults.standard.set(camera.fpsCurrent, forKey: "backCameraFps")
        }
        setButtons()
     }
    var wideAngleCamera:Bool=false//最低これはついている
    var ultrawideCamera:Bool=false
    var telephotoCamera:Bool=false
    var cameraType:Int = 0
    func getCameras(){
        if AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil{
            wideAngleCamera=true
        }
        if AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back) != nil{
            ultrawideCamera=true
        }
        if AVCaptureDevice.default(.builtInTelephotoCamera, for: .video, position: .back) != nil{
            telephotoCamera=true
        }
    }
    //cameraMode 0:front 1:wideangle 2:ultrawide 3:telephoto
    func changeCameraMode()
    {
        if cameraMode==0{//front
            cameraMode=1//wideAngle
        }else if cameraMode==1{
            if ultrawideCamera{
                cameraMode=2//ultrawide
            }else if telephotoCamera{
                cameraMode=3//telephoto
            }else{
                cameraMode=0//front
            }
        }else if cameraMode==2{
            if telephotoCamera{
                cameraMode=3
            }else{
                cameraMode=0
            }
        }else{
            cameraMode=0
        }
        print("cameraMode:",cameraMode)
    }
    /*
     @IBAction func onCameraChange(_ sender: Any) {//camera>1
         cameraType=UserDefaults.standard.integer(forKey:"cameraType")
         if cameraType==0{
             if telephotoCamera == true{
                 cameraType=1//telephoto
             }else if ultrawideCamera == true{
                 cameraType=2
             }
         }else if cameraType==1{
             if ultrawideCamera==true{
                 cameraType=2//ultraWide
             }else{
                 cameraType=0
             }
         }else{
             cameraType=0//wideAngle
         }
         print("cameraType",cameraType)
         UserDefaults.standard.set(cameraType, forKey: "cameraType")
          if session.isRunning{
         // セッションが始動中なら止める
             print("isrunning")
             session.stopRunning()
         }
         initSession(fps: fps_non_120_240)
         setBars()
     }
     // 入力 : 背面カメラ
     if cameraType==0{
         videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
     }else if cameraType==1{
         videoDevice = AVCaptureDevice.default(.builtInTelephotoCamera, for: .video, position: .back)

     }else if cameraType==2{
         videoDevice = AVCaptureDevice.default(.builtInUltraWideCamera, for: .video, position: .back)

     }*/
    /*
    @IBAction func onCameraChan(_ sender: UISegmentedControl) {
        let cameraMode=cameraChan.selectedSegmentIndex
        UserDefaults.standard.set(cameraMode, forKey: "cameraMode")
        if cameraMode==2{
            cameraView.alpha=0
        }else{
            cameraView.alpha=1
        }
        camera.stopRunning()
        camera.initSession(camera: cameraMode, bounds:view.bounds, cameraView: cameraView)
        print("cameraMode:",cameraMode)
        fpsLabel.text = String(format:"fps:%d %dx%d" ,camera.fpsCurrent,camera.widthCurrent,camera.heightCurrent)
        camera.setLedLevel(level:camera.getUserDefaultFloat(str: "ledValue", ret:0))
        if cameraMode == 1{
            UserDefaults.standard.set(camera.fpsCurrent, forKey: "backCameraFps")
        }
        setButtons()
    }*/
    @objc func onLedValueChange(){
        camera.setLedLevel(level:ledBar.value)
        UserDefaults.standard.set(ledBar.value, forKey: "ledValue")
    }
    @objc func onZoomValueChange(){
        camera.setZoom(level:zoomBar.value)
        UserDefaults.standard.set(zoomBar.value, forKey: "zoomValue")
    }
    @objc func onFocusValueChange(){
        print("bar:",focusBar.value*100)
        camera.setFocus(focus:focusBar.value)
        UserDefaults.standard.set(focusBar.value, forKey: "focusValue")
    }

    override func viewDidAppear(_ animated: Bool) {

    }

    func setButtons(){//type:Bool){
        // recording button
        
        let top=CGFloat(UserDefaults.standard.float(forKey: "top"))
        let bottom=CGFloat(UserDefaults.standard.float(forKey: "bottom"))
        let left=CGFloat(UserDefaults.standard.float(forKey: "left"))
        let right=CGFloat(UserDefaults.standard.float(forKey: "right"))
    
        let ww = view.bounds.width - left - right
        let wh = view.bounds.height - top - bottom

//        let ww=view.bounds.width
//        let wh=view.bounds.height
        let sp=ww/120//間隙
        let bw=(ww-sp*10)/7//ボタン幅
        let bh=bw*170/440
        let by=wh-bh-sp
        camera.setButtonProperty(exitButton,x:left+bw*6+sp*8,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setLabelProperty( fpsLabel,x:left+sp*3+bw,y:by,w:bw*2,h:bh,UIColor.white)
        camera.setLabelProperty(zoomLabel,x:left+bw*6+sp*8,y:by-sp/3-bh,w:bw,h:bh,UIColor.white)
        camera.setButtonProperty(cameraChangeButton, x: left+sp*2, y: by, w: bw, h: bh,UIColor.orange)
        
        camera.setLabelProperty(focusLabel,x:left+bw*6+sp*8,y:by-sp*2/3-2*bh,w:bw,h:bh,UIColor.white)
        camera.setLabelProperty(ledLabel,x:left+bw*6+sp*8,y:by-sp*3/3-3*bh,w:bw,h:bh,UIColor.white)
        ledBar.frame=CGRect(x:left+2*sp,y:by-sp*3/3-3*bh,width:ww-7*sp-bw,height:bh)
        focusBar.frame=CGRect(x:left+2*sp,y:by-sp*2/3-2*bh,width:ww-7*sp-bw,height:bh)
        zoomBar.frame=CGRect(x:left + 2*sp,y:by-sp/3-bh,width:ww-7*sp-bw,height:bh)
//        cameraChan.frame=CGRect(x:bw*3+sp*5,y:by,width:bw*3+sp*2,height:bh)
        if cameraMode==2{
//            cameraView.alpha=0.1
            focusBar.isHidden=true
            focusLabel.isHidden=true
            ledBar.isHidden=true
            ledLabel.isHidden=true
            zoomBar.isHidden=true
            zoomLabel.isHidden=true
        }else if cameraMode==1{
//            cameraView.alpha=1
            focusBar.isHidden=false
            focusLabel.isHidden=false
            ledBar.isHidden=false
            ledLabel.isHidden=false
            zoomBar.isHidden=false
            zoomLabel.isHidden=false
        }else if cameraMode==0{
            cameraView.alpha=1
//        cameraChan.isHidden=true
            focusBar.isHidden=true
            focusLabel.isHidden=true
            ledBar.isHidden=true
            ledLabel.isHidden=true
            zoomBar.isHidden=false
            zoomLabel.isHidden=false
    }
     }
}

