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
    /*
     @IBAction func doubleTap(_ sender: Any) {
         let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
         mainView.targetMode=targetMode
         delTimer()
         performSegue(withIdentifier: "fromETT", sender: self)
     }
     */
    
    
    func returnMain(){
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        mainView.targetMode=targetMode
//        self.present(mainView, animated: false, completion: nil)
        performSegue(withIdentifier: "fromHelp", sender: self)
    }
    func chanLang(){
        helpNumber += 1
        if helpNumber>3{
            helpNumber=0
        }
        if(helpNumber==0){
            helpView.image=UIImage(named:"etthelp0")
        }else if helpNumber==1{
            helpView.image=UIImage(named:"etthelp1")
        }else if helpNumber==2{
            helpView.image=UIImage(named:"etthelpeng0")
        }else{
            helpView.image=UIImage(named:"etthelpeng1")
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
        let camera = myFunctions()//name:"Fushiki")
        
        let top=CGFloat(UserDefaults.standard.float(forKey: "top"))
        let bottom=CGFloat(UserDefaults.standard.float(forKey: "bottom"))
        let left=CGFloat(UserDefaults.standard.float(forKey: "left"))
        let right=CGFloat(UserDefaults.standard.float(forKey: "right"))
    
        let ww=view.bounds.width-(left+right)
        let wh=view.bounds.height-(top+bottom)
        let sp=ww/120//間隙
        let bw=(ww-sp*10)/7//ボタン幅
        let bh=bw*170/440
        let by=wh-bh-sp
        camera.setButtonProperty(exitButton,x:left+bw*6+sp*8,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(nextButton,x:left+2*sp,y:by,w:bw,h:bh,UIColor.darkGray)
        helpView.frame=CGRect(x:left+2*sp,y:2*sp,width: ww-4*sp,height: wh-bh-3*sp)
        if UIApplication.shared.isIdleTimerDisabled == true{
            UIApplication.shared.isIdleTimerDisabled = false//監視する
        }
        helpView.image=UIImage(named:"etthelp0")
    }
}
