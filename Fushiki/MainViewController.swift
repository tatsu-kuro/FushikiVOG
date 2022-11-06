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
import CoreMotion

class MainViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {

    let camera = myFunctions()//name:"Fushiki")
    var controllerF:Bool=false
//    @IBOutlet weak var titleImage: UIImageView!
//    @IBOutlet weak var logoImage: UIImageView!
    var caloricEttOknFlag = false//falseでは、caloricEtt,Okn buttonがカメラオンオフボタンとなる。
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
    var speakerOnOff:Int = 0
    var cameraType:Int = 0
    var ledValue:Float = 0
    var ettModeText0:String = ""
    var ettModeText1:String = ""
    var ettModeText2:String = ""
    var ettModeText3:String = ""
    var cameraON:Bool!

    //motion sensor*************************

    let motionManager = CMMotionManager()
    var isStarted = false
    var tapLeft:Bool=false
    var accelx = Array<Int>()
    var accely = Array<Int>()
    var accelz = Array<Int>()
    func checkNotMove(cnt:Int)->Bool{
        var sum:Int=0
        for i in 15...25{
            sum += abs(accelx[cnt+i])
            sum += abs(accely[cnt+i])
            sum += abs(accelz[cnt+i])
        }
        print("sum:",sum)
        if sum < 2{//動かなすぎ
            return false
        }else if sum > 60{//動き過ぎ
            return false
        }
        return true
    }

    func checkTap(cnt:Int)->Bool{
        let a0=accely[cnt]
        let a1=accely[cnt+1]
        let a2=accely[cnt+2]
        let a3=accely[cnt+3]
        let a6=accely[cnt+6]
        if a0+a1<6 && a2+a3>14 && a6 < 8{
            tapLeft=true
            return true
        }else if a0+a1<6 && a2+a3 < -14 && a6 > -8{
            tapLeft=false
            return true
        }
        return false
    }

    
    func checkTaps(_ n1:Int,_ n2:Int)->Bool{
        for i in n1...n2{
            if checkTap(cnt: i){
                return true
            }
        }
        return false
    }
    
    func stopMotion() {
        isStarted = false
        motionManager.stopDeviceMotionUpdates()
    }
 
    private func updateMotionData(deviceMotion:CMDeviceMotion) {
        let ay=deviceMotion.userAcceleration.y
        let ax=deviceMotion.userAcceleration.x// rotationRate.x
        let az=deviceMotion.userAcceleration.z// rotationRate.z
        accely.append(Int(ay*100))
        accelx.append(Int(ax*100))
        accelz.append(Int(az*100))
 
        if accelx.count>200{
            accely.remove(at: 0)
            accelz.remove(at: 0)
            accelx.remove(at: 0)

            if checkTap(cnt: 140) && checkTaps(170,190) && checkNotMove(cnt: 140){
                stopMotion()
                onStartHideButton(0)
//                if tapLeft{
//                    onAutoRecordButton(0)
//                }else{
//                    onPositioningRecordButton(0)
//                }
            }
        }
    }
    
    func startMotion(){
        accelx.removeAll()
        accely.removeAll()
        accelz.removeAll()
        // start monitoring sensor data
        if motionManager.isDeviceMotionAvailable {
            motionManager.deviceMotionUpdateInterval = 0.01
            motionManager.startDeviceMotionUpdates(to: OperationQueue.current!, withHandler: {(motion:CMDeviceMotion?, error:Error?) in
                self.updateMotionData(deviceMotion: motion!)
            })
        }
        isStarted = true
    }
//motion sensor
    
    @IBAction func onStartHideButton(_ sender: Any) {
        let text=startHideButton.title(for: .normal)
        if text == "ETT"
        {
            targetMode=0
        }else if text == "OKP"{
            targetMode=1
        }else if text == "OKN"{
            targetMode=2
        }
        doModes_sub(mode: targetMode)
    }
    
    @IBOutlet weak var startHideButton: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    var soundPlayer: AVAudioPlayer? = nil
    var topPadding:CGFloat = 0
    var bottomPadding:CGFloat = 0
    var leftPadding:CGFloat = 0
    var rightPadding:CGFloat = 0
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if #available(iOS 11.0, *) {
            // viewDidLayoutSubviewsではSafeAreaの取得ができている
            topPadding = self.view.safeAreaInsets.top
            bottomPadding = self.view.safeAreaInsets.bottom
            leftPadding = self.view.safeAreaInsets.left
            rightPadding = self.view.safeAreaInsets.right
            print("in viewDidLayoutSubviews")
            UserDefaults.standard.set(topPadding, forKey: "top")
            UserDefaults.standard.set(bottomPadding, forKey: "bottom")
            UserDefaults.standard.set(leftPadding, forKey: "left")
            UserDefaults.standard.set(rightPadding, forKey: "right")
            print(topPadding,bottomPadding,leftPadding,rightPadding)    // iPhoneXなら44, その他は20.0
        }
        setButtons()
    }
    
    func sound(snd:String){
        if let soundharu = NSDataAsset(name: snd) {
            soundPlayer = try? AVAudioPlayer(data: soundharu.data)
            soundPlayer?.play() // → これで音が鳴る
        }
    }
    func doModes_sub(mode:Int){
        targetMode = mode
        setButtonsAlpha()
        sound(snd: "silence")
        doModes()
    }
 
    @IBAction func onEttButton(_ sender: Any) {
        startHideButton.setTitle("ETT", for: .normal)
        doModes_sub(mode: 0)
    }

    @IBAction func onOkpButton(_ sender: Any) {
        startHideButton.setTitle("OKP", for: .normal)
        doModes_sub(mode: 1)
    }

    @IBAction func onOknButton(_ sender: Any) {
        startHideButton.setTitle("OKN", for: .normal)
        doModes_sub(mode: 2)
    }

    @IBAction func onCaloricEttButton(_ sender: Any) {
        doModes_sub(mode: 3)
    }

    @IBAction func onCaloricOknButton(_ sender: Any) {
        doModes_sub(mode: 4)
    }
    
    @IBAction func onHelpButton(_ sender: Any) {
        doModes_sub(mode: 5)
    }
    
    @IBAction func onSetteiButton(_ sender: Any) {
        doModes_sub(mode: 6)
    }
    func doModes(){
        stopMotion()
        let storyboard: UIStoryboard = self.storyboard!
        if targetMode>=0 && targetMode<=4{
            let mainBrightness=UIScreen.main.brightness//明るさを保持
            UserDefaults.standard.set(mainBrightness, forKey: "mainBrightness")
            print("mainBrightness saved****")
        }
        if targetMode<3 && tableView.visibleCells.count>5{//録画の時tableviewをトップに戻す
            
            tableView.scrollToRow(at: IndexPath(row: 0, section: 0), at: .top, animated: true)
        }
        UserDefaults.standard.set(targetMode, forKey:"targetMode")
        if targetMode==0{//ETT
            let nextView = storyboard.instantiateViewController(withIdentifier: "ETT") as! ETTViewController
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }else if targetMode==1{//OKP
            let nextView = storyboard.instantiateViewController(withIdentifier: "OKP") as! OKPViewController
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }else if targetMode==2{//okn
            let nextView = storyboard.instantiateViewController(withIdentifier: "OKN") as! OKNViewController
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
        }else if targetMode==3{//carolicETT
            if camera.getUserDefaultBool(str: "caloricEttOknFlag", ret: false){
                let nextView = storyboard.instantiateViewController(withIdentifier: "CarolicETT") as! CarolicETTViewController
                nextView.targetMode = targetMode
                self.present(nextView, animated: true, completion: nil)
            }else{
                startMotion()
                if camera.getUserDefaultBool(str: "cameraON", ret: true){
                    return
                }else{
                    UserDefaults.standard.set(true, forKey: "cameraON")
                    setButtonsAlpha()
                    setCameraOnOffbuttons()
                }
                return                
            }
        }else if targetMode==4{//carolicOKN
            if camera.getUserDefaultBool(str: "caloricEttOknFlag", ret: false){
            let nextView = storyboard.instantiateViewController(withIdentifier: "CarolicOKN") as! CarolicOKNViewController
            nextView.targetMode = targetMode
            self.present(nextView, animated: true, completion: nil)
            }else{
                startMotion()
                if !camera.getUserDefaultBool(str: "cameraON", ret: true){
                    return
                }else{
                    UserDefaults.standard.set(false, forKey: "cameraON")
                    setButtonsAlpha()
                    setCameraOnOffbuttons()
                }
                return
            }
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
    
    func setButtonsAlpha(){
        ettButton.alpha=0.6
        okpButton.alpha=0.6
        oknButton.alpha=0.6
        caloricEttButton.alpha=0.6
        caloricOknButton.alpha=0.6
        helpButton.alpha=0.6
        setteiButton.alpha=0.6
        if targetMode==0{
            ettButton.alpha=1.0
        }else if targetMode==1{
            okpButton.alpha=1.0
        }else if targetMode==2{
            oknButton.alpha=1.0
        }else if targetMode==3{
            caloricEttButton.alpha=1.0
        }else if targetMode==4{
            caloricOknButton.alpha=1.0
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
                setButtons()
                if(targetMode == -1){
                    targetMode=2
                }else{
                    targetMode += 1
                }
                if targetMode>6 {
                    targetMode = 0
                }
                setButtonsAlpha()
                print("NextTrack")
                print(targetMode)
            case .remoteControlPreviousTrack:
                setButtons()
                if(targetMode == -1){
                    targetMode = 2
                }else{
                    targetMode -= 1
                }
                if targetMode<0{
                    targetMode = 6
                }
                setButtonsAlpha()
                print("PreviousTrack")
            default:
                print("Others")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserDefaultAll()
        print("MainViewDidLoad*****")
        startMotion()
//        sound(snd:"silence")//リモコンの操作権を貰う
//        let mainBrightness=UIScreen.main.brightness//明るさを保持
//        UserDefaults.standard.set(mainBrightness, forKey: "mainBrightness")
        if PHPhotoLibrary.authorizationStatus() != .authorized {
            PHPhotoLibrary.requestAuthorization { status in
                if status == .authorized {
//                    self.checkLibraryAuthrizedFlag=1
                    print("authorized")
                } else if status == .denied {
//                    self.checkLibraryAuthrizedFlag = -1
                    print("denied")
                }else{
//                    self.checkLibraryAuthrizedFlag = -1
                }
            }
        }else{
            camera.getAlbumAssets()//完了したら戻ってくるようにしたつもり
        }
        UIApplication.shared.isIdleTimerDisabled = false//スリープする。監視する
        UIApplication.shared.beginReceivingRemoteControlEvents()
        self.becomeFirstResponder()
        fromUnwindFlag=false
        UIApplication.shared.isIdleTimerDisabled = false//スリープする
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(foreground(notification:)),
                                               name: UIApplication.willEnterForegroundNotification,
                                               object: nil
        )
    }
    @objc func foreground(notification: Notification) {
        print("フォアグラウンド")
        startMotion()
    }
    override func viewDidAppear(_ animated: Bool) {
        if UIApplication.shared.isIdleTimerDisabled == true{
            UIApplication.shared.isIdleTimerDisabled = false//監視する
        }
        sound(snd:"silence")//リモコンの操作権を貰う
        setButtons()
        setButtonsAlpha()
        print("MainViewDidAppear*****")
        if fromUnwindFlag==true{
            if camera.videoDate.count<5{
                camera.getAlbumAssets()
            }else{
                camera.getAlbumAssets_last()
            }
        }
        fromUnwindFlag=false
        print(camera.videoPHAsset.count,camera.videoDate.count)
        let contentOffsetY = CGFloat(camera.getUserDefaultFloat(str:"contentOffsetY",ret:0))
        DispatchQueue.main.async { [self] in
            self.tableView.contentOffset.y=contentOffsetY
            self.tableView.reloadData()
        }
    }
 
    func setTopPage()
    {
        if camera.videoDate.count==0{
            tableView.isHidden=true
        }else{
            tableView.isHidden=false
        }
    }
    func getUserDefaultAll(){
        okpSpeed = camera.getUserDefaultInt(str: "okpSpeed", ret:100)
        okpTime = camera.getUserDefaultInt(str: "okpTime", ret: 5)
        okpMode = camera.getUserDefaultInt(str: "okpMode", ret: 0)
        oknSpeed = camera.getUserDefaultInt(str: "oknSpeed", ret: 100)
        oknTime = camera.getUserDefaultInt(str: "oknTime", ret: 60)
        oknMode = camera.getUserDefaultInt(str: "oknMode", ret: 0)
        ettMode = camera.getUserDefaultInt(str: "ettMode", ret: 0)
        ettWidth = camera.getUserDefaultInt(str: "ettWidth", ret: 90)
        targetMode = camera.getUserDefaultInt(str: "targetMode", ret: 6)
        speakerOnOff = camera.getUserDefaultInt(str: "speakerOnOff", ret: 0)
        cameraType = camera.getUserDefaultInt(str: "cameraType", ret: 0)
        ledValue = camera.getUserDefaultFloat(str: "ledValue", ret: 0)
        caloricEttOknFlag = camera.getUserDefaultBool(str: "caloricEttOknFlag", ret:false)
        cameraON = camera.getUserDefaultBool(str: "cameraON", ret: true)
        /*     ettModeText0 = "3,0:1:2,1:2:10,3:2:10,0:1:2,2:2:10,4:2:10,6:2:12"
         ettModeText1 = "3,0:1:2,1:2:10,0:6:3,3:2:10,0:1:2,2:2:10,0:6:3,4:2:10,0:1:2,6:2:12"
*/
        ettModeText0 = camera.getUserDefaultString(str: "ettModeText0", ret: "3,0:1:2,1:2:10,3:2:10,0:1:2,2:2:10,4:2:10,6:2:12")
        if camera.checkEttString(ettStr: ettModeText0)==false{//パラメータ並びをチェック
            UserDefaults.standard.set("3,0:1:2,1:2:10,3:2:10,0:1:2,2:2:10,4:2:10,6:2:12",forKey:"ettModeText0")
        }
        ettModeText1 = camera.getUserDefaultString(str: "ettModeText1", ret:
                                                    "3,0:1:2,1:2:10,0:6:3,3:2:10,0:1:2,2:2:10,0:6:3,4:2:10,0:1:2,6:2:12")
        if camera.checkEttString(ettStr: ettModeText1)==false{
            UserDefaults.standard.set("3,0:1:2,1:2:10,0:6:3,3:2:10,0:1:2,2:2:10,0:6:3,4:2:10,0:1:2,6:2:12",forKey:"ettModeText1")
        }
        ettModeText2 = camera.getUserDefaultString(str: "ettModeText2", ret: "3,0:1:2,1:2:12,3:2:12")
        if camera.checkEttString(ettStr: ettModeText2)==false{
            UserDefaults.standard.set("3,0:1:2,1:2:12,3:2:12",forKey:"ettModeText2")
        }
        ettModeText3 = camera.getUserDefaultString(str: "ettModeText3", ret: "1,0:6:3,6:2:10")
        if camera.checkEttString(ettStr: ettModeText3)==false{
            UserDefaults.standard.set("1,0:6:3,6:2:10",forKey:"ettModeText3")
        }
        _=camera.getUserDefaultInt(str:"posRatio",ret:80)
        _=camera.getUserDefaultInt(str:"veloRatio",ret:60)
        _=camera.getUserDefaultInt(str:"wakuLength",ret:6)
        _=camera.getUserDefaultInt(str:"eyeBorder",ret:20)
        _=camera.getUserDefaultInt(str:"faceMark",ret:0)
        _=camera.getUserDefaultInt(str:"showRect",ret:0)
     }
    var checkLibraryAuthrizedFlag:Int=0
    func checkLibraryAuthorized(){
        //iOS14に対応
        checkLibraryAuthrizedFlag=0//0：ここの処理が終わっていないとき　1：許可　−１：拒否
        if #available(iOS 14.0, *) {
            PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
                switch status {
                case .limited:
                    self.checkLibraryAuthrizedFlag=1
                    print("limited")
                    break
                case .authorized:
                    self.checkLibraryAuthrizedFlag=1
                    print("authorized")
                    break
                case .denied:
                    self.checkLibraryAuthrizedFlag = -1
                    print("denied")
                    break
                default:
                    self.checkLibraryAuthrizedFlag = -1
                    break
                }
            }
        }
        else  {
            if PHPhotoLibrary.authorizationStatus() != .authorized {
                PHPhotoLibrary.requestAuthorization { status in
                    if status == .authorized {
                        self.checkLibraryAuthrizedFlag=1
                        print("authorized")
                    } else if status == .denied {
                        self.checkLibraryAuthrizedFlag = -1
                        print("denied")
                    }
                }
            } else {
                self.checkLibraryAuthrizedFlag=1
            }
        }
    }
  
    override var prefersStatusBarHidden: Bool {
        return true
    }
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        setButtons()
        coordinator.animate(
            alongsideTransition: nil,
            completion: {(UIViewControllerTransitionCoordinatorContext) in
                self.setButtons()
        }
        )
    }
    @IBOutlet weak var setteiButton: UIButton!
    @IBOutlet weak var helpButton: UIButton!
    @IBOutlet weak var caloricEttButton: UIButton!
    @IBOutlet weak var caloricOknButton: UIButton!
    @IBOutlet weak var okpButton: UIButton!
    @IBOutlet weak var ettButton: UIButton!
    @IBOutlet weak var oknButton: UIButton!

    func setButtons(){
        let ww:CGFloat=view.bounds.width-leftPadding-rightPadding
        let wh:CGFloat=view.bounds.height-topPadding-bottomPadding
        let sp=ww/120//間隙
        let bw=(ww-sp*10)/7//ボタン幅
        let bh=bw*170/440
        let by=wh-bh-sp
        let hideButtonY=topPadding+(wh-bh-bw)/2
        tableView.frame=CGRect(x:leftPadding,y:0,width:ww,height: by)
 
        camera.setButtonProperty(ettButton,x:sp*2+leftPadding,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(okpButton,x:bw*1+sp*3+leftPadding,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(oknButton,x:bw*2+sp*4+leftPadding,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(caloricEttButton,x:bw*3+sp*5+leftPadding,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(caloricOknButton,x:bw*4+sp*6+leftPadding,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(helpButton,x:bw*5+sp*7+leftPadding,y:by,w:bw,h:bh,UIColor.darkGray)
        camera.setButtonProperty(setteiButton,x:bw*6+sp*8+leftPadding,y:by,w:bw,h:bh,UIColor.darkGray)
//        camera.setButtonProperty(startHideButton, x: bw*5+sp*7+leftPadding, y: by/10, w: bw, h: by*4/5, UIColor.darkGray)
        camera.setButtonProperty(startHideButton, x: bw*6+sp*8+leftPadding, y: hideButtonY, w: bw, h: bw, UIColor.darkGray)
//        if ww/2 > by{
//            titleImage.frame.origin.y = sp+topPadding
//            titleImage.frame.size.width = by*2
//            titleImage.frame.size.height = by
//            titleImage.frame.origin.x = (ww - titleImage.frame.size.width)/2+leftPadding
//        }else{
//            titleImage.frame.origin.x = leftPadding
//            titleImage.frame.size.width = ww
//            titleImage.frame.origin.y = (by - ww/2)/2
//            titleImage.frame.size.height = ww/2
//        }
//        logoImage.frame = CGRect(x: leftPadding, y: topPadding, width:ww, height:wh/10)
//        logoImage.isHidden=true
        setCameraOnOffbuttons()
    }
    func setCameraOnOffbuttons(){
        caloricEttOknFlag=camera.getUserDefaultBool(str: "caloricEttOknFlag", ret: false)
        cameraON=camera.getUserDefaultBool(str: "cameraON", ret: true)
        if caloricEttOknFlag==false{
            if cameraON{
                caloricEttButton.setTitle("Camera ON", for: .normal)
                caloricOknButton.setTitle("Camera off", for: .normal)
            }else{
                caloricEttButton.setTitle("Camera on", for: .normal)
                caloricOknButton.setTitle("Camera OFF", for: .normal)
            }
        }else{
            caloricEttButton.setTitle("CaloricETT", for: .normal)
            caloricOknButton.setTitle("CaloricOKN", for: .normal)
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //            // 画面非表示直後の処理を書く
        //            print("画面非表示直後")
        //        UserDefaults.standard.set(0,forKey: "contentOffsetY")
        //
        let contentOffsetY = tableView.contentOffset.y
        print("offset:",contentOffsetY)
        UserDefaults.standard.set(contentOffsetY,forKey: "contentOffsetY")
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    //nuber of cell
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return camera.videoDate.count
    }
    //set data on cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath:IndexPath) -> UITableViewCell{
        let cell:UITableViewCell = tableView.dequeueReusableCell(withIdentifier:"cell",for :indexPath)
        let number = (indexPath.row+1).description + ") "
        let phasset = camera.videoPHAsset[indexPath.row]
        cell.textLabel!.text = number + camera.videoDate[indexPath.row] + " (" + phasset.pixelWidth.description + "x" + phasset.pixelHeight.description + ")"
        return cell
    }

    //play item
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard: UIStoryboard = self.storyboard!
        let nextView = storyboard.instantiateViewController(withIdentifier: "PLAY") as! PlayViewController
        nextView.calcDate = camera.videoDate[indexPath.row]
        let phasset = camera.videoPHAsset[indexPath.row]
        let avasset = camera.requestAVAsset(asset: phasset)
        if avasset != nil{//not neccesary
            let contentOffsetY = tableView.contentOffset.y
            print("offset:",contentOffsetY)
            UserDefaults.standard.set(contentOffsetY,forKey: "contentOffsetY")
            nextView.phasset = phasset
            nextView.avasset = avasset
            self.present(nextView, animated: true, completion: nil)
        }
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
                camera.videoPHAsset.remove(at: indexPath.row)
                camera.videoDate.remove(at: indexPath.row)
                
                tableView.reloadData()
                if indexPath.row>4 && indexPath.row<camera.videoDate.count{
                    tableView.reloadRows(at: [indexPath], with: .fade)
                }else if indexPath.row == camera.videoDate.count && indexPath.row != 0{
                    let indexPath1 = IndexPath(row:indexPath.row-1,section:0)
                    tableView.reloadRows(at: [indexPath1], with: .fade)
                }
            }
        }
    }
   
    var fromUnwindFlag:Bool=false//ここではgetAlbumAssetsできないので
    //didappearでチェックしてgetAlbumAssetsする
    @IBAction func unwindAction(segue: UIStoryboardSegue) {
        if segue.source is SetteiViewController || segue.source is HelpViewController || segue.source is PlayViewController || segue.source is ImagePickerController || segue.source is PlayParaViewController{
            print("main-unwind:HelpView or SetteiView")
        }else{
            print("Main-unwind:getAlbumAssets",camera.videoDate.count)
            fromUnwindFlag=true
            UserDefaults.standard.set(0,forKey: "contentOffsetY")
            DispatchQueue.main.async { [self] in
                self.tableView.contentOffset.y=0
            }
            UIScreen.main.brightness = CGFloat(UserDefaults.standard.float(forKey: "mainBrightness"))
            print("mainScreenBrightness-unwind restored****8r")
        }
        UIApplication.shared.isIdleTimerDisabled = false//スリープする.監視する
        camera.setLedLevel(0)
        startMotion()
    }
}

