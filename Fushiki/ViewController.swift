//
//  ViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2018/07/06.
//  Copyright © 2018年 tatsuaki.kuroda. All rights reserved.
//

import UIKit
import Foundation
//import SpriteKit

class ViewController: UIViewController {
    var cirDiameter:CGFloat = 0
    var bandWidth:CGFloat = 0
    var timer: Timer!
    var timer1: Timer!
    var tcount: Int = 0
    var ettWidth:CGFloat = 200.0
    var ettSpeed:CGFloat = 0.3
    var oknSpeed:CGFloat = 5.0
    var panFlag:Bool = false
    var ettoknMode:Int = 0 //0:off 1:ettpursuits 2:ettsaccade 3:okn
    var saccadeMode:Int = 0 //0:left 1:both 2:right
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var bothButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var helpText: UILabel!
    @IBOutlet weak var textIroiro: UITextField!
    @IBOutlet weak var OKNbutton: UIButton!
    @IBOutlet weak var ETTbutton: UIButton!
    @IBOutlet weak var ETTCbutton:
    UIButton!
    @IBOutlet weak var checkerView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let skView = self.view as! SKView
//        // FPSを表示する
//        skView.showsFPS = true
//        // ノードの数を表示する
//        skView.showsNodeCount = true
//        // ビューと同じサイズでシーンを作成する
//        let scene = SKScene(size:skView.frame.size)
//        // ビューにシーンを表示する
//        skView.presentScene(scene)
        
        bandWidth = self.view.bounds.width/10
        cirDiameter = self.view.bounds.width/26
        textIroiro.text = " "
        checkerView.isHidden=true
        leftButton.isHidden=true
        rightButton.isHidden=true
        bothButton.isHidden=true
    }

    
    @IBAction func showCheck(_ sender: Any) {
        if ettoknMode == 1 || ettoknMode == 2{
        if checkerView.isHidden == true{
            checkerView.isHidden = false
        }else{
            checkerView.isHidden = true
        }
        }
    }
//    @IBOutlet weak var both1Button: UIButton!
    @IBAction func rightETT(_ sender: Any) {
        saccadeMode=2
        tcount=1
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
     }
 
    @IBAction func bothETT(_ sender: Any) {
        saccadeMode=1
        tcount=1
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
    }
    
    @IBAction func leftETT(_ sender: Any) {
        saccadeMode=0
        tcount=1
        if UIApplication.shared.isIdleTimerDisabled == false{
            UIApplication.shared.isIdleTimerDisabled = true//スリープしない
        }
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
                textIroiro.isHidden=false
                panFlag=true
            } else if sender.state == .changed {
                if sender.location(in: self.view).y>self.view.bounds.height/2{

 //               if timer?.isValid != true{
                    var pos = sender.location(in: self.view)
                    view.layer.sublayers?.removeLast()
                    pos.y = self.view.bounds.height/2
                    drawCircle(cPoint: pos)
                    ettWidth = abs(pos.x - self.view.bounds.width/2)
                    textIroiro.text = "\(ettSpeed)Hz"

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
 //               setUserDefaults()
                textIroiro.isHidden=true
            }
        }else if ettoknMode == 3{
            if sender.state == .began{
 //               textIroiro.isHidden=false
                panFlag=true
                for _ in 0..<7{
                    view.layer.sublayers?.removeLast()
                }
                drawBands(startP: bandWidth)
            }else if sender.state == .changed{
                textIroiro.isHidden=false
                checkerView.isHidden=true
                 let speed = sender.location(in:self.view).x*20/self.view.bounds.width
                 if speed > 10 {
                    oknSpeed = speed - 10 + 1
                    textIroiro.text = "\(Int(oknSpeed))"
                }else{
                    oknSpeed = speed - 10 - 1
                    textIroiro.text = "\(Int(abs(oknSpeed)))"
                }
             }else if sender.state == .ended{
                panFlag=false
                textIroiro.text = " "
//                setUserDefaults()
            }
            
        }
    }
    var ettmodeButtonsflag:Bool = false
    @IBOutlet weak var showEttmodeButton: UIButton!

    @IBAction func showEttmodeButtons(_ sender: Any) {
        if ettoknMode == 2{

        if ettmodeButtonsflag == false{
            leftButton.isHidden=false
            bothButton.isHidden=false
            rightButton.isHidden=false
            ettmodeButtonsflag = true
        }else{
            leftButton.isHidden=true
            bothButton.isHidden=true
            rightButton.isHidden=true
            ettmodeButtonsflag = false
        }
        }
    }
    
    @IBAction func tapGes(_ sender: UITapGestureRecognizer) {
        //print("doubletap",ettoknMode,"doubletap")
        if ettoknMode != 0 {
            if timer?.isValid == true{
                timer.invalidate()
            }
            if timer1?.isValid == true{
                timer1.invalidate()
            }
            if ettoknMode == 1 || ettoknMode == 2{
                view.layer.sublayers?.removeLast()
             }else if ettoknMode == 3{
                for _ in 0..<7{
                    view.layer.sublayers?.removeLast()
                }
            }
            ETTbutton.isEnabled=true
            ETTbutton.isHidden=false
            ETTCbutton.isEnabled=true
            ETTCbutton.isHidden=false
            OKNbutton.isEnabled=true
            OKNbutton.isHidden=false
            helpText.isHidden=false
            bothButton.isHidden=true
            rightButton.isHidden=true
            leftButton.isHidden=true

            ettoknMode = 0
            checkerView.isHidden=true
            UIApplication.shared.isIdleTimerDisabled = false//スリープ状態へ移行する時間を監視しているIdleTimerをon
        }
    }
    @IBAction func startOKN(_ sender: Any) {
        ettoknMode=3
        textIroiro.isHidden=false
        timer = Timer.scheduledTimer(timeInterval: 1.0/100.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        tcount=0
        ETTbutton.isEnabled=false
        ETTbutton.isHidden=true
        ETTCbutton.isEnabled=false
        ETTCbutton.isHidden=true
        OKNbutton.isEnabled=false
        OKNbutton.isHidden=true
        helpText.isHidden=true
        UIApplication.shared.isIdleTimerDisabled = true//スリープしない
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
//    func eraseCircles(){
//        /* --- 四角形を描画 --- */
//        let rectangleLayer = CAShapeLayer.init()
//        let rectangleFrame = CGRect.init(x: 0, y: self.view.bounds.height/2-cirDiameter, width: self.view.bounds.width, height: cirDiameter*2)
//        rectangleLayer.frame = rectangleFrame
//
//        // 輪郭の色
//        rectangleLayer.strokeColor = UIColor.white.cgColor
//        // 四角形の中の色
//        rectangleLayer.fillColor = UIColor.white.cgColor
//        // 輪郭の太さ
//        // rectangleLayer.lineWidth = 2.5
//
//        // 四角形を描画
//        rectangleLayer.path = UIBezierPath.init(rect: CGRect.init(x: 0, y: 0, width: rectangleFrame.size.width, height: rectangleFrame.size.height)).cgPath
//
//        self.view.layer.addSublayer(rectangleLayer)
//
//    }
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
    @IBAction func startETTC(_ sender: Any) {
        ettoknMode=2
        textIroiro.isHidden=true
        
        bothButton.isHidden=true
        leftButton.isHidden=true
        rightButton.isHidden=true
        ettmodeButtonsflag=false
        timer1 = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update1), userInfo: nil, repeats: true)
        tcount=0
        ETTbutton.isEnabled=false
        ETTbutton.isHidden=true
        ETTCbutton.isEnabled=false
        ETTCbutton.isHidden=true
        OKNbutton.isEnabled=false
        OKNbutton.isHidden=true
        helpText.isHidden=true
        UIApplication.shared.isIdleTimerDisabled = true//スリープしない
    }
    @IBAction func startETT(_ sender: Any) {
        ettoknMode = 1
        textIroiro.isHidden=true
        bothButton.isHidden=true
        leftButton.isHidden=true
        rightButton.isHidden=true
        ettmodeButtonsflag=false
        timer = Timer.scheduledTimer(timeInterval: 1.0/100.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        tcount=0
        ETTbutton.isEnabled=false
        ETTbutton.isHidden=true
        ETTCbutton.isEnabled=false
        ETTCbutton.isHidden=true
        OKNbutton.isEnabled=false
        OKNbutton.isHidden=true
        helpText.isHidden=true
        UIApplication.shared.isIdleTimerDisabled = true//スリープしない
    }
    @objc func update1(tm: Timer) {
        //print(tcount)
        var cPoint = CGPoint(x:0,y:0)
        if tcount > 0{
            view.layer.sublayers?.removeLast()
        }
        tcount += 1
        if saccadeMode == 1{
            cPoint = CGPoint(x:view.bounds.width/10,y:view.bounds.height/2)
            if tcount%4 == 1 || tcount%4 == 3{
                cPoint = CGPoint(x:view.bounds.width/2,y:view.bounds.height/2)

            }else if tcount%4 == 2{
                cPoint = CGPoint(x:view.bounds.width*9/10,y:view.bounds.height/2)
            }
        }else if saccadeMode == 2{
            cPoint = CGPoint(x:view.bounds.width*CGFloat((tcount%5)*2+1)/10,y:view.bounds.height/2)
        }else{
            cPoint = CGPoint(x:view.bounds.width*CGFloat(9 - (tcount%5)*2)/10,y:view.bounds.height/2)
        }
        drawCircle(cPoint:cPoint)
        if ettoknMode > 0{
            if tcount > 60*5 {
                if UIApplication.shared.isIdleTimerDisabled == true{
                    UIApplication.shared.isIdleTimerDisabled = false//5分たったら監視する
                }
            }
        }

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
        }else if ettoknMode == 3 && panFlag == false{
            if tcount > 0{
                for _ in 0..<7{
                    view.layer.sublayers?.removeLast()
                }
            }
            tcount += 1
            let sp:CGFloat = CGFloat(tcount)*oknSpeed
            drawBands(startP: CGFloat(Int(sp) % (2*Int(bandWidth))))

        }
        if ettoknMode > 0{
            if tcount > 100*60*5 {
                if UIApplication.shared.isIdleTimerDisabled == true{
                    UIApplication.shared.isIdleTimerDisabled = false//5分たったら監視する
                }
            }
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

