//
//  recordAlbum.swift
//  Fushiki
//
//  Created by 黒田建彰 on 2021/01/10.
//  Copyright © 2021 tatsuaki.Fushiki. All rights reserved.
//
import UIKit
import Photos
import AVFoundation
class CameraAlbumEtc: NSObject, AVCaptureFileOutputRecordingDelegate{
    var videoDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession!
    var fileOutput = AVCaptureMovieFileOutput()
    let TempFilePath: String = "\(NSTemporaryDirectory())temp.mp4"
    var soundIdx:SystemSoundID = 0
    var saved2album:Bool = false
    var albumName:String = ""
    var videoDate = Array<String>()
    var videoURL = Array<URL>()
    var stillDate = Array<String>()
    var stillURL = Array<URL>()
    var stillAsset = Array<PHAsset>()
    var albumExist:Bool = false
    var dialogStatus:Int=0
    init(name: String) {
        // 全てのプロパティを初期化する前にインスタンスメソッドを実行することはできない
        self.albumName = name
    }
    func updateRecClarification(tm: Int)->CGFloat {
        var cnt=tm%40
        if cnt>19{
            cnt = 40 - cnt
        }
//        let alpha=CGFloat(cnt)/20.0
        var alpha=CGFloat(cnt)*0.9/20.0//少し目立たなくなる
        alpha += 0.05
        return alpha
//        recClarification.alpha=alpha
//        if recordCircleCnt==1{
//            camera.recordStart()//ここだと暗くならない
//        }
    }
    func getRecClarificationRct(width:CGFloat,height:CGFloat)->CGRect{
        let imgH=height/30//415*177 2.34  383*114 3.36 257*112 2.3
        let imgW=imgH*2.3
        let space=imgW*0.1
        return CGRect(x:width-imgW-space,y:height-imgH-space,width: imgW,height:imgH)
    }
    func albumExists() -> Bool {
        // ここで以下のようなエラーが出るが、なぜか問題なくアルバムが取得できている
        let albums = PHAssetCollection.fetchAssetCollections(with: PHAssetCollectionType.album, subtype:
            PHAssetCollectionSubtype.albumRegular, options: nil)
        for i in 0 ..< albums.count {
            let album = albums.object(at: i)
            if album.localizedTitle != nil && album.localizedTitle == albumName {
                return true
            }
        }
        return false
    }
    //何も返していないが、ここで見つけたor作成したalbumを返したい。そうすればグローバル変数にアクセスせずに済む
    func createNewAlbum( callback: @escaping (Bool) -> Void) {
        if self.albumExists() {
            callback(true)
        } else {
            PHPhotoLibrary.shared().performChanges({ [self] in
                _ = PHAssetCollectionChangeRequest.creationRequestForAssetCollection(withTitle: albumName)
            }) { (isSuccess, error) in
                callback(isSuccess)
            }
        }
    }
    func makeAlbum(){
        if albumExists()==false{
            createNewAlbum() { [self] (isSuccess) in
                if isSuccess{
                    print(albumName," can be made,")
                } else{
                    print(albumName," can't be made.")
                }
            }
        }else{
            print(albumName," exist already.")
        }
    }
    func getPHAssetcollection()->PHAssetCollection{
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.isNetworkAccessAllowed = false
        requestOptions.deliveryMode = .highQualityFormat //これでもicloud上のvideoを取ってしまう
        //アルバムをフェッチ
        let assetFetchOptions = PHFetchOptions()
        assetFetchOptions.predicate = NSPredicate(format: "title == %@", albumName)
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .smartAlbumVideos, options: assetFetchOptions)
        //アルバムはviewdidloadで作っているのであるはず？
//        if (assetCollections.count > 0) {
        //同じ名前のアルバムは一つしかないはずなので最初のオブジェクトを使用
        return assetCollections.object(at:0)
    }
    var gettingAlbumF:Bool=true
    func getAlbumList(){//最後のvideoを取得するまで待つ
        gettingAlbumF = true
        getAlbumList_sub()
        while gettingAlbumF == true{
            sleep(UInt32(0.1))
        }
    }
    func getAlbumList_sub(){
        //     let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        videoURL.removeAll()
        videoDate.removeAll()
        requestOptions.isSynchronous = true
        requestOptions.isNetworkAccessAllowed = false//これでもicloud上のvideoを取ってしまう
        requestOptions.deliveryMode = .highQualityFormat
        // アルバムをフェッチ
        let assetFetchOptions = PHFetchOptions()
        assetFetchOptions.predicate = NSPredicate(format: "title == %@", albumName)
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .smartAlbumVideos, options: assetFetchOptions)
        
        //アルバムが存在しない事もある？
        if (assetCollections.count > 0) {
            //同じ名前のアルバムは一つしかないはずなので最初のオブジェクトを使用
            let assetCollection = assetCollections.object(at:0)
            // creationDate降順でアルバム内のアセットをフェッチ
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let assets = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
            albumExist=true
            if assets.count == 0{
                gettingAlbumF=false
                albumExist=false
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            for i in 0..<assets.count{
                let asset=assets[i]
                let date_sub = asset.creationDate
                let date = formatter.string(from: date_sub!)
                let duration = String(format:"%.1fs",asset.duration)
                let options=PHVideoRequestOptions()
                options.version = .original
                PHImageManager.default().requestAVAsset(forVideo:asset,
                                                        options: options){ [self](asset:AVAsset?,audioMix, info:[AnyHashable:Any]?)->Void in
                    
                    if let urlAsset = asset as? AVURLAsset{//not on iCloud
                        videoURL.append(urlAsset.url)
                        videoDate.append(date + "(" + duration + ")")
                        if i == assets.count - 1{
                            gettingAlbumF=false
                        }
                    }else{//on icloud
                        if i == assets.count - 1{
                            gettingAlbumF=false
                        }
                    }
                }
            }
        }else{
            albumExist=false
            gettingAlbumF=false
        }
    }
    func getAlbumStillList(){//最後のvideoを取得するまで待つ
        gettingAlbumF = true
        getAlbumStillList_sub()
        while gettingAlbumF == true{
            sleep(UInt32(0.1))
        }
    }
//    fileprivate var fetchResult = [PHAsset]()
    func loadPhotos() {
        let options = PHFetchOptions()
        options.sortDescriptors = [
            NSSortDescriptor(key: "creationDate", ascending: false)
        ]
        //fetchResult = PHAsset.fetchAssets(with: .image, options: options)
//        fetchResult = []
        stillAsset.removeAll()
        
        // 画像をすべて取得
        
        let assets: PHFetchResult = PHAsset.fetchAssets(with: .image, options: options)
        assets.enumerateObjects { (asset, index, stop) -> Void in
            let str = String(describing:asset)
            if str.contains("2400x1600")//vog
            {
                self.stillAsset.append(asset as PHAsset)
//                self.fetchResult.append(asset as PHAsset)
                print("stillAsset:",self.stillAsset.count)
            }
            
        }
        
    }
   
    func getAlbumStillList_sub(){
        //     let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        stillURL.removeAll()
        stillDate.removeAll()
        requestOptions.isSynchronous = true
        requestOptions.isNetworkAccessAllowed = false//これでもicloud上のvideoを取ってしまう
        requestOptions.deliveryMode = .highQualityFormat
        // アルバムをフェッチ
        let assetFetchOptions = PHFetchOptions()
        assetFetchOptions.predicate = NSPredicate(format: "title == %@", albumName)
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .smartAlbumVideos, options: assetFetchOptions)
        
        //アルバムが存在しない事もある？
        if (assetCollections.count > 0) {
            //同じ名前のアルバムは一つしかないはずなので最初のオブジェクトを使用
            let assetCollection = assetCollections.object(at:0)
            // creationDate降順でアルバム内のアセットをフェッチ
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
            let assets = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
            albumExist=true
            if assets.count == 0{
                gettingAlbumF=false
                albumExist=false
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            for i in 0..<assets.count{
                print("i:",i,assets.count)
                let asset=assets[i]
                if assets[i].duration == 0{//still -> duration==0
                    print("continue//still")
//                    print(assets[i].)
                }
                let date_sub = asset.creationDate
                let date = formatter.string(from: date_sub!)
                let duration = String(format:"%.1fs",asset.duration)
                let option = PHImageRequestOptions()

//                options.version = .original
                option.deliveryMode = .highQualityFormat

                
                PHImageManager.default().requestImage(for: asset,
                                                      targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight),
                                                      contentMode: .aspectFill,
                                                      options: option) { (image, info) in
//                    print(asset)
                
                    if let url = info?["PHImageFileURLKey"] as? URL {
                        print(url.lastPathComponent)
                        print(url.pathExtension)
                        self.stillURL.append(url)
                        self.stillDate.append(date + "(" + duration + ")")
                        if i == assets.count - 1{
                            self.gettingAlbumF=false
                        }
                    }else{
                        if i == assets.count - 1{
                            self.gettingAlbumF=false
                        }
                    }
                    
                
                
                
//                PHImageManager.default().requestAVAsset(forVideo:asset,
//                                                        options: options){ [self](asset:AVAsset?,audioMix, info:[AnyHashable:Any]?)->Void in
//
//                    if let urlAsset = asset as? AVURLAsset{//not on iCloud
//                        if assets[i].duration != 0{
//                            self.stillURL.append(urlAsset.url)
//                            self.stillDate.append(date + "(" + duration + ")")
//                        }
//                        if i == assets.count - 1{
//                            self.gettingAlbumF=false
//                        }
//                    }else{//on icloud
//                        if i == assets.count - 1{
//                            self.gettingAlbumF=false
//                        }
//                    }
                }
            }
        }else{
            albumExist=false
            gettingAlbumF=false
        }
    }
    /*
     @IBAction func eraseVideo(_ sender: Any) {
  //       videoAsset[videoCurrent]
         let requestOptions = PHImageRequestOptions()
         requestOptions.isSynchronous = true
         requestOptions.isNetworkAccessAllowed = false
         requestOptions.deliveryMode = .highQualityFormat //これでもicloud上のvideoを取ってしまう
         //アルバムをフェッチ
         let assetFetchOptions = PHFetchOptions()
         
         assetFetchOptions.predicate = NSPredicate(format: "title == %@", albumName)
         
         let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .smartAlbumVideos, options: assetFetchOptions)
 //        print("asset:",assetCollections.count)
         //アルバムが存在しない事もある？
         var dialogStatus:Int=0
         if (assetCollections.count > 0) {
             //同じ名前のアルバムは一つしかないはずなので最初のオブジェクトを使用
             let assetCollection = assetCollections.object(at:0)
             // creationDate降順でアルバム内のアセットをフェッチ
             let fetchOptions = PHFetchOptions()
             fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
             let assets = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
             let formatter = DateFormatter()
             formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
 //            var eraseAssetDate=assets[0].creationDate
 //            var eraseAssetPngNumber=0
             for i in 0..<assets.count{
                 let date_sub=assets[i].creationDate
                 let date = formatter.string(from:date_sub!)
 //                eraseAssetPngNumber=i+1
                 if videoDate[videoCurrent].contains(date){
                     if !assets[i].canPerform(.delete) {
                         return
                     }
                     var delAssets=Array<PHAsset>()
                     delAssets.append(assets[i])
                     if assets[i+1].duration==0{//pngが無くて、videoが選択されてない事を確認
                         delAssets.append(assets[i+1])//pngはその次に入っているはず
                     }
                     PHPhotoLibrary.shared().performChanges({
                         PHAssetChangeRequest.deleteAssets(NSArray(array: delAssets))
                     }, completionHandler: { success,error in//[self] _, _ in
                         if success==true{
                             dialogStatus = 1//YES
                         }else{
                             dialogStatus = -1//NO
                         }
                         // 削除後の処理
                     })
 //                    break
                 }
             }
         }
         while dialogStatus == 0{//dialogから抜けるまでは0
             sleep(UInt32(0.2))
         }
         if dialogStatus == 1{//yesで抜けた時
 //            removeFile(delFile: videoDate[videoCurrent] + "-gyro.csv")
             videoDate.remove(at: videoCurrent)
             videoURL.remove(at: videoCurrent)
             videoImg.remove(at: videoCurrent)
             videoDura.remove(at: videoCurrent)
             videoArrayCount -= 1
             videoCurrent -= 1
             showVideoIroiro(num: 0)
             if videoImg.count==0{
                 playButton.isEnabled=false
             }
         }
     }
     */
    
    
    
    
    func eraseVideo(number:Int) {
        dialogStatus=0
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.isNetworkAccessAllowed = false
        requestOptions.deliveryMode = .highQualityFormat //これでもicloud上のvideoを取ってしまう
        //アルバムをフェッチ
        let assetFetchOptions = PHFetchOptions()
        
        assetFetchOptions.predicate = NSPredicate(format: "title == %@", albumName)
        
        let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .smartAlbumVideos, options: assetFetchOptions)
//        print("asset:",assetCollections.count)
        //アルバムが存在しない事もある？
        
        if (assetCollections.count > 0) {
            //同じ名前のアルバムは一つしかないはずなので最初のオブジェクトを使用
            let assetCollection = assetCollections.object(at:0)
            // creationDate降順でアルバム内のアセットをフェッチ
            let fetchOptions = PHFetchOptions()
            fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
            let assets = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
//            var eraseAssetDate=assets[0].creationDate
//            var eraseAssetPngNumber=0
            for i in 0..<assets.count{
                let date_sub=assets[i].creationDate
                let date = formatter.string(from:date_sub!)
                if videoDate[number].contains(date){
                    if !assets[i].canPerform(.delete) {
                        return
                    }
                    var delAssets=Array<PHAsset>()
                    delAssets.append(assets[i])
                    
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.deleteAssets(NSArray(array: delAssets))
                    }, completionHandler: { [self] success,error in//[self] _, _ in
                        if success==true{
                            dialogStatus = 1//YES
                        }else{
                            dialogStatus = -1//NO
                        }
                        // 削除後の処理
                    })
//                    break
                }
            }
        }
    }
    func setSession(fps:Double){
        initSession(fps:fps)
    }
    func sessionRecStart(fps:Double){
        initSession(fps: fps)
        try? FileManager.default.removeItem(atPath: TempFilePath)
        let fileURL = NSURL(fileURLWithPath: TempFilePath)
        fileOutput.startRecording(to: fileURL as URL, recordingDelegate: self)
    }
    func recordStart(){
        try? FileManager.default.removeItem(atPath: TempFilePath)
        let fileURL = NSURL(fileURLWithPath: TempFilePath)
        fileOutput.startRecording(to: fileURL as URL, recordingDelegate: self)
    }
    func recordStop(){
        captureSession.stopRunning()//下行と入れ替えても動く
        fileOutput.stopRecording()
     }
    func setVideoFormat(desiredFps: Double)->Bool {
        var retF:Bool=false
        var fps:Double = 0
        // 取得したフォーマットを格納する変数
        var selectedFormat: AVCaptureDevice.Format! = nil
        // そのフレームレートの中で一番大きい解像度を取得する
        var maxWidth: Int32 = 0
        var maxFPS:Double=0
        // フォーマットを探る
//        var getDesiedformat:Bool=false
        for format in videoDevice!.formats {
            // フォーマット内の情報を抜き出す (for in と書いているが1つの format につき1つの range しかない)
//            if getDesiedformat==true{
//                break
//            }
            for range: AVFrameRateRange in format.videoSupportedFrameRateRanges {
                let description = format.formatDescription as CMFormatDescription    // フォーマットの説明
                let dimensions = CMVideoFormatDescriptionGetDimensions(description)  // 幅・高さ情報を抜き出す
                let width = dimensions.width
                fps = range.maxFrameRate
                if fps <= desiredFps && fps >= maxFPS && width >= maxWidth {
//                if fps == desiredFps && width >= maxWidth {
                    selectedFormat = format
                    maxWidth = width
                    maxFPS = fps
                    print(dimensions.width,dimensions.height,maxFPS)
                }//指定のFPS以下で、最高解像度
            }
        }
        print("selected:",selectedFormat.videoSupportedFrameRateRanges)
        //ipad pro 60 1920*1440
        //11 60 3840*2160 120 1920*1080
        //8  60 1440*1080
        //6s 60 1280*960
        //SE 30
//ipod touch 1280x720 1440*1080
//SE 960x540 1280x720 1920x1080
//11 192x144 352x288 480x360 640x480 1024x768 1280x720 1440x1080 1920x1080 3840x2160
//1280に設定すると上手く行く。合成のところには1920x1080で飛んでくるようだ。？
        // フォーマットが取得できていれば設定する
        if selectedFormat != nil {
            do {
                try videoDevice!.lockForConfiguration()
                videoDevice!.activeFormat = selectedFormat
                videoDevice!.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(maxFPS))
                videoDevice!.unlockForConfiguration()
                
                let description = selectedFormat.formatDescription as CMFormatDescription    // フォーマットの説明
                let dimensions = CMVideoFormatDescriptionGetDimensions(description)  // 幅・高さ情報を抜き出す
                let iCapNYSWidth = dimensions.width
                let iCapNYSHeight = dimensions.height
                print("フォーマット・フレームレートを設定 : \(maxFPS) fps・\(iCapNYSWidth) px x \(iCapNYSHeight) px")
                
                retF=true
            }
            catch {
//                print("フォーマット・フレームレートが指定できなかった")
                retF=false
            }
        }
        else {
//            print("指定のフォーマットが取得できなかった")
            retF=false
        }
        return retF
    }
    //    videoConnection.videoOrientation = .Portrait
    //    AVCaptureVideoOrientation.LandscapeRight.rawValue と同値
    //    AVCaptureVideoOrientation.landscapeRight.rawValue
    func initSession(fps:Double) {
        // セッション生成
        captureSession = AVCaptureSession()
        // 入力 : 背面カメラ
        videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        let videoInput = try! AVCaptureDeviceInput.init(device: videoDevice!)
        captureSession.addInput(videoInput)
        if setVideoFormat(desiredFps: fps) == false {
            print("フォーマット指定できなかった")
        }else{
            print("フォーマットが指定できた")
        }
        // ファイル出力設定
        //orientation.rawValue
        fileOutput = AVCaptureMovieFileOutput()
        captureSession.addOutput(fileOutput)
        let videoDataOuputConnection = fileOutput.connection(with: .video)
        let orientation = UIDevice.current.orientation
        videoDataOuputConnection!.videoOrientation = AVCaptureVideoOrientation(rawValue: AVCaptureVideoOrientation.landscapeRight.rawValue)!//AVCaptureVideoOrientation(rawValue: orientation.rawValue)!
//        videoDataOuputConnection!.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue)!
        // セッションを開始する (録画開始とは別)
        captureSession.startRunning()
        //手振れ補正はデフォルトがoff
        //        fileOutput.connections[0].preferredVideoStabilizationMode=AVCaptureVideoStabilizationMode.off
    }
    
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let soundUrl = URL(string:
                                "/System/Library/Audio/UISounds/end_record.caf"/*photoShutter.caf*/){
            AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundIdx)
            AudioServicesPlaySystemSound(soundIdx)
        }
         print("終了ボタン、最大を超えた時もここを通る")
        //         motionManager.stopDeviceMotionUpdates()//ここで止めたが良さそう。
        //         //        recordedFPS=getFPS(url: outputFileURL)
        //         //        topImage=getThumb(url: outputFileURL)
        //
        //         if timer?.isValid == true {
        //             timer!.invalidate()
        //    }
        //    let album = AlbumController(name:"fushiki")
        
        if albumExists()==true{
//            recordedFlag=true
            PHPhotoLibrary.shared().performChanges({ [self] in
                //let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: avAsset)
                let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)!
                let albumChangeRequest = PHAssetCollectionChangeRequest(for: getPHAssetcollection())
                let placeHolder = assetRequest.placeholderForCreatedAsset
                albumChangeRequest?.addAssets([placeHolder!] as NSArray)
                //imageID = assetRequest.placeholderForCreatedAsset?.localIdentifier
                print("file add to album")
            }) { [self] (isSuccess, error) in
                if isSuccess {
                    // 保存した画像にアクセスする為のimageIDを返却
                    //completionBlock(imageID)
                    print("success")
                    self.saved2album=true
                } else {
                    //failureBlock(error)
                    print("fail")
                    //                print(error)
                    self.saved2album=true
                }
                //            _ = try? FileManager.default.removeItem(atPath: self.TempFilePath)
            }
        }else{
            //上二つをunwindでチェック
            //アプリ起動中にアルバムを消したら、保存せずに戻る。
            //削除してもどこかにあるようで、参照URLは生きていて、再生できる。
        }
        while saved2album==false{
            sleep(UInt32(0.1))
        }
//        captureSession.stopRunning()
        //         performSegue(withIdentifier: "fromRecordToMain", sender: self)
    }
}
