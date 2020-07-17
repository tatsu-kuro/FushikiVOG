//
//  SetteiViewController.swift
//  Fushiki
//
//  Created by 黒田建彰 on 2020/07/17.
//  Copyright © 2020 tatsuaki.Fushiki. All rights reserved.
//

import UIKit

class SetteiViewController: UIViewController {
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
    
    @IBAction func exitBut(_ sender: Any) {
        goExit(0)
    }
    @IBAction func goExit(_ sender: Any) {
              let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
               //delTimer()
               self.present(mainView, animated: false, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setScreen()
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
