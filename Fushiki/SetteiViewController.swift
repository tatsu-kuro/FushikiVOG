//
//  SetteiViewController.swift
//  Fushiki
//
//  Created by 黒田建彰 on 2020/07/17.
//  Copyright © 2020 tatsuaki.Fushiki. All rights reserved.
//

import UIKit

class SetteiViewController: UIViewController {
    var oknSpeed:Int = 2
    var oknTime:Int = 0
    var oknMode:Int=0
    var okpSpeed:Int=1
    var okpTime:Int=0
    var okpMode:Int=0
    
    @IBOutlet weak var paraCnt0: UISegmentedControl!
    @IBOutlet weak var paraCnt1: UISlider!
    @IBOutlet weak var paraCnt2: UISlider!
    @IBOutlet weak var paraCnt3: UISegmentedControl!
    @IBOutlet weak var paraCnt4: UISlider!
    @IBOutlet weak var paraCnt5: UISlider!
    @IBOutlet weak var paraCnt6: UISegmentedControl!
    @IBOutlet weak var paraCnt7: UISlider!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var defaultButton: UIButton!
    @IBOutlet weak var paraTxt0: UILabel!
    @IBOutlet weak var paraTxt1: UILabel!
    @IBOutlet weak var paraTxt2: UILabel!
    @IBOutlet weak var paraTxt3: UILabel!
    @IBOutlet weak var paraTxt4: UILabel!
    @IBOutlet weak var paraTxt5: UILabel!
    @IBOutlet weak var paraTxt6: UILabel!
    @IBOutlet weak var paraTxt7: UILabel!
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
    @IBAction func goExit(_ sender: Any) {
        UserDefaults.standard.set(okpSpeed, forKey: "okpSpeed")
        UserDefaults.standard.set(okpTime, forKey: "okpTime")
        UserDefaults.standard.set(okpMode, forKey: "okpMode")
        UserDefaults.standard.set(oknSpeed, forKey: "oknSpeed")
        UserDefaults.standard.set(oknTime, forKey: "oknTime")
        UserDefaults.standard.set(oknMode, forKey: "oknMode")
        
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        //delTimer()
        self.present(mainView, animated: false, completion: nil)
    }
    @IBAction func defaultAct(_ sender: Any) {
        okpSpeed=100
        okpTime=5
        okpMode=0
        oknSpeed=100
        oknTime=60
        oknMode=0
        setPars()
        dispTexts()
    }
    func setPars(){
        paraCnt1.value=Float(okpSpeed)/200.0
        paraCnt2.value=Float(okpTime)/50.0
        paraCnt0.selectedSegmentIndex=okpMode%4
        paraCnt4.value=Float(oknSpeed)/200.0
        paraCnt5.value=Float(oknTime)/100.0
        paraCnt3.selectedSegmentIndex=oknMode%4
    }
    func setokpMode(){
        paraTxt0.text="OKP-MODE:" + String(Int(okpMode)) + "   "
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
        paraTxt3.text="OKN-MODE:" + String(Int(oknMode)) + "   "
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
    func setokpSpeed(){
        paraTxt1.text="OKP-MaxSPEED:" + String(Int(okpSpeed*15)) + "pt/sec" + "  ScreenWidth(" + String(Int(view.bounds.width)) + "pt)"
    }
    func setoknSpeed(){
        paraTxt4.text="OKN-SPEED:" + String(Int(oknSpeed*15)) + "pt/sec" + "  ScreenWidth(" + String(Int(view.bounds.width)) + "pt)"
    }
    func dispTexts(){
        setokpMode()
        setoknMode()
        setokpSpeed()
        setoknSpeed()
        paraTxt2.text="OKP-PAUSE:" + String(Int(okpTime)) + "sec"
        paraTxt5.text="OKN-TIME:" + String(Int(oknTime)) + "sec"
    }
    func getUserDefault(str:String,ret:Int) -> Int{//getUserDefault_one
        if (UserDefaults.standard.object(forKey: str) != nil){//keyが設定してなければretをセット
            return UserDefaults.standard.integer(forKey:str)
        }else{
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        okpSpeed = getUserDefault(str: "okpSpeed", ret:100)
        okpTime = getUserDefault(str: "okpTime", ret: 5)
        okpMode = getUserDefault(str: "okpMode", ret: 0)
        oknSpeed = getUserDefault(str: "oknSpeed", ret: 100)
        oknTime = getUserDefault(str: "oknTime", ret: 60)
        oknMode = getUserDefault(str: "oknMode", ret: 0)
        
        setScreen()
        dispTexts()
        setPars()
        // Do any additional setup after loading the view.
    }
    func setScreen(){
        let ww=view.bounds.width
        let wh=view.bounds.height
        let x0=ww/25
        var bw=ww/4
        let x1=x0+bw+x0/2
        var sp=wh/60
        
        var bh=wh/13
        let b0y=bh*4/5
        let b1y=b0y+bh+sp
        let b2y=b1y+bh+sp
        let b3y=b2y+bh+sp*3
        let b4y=b3y+bh+sp
        let b5y=b4y+bh+sp
        let b6y=b5y+bh+sp*3
        let b7y=b6y+bh+sp
        paraCnt0.frame  = CGRect(x:x0,   y: b0y ,width: bw, height: bh)
        paraTxt0.frame  = CGRect(x:x1,   y: b0y ,width: bw*5, height: bh)
        paraCnt1.frame  = CGRect(x:x0,   y: b1y ,width: bw, height: bh)
        paraTxt1.frame  = CGRect(x:x1,   y: b1y ,width: bw*5, height: bh)
        paraCnt2.frame  = CGRect(x:x0,   y: b2y ,width: bw,height:bh)
        paraTxt2.frame  = CGRect(x:x1,   y: b2y ,width: bw*5,height:bh)
        paraCnt3.frame  = CGRect(x:x0,   y: b3y ,width: bw, height: bh)
        paraTxt3.frame  = CGRect(x:x1,   y: b3y ,width: bw*5, height: bh)
        paraCnt4.frame  = CGRect(x:x0,   y: b4y ,width: bw, height: bh)
        paraTxt4.frame  = CGRect(x:x1,   y: b4y ,width: bw*5, height: bh)
        paraCnt5.frame  = CGRect(x:x0,   y: b5y ,width: bw,height:bh)
        paraTxt5.frame  = CGRect(x:x1,   y: b5y ,width: bw*5,height:bh)
        paraCnt6.frame  = CGRect(x:x0,   y: b6y ,width: bw,height:bh)
        paraTxt6.frame  = CGRect(x:x1,   y: b6y ,width: bw*5,height:bh)
        paraCnt7.frame  = CGRect(x:x0,   y: b7y ,width: bw,height:bh)
        paraTxt7.frame  = CGRect(x:x1,   y: b7y ,width: bw*5,height:bh)
        
        bw=ww*0.9/7
        bh=bw*170/440
        sp=ww*0.1/10
        let by=wh-bh-sp
        
        defaultButton.frame=CGRect(x:bw*5+sp*7,y:by,width:bw,height:bh)
        exitButton.frame=CGRect(x:bw*6+sp*8,y:by,width:bw,height:bh)
    }

}
