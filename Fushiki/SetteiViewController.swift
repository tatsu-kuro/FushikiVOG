//
//  SetteiViewController.swift
//  Fushiki
//
//  Created by 黒田建彰 on 2020/07/17.
//  Copyright © 2020 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
extension String {
    // 半角数字の判定
    func isAlphanumeric() -> Bool {
//        return self.range(of: "[^0-9]+", options: .regularExpression) == nil && self != ""
        return self.range(of: "[^,:0123456789]", options: .regularExpression) == nil && self != ""
    }
}

class SetteiViewController: UIViewController {
    let camera = CameraAlbumEtc()//name:"Fushiki")
    var oknMode:Int=0
    var oknTime:Int = 50
    var okpMode:Int=0
    var okpTime:Int=50
    var ettMode:Int = 0
//    var ettWidth:Int=50
    var targetMode:Int=0
    var screenBrightness:Float!
    var ettModeText0:String=""
    var ettModeText1:String=""
    var ettModeText2:String=""
    var ettModeText3:String=""
    var cameraMode:Int!
    var speakerOnOff:Int!
    @IBOutlet weak var frontCameraLabel: UILabel!
    @IBOutlet weak var frontCameraSwitch: UISwitch!
    @IBOutlet weak var speakerText: UILabel!
    @IBOutlet weak var speakerImage: UIImageView!
    @IBAction func onSpeakerSwitch(_ sender: UISwitch) {
        if sender.isOn==true{
            speakerOnOff=1
        }else{
            speakerOnOff=0
        }
        UserDefaults.standard.set(speakerOnOff, forKey: "speakerOnOff")
    }
    @IBOutlet weak var speakerSwitch: UISwitch!
    @IBAction func onFrontCameraSwitch(_ sender: UISwitch) {
         if sender.isOn==true{
           cameraMode=0
        }else{
            cameraMode=2
        }
        UserDefaults.standard.set(cameraMode, forKey: "cameraMode")
    }
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var okpSwitch: UISegmentedControl!
    @IBOutlet weak var okpPauseTimeSlider: UISlider!
    @IBOutlet weak var oknSwitch: UISegmentedControl!
    @IBOutlet weak var oknTimeSlider: UISlider!
    @IBOutlet weak var ettSwitch: UISegmentedControl!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var brightnessSlider: UISlider!
    @IBOutlet weak var defaultButton: UIButton!
    @IBOutlet weak var okpText: UILabel!
    @IBOutlet weak var okpPauseTimeText: UILabel!
    @IBOutlet weak var oknText: UILabel!
    @IBOutlet weak var oknTimeText: UILabel!
    @IBOutlet weak var ettText: UILabel!
    @IBOutlet weak var ettExplanationText: UILabel!
    
    @IBOutlet weak var brightnessText: UILabel!
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
 
    @IBAction func goExit(_ sender: Any) {
        setUserDefaults()
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        //delTimer()
        mainView.targetMode=targetMode
        self.present(mainView, animated: false, completion: nil)
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
        UserDefaults.standard.set(screenBrightness, forKey: "screenBrightness")
        UserDefaults.standard.set(cameraMode,forKey: "cameraMode")
        UserDefaults.standard.set(speakerOnOff,forKey: "speakerOnOff")
        UserDefaults.standard.set(ettModeText0, forKey: "ettModeText0")
        UserDefaults.standard.set(ettModeText1, forKey: "ettModeText1")
        UserDefaults.standard.set(ettModeText2, forKey: "ettModeText2")
        UserDefaults.standard.set(ettModeText3, forKey: "ettModeText3")
    }

    @IBAction func onBrightnessSlider(_ sender: UISlider) {
//        UserDefaults.standard.set(sender.value, forKey: "screenBrightness")
        screenBrightness=sender.value
        setUserDefaults()
    }
    
    @IBAction func defaultAct(_ sender: Any) {
        okpMode=0
        okpTime=5
        oknMode=0
        oknTime=60
         ettMode=0
        setControlState()
        dispTexts()
    }
    func setControlState(){
        okpSwitch.selectedSegmentIndex=okpMode%4
        okpPauseTimeSlider.value=Float(okpTime)/50.0
        oknSwitch.selectedSegmentIndex=oknMode%4
        oknTimeSlider.value=Float(oknTime)/100.0
        ettSwitch.selectedSegmentIndex=ettMode%4
        brightnessSlider.value=camera.getUserDefaultFloat(str: "screenBrightness", ret: 1.0)
        if cameraMode==0{//front camera
            frontCameraSwitch.isOn=true
        }else{//don't use camera
            frontCameraSwitch.isOn=false
        }
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
            ettText.text! = ettModeText0//" pursuit(30s) horizontal"
        }else if ettMode == 1{
            ettText.text! = ettModeText1
        }else if ettMode == 2{
            ettText.text! = ettModeText2// " saccade(30s) horizontal & vertical"
        }else{
            ettText.text! = ettModeText3//" pursuit(20s)->saccade(20s)->random(20s)"
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
        cameraMode=UserDefaults.standard.integer(forKey: "cameraMode")
        screenBrightness = camera.getUserDefaultFloat(str: "screenBrightness", ret: 1.0)
        ettMode = camera.getUserDefaultInt(str:"ettMode",ret:0)
        ettModeText0=camera.getUserDefaultString(str: "ettModeText0", ret: "0")
        ettModeText1=camera.getUserDefaultString(str: "ettModeText1", ret: "1")
        ettModeText2=camera.getUserDefaultString(str: "ettModeText2", ret: "2")
        ettModeText3=camera.getUserDefaultString(str: "ettModeText3", ret: "3")

        ettExplanationText.text="円形視標の動作の設定方法  a:b:c,....\n"
        ettExplanationText.text! += "a[視標の動き方(1-6)]:b[速さ(0-3)]:c[時間(秒)]\n"
        ettExplanationText.text! += "a) 1=振子横 2=同縦 3=衝動横 4=同縦 5=不規則横 6=同縦横"
            
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
            if ettString.isAlphanumeric(){//} isOnly(structuredBy: "0123456789:,") == true
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
                let dialog = UIAlertController(title: "", message: "0123456789,: だけです.", preferredStyle: .alert)
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
//    func getSetValueAlert(text:UILabel) {
//        print("tap")
//        let alert = UIAlertController(title: "", message: "", preferredStyle: .alert)
//        alert.textFields![0].text!=text.text!
//        let saveAction = UIAlertAction(title: "OK", style: .default) { [self] (action:UIAlertAction!) -> Void in
//            // 入力したテキストをコンソールに表示
//            let textField = alert.textFields![0] as UITextField
//            let ettString:String = textField.text!
//            if ettString.isAlphanumeric(){//} isOnly(structuredBy: "0123456789:,") == true
//                text.text=ettString
//            }else{
//                let dialog = UIAlertController(title: "", message: "0123456789,: だけです.", preferredStyle: .alert)
//                //ボタンのタイトル
//                dialog.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                //実際に表示させる
//                self.present(dialog, animated: true, completion: nil)
////                print(",:0123456789以外は受け付けません")
//            }
////            print("\(String(describing: textField.text))")
//        }
//        
//        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) -> Void in
//        }
//        // UIAlertControllerにtextFieldを追加
//        alert.addTextField { (textField:UITextField!) -> Void in
//            textField.keyboardType = UIKeyboardType.default//.numberPad
//            textField.text=text.text
//        }
//        alert.addAction(cancelAction)//この行と下の行の並びを変えるとCancelとOKの左右が入れ替わる。
//        alert.addAction(saveAction)
//        present(alert, animated: true, completion: nil)
//        
//    }
    func setScreen(){
        
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
        let b1y=b0y+bh
        let b2y=b1y+bh*3+sp
        let b3y=b2y+bh+sp
        let b4y=b3y+bh+sp*3
        let b5y=b4y+bh+sp
        let b6y=b5y+bh+sp*1.5
        let b7y=b6y+bh+sp
        let b8y=b7y+bh+sp*2
        let ettTextWidth=view.bounds.width-right-x1-sp*2

//        let b9y=b8y+bh+sp
        ettSwitch.frame  = CGRect(x:x0,   y: b0y ,width: bw,height:bh)
//        ettText.frame  = CGRect(x:x1,   y: b0y ,width: bw*5,height:bh)
//        ettText.frame  = CGRect(x:x1,   y: b0y-2 ,width: ettTextWidth, height: bh+4)
//        ettText.backgroundColor = UIColor.gray
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
        brightnessSlider.frame  = CGRect(x:x0,   y: b6y ,width: bw,height:bh)
        brightnessText.frame  = CGRect(x:x1,   y: b6y ,width: bw*5,height:bh)
        frontCameraSwitch.frame = CGRect(x:x0,y:b7y,width:bw,height: bh)
        frontCameraLabel.frame = CGRect(x:x1,y:b7y+2,width:bw*5,height:bh)
        speakerSwitch.frame = CGRect(x:x0,   y: b8y ,width: bw*5,height:bh)
        speakerImage.frame = CGRect(x:x0+50,   y: b8y ,width: 30,height:30)
        speakerText.frame = CGRect(x:x1,   y: b8y ,width: bw*5,height:bh)
        sp=ww/120//間隙
        bw=(ww-sp*10)/7//ボタン幅
        bh=bw*170/440
        let by=wh-bh-sp
        cameraButton.isHidden=true
        camera.setButtonProperty(defaultButton,x:left+bw*5+sp*7,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(exitButton,x:left+bw*6+sp*8,y:by,w:bw,h:bh,UIColor.darkGray)
    }
}
