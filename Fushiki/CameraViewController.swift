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
    @IBOutlet weak var zoomLabel: UILabel!
    @IBOutlet weak var focusLabel: UILabel!
     @IBOutlet weak var exitButton: UIButton!

    @IBAction func onFpsButton(_ sender: Any) {
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setButtons()
        let cameraMode = Int(camera.getUserDefault(str: "cameraMode", ret: 0))
        cameraChan.selectedSegmentIndex = cameraMode
        camera.initSession(camera: cameraMode, bounds:view.bounds, cameraView: cameraView)
        fpsLabel.text = String(format:"fps:%d" ,camera.fpsCurrent)
        zoomBar.minimumValue = 0
        zoomBar.maximumValue = 0.1
        zoomBar.addTarget(self, action: #selector(onZoomValueChange), for: UIControl.Event.valueChanged)
        zoomBar.value=camera.getUserDefault(str: "zoomValue", ret:0)
        camera.setZoom(level: zoomBar.value)
        focusBar.minimumValue = 0
        focusBar.maximumValue = 1.0
        focusBar.addTarget(self, action: #selector(onFocusValueChange), for: UIControl.Event.valueChanged)
        focusBar.value=camera.getUserDefault(str: "focusValue", ret: 0)
        camera.setFocus(focus: focusBar.value)
    }
    
    @IBAction func onCameraChan(_ sender: UISegmentedControl) {
        let cameraMode=cameraChan.selectedSegmentIndex
        UserDefaults.standard.set(cameraMode, forKey: "cameraMode")
        camera.stopRunning()
        camera.initSession(camera: cameraMode, bounds:view.bounds, cameraView: cameraView)
        print("cameraMode:",cameraMode)
        fpsLabel.text = String(format:"fps:%d" ,camera.fpsCurrent)
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
        let bw=ww*0.9/7
        let bh=bw*170/440
        let sp=ww*0.1/10
        let by=wh-bh-sp
        camera.setButtonProperty(exitButton,x:bw*6+sp*8,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(fpsButton,x:bw*4+sp*6,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setLabelProperty( fpsLabel,x:bw*2+sp*5,y:by,w:bw*2,h:bh,UIColor.white)
        camera.setLabelProperty( zoomLabel,x:bw*6+sp*8,y:by-sp/3-bh,w:bw,h:bh,UIColor.white)
        camera.setLabelProperty(focusLabel,x:bw*6+sp*8,y:by-sp*2/3-2*bh,w:bw,h:bh,UIColor.white)
        focusBar.frame=CGRect(x:sp,y:by-sp*2/3-2*bh,width:ww-2*sp,height:bh)
        zoomBar.frame=CGRect(x:sp,y:by-sp/3-bh,width:ww-2*sp,height:bh)
        cameraChan.frame=CGRect(x:bw*5+sp*7,y:by,width:bw,height:bh)
     }
}

