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
    let camera = CameraAlbumEtc(name:"Fushiki")
    @IBOutlet weak var fpsLabel: UILabel!
    @IBOutlet weak var cameraView: UIImageView!
    @IBOutlet weak var fpsButton: UIButton!
    @IBOutlet weak var cameraChan: UISegmentedControl!
    @IBOutlet weak var zoomBar: UISlider!
    @IBOutlet weak var focusBar: UISlider!
    
    @IBOutlet weak var ledBar: UISlider!
    @IBOutlet weak var zoomLabel: UILabel!
    @IBOutlet weak var focusLabel: UILabel!
    
    @IBOutlet weak var ledLabel: UILabel!
    @IBOutlet weak var exitButton: UIButton!

    @IBAction func onFpsButton(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtons()
        var cameraMode=0
        if camera.getUserDefault(str: "cameraMode", ret: 0) != nil{
            cameraMode = Int(camera.getUserDefault(str: "cameraMode", ret: 0))
        }
        cameraChan.selectedSegmentIndex = cameraMode
        camera.initSession(camera: cameraMode, bounds:view.bounds, cameraView: cameraView)
        fpsLabel.text = String(format:"fps:%d" ,camera.fpsCurrent)
        zoomBar.minimumValue = 0
        zoomBar.maximumValue = 0.1
        zoomBar.addTarget(self, action: #selector(onZoomValueChange), for: UIControl.Event.valueChanged)
        zoomBar.value=camera.getUserDefault(str: "zoomValue", ret:0)
        camera.setZoom(level: zoomBar.value)
        
        ledBar.minimumValue = 0
        ledBar.maximumValue = 0.1
        ledBar.addTarget(self, action: #selector(onLedValueChange), for: UIControl.Event.valueChanged)
        ledBar.value=camera.getUserDefault(str: "ledValue", ret:0)
        camera.setLedLevel(level: ledBar.value)
        
        focusBar.minimumValue = 0
        focusBar.maximumValue = 1.0
        focusBar.addTarget(self, action: #selector(onFocusValueChange), for: UIControl.Event.valueChanged)
        focusBar.value=camera.getUserDefault(str: "focusValue", ret: 0)
        camera.setFocus(focus: focusBar.value)
        if cameraMode==2{
            cameraView.alpha=0.1
        }else{
            cameraView.alpha=1
        }
    }
    
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
        fpsLabel.text = String(format:"fps:%d" ,camera.fpsCurrent)
        camera.setLedLevel(level:camera.getUserDefault(str: "ledValue", ret:0))
    }
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
        let ww=view.bounds.width
        let wh=view.bounds.height
        let sp=ww/120//間隙
        let bw=(ww-sp*10)/7//ボタン幅
        let bh=bw*170/440
        let by=wh-bh-sp
    
        camera.setButtonProperty(exitButton,x:bw*6+sp*8,y:by,w:bw,h:bh,UIColor.darkGray)
        fpsButton.isHidden=true
        camera.setLabelProperty( fpsLabel,x:bw*1+sp*4,y:by,w:bw*2,h:bh,UIColor.white)
        camera.setLabelProperty(zoomLabel,x:bw*6+sp*8,y:by-sp/3-bh,w:bw,h:bh,UIColor.white)
        camera.setLabelProperty(focusLabel,x:bw*6+sp*8,y:by-sp*2/3-2*bh,w:bw,h:bh,UIColor.white)
        camera.setLabelProperty(ledLabel,x:bw*6+sp*8,y:by-sp*3/3-3*bh,w:bw,h:bh,UIColor.white)
        ledBar.frame=CGRect(x:5*sp,y:by-sp*3/3-3*bh,width:ww-7*sp-bw,height:bh)
        focusBar.frame=CGRect(x:5*sp,y:by-sp*2/3-2*bh,width:ww-7*sp-bw,height:bh)
        zoomBar.frame=CGRect(x:5*sp,y:by-sp/3-bh,width:ww-7*sp-bw,height:bh)
        cameraChan.frame=CGRect(x:bw*3+sp*5,y:by,width:bw*3+sp*2,height:bh)
     }
}

