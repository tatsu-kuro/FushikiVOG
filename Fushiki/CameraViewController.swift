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
    let camera = myFunctions()//name:"Fushiki")
    @IBOutlet weak var cameraFpsLabel: UILabel!
    
    @IBOutlet weak var cameraTypeLabel: UILabel!
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var cameraChangeButton: UIButton!
    @IBOutlet weak var zoomBar: UISlider!
    @IBOutlet weak var focusBar: UISlider!
    @IBOutlet weak var ledBar: UISlider!
    @IBOutlet weak var zoomBarLabel: UILabel!
    @IBOutlet weak var focusBarLabel: UILabel!
    @IBOutlet weak var ledBarLabel: UILabel!
    
    @IBOutlet weak var ledValueLabel: UILabel!
    @IBOutlet weak var zoomValueLabel: UILabel!
    
    @IBOutlet weak var focusValueLabel: UILabel!
    
    @IBOutlet weak var exitButton: UIButton!
    let cameraTypeStrings : Array<String> = ["frontCamera","wideAngleCamera","ultraWideCamera","telePhotoCamera"]
    var cameraType:Int=0
    override func viewDidLoad() {
        super.viewDidLoad()
        getCameras()
        cameraType = Int(camera.getUserDefaultInt(str: "cameraType", ret: 0))
        setButtons()
        cameraView.frame=self.view.frame
//        print("camerwType:",cameraModeStrings[cameraMode])
        camera.initSession(camera: cameraType, cameraView)
//        print("camera:",cameraModeStrings[cameraMode])
//        print("camera:",cameraMode,cameraModeStrings[cameraMode])
//        let cameraStr=cameraModeStrings[cameraMode]
//        fpsLabel.text = String(format:"%s fps:%d %dx%d" ,cameraStr,camera.fpsCurrent,camera.widthCurrent,camera.heightCurrent)

//        fpsLabel.text = String(format:"%s fps:%d %dx%d" ,cameraModeStrings[cameraMode],camera.fpsCurrent,camera.widthCurrent,camera.heightCurrent)
        cameraFpsLabel.text = String(format:"fps:%d %dx%d" ,camera.fpsCurrent,camera.widthCurrent,camera.heightCurrent)
        cameraTypeLabel.text = cameraTypeStrings[cameraType]
        zoomBar.minimumValue = 0
        zoomBar.maximumValue = 0.1
        zoomBar.addTarget(self, action: #selector(onZoomValueChange), for: UIControl.Event.valueChanged)
        zoomBar.value=camera.getUserDefaultFloat(str: "zoomValue", ret:0.01)
        camera.setZoom(level: zoomBar.value)
        zoomValueLabel.text=(Int(zoomBar.value*1000)).description

        ledBar.minimumValue = 0
        ledBar.maximumValue = 0.1
        ledBar.addTarget(self, action: #selector(onLedValueChange), for: UIControl.Event.valueChanged)
        ledBar.value=camera.getUserDefaultFloat(str: "ledValue", ret:0)
        camera.setLedLevel(ledBar.value)
        ledValueLabel.text=(Int(ledBar.value*1000)).description

        focusBar.minimumValue = 0
        focusBar.maximumValue = 1.0
        focusBar.addTarget(self, action: #selector(onFocusValueChange), for: UIControl.Event.valueChanged)
        focusBar.value=camera.getUserDefaultFloat(str: "focusValue", ret: 0)
        camera.setFocus(focus: focusBar.value)
        focusValueLabel.text=(Int(focusBar.value*100)).description

    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }

    @IBAction func onCameraChangeButton(_ sender: Any) {
        cameraType=camera.getUserDefaultInt(str: "cameraType", ret: 0)
        changeCameraMode()

        UserDefaults.standard.set(cameraType, forKey: "cameraType")
        camera.stopRunning()
        camera.initSession(camera: cameraType,cameraView)
        print("camera:",cameraType,cameraTypeStrings[cameraType])

        cameraFpsLabel.text = String(format:"fps:%d %dx%d" ,camera.fpsCurrent,camera.widthCurrent,camera.heightCurrent)
        cameraTypeLabel.text = cameraTypeStrings[cameraType]
        camera.setLedLevel(camera.getUserDefaultFloat(str: "ledValue", ret:0))
        
        if cameraType > 0{
            UserDefaults.standard.set(camera.fpsCurrent, forKey: "backCameraFps")
        }
        camera.setLedLevel(ledBar.value)
//        camera.setLedLevel(ledBar.value)
        ledValueLabel.text=(Int(ledBar.value*1000)).description

        camera.setZoom(level:zoomBar.value)
        zoomValueLabel.text=(Int(zoomBar.value*1000)).description

        setButtons()
     }
    var wideAngleCamera:Bool=false//最低これはついている
    var ultrawideCamera:Bool=false
    var telephotoCamera:Bool=false

    func getCameras(){
        if AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) != nil{
            wideAngleCamera=true
        }
        //以下は選べないように変更
//        ultrawideCamera=false
//        telephotoCamera=false
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
        if cameraType==0{//front
            cameraType=1//wideAngle
        }else if cameraType==1{
            if ultrawideCamera{
                cameraType=2//ultrawide
            }else if telephotoCamera{
                cameraType=3//telephoto
            }else{
                cameraType=0//front
            }
        }else if cameraType==2{
            if telephotoCamera{
                cameraType=3
            }else{
                cameraType=0
            }
        }else{
            cameraType=0
        }
        print("cameraType:",cameraType)
    }
  
    @objc func onLedValueChange(){
        camera.setLedLevel(ledBar.value)
        ledValueLabel.text=(Int(ledBar.value*1000)).description

        UserDefaults.standard.set(ledBar.value, forKey: "ledValue")
    }
    @objc func onZoomValueChange(){
        camera.setZoom(level:zoomBar.value)
        zoomValueLabel.text=(Int(zoomBar.value*1000)).description

        UserDefaults.standard.set(zoomBar.value, forKey: "zoomValue")
    }
    @objc func onFocusValueChange(){
//        print("bar:",focusBar.value*100)
        camera.setFocus(focus:focusBar.value)
        focusValueLabel.text=(Int(focusBar.value*100)).description

        
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
        
  
        camera.setLabelProperty(focusBarLabel,x:left+bw*6+sp*8,y:by-sp*3/3-3*bh,w:bw,h:bh,UIColor.white)
        camera.setLabelProperty(focusValueLabel,x:left+bw*5+sp*7,y:by-sp*3/3-3*bh,w:bw,h:bh,UIColor.white)
        focusBar.frame=CGRect(x:left+2*sp,y:by-sp*3/3-3*bh,width:ww-7*sp-bw*2,height:bh)
        camera.setLabelProperty(ledBarLabel,x:left+bw*6+sp*8,y:by-sp*2/3-2*bh,w:bw,h:bh,UIColor.white)
        camera.setLabelProperty(ledValueLabel,x:left+bw*5+sp*7,y:by-sp*2/3-2*bh,w:bw,h:bh,UIColor.white)
        ledBar.frame=CGRect(x:left+2*sp,y:by-sp*2/3-2*bh,width:ww-7*sp-bw*2,height:bh)
        camera.setLabelProperty(zoomBarLabel,x:left+bw*6+sp*8,y:by-sp/3-bh,w:bw,h:bh,UIColor.white)
        camera.setLabelProperty(zoomValueLabel,x:left+bw*5+sp*7,y:by-sp/3-bh,w:bw,h:bh,UIColor.white)
        zoomBar.frame=CGRect(x:left + 2*sp,y:by-sp/3-bh,width:ww-7*sp-bw*2,height:bh)

        camera.setButtonProperty(exitButton,x:left+bw*6+sp*8,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setLabelProperty( cameraFpsLabel,x:left+bw*2+sp*3,y:by,w:bw*2,h:bh,UIColor.white)
        camera.setLabelProperty( cameraTypeLabel,x:left+sp*2,y:by,w:bw*2,h:bh,UIColor.orange)
        camera.setButtonProperty(cameraChangeButton, x: left+bw*5+sp*7, y: by, w: bw, h: bh,UIColor.orange)
        focusBar.isHidden=true
        focusBarLabel.isHidden=true
        focusValueLabel.isHidden=true
        ledBar.isHidden=true
        ledBarLabel.isHidden=true
        ledValueLabel.isHidden=true
        if cameraType==1 {
            focusBar.isHidden=false
            focusBarLabel.isHidden=false
            focusValueLabel.isHidden=false

            ledBar.isHidden=false
            ledBarLabel.isHidden=false
            ledValueLabel.isHidden=false

        }else if cameraType==2{
            ledBar.isHidden=false
            ledBarLabel.isHidden=false
            ledValueLabel.isHidden=false
        }
        print("setButtonsCameraType:",cameraType)

    }
    
//     Frontcamera zoom
//     wideAngle zoom led focus
//     Ultra zoom led
  
}

