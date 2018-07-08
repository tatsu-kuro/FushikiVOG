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
    var oknSpeed:CGFloat = 5.0
    var panFlag:Bool = false
    var ettoknMode:Int = 0 //0:off 1:ett 2:okn
    @IBOutlet weak var helpText: UILabel!
    @IBOutlet weak var textIroiro: UITextField!
    @IBOutlet weak var OKNbutton: UIButton!
    @IBOutlet weak var ETTbutton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        bandWidth = self.view.bounds.width/10
        cirDiameter = self.view.bounds.width/26
        textIroiro.text = " "
    }

    @IBAction func panGes(_ sender: UIPanGestureRecognizer) {
        if ETTbutton.isHidden != true{
            return
        }
        if ettoknMode == 0 {
            return
        }
        
        if ettoknMode == 1 {
            if sender.state == .began {
                panFlag=true
//                if sender.location(in: self.view).y>self.view.bounds.height/2{
//                    if timer?.isValid == true{
//                        timer.invalidate()
//                    }
//                }else{
//                }
            } else if sender.state == .changed {
                if sender.location(in: self.view).y>self.view.bounds.height/2{

 //               if timer?.isValid != true{
                    var pos = sender.location(in: self.view)
                    view.layer.sublayers?.removeLast()
                    pos.y = self.view.bounds.height/2
                    drawCircle(cPoint: pos)
                    ettWidth = abs(pos.x - self.view.bounds.width/2)
                }else{
                    let speed = sender.location(in: self.view).x*10/self.view.bounds.width
                    ettSpeed = CGFloat(Int(speed+2))/10.0
                    textIroiro.text = "\(ettSpeed)Hz"
                }
            }else if sender.state == .ended{
//                if timer?.isValid != true{
//                    view.layer.sublayers?.removeLast()
//                    startETT(0)
//                }
                textIroiro.text = " "
                panFlag=false
            }
        }else if ettoknMode == 2{
            if sender.state == .began{
                panFlag=true
                for _ in 0..<7{
                    view.layer.sublayers?.removeLast()
                }
                drawBands(startP: bandWidth)
            }else if sender.state == .changed{
                let speed = sender.location(in:self.view).x*10/self.view.bounds.width
                oknSpeed=speed
                textIroiro.text = "\(Int(oknSpeed+1))"
            }else if sender.state == .ended{
                panFlag=false
                textIroiro.text = " "
            }
            
        }
    }

    @IBAction func tapGes(_ sender: Any) {
        if ettoknMode != 0 {
            timer.invalidate()
            if ettoknMode == 1{
                view.layer.sublayers?.removeLast()
            }else{
                for _ in 0..<7{
                    view.layer.sublayers?.removeLast()
                }
            }
            ETTbutton.isEnabled=true
            ETTbutton.isHidden=false
            OKNbutton.isEnabled=true
            OKNbutton.isHidden=false
            helpText.isHidden=false
            ettoknMode = 0
        }
    }
    @IBAction func startOKN(_ sender: Any) {
        ettoknMode=2
        timer = Timer.scheduledTimer(timeInterval: 1.0/100.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        tcount=0
        ETTbutton.isEnabled=false
        ETTbutton.isHidden=true
        OKNbutton.isEnabled=false
        OKNbutton.isHidden=true
        helpText.isHidden=true
    }
    func drawBands(startP:CGFloat){
        for i  in 0..<7 {
            drawBand1(bandS: startP + bandWidth*2.0*CGFloat(i),bandW:bandWidth)
        }
        if startP>bandWidth{
            view.layer.sublayers?.removeLast()
            drawBand1(bandS:0,bandW:startP-bandWidth)
        }
    }
    func drawBand1(bandS:CGFloat,bandW:CGFloat){
        /* --- 四角形を描画 --- */
        let rectangleLayer = CAShapeLayer.init()
        let rectangleFrame = CGRect.init(x: bandS, y: 0, width: bandW , height: self.view.bounds.height)
        rectangleLayer.frame = rectangleFrame
        
        // 輪郭の色
        rectangleLayer.strokeColor = UIColor.black.cgColor
        // 四角形の中の色
        rectangleLayer.fillColor = UIColor.black.cgColor
        // 輪郭の太さ
       // rectangleLayer.lineWidth = 2.5
        
        // 四角形を描画
        rectangleLayer.path = UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: rectangleFrame.size.width, height: rectangleFrame.size.height)).cgPath
        
        self.view.layer.addSublayer(rectangleLayer)
    }
    func drawCircle(cPoint:CGPoint){
        /* --- 円を描画 --- */
        let circleLayer = CAShapeLayer.init()
        let circleFrame = CGRect.init(x:cPoint.x-cirDiameter/2,y:cPoint.y-cirDiameter/2,width:cirDiameter,height:cirDiameter)
        circleLayer.frame = circleFrame
        // 輪郭の色
        //circleLayer.strokeColor =
        // 円の中の色
        circleLayer.fillColor = UIColor.red.cgColor
        // 輪郭の太さ
        //circleLayer.lineWidth = 0.5
        // 円形を描画
        circleLayer.path = UIBezierPath.init(ovalIn: CGRect.init(x: 0, y: 0, width: circleFrame.size.width, height: circleFrame.size.height)).cgPath
        self.view.layer.addSublayer(circleLayer)
    }
    @IBAction func startETT(_ sender: Any) {
        ettoknMode = 1
        timer = Timer.scheduledTimer(timeInterval: 1.0/100.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        tcount=0
        ETTbutton.isEnabled=false
        ETTbutton.isHidden=true
        OKNbutton.isEnabled=false
        OKNbutton.isHidden=true
        helpText.isHidden=true
    }
    @objc func update(tm: Timer) {
        if ettoknMode == 1 && panFlag == false{
            if tcount > 0{
                view.layer.sublayers?.removeLast()
            }
            tcount += 1
            //3.1415*5 -> 100回で１周、100回ps
            let cPoint = CGPoint(x:view.bounds.width/2 + sin(CGFloat(tcount)*ettSpeed/(3.1415*5.0))*ettWidth, y: view.bounds.height/2)
            drawCircle(cPoint:cPoint)
        }else if ettoknMode == 2 && panFlag == false{
            if tcount > 0{
                for _ in 0..<7{
                    view.layer.sublayers?.removeLast()
                }
            }
            tcount += 1
            let sp:CGFloat = CGFloat(tcount)*oknSpeed
            drawBands(startP: CGFloat(Int(sp) % (2*Int(bandWidth))))

        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

