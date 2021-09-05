//
//  SetteiViewController.swift
//  Fushiki
//
//  Created by 黒田建彰 on 2020/07/17.
//  Copyright © 2020 tatsuaki.Fushiki. All rights reserved.
//

import UIKit

class SetteiViewController: UIViewController {
    let camera = CameraAlbumEtc()//name:"Fushiki")
    var oknMode:Int=0
    var oknSpeed:Int = 50
    var oknTime:Int = 50
    var okpMode:Int=0
    var okpSpeed:Int=50
    var okpTime:Int=50
    var ettMode:Int = 0
    var ettWidth:Int=50
    var targetMode:Int=0
    var screenBrightness:Float!
    
    @IBOutlet weak var frontCameraLabel: UILabel!
    @IBOutlet weak var frontCameraSwitch: UISwitch!
    
    @IBAction func onFrontCameraSwitch(_ sender: UISwitch) {
        var cameraMode:Int!
        if sender.isOn==true{
           cameraMode=0
        }else{
            cameraMode=2
        }
        UserDefaults.standard.set(cameraMode, forKey: "cameraMode")
    }
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var paraCnt0: UISegmentedControl!
    @IBOutlet weak var paraCnt1: UISlider!
    @IBOutlet weak var paraCnt2: UISlider!
    @IBOutlet weak var paraCnt3: UISegmentedControl!
    @IBOutlet weak var paraCnt4: UISlider!
    @IBOutlet weak var paraCnt5: UISlider!
    @IBOutlet weak var paraCnt6: UISegmentedControl!
    @IBOutlet weak var paraCnt7: UISlider!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var paraCnt8: UISlider!
    @IBOutlet weak var defaultButton: UIButton!
    @IBOutlet weak var paraTxt0: UILabel!
    @IBOutlet weak var paraTxt1: UILabel!
    @IBOutlet weak var paraTxt2: UILabel!
    @IBOutlet weak var paraTxt3: UILabel!
    @IBOutlet weak var paraTxt4: UILabel!
    @IBOutlet weak var paraTxt5: UILabel!
    @IBOutlet weak var paraTxt6: UILabel!
    @IBOutlet weak var paraTxt7: UILabel!
    
    @IBOutlet weak var paraTxt8: UILabel!
    var tapInterval=CFAbsoluteTimeGetCurrent()

    override func remoteControlReceived(with event: UIEvent?) {
         guard event?.type == .remoteControl else { return }
         
         if let event = event {
             
             switch event.subtype {
             case .remoteControlPlay:
                 print("Play")
                 if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                     print("doubleTapPlay")
                     goExit(0)
                     //                    self.dismiss(animated: true, completion: nil)
                 }
                 tapInterval=CFAbsoluteTimeGetCurrent()
             case .remoteControlTogglePlayPause:
                 print("TogglePlayPause")
                 if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                     print("doubleTapTogglePlayPause")
                     goExit(0)
                     //                    self.dismiss(animated: true, completion: nil)
                 }
                 tapInterval=CFAbsoluteTimeGetCurrent()
             default:
                 print("Others")
             }
         }
    }
    @IBAction func exitBut(_ sender: Any) {
        goExit(0)
    }
    func setUserDefaults(){
        UserDefaults.standard.set(okpSpeed, forKey: "okpSpeed")
        UserDefaults.standard.set(okpTime, forKey: "okpTime")
        UserDefaults.standard.set(okpMode, forKey: "okpMode")
        UserDefaults.standard.set(oknSpeed, forKey: "oknSpeed")
        UserDefaults.standard.set(oknTime, forKey: "oknTime")
        UserDefaults.standard.set(oknMode, forKey: "oknMode")
        UserDefaults.standard.set(ettMode,forKey: "ettMode")
        UserDefaults.standard.set(ettWidth,forKey: "ettWidth")
        UserDefaults.standard.set(screenBrightness, forKey: "screenBrightness")
    }
    @IBAction func goExit(_ sender: Any) {
//        UserDefaults.standard.set(okpSpeed, forKey: "okpSpeed")
//        UserDefaults.standard.set(okpTime, forKey: "okpTime")
//        UserDefaults.standard.set(okpMode, forKey: "okpMode")
//        UserDefaults.standard.set(oknSpeed, forKey: "oknSpeed")
//        UserDefaults.standard.set(oknTime, forKey: "oknTime")
//        UserDefaults.standard.set(oknMode, forKey: "oknMode")
//        UserDefaults.standard.set(ettMode,forKey: "ettMode")
//        UserDefaults.standard.set(ettWidth,forKey: "ettWidth")
//        UserDefaults.standard.set(screenBrightness, forKey: "screenBrightness")
        setUserDefaults()
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        //delTimer()
        mainView.targetMode=targetMode
        self.present(mainView, animated: false, completion: nil)
    }
    
     @IBAction func paraAct0(_ sender: UISegmentedControl) {
          okpMode=sender.selectedSegmentIndex
          dispTexts()
      }

     @IBAction func paraAct1(_ sender: UISlider) {
         okpSpeed=Int(sender.value*200)
         dispTexts()
     }
     
     @IBAction func paraAct2(_ sender: UISlider) {
         okpTime=Int(sender.value*50)
         dispTexts()
     }
      @IBAction func paraAct3(_ sender: UISegmentedControl) {
           oknMode=sender.selectedSegmentIndex
           dispTexts()
       }
     @IBAction func paraAct4(_ sender: UISlider) {
         oknSpeed=Int(sender.value*200)
         dispTexts()
     }
     
     @IBAction func paraAct5(_ sender: UISlider) {
         oknTime=Int(sender.value*100)
         dispTexts()
     }
     @IBAction func paraAct6(_ sender: UISegmentedControl) {
           ettMode=sender.selectedSegmentIndex
           dispTexts()
//        print("chante ett mode:",ettMode)
       }
     @IBAction func paraAct7(_ sender: UISlider) {
         ettWidth=Int(sender.value*100)
         dispTexts()
     }
    @IBAction func paraAct8(_ sender: UISlider) {
//        UserDefaults.standard.set(sender.value, forKey: "screenBrightness")
        screenBrightness=sender.value
        setUserDefaults()
    }
    
    @IBAction func defaultAct(_ sender: Any) {
        okpMode=0
        okpSpeed=100
        okpTime=5
        oknMode=0
        oknSpeed=100
        oknTime=60
         ettMode=0
        ettWidth=90
        setPars()
        dispTexts()
    }
    func setPars(){
        paraCnt0.selectedSegmentIndex=okpMode%4
        paraCnt1.value=Float(okpSpeed)/200.0
        paraCnt2.value=Float(okpTime)/50.0
        paraCnt3.selectedSegmentIndex=oknMode%4
        paraCnt4.value=Float(oknSpeed)/200.0
        paraCnt5.value=Float(oknTime)/100.0
        paraCnt6.selectedSegmentIndex=ettMode%4
        paraCnt7.value=Float(ettWidth)/100.0
        paraCnt8.value=camera.getUserDefaultFloat(str: "screenBrightness", ret: 1.0)
    }
    func setokpMode(){
        paraTxt0.text="OKP-MODE" + "   "
        if okpMode == 0{
            paraTxt0.text! += " right -> " + String(Int(okpTime)) + "sec -> left"
        }else if okpMode == 1{
            paraTxt0.text! += " left -> " + String(Int(okpTime)) + "sec -> right"
        }else if okpMode == 2{
            paraTxt0.text! += " right"
        }else{
            paraTxt0.text! += " left"
        }
    }
    func setoknMode(){
        paraTxt3.text="OKN-MODE" + "   "
        if oknMode == 0{
            paraTxt3.text! += " right(" + String(Int(oknTime)) + "sec) -> black"
        }else if oknMode == 1{
            paraTxt3.text! += " left(" + String(Int(oknTime)) + "sec) -> black"
        }else if oknMode == 2{
            paraTxt3.text! += " right"
        }else{
            paraTxt3.text! += " left"
        }
    }
    func setettMode(){
        paraTxt6.text="ETT-MODE" + "   "
        if ettMode == 0{
            paraTxt6.text! += " pursuit(30s) horizontal"
        }else if ettMode == 1{
            paraTxt6.text! += " sursuit(30s) vertical"
        }else if ettMode == 2{
            paraTxt6.text! += " saccade(30s) horizontal & vertical"
        }else{
            paraTxt6.text! += " pursuit(20s)->saccade(20s)->random(20s)"
        }
    }
    func setokpSpeed(){
        paraTxt1.text="OKP-MaxSPEED:" + String(Int(okpSpeed*15)) + "pt/sec" + "  ScreenWidth(" + String(Int(view.bounds.width)) + "pt)"
    }
    func setoknSpeed(){
        paraTxt4.text="OKN-SPEED:" + String(Int(oknSpeed*15)) + "pt/sec" + "  ScreenWidth(" + String(Int(view.bounds.width)) + "pt)"
    }
    func dispTexts(){
        setokpMode()
        setoknMode()
        setettMode()
        setokpSpeed()
        setoknSpeed()
        paraTxt2.text="OKP-PAUSE:" + String(Int(okpTime)) + "sec"
        paraTxt5.text="OKN-TIME:" + String(Int(oknTime)) + "sec"
        paraTxt7.text="ETT-WIDTH:" + String(Int(ettWidth)) + "%"
        setUserDefaults()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        okpMode = UserDefaults.standard.integer(forKey: "okpMode")
        okpSpeed = UserDefaults.standard.integer(forKey: "okpSpeed")
        okpTime = UserDefaults.standard.integer(forKey: "okpTime")
        oknMode = UserDefaults.standard.integer(forKey: "oknMode")
        oknSpeed = UserDefaults.standard.integer(forKey: "oknSpeed")
        oknTime = UserDefaults.standard.integer(forKey: "oknTime")
        ettMode = UserDefaults.standard.integer(forKey: "ettMode")
        ettWidth = UserDefaults.standard.integer(forKey: "ettWidth")
        let cameraMode = camera.getUserDefaultInt(str: "cameraMode", ret: 0)
        if cameraMode==0{//front camera
            frontCameraSwitch.isOn=true
        }else{//don't use camera
            frontCameraSwitch.isOn=false
        }
        screenBrightness = camera.getUserDefaultFloat(str: "screenBrightness", ret: 1.0)
        setScreen()
        dispTexts()
        setPars()
        // Do any additional setup after loading the view.
    }
    
      override var prefersStatusBarHidden: Bool {
          return true
      }
      override var prefersHomeIndicatorAutoHidden: Bool {
          return true
      }
    func setScreen(){
//        let ww=view.bounds.width
//        let wh=view.bounds.height
        
        let top=CGFloat(UserDefaults.standard.float(forKey: "top"))
        let bottom=CGFloat( UserDefaults.standard.float(forKey: "bottom"))
        let left=CGFloat( UserDefaults.standard.float(forKey: "left"))
        let right=CGFloat( UserDefaults.standard.float(forKey: "right"))
        print("top",top,bottom,left,right)
        let ww=view.bounds.width-(left+right)
        let wh=view.bounds.height-(top+bottom)

        var bw=ww/4.5
        var sp=ww/120
        let x0=sp*2+left
        let x1=x0+bw+sp*2
        var bh=wh/15
        let b0y=bh*4/5
        let b1y=b0y+bh+sp
        let b2y=b1y+bh+sp
        let b3y=b2y+bh+sp*3
        let b4y=b3y+bh+sp
        let b5y=b4y+bh+sp
        let b6y=b5y+bh+sp*3
        let b7y=b6y+bh+sp
        let b8y=b7y+bh+sp*3
        let b9y=b8y+bh+sp
        paraCnt3.frame  = CGRect(x:x0,   y: b0y ,width: bw, height: bh)
        paraTxt3.frame  = CGRect(x:x1,   y: b0y ,width: bw*5, height: bh)
        paraCnt4.frame  = CGRect(x:x0,   y: b1y ,width: bw, height: bh)
        paraTxt4.frame  = CGRect(x:x1,   y: b1y ,width: bw*5, height: bh)
        paraCnt5.frame  = CGRect(x:x0,   y: b2y ,width: bw,height:bh)
        paraTxt5.frame  = CGRect(x:x1,   y: b2y ,width: bw*5,height:bh)
  
        paraCnt0.frame  = CGRect(x:x0,   y: b3y ,width: bw, height: bh)
        paraTxt0.frame  = CGRect(x:x1,   y: b3y ,width: bw*5, height: bh)
        paraCnt1.frame  = CGRect(x:x0,   y: b4y ,width: bw, height: bh)
        paraTxt1.frame  = CGRect(x:x1,   y: b4y ,width: bw*5, height: bh)
        paraCnt2.frame  = CGRect(x:x0,   y: b5y ,width: bw,height:bh)
        paraTxt2.frame  = CGRect(x:x1,   y: b5y ,width: bw*5,height:bh)

        
        paraCnt6.frame  = CGRect(x:x0,   y: b6y ,width: bw,height:bh)
        paraTxt6.frame  = CGRect(x:x1,   y: b6y ,width: bw*5,height:bh)
        paraCnt7.frame  = CGRect(x:x0,   y: b7y ,width: bw,height:bh)
        paraTxt7.frame  = CGRect(x:x1,   y: b7y ,width: bw*5,height:bh)
        paraCnt8.frame  = CGRect(x:x0,   y: b8y ,width: bw,height:bh)
        paraTxt8.frame  = CGRect(x:x1,   y: b8y ,width: bw*5,height:bh)
        frontCameraSwitch.frame = CGRect(x:x0,y:b9y,width:bw,height: bh)
        frontCameraLabel.frame = CGRect(x:x0+70,y:b9y+2,width:bw*5,height:bh)
        sp=ww/120//間隙
        bw=(ww-sp*10)/7//ボタン幅
        bh=bw*170/440
        let by=wh-bh-sp
        cameraButton.isHidden=true
//        camera.setButtonProperty(cameraButton,x:bw*4+sp*6,y:by,w:bw,h: bh,UIColor.orange)
        camera.setButtonProperty(defaultButton,x:left+bw*5+sp*7,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(exitButton,x:left+bw*6+sp*8,y:by,w:bw,h:bh,UIColor.darkGray)
    }

}
