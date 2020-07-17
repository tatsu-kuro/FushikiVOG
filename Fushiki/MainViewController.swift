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
class MainViewController: UIViewController {
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
    
    @IBAction func doSettei(_ sender: Any) {
        targetMode=6
        sound(snd:"silence")
        doModes()
    }
    func doModes(){
        let storyboard: UIStoryboard = self.storyboard!
        if targetMode==0{//pursuit
            let nextView = storyboard.instantiateViewController(withIdentifier: "ETT") as! ETTViewController
            nextView.ettWidth=ettWidth
            nextView.oknSpeed = oknSpeed
            nextView.oknDirection = oknDirection
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }else if targetMode==1{//saccade
            let nextView = storyboard.instantiateViewController(withIdentifier: "OKP") as! OKPViewController
//            nextView.ettWidth=ettWidth
//            nextView.oknSpeed = oknSpeed
//            nextView.oknDirection = oknDirection
//            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }else if targetMode==2{//okn
            let nextView = storyboard.instantiateViewController(withIdentifier: "OKN") as! OKNViewController
//            nextView.ettWidth=ettWidth
//            nextView.oknSpeed = oknSpeed
//            nextView.oknDirection = oknDirection
//            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }else if targetMode==3{//carolicETT
            let nextView = storyboard.instantiateViewController(withIdentifier: "CarolicETT") as! CarolicETTViewController
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
            let nextView = storyboard.instantiateViewController(withIdentifier: "HELP") as! HelpViewController
            nextView.ettWidth=ettWidth
            nextView.oknSpeed = oknSpeed
            nextView.oknDirection = oknDirection
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }else if targetMode==6{//settei
            let nextView = storyboard.instantiateViewController(withIdentifier: "SETTEI") as! SetteiViewController
//            nextView.ettWidth=ettWidth
//            nextView.oknSpeed = oknSpeed
//            nextView.oknDirection = oknDirection
//            nextView.targetMode = targetMode
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
                if targetMode>6 {
                    targetMode = 0
                }
                if targetMode==0{
                    button0.alpha=1.0// saccadebut.alph=1.0
                }else if targetMode==1{
                    button1.alpha=1.0
                }else if targetMode==2{
                    button2.alpha=1.0
                }else if targetMode==3{
                    button3.alpha=1.0
                }else if targetMode==4{
                    button4.alpha=1.0
                }else if targetMode==5{
                    helpButton.alpha=1.0
                }else{
                    setteiButton.alpha=1.0
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
                    targetMode = 6
                }
                if targetMode==0{
                    button0.alpha=1.0// saccadebut.alph=1.0
                }else if targetMode==1{
                    button1.alpha=1.0
                }else if targetMode==2{
                    button2.alpha=1.0
                }else if targetMode==3{
                    button3.alpha=1.0
                }else if targetMode==4{
                    button4.alpha=1.0
                }else if targetMode==5{
                    helpButton.alpha=1.0
                }else{
                    setteiButton.alpha=1.0
                }
                print(targetMode)
                print("PreviousTrack")
            default:
                print("Others")
            }
        }
    }

    override func viewDidAppear(_ animated: Bool) {
        if UIApplication.shared.isIdleTimerDisabled == true{
            UIApplication.shared.isIdleTimerDisabled = false//監視する
        }
        //print("didappeariii")
        if(controllerF){
            setRotate(alp: 0.6)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        bandWidth = self.view.bounds.width/10
        cirDiameter = self.view.bounds.width/26
        setRotate(alp:1)
        
        sound(snd:"silence")
//        setupGameController()
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        prefersHomeIndicatorAutoHidden()
    }
    
    override func prefersHomeIndicatorAutoHidden() -> Bool {
        return true
    }
    

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
    @IBOutlet weak var setteiButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var button3: UIButton!
    @IBOutlet weak var button4: UIButton!
    @IBOutlet weak var button1: UIButton!
    @IBOutlet weak var button0: UIButton!
    @IBOutlet weak var button2: UIButton!
    @IBOutlet weak var titleImage: UIImageView!
    func setRotate(alp:CGFloat){
 //       print("setrotate")
        let ww:CGFloat=view.bounds.width
        let wh:CGFloat=view.bounds.height
        let bw:CGFloat=ww*0.9/7
        let bh:CGFloat=bw*170/440
        let sp=ww*0.1/10
        let by=wh-bh-sp
 
        button0.alpha=alp
        button1.alpha=alp
        button2.alpha=alp
        button3.alpha=alp
        button4.alpha=alp
        helpButton.alpha=alp
        setteiButton.alpha=alp
        button0.frame=CGRect(x:sp*2,y:by,width:bw,height:bh)
        button1.frame=CGRect(x:bw*1+sp*3,y:by,width:bw,height:bh)
        button2.frame=CGRect(x:bw*2+sp*4,y:by,width:bw,height:bh)
        button3.frame=CGRect(x:bw*3+sp*5,y:by,width:bw,height:bh)
        button4.frame=CGRect(x:bw*4+sp*6,y:by,width:bw,height:bh)
        helpButton.frame=CGRect(x:bw*5+sp*7,y:by,width:bw,height:bh)
        setteiButton.frame=CGRect(x:bw*6+sp*8,y:by,width:bw,height:bh)

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

