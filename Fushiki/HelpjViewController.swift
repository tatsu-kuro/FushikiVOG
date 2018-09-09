//
//  HelpjViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2018/09/08.
//  Copyright © 2018年 tatsuaki.kuroda. All rights reserved.
//

import UIKit

class HelpjViewController: UIViewController {
    @IBOutlet weak var helpView: UIImageView!
    var helpHlimit:CGFloat=0
    var posYlast:CGFloat=0
    override func viewDidLoad() {
        super.viewDidLoad()
        let w=view.bounds.width
        helpView.frame.origin.x=0
        helpView.frame.origin.y=20
        helpView.frame.size.width=w
        helpView.frame.size.height=w*1.79
        helpHlimit=view.bounds.height-w*1.79 - 50
        if UIApplication.shared.isIdleTimerDisabled == true{
            UIApplication.shared.isIdleTimerDisabled = false//監視する
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func moveImage(mov:CGFloat){
        helpView.frame.origin.y -= mov
    }
    @IBAction func panGes(_ sender: UIPanGestureRecognizer) {

         if sender.state == .began {
            posYlast=sender.location(in: self.view).y
         } else if sender.state == .changed {
            let posY = sender.location(in: self.view).y
            let h=helpView.frame.origin.y - posYlast + posY
            if h < 0 && h > helpHlimit{
                helpView.frame.origin.y -= posYlast-posY
                posYlast=posY
            }
         }else if sender.state == .ended{
         }
    }

}
