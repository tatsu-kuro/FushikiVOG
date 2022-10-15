//
//  HelpViewController.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2019/06/30.
//  Copyright © 2019 tatsuaki.Fushiki. All rights reserved.
//

import UIKit

class HelpViewController: UIViewController {
    var targetMode:Int = 0
    var helpImageName:String = ""
    
    @IBOutlet weak var scrollView: UIScrollView!
    var tapInterval=CFAbsoluteTimeGetCurrent()
    @IBOutlet weak var exitButton: UIButton!
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
 
    @IBAction func doubleTap(_ sender: Any) {//singleTapに変更したが、名前はそのまま
        if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
            print("doubleTapPlay")
            returnMain()
        }
        tapInterval=CFAbsoluteTimeGetCurrent()
    }

    func returnMain(){
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        mainView.targetMode=targetMode
        performSegue(withIdentifier: "fromHelp", sender: self)
    }
 
    func setHelpImageName(){//helpimagenameをセット
        let caloricFlag=UserDefaults.standard.bool(forKey: "caloricEttOknFlag")
        if Locale.preferredLanguages.first!.contains("ja"){
            print("japan")
            helpImageName="etthelp"
            if caloricFlag{
                helpImageName="etthelp2"
            }
        }else{
            print("english")
            helpImageName="etthelpeng"
            if caloricFlag{
                helpImageName="etthelpeng2"
            }
        }
//        print("helpImageName:",helpNumber,helpImageName)
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
                }
                tapInterval=CFAbsoluteTimeGetCurrent()
            case .remoteControlTogglePlayPause:
                print("TogglePlayPause")
                if (CFAbsoluteTimeGetCurrent()-tapInterval)<0.3{
                    print("doubleTap")
                    returnMain()
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
        scrollView.frame = CGRect(x:left,y:top,width: ww,height: wh)

        if UIApplication.shared.isIdleTimerDisabled == true{
            UIApplication.shared.isIdleTimerDisabled = false//監視する
        }
        setHelpImageName()

        let img = UIImage(named:helpImageName)!
        // 画像のサイズ
        let imgW = img.size.width
        let imgH = img.size.height
        let image = img.resize(size: CGSize(width:ww, height:ww*imgH/imgW))
        // UIImageView 初期化
        let imageView = UIImageView(image: image)//jellyfish)
        // UIScrollViewに追加
        scrollView.addSubview(imageView)
        // UIScrollViewの大きさを画像サイズに設定
        scrollView.contentSize = CGSize(width: ww, height: ww*imgH/imgW)
        // スクロールの跳ね返り無し
        scrollView.bounces = true
    }
}

