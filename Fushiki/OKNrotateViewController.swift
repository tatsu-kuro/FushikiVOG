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
    
    @IBOutlet weak var bandsView: UIImageView!
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
    @IBAction func gyrooffAction(_ sender: Any) {
        print("gyreooff")
    }
    @IBAction func gyroAction(_ sender: Any) {
    }
    @IBAction func width3Action(_ sender: Any) {
    }
    @IBAction func width2Action(_ sender: Any) {
    }
    @IBAction func width1Action(_ sender: Any) {
    }
    @IBAction func speed3Action(_ sender: Any) {
    }
    @IBAction func speed2Action(_ sender: Any) {
    }
    @IBAction func speed1Action(_ sender: Any) {
    }
    @IBAction func rightAction(_ sender: Any) {
    }
    @IBAction func leftAction(_ sender: Any) {
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
   //             print(attitude.pitch,attitude.roll,attitude.yaw)
  //              self.pitchLabel.text = String(format: "%0.2f", attitude.pitch * 180.0 / Double.pi)
  //              print(String(format: "%0.2f", attitude.pitch * 180.0 / Double.pi),String(format: "%0.2f", attitude.roll * 180.0 / Double.pi),String(format: "%0.2f", attitude.yaw * 180.0 / Double.pi))
      //          self.yawLabel.text = String(format: "%0.2f", attitude.yaw * 180.0 / Double.pi)
            }
        })
    }
   override func viewDidLoad() {
        super.viewDidLoad()
        motionManager = CMMotionManager()
        motionManager?.deviceMotionUpdateInterval = 0.03

        bandsView.frame.origin.x = 0 - view.bounds.width
        bandsView.frame.origin.y = 0 - view.bounds.height
        bandsView.frame.size.width=view.bounds.width*3
        bandsView.frame.size.height=view.bounds.height*3
        // Do any additional setup after loading the view.
        timer = Timer.scheduledTimer(timeInterval: 1.0/100.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        tcount=0
    }
    @objc func update(tm: Timer) {
        var rota:CGFloat=0
        tcount += 1
        rota=CGFloat(tcount)/2
        attitude()
        let t1:CGAffineTransform = CGAffineTransform(rotationAngle: -pitch)
        let t2:CGAffineTransform = CGAffineTransform(translationX: rota,y: 0)
        let t:CGAffineTransform = t1.concatenating(t2)
        bandsView.transform=t
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if timer?.isValid == true {
            timer.invalidate()
        }
    }
}
