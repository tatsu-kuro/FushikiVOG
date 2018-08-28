//
//  ViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2018/07/06.
//  Copyright © 2018年 tatsuaki.kuroda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var timer: Timer!
    var backModeETTp:Int = 0
    var backModeETTs:Int = 0
    var backModeStill:Int = 0
    var ballSizeStill:Int = 2
    var ballColorStill:Int = 1
    var cirDiameter:CGFloat = 0
    var bandWidth:CGFloat = 0
    var timer1Interval:Int = 2
    var ettWidth:CGFloat = 200.0
    var ettSpeed:CGFloat = 0.3
    var oknSpeed:CGFloat = 1.0
    var oknrSpeed:Int = 1
    var oknrDirection:Int = 0
    var oknrWidth:CGFloat = 1.0
    var oknrMode:Int = 0
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
    @objc func update(tm: Timer) {
        if UIApplication.shared.isIdleTimerDisabled == true{
            UIApplication.shared.isIdleTimerDisabled = false//5分たったら監視する
        }
   //     print("**topView  timer")
    }
 //   override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        timer = Timer.scheduledTimer(timeInterval: 60*5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
        
        if let vc = segue.destination as? OKNViewController {
            let Controller:OKNViewController = vc
            Controller.oknSpeed=oknSpeed
        }else if let vc = segue.destination as? OKNrotateViewController{
            let Controller:OKNrotateViewController = vc
            Controller.oknrSpeed=oknrSpeed
            Controller.oknrDirection=oknrDirection
            Controller.oknrWidth=oknrWidth
            Controller.oknrMode=oknrMode
        }else if let vc = segue.destination as? StillViewController{
            let Controller:StillViewController = vc
            Controller.backMode=backModeStill
            Controller.ballSize=ballSizeStill
            Controller.ballColor=ballColorStill
        }else if let vc = segue.destination as? ETTsViewController{
            let Controller:ETTsViewController = vc
            Controller.backMode=backModeETTs
            Controller.saccadeMode=saccadeMode
            Controller.timer1Interval=timer1Interval
        }else if let vc = segue.destination as? ETTcViewController{
        let Controller:ETTcViewController = vc
            Controller.backMode=backModeETTp
            Controller.ettSpeed=ettSpeed
            Controller.ettWidth=ettWidth
        }
    }
    @IBAction func unwind(_ segue: UIStoryboardSegue) {
        if UIApplication.shared.isIdleTimerDisabled == true{
            UIApplication.shared.isIdleTimerDisabled = false//監視する
        }
        if timer?.isValid == true {
            timer.invalidate()
        }
        if let vc = segue.source as? OKNViewController {
            let Controller:OKNViewController = vc
            oknSpeed=Controller.oknSpeed
        }else if let vc = segue.source as? OKNrotateViewController{
            let Controller:OKNrotateViewController = vc
            oknrSpeed=Controller.oknrSpeed
            oknrDirection=Controller.oknrDirection
            oknrWidth=Controller.oknrWidth
            oknrMode=Controller.oknrMode
        }else if let vc = segue.source as? StillViewController{
            let Controller:StillViewController = vc
            backModeStill=Controller.backMode
            ballSizeStill=Controller.ballSize
            ballColorStill=Controller.ballColor
        }else if let vc = segue.source as? ETTsViewController{
            let Controller:ETTsViewController = vc
            saccadeMode=Controller.saccadeMode
            backModeETTs=Controller.backMode
            timer1Interval=Controller.timer1Interval
        }else if let vc = segue.source as? ETTcViewController{
            let Controller:ETTcViewController = vc
            backModeETTp=Controller.backMode
            ettWidth=Controller.ettWidth
            ettSpeed=Controller.ettSpeed
        }
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

