//
//  SetteiViewController.swift
//  Fushiki
//
//  Created by 黒田建彰 on 2020/07/17.
//  Copyright © 2020 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import AVFoundation
extension String {
    // 半角数字の判定
    func isAlphanumeric() -> Bool {
//        return self.range(of: "[^0-9]+", options: .regularExpression) == nil && self != ""
        return self.range(of: "[^,:0123456789]", options: .regularExpression) == nil && self != ""
    }
}

class SetteiViewController: UIViewController {
    let camera = myFunctions()//name:"Fushiki")
    var oknMode:Int=0
    var oknTime:Int = 50
    var okpMode:Int=0
    var okpTime:Int=50
    var ettMode:Int = 0
//    var ettWidth:Int=50
    var targetMode:Int=0
    var ledValue:Float!
    var ettModeText0:String=""
    var ettModeText1:String=""
    var ettModeText2:String=""
    var ettModeText3:String=""
    var cameraType:Int!
    var speakerOnOff:Int!
    var cameraON:Bool!
    
    @IBOutlet weak var caloricLabel: UILabel!
    @IBOutlet weak var cameraLabel: UILabel!
    @IBOutlet weak var cameraSwitch: UISwitch!
    @IBOutlet weak var speakerText: UILabel!
    @IBAction func onSpeakerSwitch(_ sender: UISwitch) {
        if sender.isOn==true{
            speakerOnOff=1
        }else{
            speakerOnOff=0
        }
        UserDefaults.standard.set(speakerOnOff, forKey: "speakerOnOff")
    }
    func setCameraMode(){
        cameraLabel.text="Recording"
        dispTexts()
        UserDefaults.standard.set(cameraON, forKey: "cameraON")
    }

    @IBOutlet weak var speakerSwitch: UISwitch!

    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var okpSwitch: UISegmentedControl!
    @IBOutlet weak var okpPauseTimeSlider: UISlider!
    @IBOutlet weak var oknSwitch: UISegmentedControl!
    @IBOutlet weak var oknTimeSlider: UISlider!
    @IBOutlet weak var ettSwitch: UISegmentedControl!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var ledSlider: UISlider!
    @IBOutlet weak var defaultButton: UIButton!
    @IBOutlet weak var okpText: UILabel!
    @IBOutlet weak var okpPauseTimeText: UILabel!
    @IBOutlet weak var oknText: UILabel!
    @IBOutlet weak var oknTimeText: UILabel!
    @IBOutlet weak var ettText: UILabel!
    @IBOutlet weak var ettExplanationText: UILabel!
    
    @IBOutlet weak var ledText: UILabel!
    var tapInterval=CFAbsoluteTimeGetCurrent()

    override func remoteControlReceived(with event: UIEvent?) {
         guard event?.type == .remoteControl else { return }
         
         if let event = event {
             
             switch event.subtype {
             case .remoteControlPlay:
                 print("Play")
                 if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                     print("doubleTapPlay")
                     goExit()
                     //                    self.dismiss(animated: true, completion: nil)
                 }
                 tapInterval=CFAbsoluteTimeGetCurrent()
             case .remoteControlTogglePlayPause:
                 print("TogglePlayPause")
                 if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                     print("doubleTapTogglePlayPause")
                     goExit()
                     //                    self.dismiss(animated: true, completion: nil)
                 }
                 tapInterval=CFAbsoluteTimeGetCurrent()
             default:
                 print("Others")
             }
         }
    }
    
    func soundOnce(){
        var soundIdx:SystemSoundID = 0
        if let soundUrl = URL(string:
                                "/System/Library/Audio/UISounds/end_record.caf"/*photoShutter.caf*/){
                AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundIdx)
            AudioServicesPlaySystemSound(soundIdx)
        }
    }
    @IBAction func doubleTapGesture(_ sender: UITapGestureRecognizer) {
        let x=sender.location(in: view).x
        let y=sender.location(in: view).y
//        print("doubletap",x,y)x
        
        if x>caloricLabel.frame.minX && y<caloricLabel.frame.maxY && y>caloricLabel.frame.minY{
//            soundOnce()
            //左下あたりをdoubleTapするとcaloricEtt,Oknボタンが現れる、消すことも可能。
            let flag=UserDefaults.standard.bool(forKey: "caloricEttOknFlag")
//            print("flag",flag)
            if flag==true{
                caloricLabel.alpha=0.02
                UserDefaults.standard.set(false, forKey: "caloricEttOknFlag")
                print("to caloric off")
            }else{
                caloricLabel.alpha=0.1
                UserDefaults.standard.set(true, forKey: "caloricEttOknFlag")
                print("to caloric on")
            }
            return
        }
//        goExit()
    }
    
    func goExit() {
        setUserDefaults()
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        mainView.targetMode=targetMode
        performSegue(withIdentifier: "fromSettei", sender: self)
    }

    func cameraOnOff(){
        if cameraON==false{
            cameraSwitch.isOn=false
            speakerSwitch.isEnabled=false
            cameraButton.isHidden=true
        }else{
            cameraSwitch.isOn=true
            speakerSwitch.isEnabled=true
            cameraButton.isHidden=false
          }
    }
    
    @IBAction func onCameraSwitch(_ sender: UISwitch) {
        if sender.isOn == false {
            cameraON=false
        }else{
            cameraON=true
         }
        UserDefaults.standard.set(cameraON,forKey:"cameraON")
        cameraOnOff()
    }

    @IBAction func onOkpModeSwitch(_ sender: UISegmentedControl) {
          okpMode=sender.selectedSegmentIndex
          dispTexts()
      }
     

    @IBAction func onOkpTimeSlider(_ sender: UISlider) {
         okpTime=Int(sender.value*50)
         dispTexts()
     }
      @IBAction func onOknModeSwitch(_ sender: UISegmentedControl) {
           oknMode=sender.selectedSegmentIndex
           dispTexts()
       }
     
     @IBAction func onOknTimeSlider(_ sender: UISlider) {
         oknTime=Int(sender.value*100)
         dispTexts()
     }
    @IBAction func onEttModeSwitch(_ sender: UISegmentedControl) {
        ettMode=sender.selectedSegmentIndex
        if ettMode==0{
            ettText.text=ettModeText0
        }else if ettMode==1{
            ettText.text=ettModeText1
        }else if ettMode==2{
            ettText.text=ettModeText2
        }else if ettMode==3{
            ettText.text=ettModeText3
        }
        setUserDefaults()
    }
   
    func setUserDefaults(){
        UserDefaults.standard.set(okpTime, forKey: "okpTime")
        UserDefaults.standard.set(okpMode, forKey: "okpMode")
        UserDefaults.standard.set(oknTime, forKey: "oknTime")
        UserDefaults.standard.set(oknMode, forKey: "oknMode")
        UserDefaults.standard.set(ettMode,forKey: "ettMode")
        UserDefaults.standard.set(ledValue, forKey: "ledValue")
        UserDefaults.standard.set(cameraType,forKey: "cameraType")
        UserDefaults.standard.set(cameraON,forKey:"cameraON")
        UserDefaults.standard.set(speakerOnOff,forKey: "speakerOnOff")
        UserDefaults.standard.set(ettModeText0, forKey: "ettModeText0")
        UserDefaults.standard.set(ettModeText1, forKey: "ettModeText1")
        UserDefaults.standard.set(ettModeText2, forKey: "ettModeText2")
        UserDefaults.standard.set(ettModeText3, forKey: "ettModeText3")
    }
    
    @IBAction func onDefaultButton(_ sender: Any) {
        print("ondefault")
        okpMode=0
        okpTime=5
        oknMode=0
        oknTime=60
        ettMode=0        
        UserDefaults.standard.set(0.01, forKey: "zoomValue")
                
//        ettModeText0 = "3,0:1:2,1:2:10,3:2:10,0:1:2,2:2:10,4:2:10,6:2:12"
//        ettModeText1 = "3,0:1:2,1:2:10,0:6:3,3:2:10,0:1:2,2:2:10,0:6:3,4:2:10,0:1:2,6:2:12"
        ettModeText0 = "3,0:1:2,1:2:10,3:2:10,0:1:2,6:2:12"
        ettModeText1 = "3,0:1:2,2:2:10,4:2:10,0:1:2,6:2:12"
//        ettModeText2 = "3,0:1:2,1:2:12,3:2:12"
        
        setUserDefaults()
        setControlState()
        dispTexts()
    }
    func setControlState(){
        okpSwitch.selectedSegmentIndex=okpMode%4
        okpPauseTimeSlider.value=Float(okpTime)/50.0
        oknSwitch.selectedSegmentIndex=oknMode%4
        oknTimeSlider.value=Float(oknTime)/100.0
        ettSwitch.selectedSegmentIndex=ettMode%4

        if speakerOnOff==0{//front camera
            speakerSwitch.isOn=false
        }else{//don't use camera
            speakerSwitch.isOn=true
        }
    }
    func setOkpMode(){
        okpText.text="OKP-MODE" + "   "
        if okpMode == 0{
            okpText.text! += " right -> " + String(Int(okpTime)) + "sec -> left"
        }else if okpMode == 1{
            okpText.text! += " left -> " + String(Int(okpTime)) + "sec -> right"
        }else if okpMode == 2{
            okpText.text! += " right"
        }else{
            okpText.text! += " left"
        }
    }
    func setOknMode(){
        oknText.text="OKN-MODE" + "   "
        if oknMode == 0{
            oknText.text! += " right(" + String(Int(oknTime)) + "sec) -> black"
        }else if oknMode == 1{
            oknText.text! += " left(" + String(Int(oknTime)) + "sec) -> black"
        }else if oknMode == 2{
            oknText.text! += " right"
        }else{
            oknText.text! += " left"
        }
    }
    func setettMode(){
        if ettMode == 0{
            ettText.text! = ettModeText0
        }else if ettMode == 1{
            ettText.text! = ettModeText1
        }else if ettMode == 2{
            ettText.text! = ettModeText2
        }else{
            ettText.text! = ettModeText3
        }
    }

    func dispTexts(){
        setOkpMode()
        setOknMode()
        setettMode()
        
        okpPauseTimeText.text="OKP-PAUSE:" + String(Int(okpTime)) + "sec"
        oknTimeText.text="OKN-TIME:" + String(Int(oknTime)) + "sec"
        setUserDefaults()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        okpMode = UserDefaults.standard.integer(forKey: "okpMode")
        okpTime = UserDefaults.standard.integer(forKey: "okpTime")
        oknMode = UserDefaults.standard.integer(forKey: "oknMode")
        oknTime = UserDefaults.standard.integer(forKey: "oknTime")
        speakerOnOff=UserDefaults.standard.integer(forKey: "speakerOnOff")
        cameraType=UserDefaults.standard.integer(forKey: "cameraType")
        cameraON=UserDefaults.standard.bool(forKey: "cameraON")
        cameraOnOff()
        if camera.getUserDefaultBool(str: "caloricEttOknFlag", ret: false)==false{
            caloricLabel.alpha=0.02
        }else{
            caloricLabel.alpha=0.1
        }
        ledValue = camera.getUserDefaultFloat(str: "ledValue", ret: 0)
        ledText.isHidden=true
        ledSlider.isHidden=true 
        ettMode = camera.getUserDefaultInt(str:"ettMode",ret:0)
        ettModeText0=camera.getUserDefaultString(str: "ettModeText0", ret: "0")
        ettModeText1=camera.getUserDefaultString(str: "ettModeText1", ret: "1")
        ettModeText2=camera.getUserDefaultString(str: "ettModeText2", ret: "2")
        ettModeText3=camera.getUserDefaultString(str: "ettModeText3", ret: "3")

        setScreen()
        dispTexts()
        setControlState()
    }
    
      override var prefersStatusBarHidden: Bool {
          return true
      }
      override var prefersHomeIndicatorAutoHidden: Bool {
          return true
      }

    @IBAction func tapOnEttText(_ sender: Any) {
        print("tap")
        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "OK", style: .default) { [self] (action:UIAlertAction!) -> Void in
            // 入力したテキストをコンソールに表示
            let textField = alert.textFields![0] as UITextField
            let ettString:String = textField.text!

            if camera.checkEttString(ettStr: ettString){
                if ettMode==0{
                    ettModeText0=ettString
                }else if ettMode==1{
                    ettModeText1=ettString
                }else if ettMode==2{
                    ettModeText2=ettString
                }else{
                    ettModeText3=ettString
                }
                setUserDefaults()
                ettText.text=ettString
            }else{
                let dialog = UIAlertController(title: "", message: "0123456789,: are available.\nlike as 1,1:2:15,2:2:15", preferredStyle: .alert)
                //ボタンのタイトル
                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                //実際に表示させる
                self.present(dialog, animated: true, completion: nil)
//                print(",:0123456789以外は受け付けません")
            }
//            print("\(String(describing: textField.text))")
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) -> Void in
        }
        // UIAlertControllerにtextFieldを追加
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.keyboardType = UIKeyboardType.numbersAndPunctuation// default//.numberPad
            if self.ettMode==0{
                textField.text=self.ettModeText0
            }else if self.ettMode==1{
                textField.text=self.ettModeText1
            }else if self.ettMode==2{
                textField.text=self.ettModeText2
            }else{
                textField.text=self.ettModeText3
            }
        }
        alert.addAction(cancelAction)//この行と下の行の並びを変えるとCancelとOKの左右が入れ替わる。
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
        
    }

    
    @IBAction func onLedSlider(_ sender: UISlider) {
        ledValue=sender.value
        camera.setLedLevel(ledValue)
        setUserDefaults()
    }
 
    func setScreen(){
        let top=CGFloat(UserDefaults.standard.float(forKey: "top"))
        let bottom=CGFloat( UserDefaults.standard.float(forKey: "bottom"))
        let left=CGFloat( UserDefaults.standard.float(forKey: "left"))
        let right=CGFloat( UserDefaults.standard.float(forKey: "right"))
        print("top",top,bottom,left,right)
        let ww=view.bounds.width-(left+right)
        let wh=view.bounds.height-(top+bottom)
        var bw=ww/4.5
        let sp=ww/120
        let x0=sp*2+left
        let x1=x0+bw+sp*2
        var bh=wh/15
        let b0y=bh*4/5
        let b1y=b0y+bh
        let b2y=b1y+bh*3+sp
        let b3y=b2y+bh+sp
        let b4y=b3y+bh+sp*3
        let b5y=b4y+bh+sp
        let b6y=b5y+bh+sp*2
        let ettTextWidth=view.bounds.width-right-x1-sp*2
        ettSwitch.frame  = CGRect(x:x0,   y: b0y ,width: bw,height:bh)
        camera.setLabelProperty(ettText, x: x1, y: b0y-2, w: ettTextWidth, h: wh/15+4, UIColor.systemGray5)
        ettText.layer.cornerRadius=3

        ettExplanationText.frame  = CGRect(x:x0,   y: b1y ,width: bw*7,height:bh*3)
        okpSwitch.frame  = CGRect(x:x0,   y: b2y ,width: bw, height: bh)
        okpText.frame  = CGRect(x:x1,   y: b2y ,width: bw*5, height: bh)
        okpPauseTimeSlider.frame  = CGRect(x:x0,   y: b3y ,width: bw,height:bh)
        okpPauseTimeText.frame  = CGRect(x:x1,   y: b3y ,width: bw*5,height:bh)
        oknSwitch.frame  = CGRect(x:x0,   y: b4y ,width: bw, height: bh)
        oknText.frame  = CGRect(x:x1,   y: b4y ,width: bw*5, height: bh)
        oknTimeSlider.frame  = CGRect(x:x0,   y: b5y ,width: bw,height:bh)
        oknTimeText.frame  = CGRect(x:x1,   y: b5y ,width: bw*5,height:bh)
        cameraSwitch.frame = CGRect(x:x0,   y: b6y ,width: bw,height:bh)
 //       let switchHeight=cameraSwitch.frame.height
   //     let switchWidth=cameraSwitch.frame.width
//        let x3=x0+sp+switchWidth
     //   let dy3=(switchHeight-bh)/2
        let b7y=b6y+cameraSwitch.frame.height+sp
        camera.setButtonProperty(cameraButton, x:cameraSwitch.frame.maxX+sp, y: b6y, w: bw*3/4, h:cameraSwitch.frame.height, UIColor.systemOrange,0)
        cameraLabel.frame = CGRect(x:cameraSwitch.frame.maxX+sp,y:b6y,width:bw*5,height:cameraSwitch.frame.height)
        speakerSwitch.frame = CGRect(x:x0,y:b7y,width:bw,height: bh)
        speakerText.frame = CGRect(x:speakerSwitch.frame.maxX+sp,   y: b7y,width: bw*5,height:speakerSwitch.frame.height)
          bw=(ww-sp*10)/7//ボタン幅
        bh=bw*170/440
        let by=wh-bh-sp
        camera.setButtonProperty(defaultButton,x:left+bw*5+sp*7,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(exitButton,x:left+bw*6+sp*8,y:by,w:bw,h:bh,UIColor.darkGray)
        caloricLabel.frame=CGRect(x:left+bw*6+sp*8,y:by-sp-bw,width:bw,height:bw)
        if camera.firstLang().contains("ja"){
            cameraButton.setTitle(" 設定", for:.normal)
        }
    }
    
    @IBAction func unwindPlayPara(segue: UIStoryboardSegue) {
    }
}
