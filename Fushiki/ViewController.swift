//
//  ViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2018/07/06.
//  Copyright © 2018年 tatsuaki.kuroda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var freeCounter:Int = 0
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
    var oknSpeed:Int = 1
    var oknSpeedsub:Int = 2
    var okpSpeedsub:Int = 2
    var oknDirection:Int = 0
    var oknWidth:CGFloat = 1.0
    var gyroMode:Int = 0
    var okpMode:Int = 0
    var saccadeMode:Int = 0 //0:left 1:both 2:right
    @IBOutlet weak var counterText: UILabel!
    @IBOutlet weak var ETTpbutton: UIButton!
    @IBOutlet weak var ETTsButton: UIButton!
    @IBOutlet weak var stillButton: UIButton!
    
  //  @IBOutlet weak var showCeckbutton: UIButton!
 //   @IBOutlet weak var ETTCbutton: UIButton!
    func getUserDefault(str:String,ret:Int) -> Int{//getUserDefault_one
        if (UserDefaults.standard.object(forKey: str) != nil){//keyが設定してなければretをセット
            return UserDefaults.standard.integer(forKey:str)
        }else{
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }
    func CounterAlert(){
        
        counterText.text="\(freeCounter)/50"
        
        if freeCounter>50{
            ETTpbutton.isEnabled=false
            ETTsButton.isEnabled=false
            // アラートを作成
            let alert = UIAlertController(
                title: "over 50 trials !",
                message: "from now, some exercises are not available.",
                preferredStyle: .alert)
            // アラートにボタンをつける
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                //self.vHITcalc_pre()
            }))
            // アラート表示
            self.present(alert, animated: true, completion: nil)
            //          return
        }
    }
    @objc func viewWillEnterForeground(_ notification: Notification?) {
        freeCounter = getUserDefault(str: "freeCounter", ret:0)//50回以上になるとその由のアラームを出す
        freeCounter += 1
        UserDefaults.standard.set(freeCounter, forKey: "freeCounter")
        CounterAlert()
     }
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.viewWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        stillButton.titleLabel?.numberOfLines = 2
        stillButton.titleLabel!.textAlignment = NSTextAlignment.center
        bandWidth = self.view.bounds.width/10
        cirDiameter = self.view.bounds.width/26
        freeCounter = getUserDefault(str: "freeCounter", ret:0)//50回以上になるとその由のアラームを出す
        freeCounter += 1
        UserDefaults.standard.set(freeCounter, forKey: "freeCounter")
        CounterAlert()
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
        
        if let vc = segue.destination as? OKNrotateViewController{
            let Controller:OKNrotateViewController = vc
            Controller.oknSpeed=oknSpeed
            Controller.oknSpeedsub=oknSpeedsub
            Controller.okpSpeedsub=okpSpeedsub
            Controller.oknDirection=oknDirection
            Controller.oknWidth=oknWidth
            Controller.gyroMode=gyroMode
            Controller.okpMode=okpMode
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
        if let vc = segue.source as? OKNrotateViewController{
            let Controller:OKNrotateViewController = vc
            oknSpeed=Controller.oknSpeed
            oknSpeedsub=Controller.oknSpeedsub
            okpSpeedsub=Controller.okpSpeedsub
            oknDirection=Controller.oknDirection
            oknWidth=Controller.oknWidth
            gyroMode=Controller.gyroMode
            okpMode=Controller.okpMode
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

