//
//  OKNrotateViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2018/08/27.
//  Copyright © 2018年 tatsuaki.kuroda. All rights reserved.
//

import UIKit
import CoreMotion

class OKNrotateViewController: UIViewController {
    var timer:Timer!
    var tcount:Int = 0
    var motionManager: CMMotionManager?
    var oknrSpeed:Int = 0
    var oknrDirection:Int = 0
    var oknrWidth:CGFloat = 1.0
    var oknrMode:Int = 0
    @IBOutlet weak var bandsView3: UIImageView!
    @IBOutlet weak var bandsView2: UIImageView!
    @IBOutlet weak var bandsView1: UIImageView!
    @IBOutlet weak var bandsView: UIImageView!
    @IBOutlet weak var bandsViewtemp: UIImageView!
//    @IBOutlet weak var twiceButton: UIButton!
    @IBOutlet weak var gyroButton: UIButton!
    @IBOutlet weak var gyrooffButton: UIButton!
    @IBOutlet weak var width1Button: UIButton!
    @IBOutlet weak var width2Button: UIButton!
    @IBOutlet weak var width3Button: UIButton!
    @IBOutlet weak var speed1Button: UIButton!
    @IBOutlet weak var speed2Button: UIButton!
    @IBOutlet weak var speed3Button: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet var doubleRec:UITapGestureRecognizer!
    @IBOutlet var singleRec:UITapGestureRecognizer!
    func hideButtons(hide:Bool){
        gyroButton.isHidden=hide
        gyrooffButton.isHidden=hide
        width1Button.isHidden=hide
        width2Button.isHidden=hide
        width3Button.isHidden=hide
        rightButton.isHidden=hide
        leftButton.isHidden=hide
        speed1Button.isHidden=hide
        speed2Button.isHidden=hide
        speed3Button.isHidden=hide
    }
    //       iPhone iPad
    //oowaru:40     61
    //chwaru:42     64
    //kowaru:52     53
    @IBAction func tapGes(_ sender: UITapGestureRecognizer) {
        let pos = sender.location(in: self.view)
        if pos.y < view.bounds.height/2{
            if pos.x < 50{
                waru += 1
            }
        }else{
            if pos.x < 50{
                waru -= 1
            }else{
                if gyroButton.isHidden == true{
                    hideButtons(hide: false)
                }else{
                     hideButtons(hide: true)
                }
            }
        }
    }
    @IBAction func gyrooffAction(_ sender: Any) {
        stopTimer()
        oknrMode=0
        setTimer()
   }
    @IBAction func gyroAction(_ sender: Any) {
        stopTimer()
       oknrMode=1
        setTimer()
    }
    @IBAction func width3Action(_ sender: Any) {
        stopTimer()
       oknrWidth=3
        setBand()
        setTimer()
   }
    @IBAction func width2Action(_ sender: Any) {
        stopTimer()
       oknrWidth=2
        setBand()
        setTimer()
   }
    @IBAction func width1Action(_ sender: Any) {
        stopTimer()
        oknrWidth=1
        setBand()
        setTimer()
    }
    @IBAction func speed3Action(_ sender: Any) {
        stopTimer()
        oknrSpeed=3
        setBand()
        setTimer()
    }
    @IBAction func speed2Action(_ sender: Any) {
        stopTimer()
        oknrSpeed=2
        setBand()
        setTimer()
   }
    @IBAction func speed1Action(_ sender: Any) {
        stopTimer()
       oknrSpeed=1
        setBand()
        setTimer()
   }
    @IBAction func rightAction(_ sender: Any) {
        stopTimer()
       oknrDirection=0
        setBand()
        setTimer()
    }
    @IBAction func leftAction(_ sender: Any) {
        stopTimer()
       oknrDirection=1
        setBand()
        setTimer()
   }
    
    var pitch:CGFloat=0
    func attitude() {
        guard let _ = motionManager?.isDeviceMotionAvailable,
            let operationQueue = OperationQueue.current
            else {
                return
        }
        
        motionManager?.startDeviceMotionUpdates(to: operationQueue, withHandler: { motion, _ in
            if let attitude = motion?.attitude {
                if attitude.roll<0{
                self.pitch=CGFloat(attitude.pitch)
                }else{
                    self.pitch = -CGFloat(attitude.pitch)
                }
             }
        })
    }
    func setBand(){
        if oknrWidth == 1{
            bandsView.image=bandsView1.image
         }else if oknrWidth == 2 {
            bandsView.image=bandsView2.image
        }else{
            bandsView.image=bandsView3.image
        }
    }
    func initBands(){
        bandsViewtemp.frame.origin.x = 0 - view.bounds.width/2
        bandsViewtemp.frame.origin.y = 0 - view.bounds.height*2
        bandsViewtemp.frame.size.width=view.bounds.width*2
        bandsViewtemp.frame.size.height=view.bounds.height*5
        bandsView.frame.origin.x = 0 - view.bounds.width/2
        bandsView.frame.origin.y = 0 - view.bounds.height*2
        bandsView.frame.size.width=view.bounds.width*2
        bandsView.frame.size.height=view.bounds.height*5
        bandsView2.frame.origin.x = 0 - view.bounds.width/2
        bandsView2.frame.origin.y = 0 - view.bounds.height*2
        bandsView2.frame.size.width=view.bounds.width*2
        bandsView2.frame.size.height=view.bounds.height*5
        bandsView3.frame.origin.x = 0 - view.bounds.width/2
        bandsView3.frame.origin.y = 0 - view.bounds.height*2
        bandsView3.frame.size.width=view.bounds.width*2
        bandsView3.frame.size.height=view.bounds.height*5
    }
    func stopTimer(){
        if timer?.isValid == true {
            timer.invalidate()
        }
        tcount=0
   }
    func setTimer(){
        timer = Timer.scheduledTimer(timeInterval: 1.0/60.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        tcount=0
    }
    var waru:Int = 0
    //       iPhone iPad
    //oowaru:40     61
    //chwaru:42     64
    //kowaru:52     53

    @objc func update(tm: Timer) {
        var dist:CGFloat=0
        tcount += 1
        if view.bounds.height/view.bounds.width>0.65{//iPad
            if oknrWidth==3{
                waru=61
            }else if oknrWidth==2{
                waru=64
            }else{
                waru=53
            }
        }else{//iPhone
            if oknrWidth==3{
                waru=40
            }else if oknrWidth==2{
                waru=42
            }else{
                waru=52
            }

        }
        if oknrDirection==0{
            dist=CGFloat(tcount*oknrSpeed%waru)*6
        }else{
            dist = -CGFloat(tcount*oknrSpeed%waru)*6
        }
        print("**waru**",waru)
        if oknrMode == 1{
            attitude()
        }else{
            pitch=0
        }
        let t1:CGAffineTransform = CGAffineTransform(rotationAngle: -pitch)
        let t2:CGAffineTransform = CGAffineTransform(translationX: dist*cos(-pitch),y: dist*sin(-pitch))
        let t:CGAffineTransform = t1.concatenating(t2)
        bandsView.transform=t
  //      bandsView.image=bandsViewtemp.image
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        motionManager = CMMotionManager()
        motionManager?.deviceMotionUpdateInterval = 0.03
        initBands()
        setBand()
        singleRec.require(toFail: doubleRec)
        waru=50
        setTimer()
        hideButtons(hide: true)
        // Do any additional setup after loading the view.
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
}
