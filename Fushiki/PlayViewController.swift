//
//  PlayViewController.swift
//  Fushiki
//
//  Created by 黒田建彰 on 2021/01/16.
//  Copyright © 2021 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
@available(iOS 11.0, *)
extension UIImage {
    func resize(size _size: CGSize) -> UIImage? {
        let widthRatio = _size.width / size.width
        let heightRatio = _size.height / size.height
        let ratio = widthRatio < heightRatio ? widthRatio : heightRatio
        
        let resizedSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        UIGraphicsBeginImageContextWithOptions(resizedSize, false, 0.0) // 変更
        draw(in: CGRect(origin: .zero, size: resizedSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return resizedImage
    }
}
class PlayViewController: UIViewController {
    var cameraMode:Int!
    let album = CameraAlbumEtc(name:"Fushiki")
    let openCV = OpenCVWrapper()
    var videoURL:URL?
    var videoSize:CGSize!
    var videoFps:Float!
    var startTime=CFAbsoluteTimeGetCurrent()
    var fpsXd:Int=2//240/videoFPS 1dataのピクセル数
    var videoPlayer: AVPlayer!
    var videoDuration:Float=0
    var screenSize:CGSize!
    var currFrameNumber:Int=0
    var faceMark:Bool=true
    lazy var seekBar = UISlider()
    var timer:Timer?
    var timer_vog:Timer?
    var vogImageView:UIImageView?
//    var vogImageViewFlag:Bool=false
//    var vogTextView:UIImageView?//vog
    var vogImage:UIImage?
    var vogBoxHeight:CGFloat=0
    var vogBoxYmin:CGFloat=0
//    var vogBoxView:UIImageView?//vog
    var vogCurPoint:Int=0
    var vogBoxYcenter:CGFloat=0
    var mailWidth:CGFloat=2400//VOG
    var mailHeight:CGFloat=1600//VOG
    var videoWidth:CGFloat!
    var videoHeight:CGFloat!
    var idNumber:Int = 0
    var savedFlag:Bool = false
    @IBOutlet weak var waveButton: UIButton!
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var calcButton: UIButton!
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var setteiButton: UIButton!
    @IBOutlet weak var debugEye: UIImageView!
    @IBOutlet weak var debugEyeb: UIImageView!
    @IBOutlet weak var debugFace: UIImageView!
    @IBOutlet weak var debugFaceb: UIImageView!
    
    @IBOutlet weak var eyeWaku_image: UIImageView!
    @IBOutlet weak var faceWaku_image: UIImageView!
    @IBOutlet weak var faceWakuL_image: UIImageView!
    @IBOutlet weak var eyeWakuL_image: UIImageView!
    
    @IBOutlet weak var currTimeLabel: UILabel!
    @IBOutlet weak var fpsLabel: UILabel!
    
    @IBAction func onMailButton(_ sender: Any) {
    }
    
    @IBOutlet weak var cameraButton: UISegmentedControl!
    
    @IBAction func onCameraButton(_ sender: Any) {
        cameraMode=cameraButton.selectedSegmentIndex
        UserDefaults.standard.set(cameraMode, forKey: "video_cameraMode")
//        print("cameraMode:",cameraMode)
        dispWakus()
        showWakuImages()
    }
    func Field2value(field:UITextField) -> Int {
        if field.text?.count != 0 {
            return Int(field.text!)!
        }else{
            return 0
        }
    }
    var path2albumDoneFlag:Bool=false//不必要かもしれないが念の為
    func savePath2album(path:String){
        path2albumDoneFlag=false
        savePath2album_sub(path: path)
        while path2albumDoneFlag == false{
            sleep(UInt32(0.2))
        }
    }
 
    func savePath2album_sub(path:String){
        
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            
            let fileURL = dir.appendingPathComponent( path )
            
            PHPhotoLibrary.shared().performChanges({ [self] in
                let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(atFileURL: fileURL)!
                let albumChangeRequest = PHAssetCollectionChangeRequest(for:  album.getPHAssetcollection())
                let placeHolder = assetRequest.placeholderForCreatedAsset
                albumChangeRequest?.addAssets([placeHolder!] as NSArray)
            }) { (isSuccess, error) in
                if isSuccess {
                    self.path2albumDoneFlag=true
                    // 保存成功
                } else {
                    self.path2albumDoneFlag=true
                    // 保存失敗
                }
            }
        }
    }

    func saveImage2path(image:UIImage,path:String) {//imageを保存
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let path_url = dir.appendingPathComponent( path )
            let pngImageData = image.pngData()
            do {
                try pngImageData!.write(to: path_url, options: .atomic)
//                saving2pathFlag=false
            } catch {
                print("gyroData.txt write err")//エラー処理
            }
        }
    }
    
    func existFile(aFile:String)->Bool{
        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            
            let path_url = dir.appendingPathComponent( aFile )
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: path_url.path){
                return true
            }else{
                return false
            }
            
        }
        return false
    }
    @IBAction func onSaveButton(_ sender: Any) {
        
        if calcFlag == true || vogImageView?.isHidden == true || vogImageView == nil{
            return
        }
        
        let alert = UIAlertController(title: "FushikiETT", message: "Input ID number", preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "OK", style: .default) { [self] (action:UIAlertAction!) -> Void in
            
            // 入力したテキストをコンソールに表示
            let textField = alert.textFields![0] as UITextField
            #if DEBUG
            print("\(String(describing: textField.text))")
            #endif
            self.idNumber = self.Field2value(field: textField)
            drawVogOnePage(count:vogCurPoint)//countまでの波を表示
            // イメージビューに設定する
//            UIImageWriteToSavedPhotosAlbum(img, nil, nil, nil)
            //まずtemp.pngに保存して、それをvHIT_VOGアルバムにコピーする
            saveImage2path(image: getVogOnePage(count: vogCurPoint), path: "temp.png")
            while existFile(aFile: "temp.png") == false{
                sleep(UInt32(0.1))
            }
            savePath2album(path: "temp.png")
         }
        let cancelAction = UIAlertAction(title: "Cancel", style: .default) { (action:UIAlertAction!) -> Void in
            self.idNumber = 1//キャンセルしてもここは通らない？
        }
        // UIAlertControllerにtextFieldを追加
        alert.addTextField { (textField:UITextField!) -> Void in
            textField.keyboardType = UIKeyboardType.numberPad
        }
        alert.addAction(cancelAction)//この行と下の行の並びを変えるとCancelとOKの左右が入れ替わる。
        alert.addAction(saveAction)
        present(alert, animated: true, completion: nil)
    }

    func getNamedImage(startingImage:UIImage) ->UIImage{
        // Create a context of the starting image size and set it as the current one
        UIGraphicsBeginImageContext(startingImage.size)
        // Draw the starting image in the current context as background
        startingImage.draw(at: CGPoint.zero)
        // Get the current context
        let context = UIGraphicsGetCurrentContext()!
        // Draw a red line
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.black.cgColor)
        // パスの初期化
        let drawPath = UIBezierPath()
        let w=startingImage.size.width
        let h=startingImage.size.height
        let str1 = calcDate.components(separatedBy: ":")
        let str2 = "ID:" + String(format: "%08d", idNumber) + "  " + str1[0] + ":" + str1[1]
        let str3 = "FushikiETT"
        
        str2.draw(at: CGPoint(x: 20, y: h-100), withAttributes: [
                    NSAttributedString.Key.foregroundColor : UIColor.black,
                    NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 70, weight: UIFont.Weight.regular)])
        str3.draw(at: CGPoint(x: w-360, y: h-100), withAttributes: [
                    NSAttributedString.Key.foregroundColor : UIColor.black,
                    NSAttributedString.Key.font : UIFont.monospacedDigitSystemFont(ofSize: 70, weight: UIFont.Weight.regular)])
        
        UIColor.black.setStroke()
        // イメージコンテキストからUIImageを作る
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // イメージ処理の終了
        UIGraphicsEndImageContext()
        return image!
    }
 
    @IBAction func onPlayButton(_ sender: Any) {
        if (videoPlayer.rate != 0) && (videoPlayer.error == nil) {//playing
            videoPlayer.pause()
            currFrameNumber=Int(seekBar.value*videoFps)
            videoPlayer.seek(to: CMTimeMakeWithSeconds(Float64(seekBar.value), preferredTimescale: Int32(NSEC_PER_SEC)))
            showWakuImages()
        }else{//stoped
            if seekBar.value>seekBar.maximumValue-0.5{
                seekBar.value=0
            }
            videoPlayer.seek(to: CMTimeMakeWithSeconds(Float64(seekBar.value), preferredTimescale: Int32(NSEC_PER_SEC)))
            videoPlayer.play()
            if vogImageView?.isHidden == false{
                vogImageView?.isHidden=true
            }
        }
    }
  
    @IBAction func onExitButton(_ sender: Any) {
        killTimer()
        let mainView = storyboard?.instantiateViewController(withIdentifier: "MAIN") as! MainViewController
        if UIApplication.shared.isIdleTimerDisabled == true{
            UIApplication.shared.isIdleTimerDisabled = false//スリープする
        }
        self.present(mainView, animated: false, completion: nil)
    }
    var eyeCenter = CGPoint(x:300.0,y:100.0)
    var faceCenter = CGPoint(x:300.0,y:200.0)
    var wakuLength:CGFloat=8//rectの縦横幅
    var eyeBorder:Int = 40
    var eyeLargeRect:CGRect!
    var faceLargeRect:CGRect!
    func getRectFromCenter(center:CGPoint,len:CGFloat)->CGRect{
        return(CGRect(x:center.x-len/2,y:center.y-len/2,width:len,height: len))
    }
    func getCenterInScreen(point:CGPoint)->CGPoint{//centerをscreen上に納める
        let screen=getVideoRectOnScreen()
        var retPoint=point
        if retPoint.x<screen.origin.x+wakuLength{
            retPoint.x=screen.origin.x+wakuLength
        }else if retPoint.x>screen.origin.x+screen.width-wakuLength{
            retPoint.x=screen.origin.x+screen.width-wakuLength
        }
        if retPoint.y<screen.origin.y+wakuLength{
            retPoint.y=screen.origin.y+wakuLength
        }else if retPoint.y>screen.origin.y+screen.height-wakuLength{
            retPoint.y=screen.origin.y+screen.height-wakuLength
        }
        return retPoint
    }
    func getVideoRectOnScreen()->CGRect{
        let sw=view.frame.width
        let sh=view.frame.height
        let vw=videoSize.width// CGFloat(videoImage.extent.width)
        let vh=videoSize.height//CGFloat(videoImage.extent.height)
        
        var d=(sw-vw*sh/vh)/2
//        print(sw,sh,vh,vw,d)
        if d>0{
            return CGRect(x:d,y:0,width:sw-2*d,height:sh)
        }else{//ここがうまく行っていないようだ
            d=(sh-sw*vh/vw)/2
            return CGRect(x:0,y:d,width:sw,height:sh-2*d)
        }
    }
    //targetRect=eyeRect,viewRect=view.frame
    func resizeR2(_ targetRect:CGRect, viewRect:CGRect, image:CIImage) -> CGRect {
        //view.frameとtargetRectとimageをもらうことでその場で縦横の比率を計算してtargetRectのimage上の位置を返す関数
        //view.frameとtargetRectは画面上の位置だが、返すのはimage上の位置なので、そこをうまく考慮する必要がある。
        //getRealrectの代わり
        
        let vw = viewRect.width
        let vh = viewRect.height
        
        let iw = CGFloat(image.extent.width)
        let ih = CGFloat(image.extent.height)
        
        //　viewRect.originを引く事でtargetRectがview.bounds起点となる
        let tx = CGFloat(targetRect.origin.x) - CGFloat(viewRect.origin.x)
        let ty = CGFloat(targetRect.origin.y) - CGFloat(viewRect.origin.y)
        
        let tw = CGFloat(targetRect.width)
        let th = CGFloat(targetRect.height)
        // ここで返されるCGRectはCIImage/CGImage上の座標なので全て整数である必要がある
        // 端数があるまま渡すとmatchingが誤動作した
        return CGRect(x: (tx * iw / vw).rounded(),
                      y: ((vh - ty - th) * ih / vh).rounded(),
                      width: (tw * iw / vw).rounded(),
                      height: (th * ih / vh).rounded())
    }
    var handlingDataNowFlag = false
    func addVogWave(startingImage:UIImage,startn:Int,end:Int) ->UIImage{
        // Create a context of the starting image size and set it as the current one
        var start=startn
        if startn<0{
            start=0
        }
        UIGraphicsBeginImageContext(startingImage.size)
        // Draw the starting image in the current context as background
        startingImage.draw(at: CGPoint.zero)
        // Get the current context
        let context = UIGraphicsGetCurrentContext()!
        // Draw a red line
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.black.cgColor)
        
        var pointX = Array<CGPoint>()
        var pointXd = Array<CGPoint>()
        var pointY = Array<CGPoint>()
        var pointYd = Array<CGPoint>()
        let posR=CGFloat(posRatio)/20.0
        let veloR=CGFloat(veloRatio)
        let h=startingImage.size.height
//        let vogPos_count=eyePosXfiltered.count//eyePosOrig.count
//        var dx = Int((240/videoFps).rounded())// 1// xの間隔
//        print("dx:",dx)
//        dx = 1
        handlingDataNowFlag=true
        for i in start..<end {
//            if i < vogPos_count{
                let px = CGFloat(fpsXd * i)
                let py1 = eyePosXfiltered[i] * posR + (h-240)/5
                let py2 = eyeVelXfiltered[i] * veloR + (h-240)*2/5
                let py3 = eyePosYfiltered[i] * posR + (h-240)*3/5
                let py4 = eyeVelYfiltered[i] * veloR + (h-240)*4/5
                let point1 = CGPoint(x: px, y: py1)
                let point2 = CGPoint(x: px, y: py2)
                let point3 = CGPoint(x: px, y: py3)
                let point4 = CGPoint(x: px, y: py4)
                pointX.append(point1)
                pointXd.append(point2)
                pointY.append(point3)
                pointYd.append(point4)
//            }
        }
        handlingDataNowFlag=false
        // 始点に移動する
        context.move(to: pointX[0])
        // 配列から始点の値を取り除く
        pointX.removeFirst()
        // 配列から点を取り出して連結していく
        for pt in pointX {
            context.addLine(to: pt)
        }
        context.move(to: pointXd[0])
        pointXd.removeFirst()
        for pt in pointXd {
            context.addLine(to: pt)
        }
        context.move(to: pointY[0])
        pointY.removeFirst()
        for pt in pointY {
            context.addLine(to: pt)
        }
        context.move(to: pointYd[0])
        pointYd.removeFirst()
        for pt in pointYd {
            context.addLine(to: pt)
        }
        // 線の色
        context.strokePath()
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
   
    func getVogOnePage(count:Int)->UIImage{
        var cnt=count*fpsXd-240*10
        if cnt<0{
            cnt=0
        }
        let clipRect = CGRect(x:CGFloat(cnt) , y: 0, width: mailWidth, height: mailHeight)
        let cripImageRef = vogImage?.cgImage!.cropping(to: clipRect)
        let crippedImage = UIImage(cgImage: cripImageRef!)
        let crippedNamedImage = getNamedImage(startingImage: crippedImage)
        return crippedNamedImage
    }
    func drawVogOnePage(count:Int){//countまでの波を表示
        if vogImageView != nil{
            vogImageView?.removeFromSuperview()
        }
        var cnt=count*fpsXd - 2400
        if cnt<0{
            cnt=0
        }
        let clipRect = CGRect(x:CGFloat(cnt) , y: 0, width: mailWidth, height: mailHeight)
        let cripImageRef = vogImage?.cgImage!.cropping(to: clipRect)
        let crippedImage = UIImage(cgImage: cripImageRef!)
//        print("clipRect:",cnt,count,clipRect)
        let namedImage = getNamedImage(startingImage: crippedImage)
        let drawImage = namedImage.resize(size: CGSize(width:view.bounds.width, height:view.bounds.height*4/5))
//        let namedImage =
        vogImageView = UIImageView(image: drawImage)
        vogImageView?.center =  CGPoint(x:view.bounds.width/2,y:view.bounds.height/2)
        // 画面に表示する
        view.addSubview(vogImageView!)
    }
    
    func initVogImage(width w:CGFloat,height h:CGFloat) -> UIImage {
        let size = CGSize(width:w, height:h)
        // イメージ処理の開始
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        let context = UIGraphicsGetCurrentContext()
        // パスの初期化
        let drawRect = CGRect(x:0, y:0, width:w, height:h)
        let drawPath = UIBezierPath(rect:drawRect)

        context?.setFillColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        drawPath.fill()
        context?.setStrokeColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)
        drawPath.stroke()
        
        UIColor.black.setStroke()
        
        let wid:CGFloat=w/90.0
        for i in 0..<90 {
            let xp = CGFloat(i)*wid
            drawPath.move(to: CGPoint(x:xp,y:0))
            drawPath.addLine(to: CGPoint(x:xp,y:h-120))
        }
        drawPath.move(to:CGPoint(x:0,y:0))
        drawPath.addLine(to: CGPoint(x:w,y:0))
        drawPath.move(to:CGPoint(x:0,y:h-120))
        drawPath.addLine(to: CGPoint(x:w,y:h-120))
        //UIColor.blue.setStroke()
        drawPath.lineWidth = 2.0//1.0
        drawPath.stroke()
        // イメージコンテキストからUIImageを作る
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // イメージ処理の終了
        UIGraphicsEndImageContext()
        return image!
    }
    var timercnt:Int = 0
    var lastArraycount:Int = 0
    var elapsedTime:Double=0
    @objc func update_vog(tm: Timer) {
        timercnt += 1
        if timercnt == 1{//vogImageの背景の白、縦横線を作る
            vogImage = initVogImage(width:mailWidth*18,height:mailHeight)//枠だけ
//            vogImageViewFlag=true
            vogCurPoint=0
        }
//        static ela time = CFAbsoluteTimeGetCurrent() - startTime
        if calcFlag == true{
            elapsedTime=CFAbsoluteTimeGetCurrent()-startTime
        }
        currTimeLabel.text=String(format:"%.1f/%.1f (%.0f)",seekBar.value + Float(eyePosX.count)/videoFps,videoDuration,elapsedTime)
        if eyePosXfiltered.count < 5 {
            return
        }
        var calcFlagTemp=true
        if calcFlag == false {//終わったらここだが取り残しがある
            calcFlagTemp=false
        }
        let cntTemp=eyePosX.count
        vogImage=addVogWave(startingImage: vogImage!, startn: lastArraycount-1, end:cntTemp)
        lastArraycount=cntTemp
//        drawVogall_new()
        #if DEBUG
//        print("debug-update",timercnt,calcFlagTemp)
        #endif
        //            print("veloCount:",eyeVeloOrig.count)
        drawVogOnePage(count: cntTemp)
        //ここでcalcFlagをチェックするとデータを撮り損なうか
        if calcFlagTemp == false{//timer に入るときに終わっていた
            UIApplication.shared.isIdleTimerDisabled = false
            drawVogOnePage(count: 0)
            print("calcend")
            timer_vog!.invalidate()
            setButtons(flag: true)
        }
    }

    @IBAction func onWaveButton(_ sender: Any) {//saveresult record-unwind の２箇所
        if vogImageView == nil{
            return
        }
        if vogImageView!.isHidden == false{
            vogImageView?.isHidden=true
        }else{
            vogImageView?.isHidden=false
            view.bringSubviewToFront(vogImageView!)
        }
    }
  
    func resolutionSizeOfVideo(url:URL) -> CGSize? {
        guard let track = AVAsset(url: url).tracks(withMediaType: AVMediaType.video).first else { return nil }
        let size = track.naturalSize.applying(track.preferredTransform)
        return CGSize(width: abs(size.width), height: abs(size.height))
    }
    //iPhone11ではScreenSize=896*414 VideoImageSize=1920*1080
    func checkRect(rect:CGRect,image:CIImage)->CGRect{
        //範囲をチェックしたつもりだが、バグがありそう
        var returnRect=rect
        if rect.origin.x<0{
            returnRect.origin.x=0
        }
        if rect.origin.y<0{
            returnRect.origin.y=0
        }
        if rect.width+rect.origin.x>image.extent.width{
            returnRect.size.width=image.extent.width-rect.origin.x
        }
        if rect.height+rect.origin.y>image.extent.height{
            returnRect.size.height=image.extent.height-rect.origin.y
        }
        return returnRect
    }
    func showWakuImages(){//結果が表示されていない時、画面上部1/4をタップするとWaku表示
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let avAsset = AVURLAsset(url: videoURL!, options: options)
        var reader: AVAssetReader! = nil
        do {
            reader = try AVAssetReader(asset: avAsset)
        } catch {
            #if DEBUG
            print("could not initialize reader.")
            #endif
            return
        }
        guard let videoTrack = avAsset.tracks(withMediaType: AVMediaType.video).last else {
            #if DEBUG
            print("could not retrieve the video track.")
            #endif
            return
        }
        
        let readerOutputSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerOutputSettings)
        
        reader.add(readerOutput)
        let frameRate = videoTrack.nominalFrameRate
        let startTime = CMTime(value: CMTimeValue(currFrameNumber), timescale: CMTimeScale(frameRate))
        let timeRange = CMTimeRange(start: startTime, end:CMTime.positiveInfinity)
        reader.timeRange = timeRange //読み込む範囲を`timeRange`で指定
        reader.startReading()
        let CGeye:CGImage!//eye
        let UIeye:UIImage!
        var CGface:CGImage!//face
        var UIface:UIImage!
        let context:CIContext = CIContext.init(options: nil)
        //landscape right homeに固定すると、
        guard let sample = readerOutput.copyNextSampleBuffer() else{
            print("get sample error")
            return
        }
        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sample)!
        var ciImage:CIImage!
        if cameraMode == 0{//front Camera ここは画面表示とは関係なさそう
            ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.down)
        }else{
            ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.up)
        }
        //起動時表示が一巡？するまでは　slowImage.frame はちょっと違う値を示す
        
        let eyeRect=getRectFromCenter(center: eyeCenter, len: wakuLength)
        let eyeRectResized = resizeR2(eyeRect, viewRect:getVideoRectOnScreen(),image:ciImage)
        CGeye = context.createCGImage(ciImage, from: eyeRectResized)

        UIeye = UIImage.init(cgImage: CGeye, scale:1.0, orientation:.up)//orientation)

        eyeWakuL_image.frame=CGRect(x:view.bounds.width/2+10,y:5,width: eyeRectResized.size.width*4,height: eyeRectResized.size.height*4)
        eyeWakuL_image.layer.borderColor = UIColor.black.cgColor
        eyeWakuL_image.layer.borderWidth = 1.0
        eyeWakuL_image.backgroundColor = UIColor.clear
        eyeWakuL_image.layer.cornerRadius = 3
        eyeWakuL_image.image=UIeye
        view.bringSubviewToFront(eyeWakuL_image)
        let faceRect=getRectFromCenter(center: faceCenter, len: wakuLength)
        let faceRectResized = resizeR2(faceRect, viewRect:getVideoRectOnScreen(), image: ciImage)
        CGface = context.createCGImage(ciImage, from: faceRectResized)
        UIface = UIImage.init(cgImage: CGface, scale:1.0, orientation:.up)
        faceWakuL_image.frame=CGRect(x:view.bounds.width/2 - faceRectResized.size.width*4 - 10,y:5,width: faceRectResized.size.width*4,height: faceRectResized.size.height*4)
        faceWakuL_image.layer.borderColor = UIColor.black.cgColor
        faceWakuL_image.layer.borderWidth = 1.0
        faceWakuL_image.backgroundColor = UIColor.clear
        faceWakuL_image.layer.cornerRadius = 3
        faceWakuL_image.image=UIface
        view.bringSubviewToFront(faceWakuL_image)
        if faceMark == false{
            faceWakuL_image.isHidden=true
        }else{
            faceWakuL_image.isHidden=false
        }
    }
    
    func dispWakus(){
        let d=(wakuLength+20)/2//matchingArea(center,wakuLength)
        if faceMark == false{
            eyeORface=0
        }
        eyeWaku_image.frame=CGRect(x:eyeCenter.x-d,y:eyeCenter.y-d,width:2*d,height:2*d)
        faceWaku_image.frame=CGRect(x:faceCenter.x-d,y:faceCenter.y-d,width:2*d,height:2*d)
        eyeWaku_image.layer.borderColor = UIColor.green.cgColor
        eyeWaku_image.backgroundColor = UIColor.clear
        eyeWaku_image.layer.cornerRadius = 4
        faceWaku_image.layer.borderColor = UIColor.green.cgColor
        faceWaku_image.backgroundColor = UIColor.clear
        faceWaku_image.layer.cornerRadius = 4
        if eyeORface == 0{
            eyeWaku_image.layer.borderWidth = 2
            faceWaku_image.layer.borderWidth = 1
        }else{
            eyeWaku_image.layer.borderWidth = 1
            faceWaku_image.layer.borderWidth = 2
        }
        view.bringSubviewToFront(faceWaku_image)
        view.bringSubviewToFront(eyeWaku_image)
        if faceMark == false{
            faceWaku_image.isHidden=true
        }else{
            faceWaku_image.isHidden=false
        }
    }
    
    func moveCenter(start:CGPoint,move:CGPoint,hani:CGRect)-> CGPoint{
        var returnPoint:CGPoint=CGPoint(x:0,y:0)//2種類の枠を代入、変更してreturnで返す
        returnPoint.x = start.x + move.x
        returnPoint.y = start.y + move.y
        if returnPoint.x < hani.origin.x{
            returnPoint.x = hani.origin.x
        }else if returnPoint.x > hani.origin.x+hani.width{
            returnPoint.x = hani.origin.x+hani.width
        }
        if returnPoint.y < hani.origin.y{
            returnPoint.y = hani.origin.y
        }else if returnPoint.y > hani.origin.y+hani.height{
            returnPoint.y = hani.origin.y+hani.height
        }
        return returnPoint
    }
    var eyeORface:Int = 0//0:eye 1:face 2:outer -1:何も選択されていない
    var startEyeCenter:CGPoint!//tapした時のCenter
    var startFaceCenter:CGPoint!
    var lastmoveX:Int = 0
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        if calcFlag == true{
            return
        }
        let move:CGPoint = sender.translation(in: self.view)
        let pos = sender.location(in: self.view)
        if sender.state == .began {
            startEyeCenter=eyeCenter
            startFaceCenter=faceCenter
        } else if sender.state == .changed {
            
            if vogImageView?.isHidden == false{//vog波形表示中
//                if vogImageViewFlag == true{//vog波形表示中
                if fpsXd*eyePosX.count<240*10{//240*10以下なら動けない。
                    return
                }
                let ratio=pos.y/view.bounds.height
                let dd = Int(15*ratio)
                if Int(move.x) > lastmoveX + dd{
                    vogCurPoint -= dd*10
                    lastmoveX = Int(move.x)
                }else if Int(move.x) < lastmoveX - dd{
                    vogCurPoint += dd*10
                    lastmoveX = Int(move.x)
                }
                if vogCurPoint>eyePosX.count{
                    vogCurPoint=eyePosX.count
                }else if fpsXd*vogCurPoint<2400{
                    vogCurPoint=2400/fpsXd
                }
//                print("vogcur",vogCurPoint)
                drawVogOnePage(count: vogCurPoint)
            }else{//枠
                let ww=view.bounds.width
                let wh=view.bounds.height
                
                let et=CGRect(x:ww/10,y:wh/20,width: ww*4/5,height:wh*3/4)
                if eyeORface == 0{
                    eyeCenter=moveCenter(start:startEyeCenter,move:move,hani:et)
                }else{
                    faceCenter=moveCenter(start:startFaceCenter,move:move,hani:et)
                }
                eyeCenter=getCenterInScreen(point:eyeCenter)
                faceCenter=getCenterInScreen(point:faceCenter)
                dispWakus()
                showWakuImages()
            }
        }else if sender.state == .ended{
        }
    }
   
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        print("tap",vogImageView?.isHidden,calcFlag)
 
        if vogImageView?.isHidden == false{
            return
        }
        if eyeORface == 0{//eye
            eyeORface=1
        }else{
            eyeORface=0
        }
        dispWakus()
        showWakuImages()
    }
    
    @objc func update(tm: Timer) {
        if timer_vog?.isValid == true{
            currTimeLabel.text=String(format:"%.1f/%.1f (%.0f)",seekBar.value + Float(eyePosX.count)/videoFps,videoDuration,elapsedTime)
        }else{
            currTimeLabel.text=String(format:"%.1f/%.1f (%.0f)",seekBar.value + Float(eyePosX.count)/videoFps,videoDuration,elapsedTime)
        }
        if !((videoPlayer.rate != 0) && (videoPlayer.error == nil)) {//notplaying
            if seekBar.value>videoDuration-0.01{
                seekBar.value=0
                videoPlayer.seek(to: CMTimeMakeWithSeconds(Float64(seekBar.value), preferredTimescale: Int32(NSEC_PER_SEC)))
//                showWakuImages()
            }
        }
    }
    
    func killTimer(){
        if timer?.isValid == true {
            timer!.invalidate()
        }
    }
    func getFPS(url:URL) -> Float{
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let avAsset = AVURLAsset(url: url, options: options)
        return avAsset.tracks.first!.nominalFrameRate
    }
    
    func getUserDefaults(){
        if ( UIDevice.current.model.range(of: "iPad") != nil){//ipad
            wakuLength = CGFloat(album.getUserDefaultInt(str: "wakuLength", ret: 6))
            eyeBorder = album.getUserDefaultInt(str: "eyeBorder", ret: 20)
        }else{//iphone
            wakuLength = CGFloat(album.getUserDefaultInt(str: "wakuLength", ret: 3))
            eyeBorder = album.getUserDefaultInt(str: "eyeBorder", ret: 9)
        }
        cameraMode = album.getUserDefaultInt(str: "video_cameraMode", ret: 0)
        posRatio = album.getUserDefaultInt(str: "posRatio", ret:100)
        veloRatio = album.getUserDefaultInt(str:"veloRatio",ret :100)
        eyeCenter.x = CGFloat(album.getUserDefaultInt(str: "eyeCenterX", ret: 320))
        eyeCenter.y = CGFloat(album.getUserDefaultInt(str: "eyeCenterY", ret: 100))
        faceCenter.x = CGFloat(album.getUserDefaultInt(str: "faceCenterX", ret: 300))
        faceCenter.y = CGFloat(album.getUserDefaultInt(str: "faceCenterY", ret: 100))
        faceMark = album.getUserDefaultBool(str: "faceMark", ret:false)
    }
    func setUserDefaults(){
        UserDefaults.standard.set(eyeCenter.x, forKey: "eyeCenterX")
        UserDefaults.standard.set(eyeCenter.y, forKey: "eyeCenterY")
        UserDefaults.standard.set(faceCenter.x, forKey: "faceCenterX")
        UserDefaults.standard.set(faceCenter.y, forKey: "faceCenterY")
     }
    override func viewDidLoad() {
        super.viewDidLoad()
        getUserDefaults()
        cameraButton.selectedSegmentIndex = cameraMode
        //setteiしてなければ、以下
    
        let avAsset = AVURLAsset(url: videoURL!)
        let ww:CGFloat=view.bounds.width
        let wh:CGFloat=view.bounds.height
        let sp=ww/120//間隙
        let bw=(ww-sp*10)/7//ボタン幅
        let bh=bw*170/440
        let by = wh - bh - sp
        let seeky = by - bh
        
        videoDuration=Float(CMTimeGetSeconds(avAsset.duration))
        let playerItem: AVPlayerItem = AVPlayerItem(asset: avAsset)
        // Create AVPlayer
        videoPlayer = AVPlayer(playerItem: playerItem)
        // Add AVPlayer
        let layer = AVPlayerLayer()
        layer.videoGravity = AVLayerVideoGravity.resizeAspect
        layer.player = videoPlayer
        layer.frame = view.bounds
        view.layer.addSublayer(layer)
        // Create Movie SeekBar
        seekBar.frame = CGRect(x: sp*2, y:seeky, width: ww - 4*sp, height: bh)
        seekBar.thumbTintColor=UIColor.orange
        seekBar.minimumValue = 0
        seekBar.maximumValue = videoDuration
        seekBar.addTarget(self, action: #selector(onSliderValueChange), for: UIControl.Event.valueChanged)
        view.addSubview(seekBar)
        // Set SeekBar Interval
        let interval : Double = Double(0.5 * seekBar.maximumValue) / Double(seekBar.bounds.maxX)
        // ConvertCMTime
        let time : CMTime = CMTimeMakeWithSeconds(interval, preferredTimescale: Int32(NSEC_PER_SEC))
        // Observer
        videoPlayer.addPeriodicTimeObserver(forInterval: time, queue: nil, using: {time in
            // Change SeekBar Position
            let duration = CMTimeGetSeconds(self.videoPlayer.currentItem!.duration)
            let time = CMTimeGetSeconds(self.videoPlayer.currentTime())
            let value = Float(self.seekBar.maximumValue - self.seekBar.minimumValue) * Float(time) / Float(duration) + Float(self.seekBar.minimumValue)
            self.seekBar.value = value
        })
        currTimeLabel.frame = CGRect(x: sp*2, y: 5, width: bw*2, height: bh)
        currTimeLabel!.font=UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .medium)
        view.bringSubviewToFront(currTimeLabel)
        // Create Movie Start Button
        mailButton.frame = CGRect(x:sp*2+bw*0,y:by,width:bw,height:bh)
        setButtonProperty(button: mailButton, color: UIColor.darkGray)
        view.bringSubviewToFront(mailButton)
        saveButton.frame = CGRect(x:sp*3+bw*1,y:by,width:bw,height:bh)
        setButtonProperty(button: saveButton, color: UIColor.darkGray)
        view.bringSubviewToFront(saveButton)
        waveButton.frame = CGRect(x:sp*4+bw*2,y:by,width:bw,height:bh)
        setButtonProperty(button: waveButton, color: UIColor.darkGray)
        view.bringSubviewToFront(waveButton)
        calcButton.frame = CGRect(x: sp*5+bw*3, y: by, width: bw, height: bh)
        setButtonProperty(button: calcButton, color: UIColor.blue)
        view.bringSubviewToFront(calcButton)
        playButton.frame = CGRect(x: sp*6+bw*4, y: by, width: bw, height: bh)
        setButtonProperty(button: playButton, color: UIColor.orange)
        view.bringSubviewToFront(playButton)
        album.setButtonProperty(setteiButton,x:sp*7+bw*5,y:by,w:bw,h:bh,UIColor.darkGray)
        view.bringSubviewToFront(setteiButton)
        album.setButtonProperty(exitButton,x: sp*8+bw*6,y:by, w:bw,h:bh,UIColor.darkGray)
        view.bringSubviewToFront(exitButton)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        videoSize=resolutionSizeOfVideo(url:videoURL!)
        screenSize=view.bounds.size
        videoFps=getFPS(url: videoURL!)
        dispWakus()
        showWakuImages()
        fpsLabel.frame=CGRect(x:ww - bw*2,y:5,width: bw*2-sp*2,height: bh)
        fpsLabel.text = String(format:"fps:%.0f w:%.0f h:%.0f",videoFps,videoSize.width,videoSize.height)
        fpsLabel!.font=UIFont.monospacedDigitSystemFont(ofSize: 15, weight: .medium)
        view.bringSubviewToFront(fpsLabel)
        vogBoxHeight=ww*16/25
        vogBoxYmin=wh/2-vogBoxHeight/2
        vogBoxYcenter=wh/2
        fpsXd=Int((240.0/videoFps).rounded())
//        mailButton.isEnabled=false
        cameraButton.frame = CGRect(x:  sp*7+bw*5, y: by-bh*2, width: bw*2+sp, height:bh)
        view.bringSubviewToFront(cameraButton)
    }
  
    func setButtonProperty(button:UIButton,color:UIColor){
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1.0
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5.0
        button.backgroundColor = color
    }
 
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
   
    // SeekBar Value Changed
    @objc func onSliderValueChange(){
        videoPlayer.pause()
        let newTime = CMTime(seconds: Double(seekBar.value), preferredTimescale: 600)
        videoPlayer.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        currFrameNumber=Int(seekBar.value*videoFps)
//        dispWakus()
        showWakuImages()
//        print("curr/slider:",currFrameNumber)
    }
    
    var kalVs:[[CGFloat]]=[[0.0001,0.001,0,1,2],[0.0001,0.001,3,4,5],[0.0001,0.001,6,7,8],[0.0001,0.001,10,11,12],[0.0001,0.001,13,14,15]]
    func KalmanS(Q:CGFloat,R:CGFloat,num:Int){
        kalVs[num][4] = (kalVs[num][3] + Q) / (kalVs[num][3] + Q + R);
        kalVs[num][3] = R * (kalVs[num][3] + Q) / (R + kalVs[num][3] + Q);
    }
    func Kalman(value:CGFloat,num:Int)->CGFloat{
        KalmanS(Q:kalVs[num][0],R:kalVs[num][1],num:num);
        let result = kalVs[num][2] + (value - kalVs[num][2]) * kalVs[num][4];
        kalVs[num][2] = result;
        return result;
    }
    func KalmanInit(){
        for i in 0...4{
            kalVs[i][2]=0
            kalVs[i][3]=0
            kalVs[i][4]=0
        }
    }
    func expandRectWithBorderWide(rect:CGRect, border:CGFloat) -> CGRect {
        //左右には border 、上下には border/2 を広げる
        //この関数も上と同じようにroundした方がいいかもしれないが、
        //現状ではscreen座標のみで使っているのでfloatのまま。
        return CGRect(x:(rect.origin.x - border).rounded(),
                      y:(rect.origin.y - border).rounded(),
                      width:(rect.size.width + border * 2).rounded(),
                      height:(rect.size.height + border * 2).rounded())
    }
    func expandRectWithBorder(rect:CGRect, border:CGFloat) -> CGRect {
        //左右上下に border　を広げる
        //この関数も上と同じようにroundした方がいいかもしれないが、
        //現状ではscreen座標のみで使っているのでfloatのまま。
        return CGRect(x:(rect.origin.x - border).rounded(),
                      y:(rect.origin.y - border).rounded(),
                      width:(rect.size.width + border * 2).rounded(),
                      height:(rect.size.height + border * 2).rounded())
    }
    func expandRectError(rect:CGRect, border:CGFloat) -> CGRect {
        //左右には border 、上下には border/2 を広げる
        //この関数も上と同じようにroundした方がいいかもしれないが、
        //現状ではscreen座標のみで使っているのでfloatのまま。
        return CGRect(x:rect.origin.x - border,
                      y:rect.origin.y - border ,
                      width:rect.size.width + border * 2,
                      height:rect.size.height + border * 2)
    }
    
    func startTimer() {
        if timer_vog?.isValid == true{
            timer_vog!.invalidate()
        }
        timer_vog = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.update_vog), userInfo: nil, repeats: true)
        timercnt=0
    }
    var calcFlag:Bool=false
    var posRatio:Int = 100//vog
    var veloRatio:Int = 100//vog
    var faceF:Int = 0
    var calcDate:String = ""
    var eyePosX = Array<CGFloat>()
    var eyePosY = Array<CGFloat>()
    var eyePosYfiltered = Array<CGFloat>()
    var eyePosXfiltered = Array<CGFloat>()
    var eyeVelXfiltered = Array<CGFloat>()
    var eyeVelYfiltered = Array<CGFloat>()
//    var buttonsArray:[Bool]!
    func setButtons(flag:Bool){
        mailButton.isEnabled=flag
        saveButton.isEnabled=flag
        waveButton.isEnabled=flag
//        calcButton.isEnabled=flag
        playButton.isEnabled=flag
        setteiButton.isEnabled=flag
        exitButton.isEnabled=flag
    }
    func checkImageRect(rect:CGRect)->Bool{
        if rect.minX<0{
            return false
        }else if rect.minY<0{//} uiImage.size.height<1000{
            return false
        }else if rect.maxX>videoWidth{
            return false
        }else if rect.maxY>videoHeight{
            return false
        }
        return true
    }
    @IBAction func onCalcButton(_ sender: Any) {
//        if faceMark == false{
//            onCalcButton()
//            return
//        }
        var debugMode:Bool=true
        if  UserDefaults.standard.integer(forKey: "checkRects") == 0{
            debugMode=false
        }
        if calcFlag == true{
            calcFlag=false
            setButtons(flag: true)
            return
        }
//        var cvError:Int = 0
        startTime=CFAbsoluteTimeGetCurrent()
        setButtons(flag: false)
        setUserDefaults()//eyeCenter,faceCenter
        lastArraycount=0
        calcFlag = true
        eyePosX.removeAll()
        eyePosXfiltered.removeAll()
        eyePosY.removeAll()
        eyePosYfiltered.removeAll()
        eyeVelXfiltered.removeAll()
        eyeVelYfiltered.removeAll()
        eyePosX.append(0)
        eyePosXfiltered.append(0)
        eyePosY.append(0)
        eyePosYfiltered.append(0)
        eyeVelXfiltered.append(0)
        eyeVelYfiltered.append(0)
        
        
        KalmanInit()
        //        showBoxies(f: true)
        //        vogImage = drawWakulines(width:mailWidth*18,height:mailHeight)//枠だけ
        UIApplication.shared.isIdleTimerDisabled = true
        let eyeborder:CGFloat = CGFloat(eyeBorder)
        startTimer()//resizerectのチェックの時はここをコメントアウト*********************
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let avAsset = AVURLAsset(url: videoURL!, options: options)
        //        calcDate = avAsset.creationDate!.description
        //                print("calcdate:",calcDate)
        var reader: AVAssetReader! = nil
        do {
            reader = try AVAssetReader(asset: avAsset)
        } catch {
            #if DEBUG
            print("could not initialize reader.")
            #endif
            return
        }
        guard let videoTrack = avAsset.tracks(withMediaType: AVMediaType.video).last else {
            #if DEBUG
            print("could not retrieve the video track.")
            #endif
            return
        }
        
        let readerOutputSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerOutputSettings)
        
        reader.add(readerOutput)
        let frameRate = videoTrack.nominalFrameRate
        let startTime = CMTime(value: CMTimeValue(currFrameNumber), timescale: CMTimeScale(frameRate))
        let timeRange = CMTimeRange(start: startTime, end:CMTime.positiveInfinity)
        reader.timeRange = timeRange //読み込む範囲を`timeRange`で指定
        reader.startReading()
        // UnsafeとMutableはまあ調べてもらうとして、eX, eY等は<Int32>が一つ格納されている場所へのポインタとして宣言される。
        let eX = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        let eY = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        let fX = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        let fY = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        //        var eyeCGImage:CGImage!
        //        let eyeUIImage:UIImage!
        var eyeWithBorderCGImage:CGImage!
        var eyeWithBorderUIImage:UIImage!
        //        var faceCGImage:CGImage!
        //        var faceUIImage:UIImage!
        var faceWithBorderCGImage:CGImage!
        var faceWithBorderUIImage:UIImage!
        let eyeRectOnScreen=getRectFromCenter(center: eyeCenter, len: wakuLength)
        let eyeWithBorderRectOnScreen = expandRectWithBorderWide(rect: eyeRectOnScreen, border: eyeborder)
        let faceRectOnScreen=getRectFromCenter(center: faceCenter, len: wakuLength)
        let faceWithBorderRectOnScreen = expandRectWithBorderWide(rect: faceRectOnScreen, border: eyeborder)
        
        let context:CIContext = CIContext.init(options: nil)
        var sample:CMSampleBuffer!
        sample = readerOutput.copyNextSampleBuffer()
        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sample!)!
        var ciImage:CIImage!
        if cameraMode == 0{//front Camera ここは画面表示とは関係なさそう
            ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.down)
        }else{
            ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.up)
        }
        videoWidth=ciImage.extent.width
        videoHeight=ciImage.extent.height
        print("wh:",videoWidth,videoHeight)
        //        let ciImage = CIImage(cvPixelBuffer:pixelBuffer).oriented(CGImagePropertyOrientation.down)
        //        let maxWidth=ciImage.extent.size.width
        //        let maxHeight=ciImage.extent.size.height
        
        let eyeRect = resizeR2(eyeRectOnScreen, viewRect:getVideoRectOnScreen()/*view.frame*/, image:ciImage)
        var eyeWithBorderRect = resizeR2(eyeWithBorderRectOnScreen, viewRect:getVideoRectOnScreen()/*view.frame*/, image:ciImage)
        let faceRect = resizeR2(faceRectOnScreen, viewRect:getVideoRectOnScreen() /*view.frame*/, image:ciImage)
        var faceWithBorderRect = resizeR2(faceWithBorderRectOnScreen, viewRect:getVideoRectOnScreen()/*view.frame*/, image:ciImage)
        //eyeWithBorderRectとeyeRect の差、faceでの差も同じ
        let borderRectDiffer=faceWithBorderRect.width-faceRect.width
        let maxWidthWithBorder=videoWidth-eyeWithBorderRect.width-5
        let maxHeightWithBorder=videoHeight-eyeWithBorderRect.height-5
        //        let eyebR0 = eyeWithBorderRect
        //        let facbR0 = faceWithBorderRect
        
        let eyeCGImage = context.createCGImage(ciImage, from: eyeRect)!
        let eyeUIImage = UIImage.init(cgImage: eyeCGImage)
        let faceCGImage = context.createCGImage(ciImage, from: faceRect)!
        let faceUIImage = UIImage.init(cgImage:faceCGImage)
        
        let osEyeX:CGFloat = (eyeWithBorderRect.size.width - eyeRect.size.width) / 2.0//上下方向への差
        let osEyeY:CGFloat = (eyeWithBorderRect.size.height - eyeRect.size.height) / 2.0//左右方向への差
        let osFacX:CGFloat = (faceWithBorderRect.size.width - faceRect.size.width) / 2.0//上下方向への差
        let osFacY:CGFloat = (faceWithBorderRect.size.height - faceRect.size.height) / 2.0//左右方向への差
        //   "ofset:" osEyeX=osFac,osEyeY=osFacY eyeとface同じ
        let xDiffer=faceWithBorderRect.origin.x - eyeWithBorderRect.origin.x
        let yDiffer=faceWithBorderRect.origin.y - eyeWithBorderRect.origin.y
        var maxEyeV:Double = 0
        var maxFaceV:Double = 0
        //        var frameCnt:Int=0
        while reader.status != AVAssetReader.Status.reading {
            sleep(UInt32(0.1))
        }
        DispatchQueue.global(qos: .default).async { [self] in
            while let sample = readerOutput.copyNextSampleBuffer(), self.calcFlag != false {
                var ex:CGFloat = 0
                var ey:CGFloat = 0
                var fx:CGFloat = 0
                var fy:CGFloat = 0
                
                //for test display
                //                #if DEBUG
                var x:CGFloat = 50.0
                let y:CGFloat = 50.0
                //                #endif
                autoreleasepool{
                    let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sample)!
                    
                    if faceMark == true{
                        if faceWithBorderRect.minX>0 && faceWithBorderRect.maxX<videoWidth && faceWithBorderRect.minY>0 && faceWithBorderRect.maxY<videoHeight{
                            maxFaceV=openCV.matching(faceWithBorderUIImage, narrow: faceUIImage, x: fX, y: fY)
                            if maxFaceV>0.91{
                                fx = CGFloat(fX.pointee) - osFacX
                                fy = borderRectDiffer - CGFloat(fY.pointee) - osFacY
                            }else{
                                fx=0
                                fy=0
                            }
                        }else{
                            fx=0
                            fy=0
                        }
//                        fx = CGFloat(fX.pointee) - osFacX
//                        fy = borderRectDiffer - CGFloat(fY.pointee) - osFacY
                        faceWithBorderRect.origin.x += fx
                        faceWithBorderRect.origin.y += fy
//                    }else{
//                        //faceWithBorderRect.x, faceWidBorderRect.y とも初期値
//                        //
                    }
//                    if faceWithBorderRect.origin.x > wakuLength &&
//                        faceWithBorderRect.origin.x < maxWidthWithBorder &&
//                        faceWithBorderRect.origin.y > wakuLength &&
//                        faceWithBorderRect.origin.y < maxHeightWithBorder
//                    {
                        
                        eyeWithBorderRect.origin.x = faceWithBorderRect.origin.x - xDiffer
                        eyeWithBorderRect.origin.y = faceWithBorderRect.origin.y - yDiffer
                    if eyeWithBorderRect.minX<0 || eyeWithBorderRect.maxX>videoWidth || eyeWithBorderRect.minY<0 || eyeWithBorderRect.maxY>videoHeight{
                        eyeWithBorderRect.origin.x=0
                        eyeWithBorderRect.origin.y=0
                    }
                        if cameraMode == 0{//front Camera ここは画面表示とは関係なさそう
                            ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.down)
                        }else{
                            ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.up)
                        }
                       
                        eyeWithBorderCGImage = context.createCGImage(ciImage, from: eyeWithBorderRect)!
                        eyeWithBorderUIImage = UIImage.init(cgImage: eyeWithBorderCGImage)
                        
                        if debugMode == true{
                            //画面表示はmain threadで行う
                            DispatchQueue.main.async {
                                debugEye.frame=CGRect(x:x,y:y,width:eyeRect.size.width,height:eyeRect.size.height)
                                debugEye.image=eyeUIImage
                                x += eyeRect.size.width
                                debugEyeb.frame=CGRect(x:x,y:y,width:eyeWithBorderRect.size.width,height:eyeWithBorderRect.size.height)
                                debugEyeb.image=eyeWithBorderUIImage
                                view.bringSubviewToFront(debugEye)
                                view.bringSubviewToFront(debugEyeb)
                                x += eyeWithBorderRect.size.width + 5
                            }
                            //                        #endif
                        }
                        maxEyeV=openCV.matching(eyeWithBorderUIImage,
                                                narrow: eyeUIImage,
                                                x: eX,
                                                y: eY)
                        //                    print("OpenV",maxEyeV)
                        if maxEyeV < 0.7{
                            ex = 0
                            ey = 0
                            print("error 0.7",eyePosX.count)///Int(videoFps))
                        }else{//検出できた時
                            //eXはポインタなので、".pointee"でそのポインタの内容が取り出せる。Cでいうところの"*"
                            //上で宣言しているとおりInt32が返ってくるのでCGFloatに変換して代入
                            ex = CGFloat(eX.pointee) - osEyeX
                            ey = borderRectDiffer - CGFloat(eY.pointee) - osEyeY
                        }
                        faceWithBorderCGImage = context.createCGImage(ciImage, from:faceWithBorderRect)!
                        faceWithBorderUIImage = UIImage.init(cgImage: faceWithBorderCGImage)
                        //                        #if DEBUG
                        if debugMode == true{
                            DispatchQueue.main.async {
                                debugFace.frame=CGRect(x:x,y:y,width:faceRect.size.width,height:faceRect.size.height)
                                debugFace.image=faceUIImage
                                x += faceRect.size.width
                                debugFaceb.frame=CGRect(x:x,y:y,width:faceWithBorderRect.size.width,height:faceWithBorderRect.size.height)
                                debugFaceb.image=faceWithBorderUIImage
                                view.bringSubviewToFront(debugFace)
                                view.bringSubviewToFront(debugFaceb)
                            }
                            //                        #endif
                        }
                        context.clearCaches()
                    while handlingDataNowFlag==true{
                        sleep(UInt32(0.1))
                    }
                        eyePosX.append(ex)
                        eyePosY.append(ey)
                        eyePosXfiltered.append(-1*Kalman(value: ex,num: 0))
                        eyePosYfiltered.append(-1*Kalman(value: ey,num: 1))
                        let cnt=eyePosX.count
                        //                        if cnt == 1{
                        //                            eyeVelXfiltered.append(Kalman(value:eyePosXfiltered[cnt-1],num:2))
                        //                            eyeVelYfiltered.append(Kalman(value:eyePosYfiltered[cnt-1],num:3))
                        //                        }else{
                        eyeVelXfiltered.append(Kalman(value:eyePosXfiltered[cnt-1]-eyePosXfiltered[cnt-2],num:2))
                        eyeVelYfiltered.append(Kalman(value:eyePosYfiltered[cnt-1]-eyePosYfiltered[cnt-2],num:3))
                        //                        }
                        while reader.status != AVAssetReader.Status.reading {
                            sleep(UInt32(0.1))
                        }
//                    }else{
//                        calcFlag = false
//                    }
                    //マッチングデバッグ用スリープ、デバッグが終わったら削除
                    //                    #if DEBUG
                    if debugMode == true{
                        usleep(200)
                    }
                    //                    #endif
                }
            }
            calcFlag = false
        }
        //        setButtons(flag: true)
    }
 /*   func onCalcButton() {
        if calcFlag == true{
            calcFlag=false
            setButtons(flag: true)
            return
        }
        var debugMode:Bool=true
        if  UserDefaults.standard.integer(forKey: "checkRects") == 0{
            debugMode=false
        }
        startTime=CFAbsoluteTimeGetCurrent()
        elapsedTime=0
        setButtons(flag: false)
        setUserDefaults()//eyeCenter,faceCenter
        lastArraycount=0
        calcFlag = true
        eyePosX.removeAll()
        eyePosXfiltered.removeAll()
        eyePosY.removeAll()
        eyePosYfiltered.removeAll()
        eyeVelXfiltered.removeAll()
        eyeVelYfiltered.removeAll()
        eyePosX.append(0)
        eyePosXfiltered.append(0)
        eyePosY.append(0)
        eyePosYfiltered.append(0)
        eyeVelXfiltered.append(0)
        eyeVelYfiltered.append(0)
        
        KalmanInit()
        //        showBoxies(f: true)
        //        vogImage = drawWakulines(width:mailWidth*18,height:mailHeight)//枠だけ
        UIApplication.shared.isIdleTimerDisabled = true
        let eyeborder:CGFloat = CGFloat(eyeBorder)
        startTimer()//resizerectのチェックの時はここをコメントアウト*********************
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let avAsset = AVURLAsset(url: videoURL!, options: options)
        //        calcDate = avAsset.creationDate!.description
        //                print("calcdate:",calcDate)
        var reader: AVAssetReader! = nil
        do {
            reader = try AVAssetReader(asset: avAsset)
        } catch {
            #if DEBUG
            print("could not initialize reader.")
            #endif
            return
        }
        guard let videoTrack = avAsset.tracks(withMediaType: AVMediaType.video).last else {
            #if DEBUG
            print("could not retrieve the video track.")
            #endif
            return
        }
        
        let readerOutputSettings: [String: Any] = [kCVPixelBufferPixelFormatTypeKey as String : Int(kCVPixelFormatType_420YpCbCr8BiPlanarFullRange)]
        let readerOutput = AVAssetReaderTrackOutput(track: videoTrack, outputSettings: readerOutputSettings)
        
        reader.add(readerOutput)
        let frameRate = videoTrack.nominalFrameRate
        let startTime = CMTime(value: CMTimeValue(currFrameNumber), timescale: CMTimeScale(frameRate))
        let timeRange = CMTimeRange(start: startTime, end:CMTime.positiveInfinity)
        reader.timeRange = timeRange //読み込む範囲を`timeRange`で指定
        reader.startReading()
        // UnsafeとMutableはまあ調べてもらうとして、eX, eY等は<Int32>が一つ格納されている場所へのポインタとして宣言される。
        let eX = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        let eY = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        //        let fX = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
        //        let fY = UnsafeMutablePointer<Int32>.allocate(capacity: 1)
//        var eyeCGImage:CGImage!
//        let eyeUIImage:UIImage!
        var eyeWithBorderCGImage:CGImage!
        var eyeWithBorderUIImage:UIImage!
 
        let eyeRectOnScreen=getRectFromCenter(center: eyeCenter, len: wakuLength)
        let eyeWithBorderRectOnScreen = expandRectWithBorderWide(rect: eyeRectOnScreen, border: eyeborder)

        let context:CIContext = CIContext.init(options: nil)
        var sample:CMSampleBuffer!
        sample = readerOutput.copyNextSampleBuffer()
        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sample!)!
//        let ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(CGImagePropertyOrientation.down)
        var ciImage:CIImage!
        if cameraMode == 0{//front Camera ここは画面表示とは関係なさそう
            ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.down)
        }else{
            ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.up)
        }
        videoWidth=ciImage.extent.width
        videoHeight=ciImage.extent.height
 
        print("x-y:",ciImage.extent.width,ciImage.extent.height)
        let eyeRect = resizeR2(eyeRectOnScreen, viewRect:getVideoRectOnScreen()/*view.frame*/, image:ciImage)
        let eyeWithBorderRect = resizeR2(eyeWithBorderRectOnScreen, viewRect:getVideoRectOnScreen()/*view.frame*/, image:ciImage)
        
        let borderRectDiffer=eyeWithBorderRect.width-eyeRect.width
        
        let eyeCGImage = context.createCGImage(ciImage, from: eyeRect)!
        let eyeUIImage = UIImage.init(cgImage: eyeCGImage)
        
        let osEyeX:CGFloat = (eyeWithBorderRect.size.width - eyeRect.size.width) / 2.0//上下方向への差
        let osEyeY:CGFloat = (eyeWithBorderRect.size.height - eyeRect.size.height) / 2.0//左右方向への差
        let maxWidthWithBorder=videoWidth-eyeWithBorderRect.width-5
        let maxHeightWithBorder=videoHeight-eyeWithBorderRect.height-5

        var maxEyeV:Double = 0
        let eyebR0 = eyeWithBorderRect
//        let facbR0 = faceWithBorderRect
        while reader.status != AVAssetReader.Status.reading {
            sleep(UInt32(0.1))
        }
        DispatchQueue.global(qos: .default).async { [self] in
//            var vogCnt:Int=0
            while let sample = readerOutput.copyNextSampleBuffer(), self.calcFlag != false {
                var ex:CGFloat = 0
                var ey:CGFloat = 0
                
                //for test display
//                #if DEBUG
                var x:CGFloat = 50.0
                let y:CGFloat = 50.0
//                #endif
                autoreleasepool{
                    let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sample)!
                    
                    if cameraMode == 0{//front Camera ここは画面表示とは関係なさそう
                        ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.down)
                    }else{
                        ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(.up)
                    }
                    
                    //                    let ciImage: CIImage =
                    //                        CIImage(cvPixelBuffer: pixelBuffer).oriented(CGImagePropertyOrientation.down)
                    
//                    if checkImageRect(rect:eyeWithBorderRect) == true{
                        
                        eyeWithBorderCGImage = context.createCGImage(ciImage, from: eyeWithBorderRect)!
                        eyeWithBorderUIImage = UIImage.init(cgImage: eyeWithBorderCGImage)
//                    }
                    
                    //                    #if DEBUG
                    if debugMode == true{
                    //画面表示はmain threadで行う
                    DispatchQueue.main.async {
                        self.debugEye.frame=CGRect(x:x,y:y,width:eyeRect.size.width,height:eyeRect.size.height)
                        self.debugEye.image=eyeUIImage
                        x += eyeRect.size.width
                        self.debugEyeb.frame=CGRect(x:x,y:y,width:eyeWithBorderRect.size.width,height:eyeWithBorderRect.size.height)
                        self.debugEyeb.image=eyeWithBorderUIImage
                        self.view.bringSubviewToFront(self.debugEye)
                        self.view.bringSubviewToFront(self.debugEyeb)
                        x += eyeWithBorderRect.size.width + 5
                    }
//                    #endif
                    }
                    maxEyeV=self.openCV.matching(eyeWithBorderUIImage,
                                                 narrow: eyeUIImage,
                                                 x: eX,
                                                 y: eY)
                    //                    print("OpenV",maxEyeV)
                    if maxEyeV < 0.7{
                        ex = 0
                        ey = 0
                        print("error 0.7",eyePosX.count)///Int(videoFps))
                    }else{//検出できた時
                        //eXはポインタなので、".pointee"でそのポインタの内容が取り出せる。Cでいうところの"*"
                        //上で宣言しているとおりInt32が返ってくるのでCGFloatに変換して代入
                        ex = CGFloat(eX.pointee) - osEyeX
                        ey = borderRectDiffer - CGFloat(eY.pointee) - osEyeY
                    }
                    
                    context.clearCaches()
//filter１回なら、下２行
//                    self.eyeVelXfiltered.append(self.Kalman(value:ex - self.eyePosX.last!,num:2))
//                    self.eyeVelYfiltered.append(self.Kalman(value:ey - self.eyePosY.last!,num:3))
                    
                    let lastPosXfiltered=self.eyePosXfiltered.last
                    let lastPosYfiltered=self.eyePosYfiltered.last
                    self.eyePosX.append(ex)
                    self.eyePosY.append(ey)
                    self.eyePosXfiltered.append(-1*self.Kalman(value: ex,num: 0))
                    self.eyePosYfiltered.append(-1*self.Kalman(value: ey,num: 1))
  //filter２回なら下２行
                    self.eyeVelXfiltered.append(self.Kalman(value:self.eyePosXfiltered.last! - lastPosXfiltered!,num:2))
                    self.eyeVelYfiltered.append(self.Kalman(value:self.eyePosYfiltered.last! - lastPosYfiltered!,num:3))
  
                    while reader.status != AVAssetReader.Status.reading {
                        sleep(UInt32(0.1))
                    }
                    if eyeWithBorderRect.origin.x < 5 ||
                        eyeWithBorderRect.origin.x > maxWidthWithBorder ||
                        eyeWithBorderRect.origin.y < 5 ||
                        eyeWithBorderRect.origin.y > maxHeightWithBorder
                    {
                        self.calcFlag=false//quit
                    }
                    //マッチングデバッグ用スリープ、デバッグが終わったら削除
                    //                    #if DEBUG
                    if debugMode == true{
                        usleep(200)
                        //                    #endif
                    }
                }
            }
            self.calcFlag = false
        }
    }
*/
    @IBAction func unwindPlay(segue: UIStoryboardSegue) {
//        UIApplication.shared.isIdleTimerDisabled = false//スリープする
        print("unwindPlay")
        posRatio=UserDefaults.standard.integer(forKey:"posRatio")
        veloRatio=UserDefaults.standard.integer(forKey:"veloRatio")
        wakuLength=CGFloat(UserDefaults.standard.integer(forKey:"wakuLength"))
        eyeBorder=UserDefaults.standard.integer(forKey:"eyeBorder")
        faceMark = UserDefaults.standard.bool(forKey: "faceMark")
        dispWakus()
        showWakuImages()
        if vogImageView?.isHidden == false{//wakuimageなどの前に持ってくる
            view.bringSubviewToFront(vogImageView!)
        }
    }
    func drawWakulines(width w:CGFloat,height h:CGFloat) ->UIImage{
        let size = CGSize(width:w, height:h)
        // イメージ処理の開始
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        // パスの初期化
        let drawPath = UIBezierPath()
        
        //let wI:Int = Int(w)//2400*18
        let wid:CGFloat=w/90.0
        for i in 0..<90 {
            let xp = CGFloat(i)*wid
            drawPath.move(to: CGPoint(x:xp,y:0))
            drawPath.addLine(to: CGPoint(x:xp,y:h-120))
        }
        drawPath.move(to:CGPoint(x:0,y:0))
        drawPath.addLine(to: CGPoint(x:w,y:0))
        drawPath.move(to:CGPoint(x:0,y:h-120))
        drawPath.addLine(to: CGPoint(x:w,y:h-120))
        //UIColor.blue.setStroke()
        drawPath.lineWidth = 2.0//1.0
        drawPath.stroke()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // イメージ処理の終了
        UIGraphicsEndImageContext()
        return image!
    }
}
