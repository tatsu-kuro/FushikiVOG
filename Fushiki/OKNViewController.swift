//
//  OKNViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2018/08/05.
//  Copyright © 2018年 tatsuaki.kuroda. All rights reserved.
//

import UIKit

class OKNViewController: UIViewController {
    var timer: Timer!
    var tcount: Int = 0
    var oknSpeed:CGFloat = 5.0
    var bandWidth:CGFloat = 0
    var panFlag:Bool = false
     @IBOutlet weak var textIroiro: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        bandWidth = self.view.bounds.width/10
        textIroiro.isHidden=false
        timer = Timer.scheduledTimer(timeInterval: 1.0/100.0, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        tcount=0
        UIApplication.shared.isIdleTimerDisabled = true//スリープしない
    }
 @IBAction func panGes(_ sender: UIPanGestureRecognizer) {
    if sender.state == .began{
        //               textIroiro.isHidden=false
        panFlag=true
        for _ in 0..<7{
            view.layer.sublayers?.removeLast()
        }
        drawBands(startP: bandWidth)
    }else if sender.state == .changed{
        textIroiro.isHidden=false
 //       checkerView.isHidden=true
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
    
@objc func update(tm: Timer) {
    if panFlag==true{
        return
    }
    if tcount > 0{
        for _ in 0..<7{
            view.layer.sublayers?.removeLast()
        }
    }
    tcount += 1
    let sp:CGFloat = CGFloat(tcount)*oknSpeed
    drawBands(startP: CGFloat(Int(sp) % (2*Int(bandWidth))))
    if tcount > 100*60*5 {
        if UIApplication.shared.isIdleTimerDisabled == true{
            UIApplication.shared.isIdleTimerDisabled = false//5分たったら監視する
        }
    }


    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
}
