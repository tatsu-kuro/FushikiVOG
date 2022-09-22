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
    var targetMode:Int = 0
    var helpImageName:String = ""
    var tapInterval=CFAbsoluteTimeGetCurrent()
    @IBOutlet weak var helpView: UIImageView!
//    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
//    @IBAction func onNextButton(_ sender: Any) {
//        helpNumber += 1
//        if helpNumber>1{
//            helpNumber=0
//        }
//        setHelpImageName()
//        setHelpImage()
//    }
    @IBAction func doubleTap(_ sender: Any) {//singleTapに変更したが、名前はそのまま
        if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
            print("doubleTapPlay")
            returnMain()
//        }else{
//            onNextButton(0)
        }
        tapInterval=CFAbsoluteTimeGetCurrent()
    }

    func returnMain(){
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        mainView.targetMode=targetMode
        performSegue(withIdentifier: "fromHelp", sender: self)
    }
    
    func setHelpImage(){
        let left=CGFloat(UserDefaults.standard.float(forKey: "left"))
        let right=CGFloat(UserDefaults.standard.float(forKey: "right"))

        helpView.image = UIImage(named:helpImageName)!
        let image:UIImage = UIImage(named:helpImageName)!
        // 画像の縦横サイズを取得
        let imgWidth:CGFloat = image.size.width
        let imgHeight:CGFloat = image.size.height
        // 画像サイズをスクリーン幅に合わせる
        let scale:CGFloat = imgHeight / imgWidth
        helpView.frame=CGRect(x:left,y:0,width:view.bounds.width-left-right,height: view.bounds.width*scale)
        helpHlimit=(view.bounds.width-left-right)*scale-view.bounds.height+50
    }
    
    func setHelpImageName(){//helpimagenameをセット
        let caloricFlag=UserDefaults.standard.bool(forKey: "caloricEttOknFlag")
        if Locale.preferredLanguages.first!.contains("ja"){
            print("japan")
            helpImageName="etthelp"
            if caloricFlag{
                helpImageName="etthelp2"
            }
//            if helpNumber == 0{
//                helpImageName="etthelp0"
//            }else if helpNumber == 1{
//                if caloricFlag{
//                    helpImageName="etthelp2"
//                }else{
//                    helpImageName="etthelp1"
//                }
//            }else if helpNumber == 2{
//                helpImageName="etthelpeng0"
//            }else{
//                if caloricFlag{
//                    helpImageName="etthelpeng2"
//                }else{
//                    helpImageName="etthelpeng1"
//                }
//            }
        }else{
            print("english")
            helpImageName="etthelpeng"
            if caloricFlag{
                helpImageName="etthelpeng2"
            }
//            if helpNumber == 0{
//                helpImageName="etthelpeng0"
//            }else if helpNumber == 1{
//                if caloricFlag{
//                    helpImageName="etthelpeng2"
//                }else{
//                    helpImageName="etthelpeng1"
//                }
//            }else if helpNumber == 2{
//                helpImageName="etthelp0"
//            }else{
//                if caloricFlag{
//                    helpImageName="etthelp2"
//                }else{
//                    helpImageName="etthelp1"
//                }
//            }
        }
        print("helpImageName:",helpNumber,helpImageName)
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
//                }else{
//                    onNextButton(0)
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            case .remoteControlTogglePlayPause:
                print("TogglePlayPause")
                if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                    print("doubleTap")
                    returnMain()
//                }else{
//                    onNextButton(0)
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            default:
                print("Others")
            }
        }
    }
 
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        let move:CGPoint = sender.translation(in: self.view)
        let height=helpView.frame.size.height
        let exitY=exitButton.frame.minY
        if sender.state == .began {
            posYlast=helpView.frame.origin.y
        }else if sender.state == .changed {
            helpView.frame.origin.y = posYlast + move.y
            if helpView.frame.origin.y > 0{
                helpView.frame.origin.y=0
            }else if helpView.frame.origin.y < -height+exitY{
                helpView.frame.origin.y = -height+exitY//view.bounds.height-exitY
            }
        }else if sender.state == .ended{
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
        
//        camera.setButtonProperty(nextButton,x:left+2*sp,y:by,w:bw,h:bh,UIColor.darkGray)
        helpView.frame=CGRect(x:left+2*sp,y:2*sp,width: ww-4*sp,height: wh-bh-3*sp)
        if UIApplication.shared.isIdleTimerDisabled == true{
            UIApplication.shared.isIdleTimerDisabled = false//監視する
        }
        helpNumber=0
        setHelpImageName()
        setHelpImage()
    }
}
/*
class HelpjViewController: UIViewController{
    var calcMode:Int?
    var jap_eng:Int=0
    @IBOutlet weak var helpView: UIImageView!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var langButton: UIButton!
    var currentImageName:String!
    func setHelpImage(){
        if jap_eng==1{
            if calcMode != 2{
                currentImageName="vHITen"
            }else{
                currentImageName="VOGen"
            }
        }else{
            if calcMode != 2{
                currentImageName="vHITja"
            }else{
                currentImageName="VOGja"
            }
        }
        helpView.image = UIImage(named:currentImageName)!
        let image:UIImage = UIImage(named:currentImageName)!
        // 画像の縦横サイズを取得
        let imgWidth:CGFloat = image.size.width
        let imgHeight:CGFloat = image.size.height
        // 画像サイズをスクリーン幅に合わせる
        let scale:CGFloat = imgHeight / imgWidth
        helpView.frame=CGRect(x:0,y:20,width:view.bounds.width,height: view.bounds.width*scale)
        helpHlimit=view.bounds.width*scale-view.bounds.height+50
    }
    @IBAction func langChan(_ sender: Any) {
        if jap_eng==0{
            jap_eng=1
        }else{
            jap_eng=0
        }
        setHelpImage()
        UserDefaults.standard.set(0,forKey:"currentHelpY")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        if Locale.preferredLanguages.first!.contains("ja"){
            jap_eng=1//langChan()で表示するので０でなくて１
        }else{
            jap_eng=0
        }
        langChan(0)//contains setHelpImage()
        UserDefaults.standard.set(0,forKey:"currentHelpY")
    }
    
    func getUserDefaultFloat(str:String,ret:Float) -> Float{
        if (UserDefaults.standard.object(forKey: str) != nil){
            return UserDefaults.standard.float(forKey: str)
        }else{//keyが設定してなければretをセット
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }

    var helpHlimit:CGFloat=0
    var posYlast:CGFloat=0
    @IBAction func panGestuer(_ sender: UIPanGestureRecognizer) {
        if sender.state == .began {
            posYlast=sender.location(in: self.view).y
        }else if sender.state == .changed {
            let posY = sender.location(in: self.view).y
            let h=helpView.frame.origin.y - posYlast + posY
            if h < 20 && h > -helpHlimit{
                helpView.frame.origin.y -= posYlast-posY
                posYlast=posY
            }
        }else if sender.state == .ended{
        }
    }
    func setButtons(){
        let sp:CGFloat=5
        let butw=(view.bounds.width-sp*7)/4
        let buth=butw/2
        let buty=view.bounds.height-sp-buth-bottomPadding
 
        langButton.frame=CGRect(x:2*sp,y:buty,width:butw,height: buth)
        exitButton.frame=CGRect(x:butw*3+5*sp,y:buty,width:butw,height: buth)
        langButton.layer.cornerRadius = 5
        exitButton.layer.cornerRadius = 5
    }
    var bottomPadding:CGFloat=0
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
             bottomPadding = self.view.safeAreaInsets.bottom
        }
        setButtons()
    }
}
*/
