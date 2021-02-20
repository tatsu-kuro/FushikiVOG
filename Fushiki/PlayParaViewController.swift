//
//  PlayParaViewController.swift
//  Fushiki
//
//  Created by 黒田建彰 on 2021/02/03.
//  Copyright © 2021 tatsuaki.Fushiki. All rights reserved.
//

import UIKit

class PlayParaViewController: UIViewController {
    let camera = CameraAlbumEtc()//name:"Fushiki")
    @IBOutlet weak var default4Button: UIButton!
    @IBOutlet weak var default2Button: UIButton!
    
    @IBOutlet weak var default3Button: UIButton!
    @IBOutlet weak var default1Button: UIButton!
    @IBOutlet weak var faceMark: UISwitch!
    @IBOutlet weak var checkRects: UISwitch!
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
    var paraInt1:Int=0
    var paraInt2:Int=0
    var paraInt3:Int=0
    var paraInt4:Int=0
    var paraInt5:Int=0
    var paraInt6:Int=0
    
    @IBAction func onCheckRects(_ sender: Any) {
        if checkRects.isOn{
            paraInt6=1
        }else{
            paraInt6=0
        }
        setUserDefaults()
    }
    @IBAction func onFaceMark(_ sender: Any) {
        if faceMark.isOn{
            paraInt5=1
        }else{
            paraInt5=0
        }
        setUserDefaults()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        paraInt1.delegate = self
        paraInt1=UserDefaults.standard.integer(forKey:"posRatio")
        paraInt2=UserDefaults.standard.integer(forKey:"veloRatio")
        paraInt3=UserDefaults.standard.integer(forKey:"wakuLength")
        paraInt4=UserDefaults.standard.integer(forKey:"eyeBorder")
        paraInt5=UserDefaults.standard.integer(forKey:"faceMark")
        paraInt6=UserDefaults.standard.integer(forKey: "checkRects")
        para1.text = "\(paraInt1)"
        para2.text = "\(paraInt2)"
        para3.text = "\(paraInt3)"
        para4.text = "\(paraInt4)"
        if paraInt5==0{
            faceMark.isOn=false
        }else{
            faceMark.isOn=true
        }
        if paraInt6==0{
            checkRects.isOn=false
        }else{
            checkRects.isOn=true
        }
        setScreen()
        keyPadDownButton.isHidden=true
    }
  
    @IBAction func onDefault1Button(_ sender: Any) {
        paraInt1=100
        paraInt2=100
        if ( UIDevice.current.model.range(of: "iPad") != nil){//ipad
            paraInt3 = 6
            paraInt4 = 20
        }else{//iphone
            paraInt3 = 3
            paraInt4 = 10
        }
        paraInt5=1
        paraInt6=1
        setUserDefaults()
    }
    @IBAction func onDefault2Button(_ sender: Any) {
        paraInt1=100
        paraInt2=100
        if ( UIDevice.current.model.range(of: "iPad") != nil){//ipad
            paraInt3 = 10
            paraInt4 = 24
        }else{//iphone
            paraInt3 = 5
            paraInt4 = 12
        }
        paraInt5=1
        paraInt6=1
        setUserDefaults()
    }
    @IBAction func onDefault3Button(_ sender: Any) {
        paraInt1=100
        paraInt2=100
        if ( UIDevice.current.model.range(of: "iPad") != nil){//ipad
            paraInt3 = 15
            paraInt4 = 30
        }else{//iphone
            paraInt3 = 8
            paraInt4 = 15
        }
        paraInt5=1
        paraInt6=1
        setUserDefaults()
    }
    @IBAction func onDefault4Button(_ sender: Any) {
        paraInt1=100
        paraInt2=100
        if ( UIDevice.current.model.range(of: "iPad") != nil){//ipad
            paraInt3 = 20
            paraInt4 = 40
        }else{//iphone
            paraInt3 = 10
            paraInt4 = 20
        }
        paraInt5=1
        paraInt6=1
        setUserDefaults()
    }
    func setUserDefaults(){
        UserDefaults.standard.set(paraInt1, forKey: "posRatio")
        UserDefaults.standard.set(paraInt2, forKey: "veloRatio")
        UserDefaults.standard.set(paraInt3, forKey: "wakuLength")
        UserDefaults.standard.set(paraInt4, forKey: "eyeBorder")
        UserDefaults.standard.set(paraInt5, forKey: "faceMark")
        UserDefaults.standard.set(paraInt6, forKey: "checkRects")
        para1.text = "\(paraInt1)"
        para2.text = "\(paraInt2)"
        para3.text = "\(paraInt3)"
        para4.text = "\(paraInt4)"
        if paraInt5==0{
            faceMark.isOn=false
        }else{
            faceMark.isOn=true
        }
        if paraInt6==0{
            checkRects.isOn=false
        }else{
            checkRects.isOn=true
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
        paraInt1 = Field2value(field:para1)
        paraInt2 = Field2value(field:para2)
        paraInt3 = Field2value(field:para3)
        paraInt4 = Field2value(field:para4)
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
        let ww=view.bounds.width
        let wh=view.bounds.height

        let sp=ww/120//間隙
        let bw=(ww-sp*10)/7//ボタン幅
        let bh=bw*170/440
        let by=wh-bh-sp
        let lw=ww-bw*2
        let head=sp*3
        camera.setButtonProperty(keyPadDownButton, x: bw*6+sp*8, y: sp, w: bw, h: bh, UIColor.darkGray)
        camera.setButtonProperty(exitButton,x:bw*6+sp*8,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(default1Button, x: bw*2+sp*4, y: by, w: bw, h: bh, UIColor.darkGray)
        camera.setButtonProperty(default2Button, x: bw*3+sp*5, y: by, w: bw, h: bh, UIColor.darkGray)
        camera.setButtonProperty(default3Button, x: bw*4+sp*6, y: by, w: bw, h: bh, UIColor.darkGray)
        camera.setButtonProperty(default4Button, x: bw*5+sp*7, y: by, w: bw, h: bh, UIColor.darkGray)
        para1.frame=CGRect(x:head+2*sp,y:sp,width:bw,height: bh)
        para2.frame=CGRect(x:head+2*sp,y:sp*2+bh,width:bw,height: bh)
        para3.frame=CGRect(x:head+2*sp,y:sp*3+bh*2,width:bw,height: bh)
        para4.frame=CGRect(x:head+2*sp,y:sp*4+bh*3,width:bw,height: bh)
        faceMark.frame=CGRect(x:head+2*sp,y:sp*5+bh*4,width:bw,height: bh)
        checkRects.frame=CGRect(x:head+2*sp,y:sp*6+bh*5,width:bw,height: bh)
        paraText1.frame=CGRect(x:head+bw+3*sp,y:sp,width:lw,height: bh)
        paraText2.frame=CGRect(x:head+bw+3*sp,y:sp*2+bh,width:lw,height: bh)
        paraText3.frame=CGRect(x:head+bw+3*sp,y:sp*3+bh*2,width:lw,height: bh)
        paraText4.frame=CGRect(x:head+bw+3*sp,y:sp*4+bh*3,width:lw,height: bh)
        paraText5.frame=CGRect(x:head+bw+3*sp,y:sp*5+bh*4,width:lw,height: bh)
        paraText6.frame=CGRect(x:head+bw+3*sp,y:sp*6+bh*5,width:lw,height: bh)
    }
}
