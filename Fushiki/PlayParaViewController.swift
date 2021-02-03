//
//  PlayParaViewController.swift
//  Fushiki
//
//  Created by 黒田建彰 on 2021/02/03.
//  Copyright © 2021 tatsuaki.Fushiki. All rights reserved.
//

import UIKit

class PlayParaViewController: UIViewController {
    @IBOutlet weak var defaultButton: UIButton!
    
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var para4: UITextField!
    @IBOutlet weak var para3: UITextField!
    @IBOutlet weak var para2: UITextField!
    @IBOutlet weak var para1: UITextField!
    var paraInt1:Int=0
    var paraInt2:Int=0
    var paraInt3:Int=0
    var paraInt4:Int=0
    override func viewDidLoad() {
        super.viewDidLoad()
        paraInt1=UserDefaults.standard.integer(forKey:"posRatio")
        paraInt2=UserDefaults.standard.integer(forKey:"veloRatio")
        paraInt3=UserDefaults.standard.integer(forKey:"wakuLength")
        paraInt4=UserDefaults.standard.integer(forKey:"eyeBorder")
        para1.text = "\(paraInt1)"
        para2.text = "\(paraInt2)"
        para3.text = "\(paraInt3)"
        para4.text = "\(paraInt4)"
        setScreen()
    }
  
    func setUserDefaults(){
        UserDefaults.standard.set(paraInt1, forKey: "posRatio")
        UserDefaults.standard.set(paraInt2, forKey: "veloRatio")
        UserDefaults.standard.set(paraInt3, forKey: "wakuLength")
        UserDefaults.standard.set(paraInt4, forKey: "eyeBorder")
        para1.text = "\(paraInt1)"
        para2.text = "\(paraInt2)"
        para3.text = "\(paraInt3)"
        para4.text = "\(paraInt4)"
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
    @IBAction func inputPara1(_ sender: Any) {
        paraInt1 = Field2value(field:para1)
        setUserDefaults()
    }
    @IBAction func inputPara2(_ sender: Any) {
        paraInt2 = Field2value(field:para2)
        setUserDefaults()
    }
    @IBAction func inputPara3(_ sender: Any) {
        paraInt3 = Field2value(field:para3)
        setUserDefaults()
    }
    @IBAction func inputPara4(_ sender: Any) {
        paraInt4 = Field2value(field:para4)
        setUserDefaults()
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
//        paraCnt0.frame  = CGRect(x:x0,   y: b0y ,width: bw, height: bh)
//        paraTxt0.frame  = CGRect(x:x1,   y: b0y ,width: bw*5, height: bh)
//        paraCnt1.frame  = CGRect(x:x0,   y: b1y ,width: bw, height: bh)
//        paraTxt1.frame  = CGRect(x:x1,   y: b1y ,width: bw*5, height: bh)
//        paraCnt2.frame  = CGRect(x:x0,   y: b2y ,width: bw,height:bh)
//        paraTxt2.frame  = CGRect(x:x1,   y: b2y ,width: bw*5,height:bh)
//        paraCnt3.frame  = CGRect(x:x0,   y: b0y ,width: bw, height: bh)
//        paraTxt3.frame  = CGRect(x:x1,   y: b0y ,width: bw*5, height: bh)
//        paraCnt4.frame  = CGRect(x:x0,   y: b1y ,width: bw, height: bh)
//        paraTxt4.frame  = CGRect(x:x1,   y: b1y ,width: bw*5, height: bh)
//        paraCnt5.frame  = CGRect(x:x0,   y: b2y ,width: bw,height:bh)
//        paraTxt5.frame  = CGRect(x:x1,   y: b2y ,width: bw*5,height:bh)
//
//        paraCnt0.frame  = CGRect(x:x0,   y: b3y ,width: bw, height: bh)
//        paraTxt0.frame  = CGRect(x:x1,   y: b3y ,width: bw*5, height: bh)
//        paraCnt1.frame  = CGRect(x:x0,   y: b4y ,width: bw, height: bh)
//        paraTxt1.frame  = CGRect(x:x1,   y: b4y ,width: bw*5, height: bh)
//        paraCnt2.frame  = CGRect(x:x0,   y: b5y ,width: bw,height:bh)
//        paraTxt2.frame  = CGRect(x:x1,   y: b5y ,width: bw*5,height:bh)
//
//
//        paraCnt6.frame  = CGRect(x:x0,   y: b6y ,width: bw,height:bh)
//        paraTxt6.frame  = CGRect(x:x1,   y: b6y ,width: bw*5,height:bh)
//        paraCnt7.frame  = CGRect(x:x0,   y: b7y ,width: bw,height:bh)
//        paraTxt7.frame  = CGRect(x:x1,   y: b7y ,width: bw*5,height:bh)
//
        bw=ww*0.9/7
        bh=bw*170/440
        sp=ww*0.1/10
        let by=wh-bh-sp
        
        defaultButton.frame=CGRect(x:bw*5+sp*7,y:by,width:bw,height:bh)
        exitButton.frame=CGRect(x:bw*6+sp*8,y:by,width:bw,height:bh)
    }

}
