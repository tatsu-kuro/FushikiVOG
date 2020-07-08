//
//  HelpViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2019/06/30.
//  Copyright © 2019 tatsuaki.Fushiki. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    var englishF:Bool=false
    var helpHlimit:CGFloat=0
    var posYlast:CGFloat=0
    var ettWidth:Int = 0//1:narrow,2:wide
    var oknSpeed:Int = 0
    var oknDirection:Int = 0
    var targetMode:Int = 0
    var tapInterval=CFAbsoluteTimeGetCurrent()
    @IBOutlet weak var helpView: UIImageView!
    
    @IBOutlet weak var helpVieweng: UIImageView!
    
    @IBOutlet weak var exitButton: UIButton!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func doubleTap(_ sender: Any) {//singleTapに変更したが、名前はそのまま
        if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
            print("doubleTapPlay")
            returnMain()
            //                    doubleTap(0)
            //                    self.dismiss(animated: true, completion: nil)
        }else{
            if(englishF){
                englishF=false
                helpView.alpha=1.0
                helpVieweng.alpha=0
            }else{
                englishF=true
                helpView.alpha=0
                helpVieweng.alpha=1.0
            }
        }
        tapInterval=CFAbsoluteTimeGetCurrent()
    }
    func returnMain(){
        let mainView = storyboard?.instantiateViewController(withIdentifier: "mainView") as! ViewController
        mainView.ettWidth=ettWidth
        mainView.oknSpeed=oknSpeed
        mainView.oknDirection=oknDirection
        mainView.targetMode=targetMode
        self.present(mainView, animated: false, completion: nil)
    }
//    @IBAction func exitGo(_ sender: Any) {
//        doubleTap(0)
//    }
    override func remoteControlReceived(with event: UIEvent?) {
        guard event?.type == .remoteControl else { return }
        
        if let event = event {
            
            switch event.subtype {
            case .remoteControlPlay:
                print("Play")
                if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                    print("doubleTapPlay")
                    returnMain()
//                    doubleTap(0)
                    //                    self.dismiss(animated: true, completion: nil)
                }else{
                    if(englishF){
                        englishF=false
                        helpView.alpha=1.0
                        helpVieweng.alpha=0
                    }else{
                        englishF=true
                        helpView.alpha=0
                        helpVieweng.alpha=1.0
                    }
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            case .remoteControlTogglePlayPause:
                print("TogglePlayPause")
                if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                    print("doubleTap")
                    returnMain()
//                    doubleTap(0)
                    //                 self.dismiss(animated: true, completion: nil)
                }else{
                    if(englishF){
                        englishF=false
                        helpView.alpha=1.0
                        helpVieweng.alpha=0
                    }else{
                        englishF=true
                        helpView.alpha=0
                        helpVieweng.alpha=1.0
                    }
                    print("singletap")
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            default:
                print("Others")
            }
        }
    }
    
    @IBAction func goExit(_ sender: Any) {
        returnMain()
    }
    
    
    func moveImage(mov:CGFloat){
        helpView.frame.origin.y -= mov
    }
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        
//        if sender.state == .began {
//            posYlast=sender.location(in: self.view).y
//        } else if sender.state == .changed {
//            let posY = sender.location(in: self.view).y
//            let h=helpView.frame.origin.y - posYlast + posY
//            if h < 0 && h > helpHlimit{
//                helpView.frame.origin.y -= posYlast-posY
//                posYlast=posY
//            }
//        }else if sender.state == .ended{
//        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
 //       helpVieweng.alpha=0//はみ出ているので
//        let ww=view.bounds.width
//        let wh=view.bounds.height
//        let bw=ww/17
//        let bh=bw//*15/20
//        self.exitButton.frame = CGRect(x:ww-bw*4/3,y:wh-bh*4/3,width: bw,height: bh)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        let ww:CGFloat=view.bounds.width
            let wh:CGFloat=view.bounds.height
            let bw:CGFloat=ww*20/129
            let bh:CGFloat=bw*160/440
            let sp=ww/129
            let by=wh-bh-sp*2
        exitButton.frame.size.width = bw
            exitButton.frame.size.height = bh
            exitButton.frame.origin.x = bw*5+sp*7
            exitButton.frame.origin.y  = by
//        let w=view.bounds.width
//        let h=view.bounds.height
//        helpView.frame.origin.x=10
//        helpView.frame.origin.y=10
//        helpView.frame.size.width=w-20
//        helpView.frame.size.height=(w-2)*660/1320
//        helpHlimit=view.bounds.height-(w-20)*660/1320 - 20
        if UIApplication.shared.isIdleTimerDisabled == true{
            UIApplication.shared.isIdleTimerDisabled = false//監視する
        }
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
