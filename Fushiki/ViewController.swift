//
//  ViewController.swift
//  Fushiki
//
//  Created by Fushiki tatsuaki on 2018/07/06.
//  Copyright © 2018年 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

//import GameController
class ViewController: UIViewController {
    var controllerF:Bool=false
    var timer: Timer!
    var backModeETTp:Int = 0
    var backModeETTs:Int = 0
    var backModeStill:Int = 0
    var ballSizeStill:Int = 2
    var ballColorStill:Int = 1
    var cirDiameter:CGFloat = 0
    var bandWidth:CGFloat = 0
//    var timer1Interval:Int = 2
    var ettWidth:Int = 0
    var oknSpeed:Int = 2
    var targetMode:Int = -1
    var oknDirection:Int = 0
    var soundPlayer: AVAudioPlayer? = nil
    
    func sound(snd:String){
        if let soundharu = NSDataAsset(name: snd) {
            soundPlayer = try? AVAudioPlayer(data: soundharu.data)
            soundPlayer?.play() // → これで音が鳴る
        }
    }
    
    @IBAction func doMode0(_ sender: Any) {
        targetMode=0
        sound(snd:"silence")
        doModes()
    }
    
    @IBAction func doMode1(_ sender: Any) {
        targetMode=1
        sound(snd:"silence")
        doModes()
    }
    
    @IBAction func doMode2(_ sender: Any) {
        targetMode=2
        sound(snd:"silence")
        doModes()
    }
    
    @IBAction func doMode3(_ sender: Any) {
        targetMode=3
        sound(snd:"silence")
        doModes()
    }
    
    @IBAction func doMode4(_ sender: Any) {
        targetMode=4
        sound(snd:"silence")
        doModes()
    }
    
    @IBAction func doHelp(_ sender: Any) {
        targetMode=5
        sound(snd:"silence")
        doModes()
    }
    func doModes(){
        let storyboard: UIStoryboard = self.storyboard!
        if targetMode==0{//pursuit
            let nextView = storyboard.instantiateViewController(withIdentifier: "ETTc") as! ETTcViewController
            nextView.ettWidth=ettWidth
            nextView.oknSpeed = oknSpeed
            nextView.oknDirection = oknDirection
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }else if targetMode==1{//saccade
            let nextView = storyboard.instantiateViewController(withIdentifier: "Saccade") as! SaccadeViewController
            nextView.ettWidth=ettWidth
            nextView.oknSpeed = oknSpeed
            nextView.oknDirection = oknDirection
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }else if targetMode==2{//okn
            let nextView = storyboard.instantiateViewController(withIdentifier: "OKNrotate") as! OKNrotateViewController
            nextView.ettWidth=ettWidth
            nextView.oknSpeed = oknSpeed
            nextView.oknDirection = oknDirection
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }else if targetMode==3{//carolicETT
            let nextView = storyboard.instantiateViewController(withIdentifier: "ETTs") as! ETTsViewController
//            nextView.timer1Interval=timer1Interval
            nextView.ettWidth=ettWidth
            nextView.oknSpeed = oknSpeed
            nextView.oknDirection = oknDirection
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }else if targetMode==4{//carolicOKN
            let nextView = storyboard.instantiateViewController(withIdentifier: "CarolicOKN") as! CarolicOKNViewController
            nextView.ettWidth=ettWidth
            nextView.oknSpeed = oknSpeed
            nextView.oknDirection = oknDirection
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }else if targetMode==5{//help
            let nextView = storyboard.instantiateViewController(withIdentifier: "helpView") as! HelpViewController
            nextView.ettWidth=ettWidth
            nextView.oknSpeed = oknSpeed
            nextView.oknDirection = oknDirection
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }
    }
    override func remoteControlReceived(with event: UIEvent?) {
        guard event?.type == .remoteControl else { return }
        
        if let event = event {
            controllerF=true
            switch event.subtype {
            case .remoteControlPlay:
                print("Play")
                doModes()
            case .remoteControlTogglePlayPause:
               print("TogglePlayPause")
               doModes()
            case .remoteControlNextTrack:
                setRotate(alp: 0.6)
                if(targetMode == -1){
                    targetMode=2
                }else{
                    targetMode += 1
                }
                if targetMode>5 {
                    targetMode = 0
                }
                if targetMode==0{
                    leftButton.alpha=1.0// saccadebut.alph=1.0
                }else if targetMode==1{
                    midButton.alpha=1.0
                }else if targetMode==2{
                    rightButton.alpha=1.0
                }else if targetMode==3{
                    mode3Button.alpha=1.0
                }else if targetMode==4{
                    mode4Button.alpha=1.0
                }else{
                    helpButton.alpha=1.0
                }
                print("NextTrack")
                print(targetMode)
            case .remoteControlPreviousTrack:
                setRotate(alp: 0.6)
                if(targetMode == -1){
                    targetMode = 2
                }else{
                    targetMode -= 1
                }
                if targetMode<0{
                    targetMode = 5
                }
                if targetMode==0{
                    leftButton.alpha=1.0// saccadebut.alph=1.0
                }else if targetMode==1{
                    midButton.alpha=1.0
                }else if targetMode==2{
                    rightButton.alpha=1.0
                }else if targetMode==3{
                    mode3Button.alpha=1.0
                }else if targetMode==4{
                    mode4Button.alpha=1.0
                }else{
                    helpButton.alpha=1.0
                }
                print(targetMode)
                print("PreviousTrack")
            default:
                print("Others")
            }
        }
    }
 /*   func getUserDefault(str:String,ret:Int) -> Int{//getUserDefault_one
        if (UserDefaults.standard.object(forKey: str) != nil){//keyが設定してなければretをセット
            return UserDefaults.standard.integer(forKey:str)
        }else{
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }*/
    override func viewDidAppear(_ animated: Bool) {
        if UIApplication.shared.isIdleTimerDisabled == true{
            UIApplication.shared.isIdleTimerDisabled = false//監視する
        }
        //print("didappeariii")
        if(controllerF){
            setRotate(alp: 0.6)
        }
    }
//    @objc func viewWillEnterForeground(_ notification: Notification?) {
//        print("viewWillEnterForground")
//        sound(snd:"silence")
//    }
    override func viewDidLoad() {
        super.viewDidLoad()
//        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.viewWillEnterForeground(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        bandWidth = self.view.bounds.width/10
        cirDiameter = self.view.bounds.width/26
        setRotate(alp:1)
        
        sound(snd:"silence")
//        setupGameController()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
 
           
//      override var representedObject: Any? {
//          didSet {
          // Update the view, if already loaded.
//          }
 //     }
 //   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        print("prepare")
//        sound(snd:"silence")
//    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
  
        setRotate(alp:1)
        coordinator.animate(
            alongsideTransition: nil,
            completion: {(UIViewControllerTransitionCoordinatorContext) in
                self.setRotate(alp:1)
        }
        )
    }
    
//    @IBAction func unwind(_ segue: UIStoryboardSegue) {
//
//        print("unwind")
//        if timer?.isValid == true {
//            timer.invalidate()
//        }
//        setRotate(alp:1)
//    }
    
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var mode3Button: UIButton!
    @IBOutlet weak var mode4Button: UIButton!
    @IBOutlet weak var midButton: UIButton!
    @IBOutlet weak var leftButton: UIButton!
    @IBOutlet weak var rightButton: UIButton!
    @IBOutlet weak var titleImage: UIImageView!
    func setRotate(alp:CGFloat){
 //       print("setrotate")
        let ww:CGFloat=view.bounds.width
        let wh:CGFloat=view.bounds.height
        let bw:CGFloat=ww*20/129
        let bh:CGFloat=bw*160/440
        let sp=ww/129
        let by=wh-bh-sp*2
 
        leftButton.alpha=alp
        midButton.alpha=alp
        rightButton.alpha=alp
        mode3Button.alpha=alp
        mode4Button.alpha=alp
        helpButton.alpha=alp

        leftButton.frame.size.width = bw
        leftButton.frame.size.height = bh
        leftButton.frame.origin.x = sp*2
        leftButton.frame.origin.y = by
        midButton.frame.size.width = bw
        midButton.frame.size.height = bh
        midButton.frame.origin.x = bw*1+sp*3
        midButton.frame.origin.y = by
        rightButton.frame.size.width = bw
        rightButton.frame.size.height = bh
        rightButton.frame.origin.x = bw*2+sp*4
        rightButton.frame.origin.y = by
        mode3Button.frame.size.width=bw
        mode3Button.frame.size.height=bh
        mode3Button.frame.origin.x=bw*3+sp*5
        mode3Button.frame.origin.y=by
        mode4Button.frame.size.width=bw
        mode4Button.frame.size.height=bh
        mode4Button.frame.origin.x=bw*4+sp*6
        mode4Button.frame.origin.y=by

        helpButton.frame.size.width = bw
        helpButton.frame.size.height = bh
        helpButton.frame.origin.x = bw*5+sp*7
        helpButton.frame.origin.y  = by

        let logoY = ww/13
        if view.bounds.width/2 > by - logoY{

            titleImage.frame.origin.y = logoY
            //view.bounds.width*56/730
            titleImage.frame.size.width = (by - logoY)*2
            //view.bounds.height/2*1800/700
            titleImage.frame.size.height = by - logoY//view.bounds.height/2
            titleImage.frame.origin.x = (view.bounds.width - titleImage.frame.size.width)/2
        }else{
            titleImage.frame.origin.x = 0
            titleImage.frame.size.width = view.bounds.width
            titleImage.frame.origin.y = logoY + (by - logoY - view.bounds.width/2)/2
            titleImage.frame.size.height = view.bounds.width/2
        }
//        if UIApplication.shared.isIdleTimerDisabled == true{
//            UIApplication.shared.isIdleTimerDisabled = false//監視する
//        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

