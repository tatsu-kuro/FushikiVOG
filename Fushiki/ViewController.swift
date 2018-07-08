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
    var ettWidth:CGFloat = 200.0
    var ettSpeed:CGFloat = 0.3
    @IBOutlet weak var textIroiro: UITextField!
    @IBOutlet weak var OKNbutton: UIButton!
    @IBOutlet weak var ETTbutton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        bandWidth = self.view.bounds.width/12
        cirDiameter = self.view.bounds.width/12/3
        textIroiro.text = " "
    }

    @IBAction func panGes(_ sender: UIPanGestureRecognizer) {
        if ETTbutton.isHidden != true{
            return
        }
        if sender.state == .began {
            if sender.location(in: self.view).y>self.view.bounds.height/2{
                if timer?.isValid == true{
                    timer.invalidate()
                }
            }else{
            }
        } else if sender.state == .changed {
            if timer?.isValid != true{
                var pos = sender.location(in: self.view)
                view.layer.sublayers?.removeLast()
                pos.y = self.view.bounds.height/2
                drawCircle(cPoint: pos)
                ettWidth = abs(pos.x - self.view.bounds.width/2)
            }else{
                let speed = sender.location(in: self.view).x*10/self.view.bounds.width
                ettSpeed = CGFloat(Int(speed+2))/10.0
                textIroiro.text = "\(ettSpeed)"
 //               print(ettSpeed)
            }
        }else if sender.state == .ended{
            if timer?.isValid != true{
                view.layer.sublayers?.removeLast()
                startETT(0)
            }
            textIroiro.text = " "
        }
    }

    @IBAction func tapGes(_ sender: Any) {
        
        if timer?.isValid == true && ETTbutton.isHidden == true{
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
        let circleFrame = CGRect.init(x:cPoint.x-cirDiameter/2,y:cPoint.y-cirDiameter/2,width:cirDiameter,height:cirDiameter)//circleFrame
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
            timer = Timer.scheduledTimer(timeInterval: 1.0/100.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
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
        //3.1415*5 -> 50回で１周、50回ps
        let cPoint = CGPoint(x:view.bounds.width/2 + sin(CGFloat(tcount)*ettSpeed/(3.1415*5.0))*ettWidth, y: view.bounds.height/2)
        drawCircle(cPoint:cPoint)
//        if tcount%10 == 0{
//            textIroiro.text = "\(ettSpeed)"
//        }
//        print(tcount,ettSpeed,sin(CGFloat(tcount)/ettSpeed))
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

