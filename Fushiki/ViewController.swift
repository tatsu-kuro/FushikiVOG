//
//  ViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2018/07/06.
//  Copyright © 2018年 tatsuaki.kuroda. All rights reserved.
//

import UIKit
import Foundation

class ViewController: UIViewController {
    var cirDiameter:CGFloat = 0
    var bandWidth:CGFloat = 0
    var timer: Timer!
    var tcount: Int = 0
    var ettWidth:CGFloat = 200
    var ettSpeed:CGFloat = 20
    @IBOutlet weak var OKNbutton: UIButton!
    @IBOutlet weak var ETTbutton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        bandWidth = self.view.bounds.width/12
        cirDiameter = self.view.bounds.width/12/3
    }

   
    @IBAction func panGes(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            if timer?.isValid == true{
                timer.invalidate()
            }
        } else if sender.state == .changed {
            var pos = sender.location(in: self.view)
            view.layer.sublayers?.removeLast()
            pos.y = self.view.bounds.height/2
            drawCircle(cPoint: pos)
            ettWidth = abs(pos.x - self.view.bounds.width/2)
        }else if sender.state == .ended{
            view.layer.sublayers?.removeLast()
            startETT(0)
        }
    }

    @IBAction func tapGes(_ sender: Any) {
        if timer?.isValid == true {
            timer.invalidate()
            view.layer.sublayers?.removeLast()
            ETTbutton.isEnabled=true
            ETTbutton.isHidden=false
            OKNbutton.isEnabled=true
            OKNbutton.isHidden=false
        }
    }
    @IBAction func startOKN(_ sender: Any) {

    }

    func drawCircle(cPoint:CGPoint){
        /* --- 円を描画 --- */
        let circleLayer = CAShapeLayer.init()
        let circleFrame = CGRect.init(x:cPoint.x,y:cPoint.y,width:cirDiameter,height:cirDiameter)//circleFrame
        circleLayer.frame = circleFrame//CGRect.init(x:0,y:0,width:cirDiameter,height:cirDiameter)//circleFrame
        // 輪郭の色
        //circleLayer.strokeColor = UIColor.white.cgColor
        // 円の中の色
        circleLayer.fillColor = UIColor.red.cgColor
        // 輪郭の太さ
        //circleLayer.lineWidth = 0.5//詳細不明？
        //print(circleLayer.lineWidth)
        // 円形を描画
        circleLayer.path = UIBezierPath.init(ovalIn: CGRect.init(x: 0, y: 0, width: circleFrame.size.width, height: circleFrame.size.height)).cgPath
        
        
  //      circleLayer.path = UIBezierPath.init(ovalIn: circleLayer.frame).cgPath
        self.view.layer.addSublayer(circleLayer)
    }
    @IBAction func startETT(_ sender: Any) {
        if timer?.isValid == true {
            timer.invalidate()
        }else{
            timer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
            tcount=0
            ETTbutton.isEnabled=false
            ETTbutton.isHidden=true
            OKNbutton.isEnabled=false
            OKNbutton.isHidden=true
        }
    }
    @objc func update(tm: Timer) {
        if tcount > 0{
            view.layer.sublayers?.removeLast()
        }
        tcount += 1
        let cPoint = CGPoint(x:view.bounds.width/2 + sin(CGFloat(tcount)/ettSpeed)*ettWidth, y: view.bounds.height/2)
        drawCircle(cPoint:cPoint)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //    var pinchStartWidth:CGFloat = 1
    //    @IBAction func pinchGes(_ sender: UIPinchGestureRecognizer) {
    //        var startWidth:CGFloat = 100
    //        if (sender.numberOfTouches >= 2) {
    //             let p:CGPoint = sender.location(ofTouch: 0, in: self.view)
    //            let q:CGPoint = sender.location(ofTouch: 1, in: self.view)
    //            if sender.state == .began{
    //                pinchStartWidth = abs(p.x - q.x)
    //                startWidth = ettWidth
    //            } else if sender.state == .changed {
    ////            print(abs(p.x-q.x)/pinchStartWidth)
    //                let temp = startWidth + abs(p.x-q.x) - pinchStartWidth
    //                if temp < 20 {
    //                    ettWidth = 20
    //                } else if temp > 300{
    //                    ettWidth = 300
    //                } else {
    //                    ettWidth = temp
    //                }
    //                print(ettWidth)
    //                //ettWidth =  startWidth + sa
    //            }
    //        }
    //    }
}

