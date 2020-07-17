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
//    var ettWidth:Int = 0//1:narrow,2:wide
//    var oknSpeed:Int = 0
//    var oknDirection:Int = 0
    var targetMode:Int = 0
    var tapInterval=CFAbsoluteTimeGetCurrent()
    @IBOutlet weak var helpView: UIImageView!
    
    @IBOutlet weak var helpVieweng: UIImageView!
    @IBOutlet weak var globeButton: UIButton!
    
    @IBOutlet weak var exitButton: UIButton!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func globeBut(_ sender: Any) {
        chanLang()
    }
    @IBAction func doubleTap(_ sender: Any) {//singleTapに変更したが、名前はそのまま
        if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
            print("doubleTapPlay")
            returnMain()
        }else{
            chanLang()
        }
        tapInterval=CFAbsoluteTimeGetCurrent()
    }
    func returnMain(){
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController

        mainView.targetMode=targetMode
        self.present(mainView, animated: false, completion: nil)
    }
    func chanLang(){
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
    override func remoteControlReceived(with event: UIEvent?) {
        guard event?.type == .remoteControl else { return }
        
        if let event = event {
            
            switch event.subtype {
            case .remoteControlPlay:
                print("Play")
                if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                    print("doubleTapPlay")
                    returnMain()
                }else{
                    chanLang()
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            case .remoteControlTogglePlayPause:
                print("TogglePlayPause")
                if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                    print("doubleTap")
                    returnMain()
                }else{
                    chanLang()
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
//    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
//        
////        if sender.state == .began {
////            posYlast=sender.location(in: self.view).y
////        } else if sender.state == .changed {
////            let posY = sender.location(in: self.view).y
////            let h=helpView.frame.origin.y - posYlast + posY
////            if h < 0 && h > helpHlimit{
////                helpView.frame.origin.y -= posYlast-posY
////                posYlast=posY
////            }
////        }else if sender.state == .ended{
////        }
//    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     }
    override func viewDidLoad() {
        super.viewDidLoad()
        let ww:CGFloat=view.bounds.width
        let wh:CGFloat=view.bounds.height
       
        var bw=ww*0.9/7
        var bh=bw*170/440
        var sp=ww*0.1/10
        var by=wh-bh-sp
        exitButton.frame=CGRect(x:bw*6+sp*8,y:by,width:bw,height:bh)
        globeButton.frame=CGRect(x:ww-bw/2.5-sp*2,y:sp,width:bw/2.5,height: bw/2.5)
        if UIApplication.shared.isIdleTimerDisabled == true{
            UIApplication.shared.isIdleTimerDisabled = false//監視する
        }
        self.setNeedsStatusBarAppearanceUpdate()
        prefersHomeIndicatorAutoHidden()
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}
