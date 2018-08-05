//
//  ViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2018/07/06.
//  Copyright © 2018年 tatsuaki.kuroda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
 
    var backMode:Int = 0
    var cirDiameter:CGFloat = 0
    var bandWidth:CGFloat = 0
    var timer1Interval:Int = 2
    var ettWidth:CGFloat = 200.0
    var ettSpeed:CGFloat = 0.3
    var oknSpeed:CGFloat = 5.0
    var saccadeMode:Int = 0 //0:left 1:both 2:right
     
    @IBOutlet weak var helpText: UILabel!
     @IBOutlet weak var OKNbutton: UIButton!
     @IBOutlet weak var stillButton: UIButton!
    
    @IBOutlet weak var showCeckbutton: UIButton!
    @IBOutlet weak var ETTCbutton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
         bandWidth = self.view.bounds.width/10
        cirDiameter = self.view.bounds.width/26
  
    }
 
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    }
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

