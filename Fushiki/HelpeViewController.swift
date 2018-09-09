//
//  HelpeViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2018/09/08.
//  Copyright © 2018年 tatsuaki.kuroda. All rights reserved.
//

import UIKit

class HelpeViewController: UIViewController {
    var helpHlimit:CGFloat=0
    var posYlast:CGFloat=0
    @IBOutlet weak var helpeView: UIImageView!
    override func viewDidLoad() {
        super.viewDidLoad()
        let w=view.bounds.width
        helpeView.frame.origin.x=0
        helpeView.frame.origin.y=20
        helpeView.frame.size.width=w
        helpeView.frame.size.height=w*1.30
        helpHlimit=view.bounds.height-w*1.30 - 50
        if UIApplication.shared.isIdleTimerDisabled == true{
            UIApplication.shared.isIdleTimerDisabled = false//監視する
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    func moveImage(mov:CGFloat){
        helpeView.frame.origin.y -= mov
    }

    @IBAction func panGes(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            posYlast=sender.location(in: self.view).y
        } else if sender.state == .changed {
            let posY = sender.location(in: self.view).y
            let h=helpeView.frame.origin.y - posYlast + posY
            if h < 0 && h > helpHlimit{
                helpeView.frame.origin.y -= posYlast-posY
                posYlast=posY
            }
        }else if sender.state == .ended{
        }
    }

}
