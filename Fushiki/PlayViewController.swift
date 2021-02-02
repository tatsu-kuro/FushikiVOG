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
    let openCV = OpenCVWrapper()
    var videoURL:URL?
    var videoSize:CGSize!
    var videoFps:Float!
    var videoPlayer: AVPlayer!
    var videoDuration:Float=0
    var screenSize:CGSize!
    var currTime:UILabel?
    var currFrameNumber:Int=0
    lazy var seekBar = UISlider()
    var timer:Timer?
    var timer_vog:Timer?
    var wave3View:UIImageView?
    var vogLineView:UIImageView?//vog
    var vogImage:UIImage?
    var vogBoxHeight:CGFloat=0
    var vogBoxYmin:CGFloat=0
    var vogBoxYcenter:CGFloat=0
    var mailWidth:CGFloat=2400//VOG
    var mailHeight:CGFloat=1600//VOG
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
    
    @IBOutlet weak var fpsLabel: UILabel!
    
    @IBAction func onMailButton(_ sender: Any) {
    }
    
    @IBAction func onSaveButton(_ sender: Any) {
    }
    
    @IBAction func onWaveButton(_ sender: Any) {
    }
    
    @IBAction func onSetteiButton(_ sender: Any) {
    }
    @IBAction func onPlayButton(_ sender: Any) {
        if (videoPlayer.rate != 0) && (videoPlayer.error == nil) {//playing
            videoPlayer.pause()
            videoPlayer.seek(to: CMTimeMakeWithSeconds(Float64(seekBar.value), preferredTimescale: Int32(NSEC_PER_SEC)))
        }else{//stoped
            if seekBar.value>seekBar.maximumValue-0.5{
                seekBar.value=0
            }
            videoPlayer.seek(to: CMTimeMakeWithSeconds(Float64(seekBar.value), preferredTimescale: Int32(NSEC_PER_SEC)))
            videoPlayer.play()
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
    func drawVogall_new(){//すべてのvogを画面に表示
        if vogLineView != nil{
            vogLineView?.removeFromSuperview()
        }
        if wave3View != nil{
            wave3View?.removeFromSuperview()
        }
        
        let drawImage = vogImage!.resize(size: CGSize(width:view.bounds.width*18, height:vogBoxHeight))
        // 画面に表示する
        wave3View = UIImageView(image: drawImage)
        view.addSubview(wave3View!)
        //上手くいかないので、諦めて最初を表示する
        //        var temp = -vogCurpoint*Int(view.bounds.width)/Int(mailWidth)
        //
        //        if temp>0{
        //            temp = 0
        //        }
        //        //print("start:",temp)
        //        temp=0
        wave3View!.frame=CGRect(x:0,y:vogBoxYmin,width:view.bounds.width*18,height:vogBoxHeight)
    }
    func drawVogall(){//すべてのvogを画面に表示
        if vogLineView != nil{
            vogLineView?.removeFromSuperview()
        }
        if wave3View != nil{
            wave3View?.removeFromSuperview()
        }
        let dImage = drawAllvogwaves(width:mailWidth*18,height:mailHeight)
        let drawImage = dImage.resize(size: CGSize(width:view.bounds.width*18, height:vogBoxHeight))
        // 画面に表示する
        wave3View = UIImageView(image: drawImage)
        view.addSubview(wave3View!)
        //        var bai:CGFloat=1
        //        if okpMode==0{//okpModeの時は3分全部を表示
        //            bai=18
        //        }
        
        wave3View!.frame=CGRect(x:0,y:vogBoxYmin,width:view.bounds.width*18,height:vogBoxHeight)
    }
    
    func drawAllvogwaves(width w:CGFloat,height h:CGFloat) ->UIImage{
        //        let nx:Int=18//3min 180sec 目盛は10秒毎 18本
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
        drawPath.removeAllPoints()
        var pointList = Array<CGPoint>()
        var pointList2 = Array<CGPoint>()
        //let pointCount = Int(w) // 点の個数
        //        print("pointCount:",wI)
        
        let dx = 1// xの間隔
        
        for i in 0..<Int(w) {
            if i < eyePosXfiltered.count - 4{
                let px = CGFloat(dx * i)
                let py = eyePosXfiltered[i] * CGFloat(posRatio)/20.0 + (h-240)/4 + 120
//                let py2 = eyeVeloFiltered[i] * CGFloat(veloRatio)/10.0 + (h-240)*3/4 + 120
                let point = CGPoint(x: px, y: py)
//                let point2 = CGPoint(x: px, y: py2)
                pointList.append(point)
//                pointList2.append(point2)
            }
        }
        // 始点に移動する
        drawPath.move(to: pointList[0])
        // 配列から始点の値を取り除く
        pointList.removeFirst()
        // 配列から点を取り出して連結していく
        for pt in pointList {
            drawPath.addLine(to: pt)
        }
//        drawPath.move(to: pointList2[0])
//        pointList2.removeFirst()
//        for pt in pointList2 {
//            drawPath.addLine(to: pt)
//        }
        // 線の色
        UIColor.black.setStroke()
        // 線を描く
        drawPath.stroke()
        // イメージコンテキストからUIImageを作る
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // イメージ処理の終了
        UIGraphicsEndImageContext()
        return image!
    }
 
    func drawVogwaves(timeflag:Bool,num:Int, width w:CGFloat,height h:CGFloat) -> UIImage {
        let size = CGSize(width:w, height:h)
        // イメージ処理の開始
        UIGraphicsBeginImageContextWithOptions(size, false, 1.0)
        // パスの初期化
        let drawPath = UIBezierPath()
        
        UIColor.black.setStroke()
        drawPath.lineWidth = 2.0//1.0
        let wI:Int = Int(w)
        var startp=num-240*10
        if num<240*10{
            startp=0
        }
        for i in 0...5 {
            let xp:CGFloat = CGFloat(i*wI/5-startp%(wI/5))
            drawPath.move(to: CGPoint(x:xp,y:0))
            drawPath.addLine(to: CGPoint(x:xp,y:h-120))
        }
        drawPath.move(to:CGPoint(x:0,y:0))
        drawPath.addLine(to: CGPoint(x:w,y:0))
        drawPath.move(to:CGPoint(x:0,y:h-120))
        drawPath.addLine(to: CGPoint(x:w,y:h-120))
        drawPath.stroke()
        drawPath.removeAllPoints()
        var pointX = Array<CGPoint>()
        var pointXd = Array<CGPoint>()
        var pointY = Array<CGPoint>()
        var pointYd = Array<CGPoint>()
        let dataCnt=eyePosXfiltered.count
//        let xarray=sample(width:wI,start: startp, x: eyePosXfiltered_s)
        let dx = 1// xの間隔
        //        print("vogPos5,vHITEye5,vHITeye",vogPos5.count,vHITEye5.count,vHITEye.count)
        for n in 1..<wI {
            if startp + n < dataCnt - 1{//-20としてみたがエラー。関係なさそう。
                let px = CGFloat(dx * n)
                
                let py1 = eyePosXfiltered[startp + n] * CGFloat(posRatio)/20.0 + (h-240)/5
                let py2 = eyeVelXfiltered[startp + n] * CGFloat(veloRatio) + (h-240)*2/5
                let py3 = eyePosYfiltered[startp + n] * CGFloat(posRatio)/20.0 + (h-240)*3/5
                let py4 = eyeVelYfiltered[startp + n] * CGFloat(veloRatio) + (h-240)*4/5
                let point1 = CGPoint(x: px, y: py1)
                let point2 = CGPoint(x: px, y: py2)
                let point3 = CGPoint(x: px, y: py3)
                let point4 = CGPoint(x: px, y: py4)
                pointX.append(point1)
                pointXd.append(point2)
                pointY.append(point3)
                pointYd.append(point4)
            }
        }
        drawPath.move(to: pointX[0])// 始点に移動する
        pointX.removeFirst()// 配列から始点の値を取り除く
        for pt in pointX {// 配列から点を取り出して連結していく
            drawPath.addLine(to: pt)
        }
        drawPath.move(to: pointXd[0])
        pointXd.removeFirst()
        for pt in pointXd {
            drawPath.addLine(to: pt)
        }
        drawPath.move(to: pointY[0])
        pointY.removeFirst()
        for pt in pointY {
            drawPath.addLine(to: pt)
        }
        drawPath.move(to: pointYd[0])
        pointYd.removeFirst()
        for pt in pointYd {
            drawPath.addLine(to: pt)
        }
        // 線の色
        UIColor.black.setStroke()
        // 線を描く
        drawPath.stroke()
        // イメージコンテキストからUIImageを作る
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // イメージ処理の終了
        UIGraphicsEndImageContext()
        return image!
    }
//    func getPointList(width:CGFloat,height:CGFloat,start:Int,x: [CGFloat],type:Bool)->[CGPoint] {
//        var pointList = Array<CGPoint>()
//        let w=Int(width)
//        let cnt=x.count
//        var py:CGFloat=0
//        for n in 1..<w {
//            if start + n < cnt - 1{
//                let px = CGFloat(n)
//                if(type==false){
//                    py = x[start + n] * CGFloat(posRatio)/20.0 + (height-240)/4 + 120
//                }else{
//                py = (x[start + n + 1] - x[start + n]) * CGFloat(veloRatio) + (height-240)*3/4 + 120
//                }
//                let point = CGPoint(x: px, y: py)
//                pointList.append(point)
//            }
//        }
//        return pointList
//    }
   
    func drawVog(startcount:Int){//startcountまでのvogを画面に表示
        if vogLineView != nil{
            vogLineView?.removeFromSuperview()
        }
        if wave3View != nil{
            wave3View?.removeFromSuperview()
        }
        let dImage = drawVogwaves(timeflag:true,num:startcount,width:mailWidth,height:mailHeight)
        let drawImage = dImage.resize(size: CGSize(width:view.bounds.width, height:vogBoxHeight*2/3))
        vogLineView = UIImageView(image: drawImage)
        vogLineView?.center =  CGPoint(x:view.bounds.width/2,y:view.bounds.height/2)
        // 画面に表示する
        view.addSubview(vogLineView!)
    }
    func addwaveImage(startingImage:UIImage,sn:Int,en:Int) ->UIImage{
        // Create a context of the starting image size and set it as the current one
        var stn=sn
        if sn<0{
            stn=0
        }
        UIGraphicsBeginImageContext(startingImage.size)
        // Draw the starting image in the current context as background
        startingImage.draw(at: CGPoint.zero)
        
        // Get the current context
        let context = UIGraphicsGetCurrentContext()!
        
        // Draw a red line
        context.setLineWidth(2.0)
        context.setStrokeColor(UIColor.black.cgColor)
        
        var pointList = Array<CGPoint>()
        var pointList2 = Array<CGPoint>()
        let h=startingImage.size.height
        let vogPos_count=eyePosXfiltered.count//eyePosOrig.count
        let dx = 1// xの間隔
        for i in stn..<en {
            if i < vogPos_count{
                let px = CGFloat(dx * i)
                let py = eyePosXfiltered[i] * CGFloat(posRatio)/20.0 + (h-240)/4 + 120
//                let py2 = eyeVeloFiltered[i] * CGFloat(veloRatio)/10.0 + (h-240)*3/4 + 120
                let point = CGPoint(x: px, y: py)
//                let point2 = CGPoint(x: px, y: py2)
                pointList.append(point)
//                pointList2.append(point2)
            }
        }
        // 始点に移動する
        context.move(to: pointList[0])
        // 配列から始点の値を取り除く
        pointList.removeFirst()
        // 配列から点を取り出して連結していく
        for pt in pointList {
            context.addLine(to: pt)
        }
//        context.move(to: pointList2[0])
//        // 配列から始点の値を取り除く
//        pointList2.removeFirst()
//        // 配列から点を取り出して連結していく
//        for pt in pointList2 {
//            context.addLine(to: pt)
//        }
        // 線の色
        context.strokePath()
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        // イメージ処理の終了
        UIGraphicsEndImageContext()
        return image!
    }
    
    var timercnt:Int = 0
    var lastArraycount:Int = 0
    @objc func update_vog(tm: Timer) {
        timercnt += 1
        if eyePosXfiltered.count < 5 {
            return
        }
        if calcFlag == false {//終わったらここ
            timer_vog!.invalidate()
            //            setButtons(mode: true)
            UIApplication.shared.isIdleTimerDisabled = false
//            vogImage=addwaveImage(startingImage: vogImage!, sn: lastArraycount-100, en: eyeVeloOrig.count)
            
//            drawVogall_new()
            if vogLineView != nil{
//                vogLineView?.removeFromSuperview()//waveを消して
                //                drawVogtext()//文字を表示
            }
            //終わり直前で認識されたvhitdataが認識されないこともあるかもしれない
        }else{
            #if DEBUG
            print("debug-update",timercnt)
            #endif
//            print("veloCount:",eyeVeloOrig.count)
            drawVog(startcount: eyePosXfiltered.count)
//            vogImage=addwaveImage(startingImage: vogImage!, sn: lastArraycount-100, en: eyeVeloOrig.count)
            //            vogCurpoint=vHITeye.count
            lastArraycount=eyePosXfiltered.count
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
        //UIImage.Orientation.up CIImage(....Orientation.down)で向きが一致する。
//        let orientation = UIImage.Orientation.up
        var sample:CMSampleBuffer!
        sample = readerOutput.copyNextSampleBuffer()
        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sample!)!
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(CGImagePropertyOrientation.down)//4行上ともupで良いような？
        //起動時表示が一巡？するまでは　slowImage.frame はちょっと違う値を示す
        //        eyeCenter=transPoint(point: eyeCenter, videoImage: ciImage)
        let eyeRect=getRectFromCenter(center: eyeCenter, len: wakuLength)
        let eyeRectResized = resizeR2(eyeRect, viewRect:getVideoRectOnScreen(),image:ciImage)
//        let eyeRectResized = checkRect(rect:eyeRectResized1,image:ciImage)
        CGeye = context.createCGImage(ciImage, from: eyeRectResized)
        UIeye = UIImage.init(cgImage: CGeye, scale:1.0, orientation:.up)//orientation)
        eyeWakuL_image.frame=CGRect(x:view.bounds.width/4+10,y:5,width: eyeRectResized.size.width*4,height: eyeRectResized.size.height*4)
        eyeWakuL_image.layer.borderColor = UIColor.black.cgColor
        eyeWakuL_image.layer.borderWidth = 1.0
        eyeWakuL_image.backgroundColor = UIColor.clear
        eyeWakuL_image.layer.cornerRadius = 3
        eyeWakuL_image.image=UIeye
        view.bringSubviewToFront(eyeWakuL_image)
        //        faceCenter=transPoint(point: faceCenter,videoImage: ciImage)
        let faceRect=getRectFromCenter(center: faceCenter, len: wakuLength)
        let faceRectResized = resizeR2(faceRect, viewRect:getVideoRectOnScreen(), image: ciImage)
//        let faceRectResized = checkRect(rect:faceRectResized1,image:ciImage)
        CGface = context.createCGImage(ciImage, from: faceRectResized)
        UIface = UIImage.init(cgImage: CGface, scale:1.0, orientation:.up)
        faceWakuL_image.frame=CGRect(x:view.bounds.width/4 - faceRectResized.size.width*4 - 10,y:5,width: faceRectResized.size.width*4,height: faceRectResized.size.height*4)
        faceWakuL_image.layer.borderColor = UIColor.black.cgColor
        faceWakuL_image.layer.borderWidth = 1.0
        faceWakuL_image.backgroundColor = UIColor.clear
        faceWakuL_image.layer.cornerRadius = 3
        faceWakuL_image.image=UIface
//        let grayFace=openCV.grayScale(UIface)
//        faceWakuL_image.image=grayFace
        view.bringSubviewToFront(faceWakuL_image)
//        fpsLabel.frame=CGRect(x:100,y:100,width:100,height: 100)
    }
    
    func dispWakus(){
        let d=(wakuLength+20)/2//matchingArea(center,wakuLength)
        eyeWaku_image.frame=CGRect(x:eyeCenter.x-d,y:eyeCenter.y-d,width:2*d,height:2*d)
        faceWaku_image.frame=CGRect(x:faceCenter.x-d,y:faceCenter.y-d,width:2*d,height:2*d)
        eyeWaku_image.layer.borderColor = UIColor.green.cgColor
        eyeWaku_image.backgroundColor = UIColor.clear
        eyeWaku_image.layer.cornerRadius = 4
        faceWaku_image.layer.borderColor = UIColor.green.cgColor
        faceWaku_image.backgroundColor = UIColor.clear
        faceWaku_image.layer.cornerRadius = 4
        if eyeORface==0{
            eyeWaku_image.layer.borderWidth = 2
            faceWaku_image.layer.borderWidth = 1
        }else{
            eyeWaku_image.layer.borderWidth = 1
            faceWaku_image.layer.borderWidth = 2
        }
        view.bringSubviewToFront(faceWaku_image)
        view.bringSubviewToFront(eyeWaku_image)
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
    @IBAction func panGesture(_ sender: UIPanGestureRecognizer) {
        let move:CGPoint = sender.translation(in: self.view)
        if sender.state == .began {
            startEyeCenter=eyeCenter
            startFaceCenter=faceCenter
        } else if sender.state == .changed {
            
            let ww=view.bounds.width
            let wh=view.bounds.height
            
            let et=CGRect(x:ww/10,y:wh/20,width: ww*4/5,height:wh*3/4)
            if eyeORface==0{
                eyeCenter=moveCenter(start:startEyeCenter,move:move,hani:et)
            }else{
                faceCenter=moveCenter(start:startFaceCenter,move:move,hani:et)
            }
            eyeCenter=getCenterInScreen(point:eyeCenter)
            faceCenter=getCenterInScreen(point:faceCenter)
            dispWakus()
            showWakuImages()
        }else if sender.state == .ended{
        }
    }
    
    @IBAction func tapGesture(_ sender: UITapGestureRecognizer) {
        print("tap")
        if eyeORface==0{//eye
            eyeORface=1
        }else{
            eyeORface=0
        }
        dispWakus()
    }
    
    
    @objc func update(tm: Timer) {
        currTime?.text=String(format:"%.1f/%.1f",seekBar.value,videoDuration)
        if !((videoPlayer.rate != 0) && (videoPlayer.error == nil)) {//notplaying
            if seekBar.value>videoDuration-0.01{
                seekBar.value=0
                videoPlayer.seek(to: CMTimeMakeWithSeconds(Float64(seekBar.value), preferredTimescale: Int32(NSEC_PER_SEC)))
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
    override func viewDidLoad() {
        super.viewDidLoad()
        //setteiしてなければ、以下
        if ( UIDevice.current.model.range(of: "iPad") != nil){//ipad
            wakuLength = 6
            eyeBorder = 20
        }else{//iphone
            wakuLength=3
            eyeBorder=10
        }
        let avAsset = AVURLAsset(url: videoURL!)
        let ww:CGFloat=view.bounds.width
        let wh:CGFloat=view.bounds.height
        let dw=ww/120//間隙
        let bw=(ww-dw*8)/7//ボタン幅
        let bh=bw/3.5//ボタン厚さ
        let by = wh - bh - dw
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
        seekBar.frame = CGRect(x: dw, y:seeky, width: ww - 2*dw, height: bh)
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
        
        currTime = UILabel(frame:CGRect(x: dw, y: 5, width: bw, height: bh))
        currTime!.backgroundColor = UIColor.white
        currTime!.layer.masksToBounds = true
        currTime!.layer.cornerRadius = 5
        currTime!.textColor = UIColor.black
        currTime!.textAlignment = .center
        currTime!.font=UIFont.monospacedDigitSystemFont(ofSize: 18, weight: .medium)
        currTime!.layer.borderColor = UIColor.black.cgColor
        currTime!.layer.borderWidth = 1.0
        view.addSubview(currTime!)

        // Create Movie Start Button
 
        mailButton.frame = CGRect(x:dw*1+bw*0,y:by,width:bw,height:bh)
        setButtonProperty(button: mailButton, txt: "Mail", color: UIColor.darkGray)
        view.bringSubviewToFront(mailButton)
        saveButton.frame = CGRect(x:dw*2+bw*1,y:by,width:bw,height:bh)
        setButtonProperty(button: saveButton, txt: "Save", color: UIColor.darkGray)
        view.bringSubviewToFront(saveButton)
        waveButton.frame = CGRect(x:dw*3+bw*2,y:by,width:bw,height:bh)
        setButtonProperty(button: waveButton, txt: "Wave", color: UIColor.darkGray)
        view.bringSubviewToFront(waveButton)
        calcButton.frame = CGRect(x: dw*4+bw*3, y: by, width: bw, height: bh)
        setButtonProperty(button: calcButton, txt: "Calc", color: UIColor.blue)
        view.bringSubviewToFront(calcButton)
        playButton.frame = CGRect(x: dw*5+bw*4, y: by, width: bw, height: bh)
        setButtonProperty(button: playButton, txt: "", color: UIColor.orange)
        view.bringSubviewToFront(playButton)
        setteiButton.frame = CGRect(x:dw*6+bw*5,y:by,width:bw,height:bh)
        setButtonProperty(button: setteiButton, txt: "", color: UIColor.darkGray)
        view.bringSubviewToFront(setteiButton)
        exitButton.frame = CGRect(x: dw*7+bw*6, y: by, width: bw, height: bh)
        setButtonProperty(button: exitButton, txt: "Exit", color: UIColor.darkGray)
        view.bringSubviewToFront(exitButton)
        timer = Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
        videoSize=resolutionSizeOfVideo(url:videoURL!)
        screenSize=view.bounds.size
        videoFps=getFPS(url: videoURL!)
        dispWakus()
        showWakuImages()
        fpsLabel.frame=CGRect(x:ww - bw*2,y:5,width: bw*2-dw,height: bh)
        fpsLabel.text = String(format:"fps:%.0f w:%.0f h:%.0f",videoFps,screenSize.width,screenSize.height)
        fpsLabel.layer.cornerRadius = 2.0
        fpsLabel.layer.borderColor = UIColor.black.cgColor
        fpsLabel.layer.borderWidth = 1.0
        view.bringSubviewToFront(fpsLabel)
        vogBoxHeight=ww*16/24
        vogBoxYmin=wh/2-vogBoxHeight/2
        vogBoxYcenter=wh/2
    }
    func setButtonProperty(button:UIButton,txt:String,color:UIColor){
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1.0
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 5.0
        button.backgroundColor = color
        button.setTitle(txt, for:UIControl.State.normal)
    }
 
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
   
    // Start Button Tapped
//    @objc func onStartButtonTapped(){
//        if (videoPlayer.rate != 0) && (videoPlayer.error == nil) {//playing
//            videoPlayer.pause()
//        }else{//stoped
//            if seekBar.value>seekBar.maximumValue-0.5{
//                seekBar.value=0
//            }
//            videoPlayer.seek(to: CMTimeMakeWithSeconds(Float64(seekBar.value), preferredTimescale: Int32(NSEC_PER_SEC)))
//            videoPlayer.play()
//        }
//    }
//    @objc func onStopButtonTapped(){
//        if (videoPlayer.rate != 0) && (videoPlayer.error == nil) {//playing
//            videoPlayer.pause()
//            currFrameNumber=Int(seekBar.value*videoFps)
//            print("curr:",currFrameNumber)
//        }
//    }
    // SeekBar Value Changed
    @objc func onSliderValueChange(){
        videoPlayer.pause()
        let newTime = CMTime(seconds: Double(seekBar.value), preferredTimescale: 600)
        videoPlayer.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
        currFrameNumber=Int(seekBar.value*videoFps)
        print("curr/slider:",currFrameNumber)
    }
//    func onNextButtonTapped(){//このようなボタンを作ってみれば良さそう。無くてもいいか？
//        var seekBarValue=seekBar.value+0.01
//        if seekBarValue>videoDuration-0.1{
//            seekBarValue = videoDuration-0.1
//        }
//        let newTime = CMTime(seconds: Double(seekBarValue), preferredTimescale: 600)
//        currTime!.text = String(format:"%.1f/%.1f",seekBarValue,videoDuration)
//        videoPlayer.seek(to: newTime, toleranceBefore: .zero, toleranceAfter: .zero)
//    }
//    @objc func onExitButtonTapped(){//このボタンのところにsegueでunwindへ行く

//    }
    
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
//    var eyeVeloFiltered = Array<CGFloat>()
    var eyeVelXfiltered = Array<CGFloat>()
    var eyeVelYfiltered = Array<CGFloat>()
    @IBAction func onCalcButton(_ sender: Any) {
//    }
//    @objc func onCalcButtonTapped(){
        calcFlag = true
//        eyeVeloFiltered.removeAll()
        eyePosXfiltered.removeAll()
        eyePosX.removeAll()
        eyePosXfiltered.removeAll()
        eyePosY.removeAll()
        eyePosYfiltered.removeAll()

        KalmanInit()
        //        showBoxies(f: true)
        //        vogImage = drawWakulines(width:mailWidth*18,height:mailHeight)//枠だけ
        UIApplication.shared.isIdleTimerDisabled = true
        let eyeborder:CGFloat = CGFloat(eyeBorder)
        startTimer()//resizerectのチェックの時はここをコメントアウト*********************
        let options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
        let avAsset = AVURLAsset(url: videoURL!, options: options)
        calcDate = avAsset.creationDate!.description
        //        print("calcdate:",calcDate)
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
        var eyeCGImage:CGImage!
        let eyeUIImage:UIImage!
        var eyeWithBorderCGImage:CGImage!
        var eyeWithBorderUIImage:UIImage!
        var faceCGImage:CGImage!
        var faceUIImage:UIImage!
        var faceWithBorderCGImage:CGImage!
        var faceWithBorderUIImage:UIImage!
        let eyeRectOnScreen=getRectFromCenter(center: eyeCenter, len: wakuLength)
        let eyeWithBorderRectOnScreen = expandRectWithBorderWide(rect: eyeRectOnScreen, border: eyeborder)
        let faceRectOnScreen=getRectFromCenter(center: faceCenter, len: wakuLength)
        let faceWithBorderRectOnScreen = expandRectWithBorderWide(rect: faceRectOnScreen, border: eyeborder)
        
        let context:CIContext = CIContext.init(options: nil)
        //        let orientation = UIImage.Orientation.up
        var sample:CMSampleBuffer!
        sample = readerOutput.copyNextSampleBuffer()
        let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sample!)!
        let ciImage = CIImage(cvPixelBuffer: pixelBuffer).oriented(CGImagePropertyOrientation.down)//4行上ともupで良いような？
        
        let maxWidth=ciImage.extent.size.width
        let maxHeight=ciImage.extent.size.height
        
        let eyeRect = resizeR2(eyeRectOnScreen, viewRect:getVideoRectOnScreen()/*view.frame*/, image:ciImage)
        var eyeWithBorderRect = resizeR2(eyeWithBorderRectOnScreen, viewRect:getVideoRectOnScreen()/*view.frame*/, image:ciImage)
        let faceRect = resizeR2(faceRectOnScreen, viewRect:getVideoRectOnScreen() /*view.frame*/, image:ciImage)
        var faceWithBorderRect = resizeR2(faceWithBorderRectOnScreen, viewRect:getVideoRectOnScreen()/*view.frame*/, image:ciImage)
        //eyeWithBorderRectとeyeRect の差、faceでの差も同じ
        let borderRectDiffer=faceWithBorderRect.width-faceRect.width
        let maxWidthWithBorder=maxWidth-eyeWithBorderRect.width-5
        let maxHeightWithBorder=maxHeight-eyeWithBorderRect.height-5
//        let eyebR0 = eyeWithBorderRect
//        let facbR0 = faceWithBorderRect
        
        eyeCGImage = context.createCGImage(ciImage, from: eyeRect)!
        eyeUIImage = UIImage.init(cgImage: eyeCGImage)
        faceCGImage = context.createCGImage(ciImage, from: faceRect)!
        faceUIImage = UIImage.init(cgImage:faceCGImage)
        
        let osEyeX:CGFloat = (eyeWithBorderRect.size.width - eyeRect.size.width) / 2.0//上下方向への差
        let osEyeY:CGFloat = (eyeWithBorderRect.size.height - eyeRect.size.height) / 2.0//左右方向への差
        let osFacX:CGFloat = (faceWithBorderRect.size.width - faceRect.size.width) / 2.0//上下方向への差
        let osFacY:CGFloat = (faceWithBorderRect.size.height - faceRect.size.height) / 2.0//左右方向への差
        //   "ofset:" osEyeX=osFac,osEyeY=osFacY eyeとface同じ
        let xDiffer=faceWithBorderRect.origin.x - eyeWithBorderRect.origin.x
        let yDiffer=faceWithBorderRect.origin.y - eyeWithBorderRect.origin.y
        var maxEyeV:Double = 0
        var maxFaceV:Double = 0
        var frameCnt:Int=0
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
                #if DEBUG
                var x:CGFloat = 40.0
                let y:CGFloat = 0.0
                #endif
                autoreleasepool{
                    let pixelBuffer: CVPixelBuffer = CMSampleBufferGetImageBuffer(sample)!
 
                    maxFaceV=self.openCV.matching(faceWithBorderUIImage, narrow: faceUIImage, x: fX, y: fY)
                    fx = CGFloat(fX.pointee) - osFacX
                    fy = borderRectDiffer - CGFloat(fY.pointee) - osFacY
                    faceWithBorderRect.origin.x += fx
                    faceWithBorderRect.origin.y += fy
                    eyeWithBorderRect.origin.x = faceWithBorderRect.origin.x - xDiffer
                    eyeWithBorderRect.origin.y = faceWithBorderRect.origin.y - yDiffer

                    let ciImage: CIImage =
                        CIImage(cvPixelBuffer: pixelBuffer).oriented(CGImagePropertyOrientation.down)
                    eyeWithBorderCGImage = context.createCGImage(ciImage, from: eyeWithBorderRect)!
                    eyeWithBorderUIImage = UIImage.init(cgImage: eyeWithBorderCGImage)
                    
                    #if DEBUG
                    //画面表示はmain threadで行う
                    DispatchQueue.main.async {
                        self.debugEye.frame=CGRect(x:x,y:y,width:eyeRect.size.width,height:eyeRect.size.height)
                        self.debugEye.image=eyeUIImage
                        self.debugEyeb.frame=CGRect(x:x,y:eyeRect.size.width + 10,width:eyeWithBorderRect.size.width,height:eyeWithBorderRect.size.height)
                        self.debugEyeb.image=eyeWithBorderUIImage
                        self.view.bringSubviewToFront(self.debugEye)
                        self.view.bringSubviewToFront(self.debugEyeb)
                        x += eyeWithBorderRect.size.width + 10
                    }
                    #endif
                    
                    maxEyeV=self.openCV.matching(eyeWithBorderUIImage,
                                                 narrow: eyeUIImage,
                                                 x: eX,
                                                 y: eY)
                    if maxEyeV < 0.7{
                        ex = 0
                        ey = 0
                    }else{//検出できた時
            //eXはポインタなので、".pointee"でそのポインタの内容が取り出せる。Cでいうところの"*"
            //上で宣言しているとおりInt32が返ってくるのでCGFloatに変換して代入
                        ex = CGFloat(eX.pointee) - osEyeX
                        ey = borderRectDiffer - CGFloat(eY.pointee) - osEyeY
                    }
                     faceWithBorderCGImage = context.createCGImage(ciImage, from:faceWithBorderRect)!
                    faceWithBorderUIImage = UIImage.init(cgImage: faceWithBorderCGImage)
                    #if DEBUG
                    DispatchQueue.main.async {
                        self.debugFace.frame=CGRect(x:x,y:y,width:faceRect.size.width,height:faceRect.size.height)
                        self.debugFace.image=faceUIImage
//                        x += faceRect.size.width + 10
                        self.debugFaceb.frame=CGRect(x:x,y:faceRect.size.width + 10,width:faceWithBorderRect.size.width,height:faceWithBorderRect.size.height)
                        self.debugFaceb.image=faceWithBorderUIImage
                        self.view.bringSubviewToFront(self.debugFace)
                        self.view.bringSubviewToFront(self.debugFaceb)
                    }
                    #endif
                    context.clearCaches()
          
                    self.eyePosX.append(ex)
                    self.eyePosY.append(ey)
                    self.eyePosXfiltered.append(-1*self.Kalman(value: ex,num: 0))
                    self.eyePosYfiltered.append(-1*self.Kalman(value: ey,num: 1))
                    let cnt=eyePosX.count
                    if cnt == 1{
                        self.eyeVelXfiltered.append(self.Kalman(value:self.eyePosXfiltered[cnt-1],num:2))
                        self.eyeVelYfiltered.append(self.Kalman(value:self.eyePosYfiltered[cnt-1],num:3))
                    }else{
                        self.eyeVelXfiltered.append(self.Kalman(value:self.eyePosXfiltered[cnt-1]-self.eyePosXfiltered[cnt-2],num:2))
                        self.eyeVelYfiltered.append(self.Kalman(value:self.eyePosYfiltered[cnt-1]-self.eyePosYfiltered[cnt-2],num:3))
                    }
                    while reader.status != AVAssetReader.Status.reading {
                        sleep(UInt32(0.1))
                    }
                    //eyeのみでチェックしているが。。。。
                    if eyeWithBorderRect.origin.x < 5 ||
                        eyeWithBorderRect.origin.x > maxWidthWithBorder ||
                        eyeWithBorderRect.origin.y < 5 ||
                        eyeWithBorderRect.origin.y > maxHeightWithBorder
                    {
                        self.calcFlag=false
                    }
                }
                //マッチングデバッグ用スリープ、デバッグが終わったら削除
                #if DEBUG
                usleep(200)
                #endif
            }
            self.calcFlag = false
        }
    }
}
