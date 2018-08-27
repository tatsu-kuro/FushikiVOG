//
//  OKNrotateViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2018/08/27.
//  Copyright © 2018年 tatsuaki.kuroda. All rights reserved.
//

import UIKit

class OKNrotateViewController: UIViewController {
    @IBOutlet weak var bandsView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()
        bandsView.frame.origin.x = 0 - view.bounds.width
        bandsView.frame.origin.y = 0 - view.bounds.height
        bandsView.frame.size.width=view.bounds.width*3
        bandsView.frame.size.height=view.bounds.height*3

        // Do any additional setup after loading the view.
        bandsView.transform=CGAffineTransform(rotationAngle: CGFloat(M_PI/4))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
