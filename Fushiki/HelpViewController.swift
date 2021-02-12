//
//  HelpViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2019/06/30.
//  Copyright © 2019 tatsuaki.Fushiki. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    var helpNumber:Int=0
    var helpHlimit:CGFloat=0
    var posYlast:CGFloat=0
//    var ettWidth:Int = 0//1:narrow,2:wide
//    var oknSpeed:Int = 0
//    var oknDirection:Int = 0
    var targetMode:Int = 0
    var tapInterval=CFAbsoluteTimeGetCurrent()
    @IBOutlet weak var helpView: UIImageView!
    
    @IBOutlet weak var nextButton: UIButton!
    
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
        helpNumber += 1
        if helpNumber>3{
            helpNumber=0
        }
        if(helpNumber==0){
            helpView.image=UIImage(named:"fushiki_j")
        }else if helpNumber==1{
            helpView.image=UIImage(named:"etthelp")
        }else if helpNumber==2{
            helpView.image=UIImage(named:"fushiki_e")
        }else{
            helpView.image=UIImage(named:"etthelpeng")
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

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
     }
    override func viewDidLoad() {
        super.viewDidLoad()
        let camera = CameraAlbumEtc(name:"Fushiki")
        let ww:CGFloat=view.bounds.width
        let wh:CGFloat=view.bounds.height
       
        let bw=ww*0.9/7//fit to mainView buttons
        let bh=bw*170/440
        let sp=ww*0.1/10
        let by=wh-bh-sp
//        exitButton.frame=CGRect(x:bw*6+sp*8,y:by,width:bw,height:bh)
        camera.setButtonProperty(exitButton,x:bw*6+sp*8,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(nextButton,x:sp,y:wh-bh-sp,w:bh,h:bh,UIColor.darkGray)
//        nextButton.frame=CGRect(x:sp,y:wh-bh-sp,width:bh,height: bh)
        if UIApplication.shared.isIdleTimerDisabled == true{
            UIApplication.shared.isIdleTimerDisabled = false//監視する
        }
        helpView.image=UIImage(named:"fushiki_j")
    }
}
