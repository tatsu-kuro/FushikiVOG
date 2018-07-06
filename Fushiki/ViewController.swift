//
//  ViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2018/07/06.
//  Copyright © 2018年 tatsuaki.kuroda. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var cirDiameter:CGFloat = 0
    var bandWidth:CGFloat = 0
    @IBOutlet weak var OKNbutton: UIButton!
    @IBOutlet weak var ETTbutton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        bandWidth = self.view.bounds.width/12
        cirDiameter = self.view.bounds.width/12/5
    }
    func makeCircle(diameter dia:CGFloat) -> UIImage{
        let size = CGSize(width: dia, height: dia)
        UIGraphicsBeginImageContextWithOptions(size,false,1.0)
        let context = UIGraphicsGetCurrentContext()
        let circleRect = CGRect(x:0,y:0,width:dia,height:dia)
        let drawPath = UIBezierPath(ovalIn: circleRect)
        context?.setFillColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        drawPath.fill()
        context?.setStrokeColor(red:1.0,green:0.0,blue:0.0,alpha:1.0)
        drawPath.stroke()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    @IBAction func startOKN(_ sender: Any) {
    }
    @IBAction func startETT(_ sender: Any) {
        let circleImage = makeCircle(diameter: cirDiameter)
        let circleView = UIImageView(image:circleImage)
        circleView.center = view.center
        view.addSubview(circleView)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

