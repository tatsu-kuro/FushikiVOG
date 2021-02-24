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
import Photos

class MainViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    let camera = CameraAlbumEtc()//name:"Fushiki")
    var controllerF:Bool=false
    @IBOutlet weak var titleImage: UIImageView!
    
    @IBOutlet weak var logoImage: UIImageView!

    var videoArrayCount:Int = 0
    var oknSpeed:Int = 50
    var oknTime:Int = 50
    var oknMode:Int=0
    var okpSpeed:Int=50
    var okpTime:Int=50
    var okpMode:Int=0
    var ettMode:Int = 0
    var ettWidth:Int=500
    var targetMode:Int = 6
    @IBOutlet weak var tableView: UITableView!
    
    var soundPlayer: AVAudioPlayer? = nil
    
    func sound(snd:String){
        if let soundharu = NSDataAsset(name: snd) {
            soundPlayer = try? AVAudioPlayer(data: soundharu.data)
            soundPlayer?.play() // → これで音が鳴る
        }
    }
    func doModes_sub(mode:Int){
        if targetMode == mode {
            sound(snd: "silence")
            doModes()
        }else{
            targetMode = mode
            setAlpha()
        }
    }
    
    @IBAction func doMode0(_ sender: Any) {
        doModes_sub(mode: 0)
    }
    
    @IBAction func doMode1(_ sender: Any) {
        doModes_sub(mode: 1)
    }
    
    @IBAction func doMode2(_ sender: Any) {
        doModes_sub(mode: 2)
    }
    
    @IBAction func doMode3(_ sender: Any) {
        doModes_sub(mode: 3)
    }
    
    @IBAction func doMode4(_ sender: Any) {
        doModes_sub(mode: 4)
    }
    
    @IBAction func doHelp(_ sender: Any) {
        doModes_sub(mode: 5)
    }
    
    @IBAction func doSettei(_ sender: Any) {
        doModes_sub(mode: 6)
    }
    func doModes(){
        let storyboard: UIStoryboard = self.storyboard!
        if targetMode<5{//録画の時tableviewをトップに戻す
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        UserDefaults.standard.set(targetMode, forKey:"targetMode")
        if targetMode==0{//pursuit
            let nextView = storyboard.instantiateViewController(withIdentifier: "ETT") as! ETTViewController
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }else if targetMode==1{//saccade
            let nextView = storyboard.instantiateViewController(withIdentifier: "OKP") as! OKPViewController
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }else if targetMode==2{//okn
            let nextView = storyboard.instantiateViewController(withIdentifier: "OKN") as! OKNViewController
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }else if targetMode==3{//carolicETT
            let nextView = storyboard.instantiateViewController(withIdentifier: "CarolicETT") as! CarolicETTViewController
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }else if targetMode==4{//carolicOKN
            let nextView = storyboard.instantiateViewController(withIdentifier: "CarolicOKN") as! CarolicOKNViewController
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }else if targetMode==5{//help
            let nextView = storyboard.instantiateViewController(withIdentifier: "HELP") as! HelpViewController
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }else if targetMode==6{//settei
            let nextView = storyboard.instantiateViewController(withIdentifier: "SETTEI") as! SetteiViewController
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }
    }
    func setAlpha(){
        setRotate(alp: 0.6)
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
 
        setRotate(alp: 0.6)
        if targetMode==0{
            button0.alpha=1.0
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
        print("didappear")
        camera.getAlbumAssets()
        for i in 0..<camera.videoURL.count{//cloud のURL->nilを入れる
            camera.videoURL[i] = camera.getURLfromPHAsset(asset: camera.videoAlbumAssets[i])
        }
        for i in (0..<camera.videoURL.count).reversed(){//cloud(nil) のものは削除する
            if camera.videoURL[i] == nil{
                camera.videoURL.remove(at: i)
                camera.videoDate.remove(at: i)
                camera.videoAlbumAssets.remove(at: i)
            }
        }
        videoArrayCount=camera.videoURL.count
        print(videoArrayCount,camera.videoURL.count,camera.videoDate.count)
        tableView.reloadData()
        setToppage()
    }
    
    func setToppage()
    {
        if camera.videoURL.count==0{
            tableView.isHidden=true
        }else{
            tableView.isHidden=false
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        okpSpeed = camera.getUserDefaultInt(str: "okpSpeed", ret:100)
        okpTime = camera.getUserDefaultInt(str: "okpTime", ret: 5)
        okpMode = camera.getUserDefaultInt(str: "okpMode", ret: 0)
        oknSpeed = camera.getUserDefaultInt(str: "oknSpeed", ret: 100)
        oknTime = camera.getUserDefaultInt(str: "oknTime", ret: 60)
        oknMode = camera.getUserDefaultInt(str: "oknMode", ret: 0)
        ettMode = camera.getUserDefaultInt(str: "ettMode", ret: 0)
        ettWidth = camera.getUserDefaultInt(str: "ettWidth", ret: 90)
        targetMode = camera.getUserDefaultInt(str: "targetMode", ret: 6)
        print("viewDidLoad")
        setRotate(alp:1)
        sound(snd:"silence")
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
    }
  
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
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
    
    @IBOutlet weak var doModeButton: UIButton!
    @IBAction func onDoModeButton(_ sender: Any) {
        sound(snd: "silence")
        doModes()
    }
    
    @IBOutlet weak var cameraButton2: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    //    @IBOutlet weak var titleImage: UIImageView!
    func setRotate(alp:CGFloat){

        let ww:CGFloat=view.bounds.width
        let wh:CGFloat=view.bounds.height
        let sp=ww/120//間隙
        let bw=(ww-sp*10)/7//ボタン幅
        let bh=bw*170/440
        let by=wh-bh-sp
        
        tableView.frame=CGRect(x:0,y:0,width:ww,height: by)
        button0.alpha=alp
        button1.alpha=alp
        button2.alpha=alp
        button3.alpha=alp
        button4.alpha=alp
        helpButton.alpha=alp
        setteiButton.alpha=alp
        camera.setButtonProperty(doModeButton, x: 0, y: 0, w: bw, h: bw, UIColor.white)
        camera.setButtonProperty(button0,x:sp*2,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(button1,x:bw*1+sp*3,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(button2,x:bw*2+sp*4,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(button3,x:bw*3+sp*5,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(button4,x:bw*4+sp*6,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(helpButton,x:bw*5+sp*7,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(setteiButton,x:bw*6+sp*8,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(cameraButton, x: bw*6+sp*8, y: by-bh-sp, w: bw, h: bh, UIColor.orange)
        //seにおいてカメラボタンが反応しにくいので　tableViewの上にあるためか？
        cameraButton2.frame=CGRect(x:ww-bw,y:by-bh,width:bw,height:bh+sp*2)

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
        logoImage.frame = CGRect(x: 0, y: 0, width:view.bounds.width, height:view.bounds.height/10)
//        if UIApplication.shared.isIdleTimerDisabled == true{
//            UIApplication.shared.isIdleTimerDisabled = false//監視する
//        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //nuber of cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return camera.videoURL.count
    }
    //set data on cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier:"cell",for :indexPath)
        let number = (indexPath.row+1).description + ") "
        cell.textLabel!.text = number + camera.videoDate[indexPath.row]
        return cell
    }
    //play item
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "PLAY") as! PlayViewController
        nextView.videoURL = camera.videoURL[indexPath.row]
        nextView.calcDate = camera.videoDate[indexPath.row]
        self.present(nextView, animated: true, completion: nil)
        
    }
    func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        print("set canMoveRowAt")
        return false
    }//not sort
    
    //セルの削除ボタンが押された時の処理
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        //削除するだけなのでindexPath_row = indexPath.rowをする必要はない。
        if editingStyle == UITableViewCell.EditingStyle.delete {
            camera.eraseVideo(number: indexPath.row)
            while camera.dialogStatus==0{
                sleep(UInt32(0.1))
            }
            if camera.dialogStatus==1{
                camera.videoURL.remove(at: indexPath.row)
                camera.videoDate.remove(at: indexPath.row)
                tableView.reloadData()
                if indexPath.row>4 && indexPath.row<camera.videoURL.count{
                    tableView.reloadRows(at: [indexPath], with: .fade)
                }else if indexPath.row == camera.videoURL.count{
                    let indexPath1 = IndexPath(row:indexPath.row-1,section:0)
                    tableView.reloadRows(at: [indexPath1], with: .fade)
                }
            }
        }
    }
    @IBAction func unwindAction(segue: UIStoryboardSegue) {
//        UIApplication.shared.isIdleTimerDisabled = false//スリープする
        print("unwindAction")
//        if let vc = segue.source as? PlayViewController {
//            if vc.timer != nil{
//                vc.timer?.invalidate()
//            }
//            print("index:",vc.currentIndex)
//        }
     }
}

