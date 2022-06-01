//
//  PlayParaViewController.swift
//  Fushiki
//
//  Created by 黒田建彰 on 2021/02/03.
//  Copyright © 2021 tatsuaki.Fushiki. All rights reserved.
//

import UIKit

class PlayParaViewController: UIViewController {
    let camera = myFunctions()//name:"Fushiki")
    @IBOutlet weak var defaultButton: UIButton!
    @IBOutlet weak var default2Button: UIButton!
    
    @IBOutlet weak var default3Button: UIButton!
    @IBOutlet weak var default1Button: UIButton!
    @IBOutlet weak var faceMarkSwitch: UISwitch!
    @IBOutlet weak var showRectSwitch: UISwitch!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var para4: UITextField!
    @IBOutlet weak var para3: UITextField!
    @IBOutlet weak var para2: UITextField!
    @IBOutlet weak var para1: UITextField!

    @IBOutlet weak var paraText1: UILabel!
    @IBOutlet weak var paraText2: UILabel!
    @IBOutlet weak var paraText3: UILabel!
    @IBOutlet weak var paraText4: UILabel!
    @IBOutlet weak var paraText5: UILabel!
    @IBOutlet weak var paraText6: UILabel!
    var posRatio:Int=0
    var veloRatio:Int=0
    var wakuLength:Int=0
    var eyeBorder:Int=0
    var faceMark:Int=0
    var showRect:Int=0
    
    @IBAction func onShowRect(_ sender: Any) {
        if showRectSwitch.isOn{
            showRect=1
        }else{
            showRect=0
        }
        setUserDefaults()
    }
    @IBAction func onFaceMark(_ sender: Any) {
         
        if faceMarkSwitch.isOn{
            faceMark=1
        }else{
            faceMark=0
        }
        setUserDefaults()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        print("viewdidload")
//        paraInt1.delegate = self
        posRatio=UserDefaults.standard.integer(forKey:"posRatio")
        veloRatio=UserDefaults.standard.integer(forKey:"veloRatio")
        wakuLength=UserDefaults.standard.integer(forKey:"wakuLength")
        eyeBorder=UserDefaults.standard.integer(forKey:"eyeBorder")
        faceMark=UserDefaults.standard.integer(forKey:"faceMark")
        showRect=UserDefaults.standard.integer(forKey: "showRect")
        para1.text = "\(posRatio)"
        para2.text = "\(veloRatio)"
        para3.text = "\(wakuLength)"
        para4.text = "\(eyeBorder)"
        if faceMark==0{
            faceMarkSwitch.isOn=false
        }else{
            faceMarkSwitch.isOn=true
        }
        if showRect==0{
            showRectSwitch.isOn=false
        }else{
            showRectSwitch.isOn=true
        }
        setScreen()
        keyPadDownButton.isHidden=true
    }
    
      override var prefersStatusBarHidden: Bool {
          return true
      }
      override var prefersHomeIndicatorAutoHidden: Bool {
          return true
      }
  
    @IBAction func onDefault1Button(_ sender: Any) {
        posRatio=80
        veloRatio=60
//        print("button1")
//        if ( UIDevice.current.model.range(of: "iPad") != nil){//ipad
//            wakuLength = 6
//            eyeBorder = 10
//        }else{//iphone
//            wakuLength = 3
//            eyeBorder = 5
//        }
        wakuLength = 6
        eyeBorder = 12
//        faceMark=1
//        showRect=1
        setUserDefaults()
    }
    @IBAction func onDefault2Button(_ sender: Any) {
        posRatio=150
        veloRatio=150
//        if ( UIDevice.current.model.range(of: "iPad") != nil){//ipad
//            wakuLength = 10
//            eyeBorder = 16
//        }else{//iphone
            wakuLength = 4
            eyeBorder = 8
//        }
//        faceMark=1
//        showRect=1
        setUserDefaults()
    }
    @IBAction func onDefault3Button(_ sender: Any) {
        posRatio=200
        veloRatio=200
//        if ( UIDevice.current.model.range(of: "iPad") != nil){//ipad
//            wakuLength = 14
//            eyeBorder = 20
//        }else{//iphone
            wakuLength = 3
            eyeBorder = 8
//        }
//        faceMark=1
//        showRect=1
        setUserDefaults()
    }
    @IBAction func onDefaultButton(_ sender: Any) {
        posRatio=80
        veloRatio=60
//        if ( UIDevice.current.model.range(of: "iPad") != nil){//ipad
//            wakuLength = 18
//            eyeBorder = 24
//        }else{//iphone
            wakuLength = 6
            eyeBorder = 12
//        }
//        faceMark=1
//        showRect=1
        setUserDefaults()
    }
    func setUserDefaults(){
        UserDefaults.standard.set(posRatio, forKey: "posRatio")
        UserDefaults.standard.set(veloRatio, forKey: "veloRatio")
        UserDefaults.standard.set(wakuLength, forKey: "wakuLength")
        UserDefaults.standard.set(eyeBorder, forKey: "eyeBorder")
        UserDefaults.standard.set(faceMark, forKey: "faceMark")
        UserDefaults.standard.set(showRect, forKey: "showRect")
        para1.text = "\(posRatio)"
        para2.text = "\(veloRatio)"
        para3.text = "\(wakuLength)"
        para4.text = "\(eyeBorder)"
        if faceMark==0{
            faceMarkSwitch.isOn=false
        }else{
            faceMarkSwitch.isOn=true
        }
        if showRect==0{
            showRectSwitch.isOn=false
        }else{
            showRectSwitch.isOn=true
        }
     }
    func isAlphanumeric(text:String) -> Bool {
        if text.range(of: "[^0-9]+", options: .regularExpression) == nil && text != ""{
            return true
        }else{
            return false
        }
    }
    func Field2value(field:UITextField) -> Int {
        if isAlphanumeric(text: field.text!){
        if field.text?.count != 0 {
            return Int(field.text!)!
        }else{
            return 0
        }
        }else{
            return 0
        }
    }
    func setParas(){
        posRatio = Field2value(field:para1)
        veloRatio = Field2value(field:para2)
        wakuLength = Field2value(field:para3)
        eyeBorder = Field2value(field:para4)
        setUserDefaults()
        keyPadDownButton.isHidden=false
    }
//    func textFieldDidBeginEditing(_ textField: UITextField) {
//        keyPadDownButton.isHidden = false
//    }
    @IBOutlet weak var keyPadDownButton: UIButton!
    @IBAction func onKeyPadDownButton(_ sender: Any) {
        tapAction(0)
    }
    @IBAction func tapAction(_ sender: Any){
        para1.endEditing(true)
        para2.endEditing(true)
        para3.endEditing(true)
        para4.endEditing(true)
        keyPadDownButton.isHidden=true
    }
    @IBAction func editingDidBegin(_ sender: Any){
        keyPadDownButton.isHidden=false
    }
    @IBAction func editingChanged(_ sender: Any) {
        setParas()
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

        let sp=ww/120//間隙
        let bw=(ww-sp*10)/7//ボタン幅
//        let bw_wide=(ww-bw-8*sp)/4
        let bh=bw*170/440
        let by=wh-bh-sp
        let lw=ww-bw*2
        let head=sp*2+left
        camera.setButtonProperty(keyPadDownButton, x: head+bw*6+sp*6, y: sp, w: bw, h: bh, UIColor.darkGray)
        camera.setButtonProperty(exitButton,x:head+sp*6+bw*6,y:by,w:bw,h:bh,UIColor.darkGray)
//        camera.setButtonProperty(default1Button, x:head, y: by, w: bw_wide, h: bh, UIColor.darkGray)
//        camera.setButtonProperty(default2Button, x:head+sp+bw_wide, y: by, w: bw_wide, h: bh, UIColor.darkGray)
//        camera.setButtonProperty(default3Button, x:head+sp*2+bw_wide*2, y: by, w: bw_wide, h: bh, UIColor.darkGray)
        camera.setButtonProperty(defaultButton, x:head+sp*5+bw*5, y: by, w: bw, h: bh, UIColor.darkGray)
        para1.frame=CGRect(x:head,y:sp,width:bw,height: bh)
        para2.frame=CGRect(x:head,y:sp*2+bh,width:bw,height: bh)
        para3.frame=CGRect(x:head,y:sp*3+bh*2,width:bw,height: bh)
        para4.frame=CGRect(x:head,y:sp*4+bh*3,width:bw,height: bh)
        faceMarkSwitch.frame=CGRect(x:head,y:sp*5+bh*4,width:bw,height: bh)
        showRectSwitch.frame=CGRect(x:head,y:sp*6+bh*5,width:bw,height: bh)
        paraText1.frame=CGRect(x:head+bw+3*sp,y:sp,width:lw,height: bh)
        paraText2.frame=CGRect(x:head+bw+3*sp,y:sp*2+bh,width:lw,height: bh)
        paraText3.frame=CGRect(x:head+bw+3*sp,y:sp*3+bh*2,width:lw,height: bh)
        paraText4.frame=CGRect(x:head+bw+3*sp,y:sp*4+bh*3,width:lw,height: bh)
        paraText5.frame=CGRect(x:head+bw+3*sp,y:sp*5+bh*4,width:lw,height: bh)
        paraText6.frame=CGRect(x:head+bw+3*sp,y:sp*6+bh*5,width:lw,height: bh)
        
        default1Button.isHidden=true
        default2Button.isHidden=true
        default3Button.isHidden=true
//        default1Button.setTitle("12-ultraWide", for: .normal)
//        default2Button.setTitle("12-wideAngle", for: .normal)
//        default3Button.setTitle("se(1st)-back", for: .normal)
//        default4Button.setTitle("se(1st)-front", for: .normal)
    }
}
