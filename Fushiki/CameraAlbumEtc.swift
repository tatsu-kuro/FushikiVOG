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
extension PHAsset {
    func getURL(completionHandler : @escaping ((_ responseURL : URL?) -> Void)){
        if self.mediaType == .image {
            let options: PHContentEditingInputRequestOptions = PHContentEditingInputRequestOptions()
            options.canHandleAdjustmentData = {(adjustmeta: PHAdjustmentData) -> Bool in
                return true
            }
            self.requestContentEditingInput(with: options, completionHandler: {(contentEditingInput: PHContentEditingInput?, info: [AnyHashable : Any]) -> Void in
                completionHandler(contentEditingInput!.fullSizeImageURL as URL?)
            })
        } else if self.mediaType == .video {
            let options: PHVideoRequestOptions = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: self, options: options, resultHandler: {(asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {
                    let localVideoUrl: URL = urlAsset.url as URL
                    completionHandler(localVideoUrl)
                } else {
                    completionHandler(nil)
                }
            })
        }
    }
}
class CameraAlbumEtc: NSObject, AVCaptureFileOutputRecordingDelegate{
    var videoDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession!
    var fileOutput = AVCaptureMovieFileOutput()
    let TempFilePath: String = "\(NSTemporaryDirectory())temp.mp4"
    let tempFilePath: String = "\(NSTemporaryDirectory())temp.mp4"
       let tempFileURL = URL(string: "\(NSTemporaryDirectory())temp.mp4")

    var soundIdx:SystemSoundID = 0
    var saved2album:Bool = false
    var albumName:String = "Fushiki"
    var videoDate = Array<String>()
    var videoURL = Array<URL>()
    var videoIdentifier = Array<String>()
    var videoIdentifierDate = Array<String>()
    var videoAlbumAssets = Array<PHAsset>()

    var stillDate = Array<String>()
    var stillURL = Array<URL>()
    var stillAsset = Array<PHAsset>()
    var stillImage = Array<UIImageView>()
    var albumExistFlag:Bool = false
    var dialogStatus:Int=0
    var fpsCurrent:Int=0
    var cameraMode:Int=0
//    init(name: String) {
//        // 全てのプロパティを初期化する前にインスタンスメソッドを実行することはできない
//        self.albumName = "Fushiki"//name
//    }
    //ジワーッと文字を表示するため
    func updateRecClarification(tm: Int)->CGFloat {
        var cnt=tm%40
        if cnt>19{
            cnt = 40 - cnt
        }
        var alpha=CGFloat(cnt)*0.9/20.0//少し目立たなくなる
        alpha += 0.05
        return alpha
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
    var gettingAlbumF:Bool=false
    func getAlbumList()->Bool{//最後のvideoを取得するまで待つ
        if gettingAlbumF == true{
            return false
        }
        gettingAlbumF = true
        getAlbumList_sub()
        while gettingAlbumF == true{
            sleep(UInt32(0.1))
        }
        return true
    }
/*    func getAlbumList_sub1(){
        //     let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        videoURL.removeAll()
        videoDate.removeAll()
        videoIdentifier.removeAll()
        videoIdentifierDate.removeAll()
        requestOptions.isSynchronous = true
        requestOptions.isNetworkAccessAllowed = true//これでもicloud上のvideoを取ってしまう
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
            albumExistFlag=true
            if assets.count == 0{
                gettingAlbumF=false
                albumExistFlag=false
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            for i in 0..<assets.count{
                let asset=assets[i]
//                print(asset)
                let date_sub = asset.creationDate
                let date = formatter.string(from: date_sub!)
                let duration = String(format:"%.1fs",asset.duration)
                let options=PHVideoRequestOptions()
                videoIdentifier.append(asset.localIdentifier)
                videoIdentifierDate.append(date + "(" + duration + ")")
                options.version = .original
//                asset.getURL(completionHandler: <#T##((URL?) -> Void)##((URL?) -> Void)##(URL?) -> Void#>)
//                var url=getURL(ofPhotoWith: asset)
//                DispatchQueue.global(qos: .default).async{
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
//                }
            }
        }else{
            albumExistFlag=false
            gettingAlbumF=false
        }
    }*/
    func getAlbumList_sub(){
        //     let imgManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        videoURL.removeAll()
        videoDate.removeAll()
        videoIdentifier.removeAll()
        videoIdentifierDate.removeAll()

        requestOptions.isSynchronous = true
        requestOptions.isNetworkAccessAllowed = true//これでもicloud上のvideoを取ってしまう
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
            albumExistFlag=true
            if assets.count == 0{
                gettingAlbumF=false
                albumExistFlag=false
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            
            for i in 0..<assets.count{
                let asset=assets[i]
//                print(asset)
                let date_sub = asset.creationDate
                let date = formatter.string(from: date_sub!)
                let duration = String(format:"%.1fs",asset.duration)
                let options=PHVideoRequestOptions()
                if asset.duration>0{
                    videoIdentifier.append(asset.localIdentifier)
                    videoIdentifierDate.append(date + "(" + duration + ")")
//                    print(videoIdentifier.last)
                }
                options.version = .original
//                asset.getURL(completionHandler: <#T##((URL?) -> Void)##((URL?) -> Void)##(URL?) -> Void#>)
//                var url=getURL(ofPhotoWith: asset)
//                DispatchQueue.global(qos: .default).async{
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
//                }
            }
        }else{
            albumExistFlag=false
            gettingAlbumF=false
        }
    }
    func getAlbumAssets()->Int{
           let requestOptions = PHImageRequestOptions()
           videoAlbumAssets.removeAll()
           videoURL.removeAll()
           videoDate.removeAll()
           requestOptions.isSynchronous = true
           requestOptions.isNetworkAccessAllowed = true//これでもicloud上のvideoを取ってしまう
           requestOptions.deliveryMode = .highQualityFormat
           // アルバムをフェッチ
           let assetFetchOptions = PHFetchOptions()
           assetFetchOptions.predicate = NSPredicate(format: "title == %@", albumName)
           let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .smartAlbumVideos, options: assetFetchOptions)
           if (assetCollections.count > 0) {//アルバムが存在しない時
               //同じ名前のアルバムは一つしかないはずなので最初のオブジェクトを使用
               let assetCollection = assetCollections.object(at:0)
               // creationDate降順でアルバム内のアセットをフェッチ
               let fetchOptions = PHFetchOptions()
               fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
               let assets = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
               let formatter = DateFormatter()
               formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
               for i in 0..<assets.count{
                   let asset=assets[i]
                   if asset.duration>0{//静止画を省く
                       videoAlbumAssets.append(asset)
                       videoURL.append(tempFileURL!)
                       
                       let date_sub = asset.creationDate
                       let date = formatter.string(from: date_sub!)
                       let duration = String(format:"%.1fs",asset.duration)
                       videoDate.append(date + "(" + duration + ")")
                   }
               }
               return videoAlbumAssets.count
           }
           return 0
       }
   //     func getAlbumIdentifiers()->Bool{
   //         let requestOptions = PHImageRequestOptions()
   //         videoIdentifier.removeAll()
   //         videoIdentifierDate.removeAll()
   //         videoURL.removeAll()
   //         requestOptions.isSynchronous = true
   //         requestOptions.isNetworkAccessAllowed = true//これでもicloud上のvideoを取ってしまう
   //         requestOptions.deliveryMode = .highQualityFormat
   //         // アルバムをフェッチ
   //         let assetFetchOptions = PHFetchOptions()
   //         assetFetchOptions.predicate = NSPredicate(format: "title == %@", albumName)
   //         let assetCollections = PHAssetCollection.fetchAssetCollections(with: .album, subtype: .smartAlbumVideos, options: assetFetchOptions)
   //         if (assetCollections.count > 0) {//アルバムが存在しない時
   //             //同じ名前のアルバムは一つしかないはずなので最初のオブジェクトを使用
   //             let assetCollection = assetCollections.object(at:0)
   //             // creationDate降順でアルバム内のアセットをフェッチ
   //             let fetchOptions = PHFetchOptions()
   //             fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
   //             let assets = PHAsset.fetchAssets(in: assetCollection, options: fetchOptions)
   //             let formatter = DateFormatter()
   //             formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
   //
   //             for i in 0..<assets.count{
   //                 let asset=assets[i]
   //                 let date_sub = asset.creationDate
   //                 let date = formatter.string(from: date_sub!)
   //                 let duration = String(format:"%.1fs",asset.duration)
   // //                let options=PHVideoRequestOptions()
   //                 if asset.duration>0{//静止画を省く
   //                     videoIdentifier.append(asset.localIdentifier)
   //                     videoIdentifierDate.append(date + "(" + duration + ")")
   //                     videoURL.append(tempFileURL!)//取り敢えずのURLを登録しておく
   //                 }
   //             }
   //             if assets.count>0{
   // //                albumExistFlag=true
   //                 return true
   //             }else{
   // //                albumExistFlag=false
   //                 return false
   //             }
   //         }else{
   //             return false
   //         }
   //     }
        var settingUrlFlag = true
        func setURLfromIdentifier(localID:[String],num:Int){
            let asset = PHAsset.fetchAssets(withLocalIdentifiers: localID, options: nil).object(at: num)
            let options = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { [self] (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {//on iphone?
                    let localVideoUrl = urlAsset.url as URL
                    videoURL[num]=localVideoUrl
                   
                    if num == videoURL.count - 1{
                        print("seturlfromidentifier:",videoURL.count,num)
                        self.settingUrlFlag = false
                    }
                }else{//on cloud?
                    videoURL[num]=tempFileURL!// URL(string: TempFilePath)
                    if num == videoURL.count - 1{
                        self.settingUrlFlag = false
                    }
                }
            }
        }
        var setURLfromPHAssetFlag:Bool=false
        var getURL:URL?
        func getURLfromPHAsset(asset:PHAsset)->URL{
            setURLfromPHAssetFlag=false
            setURLfromPHAsset(asset: asset)
            while setURLfromPHAssetFlag == false{
                sleep(UInt32(0.1))
            }
            return getURL!
        }
        func setURLfromPHAsset(asset:PHAsset){
    //        let asset = PHAsset.fetchAssets(withLocalIdentifiers: localID, options: nil).object(at: num)
            let options = PHVideoRequestOptions()
            options.version = .original
            PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { [self] (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                if let urlAsset = asset as? AVURLAsset {//on iphone?
                    let localVideoUrl = urlAsset.url as URL
                    getURL = localVideoUrl
                    setURLfromPHAssetFlag=true
                }else{//on cloud?
                    getURL=tempFileURL!// URL(string: tempFilePath)
                    setURLfromPHAssetFlag=true
                }
            }
        }
    /*
    
    if let asset = PHAsset.fetchAssets(withLocalIdentifiers: [ここにlocalID], options: nil).firstObject {
        let options = PHVideoRequestOptions()
        options.version = .original
        PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
            if let urlAsset = asset as? AVURLAsset {
                let localVideoUrl = urlAsset.url as URL
                print(localVideoUrl) // ここで取れる？
            }
        }
    }
*/
//    func getURL(ofPhotoWith mPhasset: PHAsset) -> URL{
//        let options: PHVideoRequestOptions = PHVideoRequestOptions()
//        options.deliveryMode = .highQualityFormat
//        options.version = .current
//        var urlStr2 = URL(string:"")
//
//        let semaphore = DispatchSemaphore(value: 0)
//        PHImageManager.default().requestAVAsset(forVideo: mPhasset, options: options, resultHandler: { (asset, audioMix, info) in
//
//            if let tokenStr = info?["PHImageFileSandboxExtensionTokenKey"] as? String {
//                let tokenKeys = tokenStr.components(separatedBy: ";")
//                let urlStr = tokenKeys.filter { $0.contains("/private/var/mobile/Media") }.first
//                urlStr2 = URL(string:urlStr!)
//                if let urlStr = urlStr {
//                    if let url = URL(string: urlStr) {
//                        print(url.lastPathComponent)
//                        print(url.pathExtension)
//                    }
//                }
//            }
//            defer {semaphore.signal() }
//        })
//        semaphore.wait(timeout: DispatchTime.distantFuture)
//        return urlStr2!
//    }
//    var appendURLArray = Array<URL>()
    func printURLArrayFirst(localID:[String]){
        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: localID, options: nil).firstObject {
                  let options = PHVideoRequestOptions()
                  options.version = .original
                  PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
                      if let urlAsset = asset as? AVURLAsset {
                          let localVideoUrl = urlAsset.url as URL
//                        self.appendURLArray.append(localVideoUrl)//localVideoUrl)
                          print(localVideoUrl) // ここで取れる？
                      }
                  }
              }
        
        
        
        
        
//
//
//        if let asset = PHAsset.fetchAssets(withLocalIdentifiers: localID, options: nil).firstObject {
//            let options = PHVideoRequestOptions()
//            options.version = .original
//            PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { [self] (asset: AVAsset?, audioMix: AVAudioMix?, info: [AnyHashable : Any]?) -> Void in
//                if let urlAsset = asset as? AVURLAsset {
//                    let localVideoUrl = urlAsset.url as URL
//                    appendURLArray.append(localVideoUrl) // ここで取れる？
//                    //return urlAsset.url
//                }
//            }
//        }
    }
    func setZoom(level:Float){//ledとなっているので要変更！！！
        if cameraMode==2{
            return
        }
        if let device = videoDevice {
        do {
            try device.lockForConfiguration()
                device.ramp(
                    toVideoZoomFactor: (device.minAvailableVideoZoomFactor) + CGFloat(level) * ((device.maxAvailableVideoZoomFactor) - (device.minAvailableVideoZoomFactor)),
                    withRate: 30.0)
            device.unlockForConfiguration()
            } catch {
                print("Failed to change zoom.")
            }
        }
    }
    
    func setFocus(focus:Float){//focus 0:最接近　0-1.0
        if cameraMode==2{
            return
        }
        if let device = videoDevice {
            do {
                try! device.lockForConfiguration()
                if device.isFocusPointOfInterestSupported{
                    //Add Focus on Point
                    device.focusMode = .locked
                    device.setFocusModeLocked(lensPosition: focus, completionHandler: { _ in
                        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                            device.unlockForConfiguration()
                        })
                    })
                }
                device.unlockForConfiguration()
            }
        }
    }

    fileprivate var imageManager = PHCachingImageManager()
    fileprivate var targetSize = CGSize.zero
    func getImages(){
        stillImage.removeAll()
        //        var imageCell:UIImageView?
        for i in 0 ..< stillAsset.count{
            let photoAsset = stillAsset[i]
            imageManager.requestImage(for: photoAsset, targetSize: targetSize, contentMode: .aspectFill, options: nil) { [self] (image, info) -> Void in
                            let oneImage = UIImageView(image: image)
                stillImage.append(oneImage)
                
                //            imageCell!.frame.size = cell.frame.size
                //            imageCell!.contentMode = .scaleToFill //.scaleAspectFit// .scaleAspectFill
                //            imageCell!.clipsToBounds = false//true
            }
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
//                self.stillImage.append((asset as PHAsset).i
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
            albumExistFlag=true
            if assets.count == 0{
                gettingAlbumF=false
                albumExistFlag=false
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
                }
            }
        }else{
            albumExistFlag=false
            gettingAlbumF=false
        }
    }
    
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

    func recordStart(){
        if cameraMode==2{
            return
        }
        try? FileManager.default.removeItem(atPath: TempFilePath)
        let fileURL = NSURL(fileURLWithPath: TempFilePath)
        fileOutput.startRecording(to: fileURL as URL, recordingDelegate: self)
    }
    func recordStop(){
        if cameraMode==2{
            return
        }
        captureSession.stopRunning()//下行と入れ替えても動く
        fileOutput.stopRecording()
     }
    func stopRunning(){
        if cameraMode==2{
            return
        }
        captureSession.stopRunning()
    }

    func initSession(camera:Int,bounds:CGRect,cameraView:UIImageView) {
        // セッション生成
        cameraMode=camera
        if cameraMode==2{
            return
        }
        captureSession = AVCaptureSession()
        // 入力 : 背面カメラ
        if camera==0{
        videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        }else{
            videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back)
        }
        let videoInput = try! AVCaptureDeviceInput.init(device: videoDevice!)
        captureSession.addInput(videoInput)

        if switchFormat(desiredFps: 240.0)==false{
            if switchFormat(desiredFps: 120.0)==false{
                if switchFormat(desiredFps: 60.0)==false{
                    if switchFormat(desiredFps: 30.0)==false{
                        print("set fps error")
                    }
                }
            }
        }
//        print("fps:",fpsCurrent)
        // ファイル出力設定
        //orientation.rawValue
        fileOutput = AVCaptureMovieFileOutput()
        captureSession.addOutput(fileOutput)
        let videoDataOuputConnection = fileOutput.connection(with: .video)
        videoDataOuputConnection!.videoOrientation = AVCaptureVideoOrientation(rawValue: AVCaptureVideoOrientation.landscapeRight.rawValue)!
        if bounds.width != 0{//previewしない時は、bounds.width==0とする
            let videoLayer : AVCaptureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoLayer.frame = bounds
            videoLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill//無くても同じ
            videoLayer.connection!.videoOrientation = .landscapeRight//　orientation
            cameraView.layer.addSublayer(videoLayer)
        }
        // セッションを開始する (録画開始とは別)
        captureSession.startRunning()
        //手振れ補正はデフォルトがoff
        //        fileOutput.connections[0].preferredVideoStabilizationMode=AVCaptureVideoStabilizationMode.off
    }
 
    func switchFormat(desiredFps: Double)->Bool {
        // セッションが始動しているかどうか
        var retF:Bool=false
        let isRunning = captureSession.isRunning
        
        // セッションが始動中なら止める
        if isRunning {
            print("isrunning")
            captureSession.stopRunning()
        }
        
        // 取得したフォーマットを格納する変数
        var selectedFormat: AVCaptureDevice.Format! = nil
        // そのフレームレートの中で一番大きい解像度を取得する
        var maxWidth: Int32 = 0
        
        // フォーマットを探る
        for format in videoDevice!.formats {
            // フォーマット内の情報を抜き出す (for in と書いているが1つの format につき1つの range しかない)
            for range: AVFrameRateRange in format.videoSupportedFrameRateRanges {
                let description = format.formatDescription as CMFormatDescription    // フォーマットの説明
                let dimensions = CMVideoFormatDescriptionGetDimensions(description)  // 幅・高さ情報を抜き出す
                let width = dimensions.width
                if desiredFps == range.maxFrameRate && width >= maxWidth {
                    selectedFormat = format
                    maxWidth = width
                }
            }
        }
        fpsCurrent=0
        // フォーマットが取得できていれば設定する
        if selectedFormat != nil {
            do {
                try videoDevice!.lockForConfiguration()
                videoDevice!.activeFormat = selectedFormat
                videoDevice!.activeVideoMinFrameDuration = CMTimeMake(value: 1, timescale: Int32(desiredFps))
                videoDevice!.activeVideoMaxFrameDuration = CMTimeMake(value: 1, timescale: Int32(desiredFps))
                videoDevice!.unlockForConfiguration()
                print("フォーマット・フレームレートを設定 : \(desiredFps) fps・\(maxWidth) px")
                retF=true
                fpsCurrent=Int(desiredFps)
            }
            catch {
                print("フォーマット・フレームレートが指定できなかった")
                retF=false
            }
        }
        else {
            print("指定のフォーマットが取得できなかった")
            retF=false
        }
        // セッションが始動中だったら再開する
        if isRunning {
            captureSession.startRunning()
        }
        return retF
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
    func setLabelProperty(_ label:UILabel,x:CGFloat,y:CGFloat,w:CGFloat,h:CGFloat,_ color:UIColor){
        label.frame = CGRect(x:x, y:y, width: w, height: h)
        label.layer.borderColor = UIColor.black.cgColor
        label.layer.borderWidth = 1.0
        label.layer.masksToBounds = true
        label.layer.cornerRadius = 5
        label.backgroundColor = color
    }
    //button.backgroundColor = color
    func setButtonProperty(_ button:UIButton,x:CGFloat,y:CGFloat,w:CGFloat,h:CGFloat,_ color:UIColor){
        button.frame   = CGRect(x:x, y:y, width: w, height: h)
        button.layer.borderColor = UIColor.black.cgColor
        button.layer.borderWidth = 1.0
        button.layer.cornerRadius = 5
        button.backgroundColor = color
    }
    func getUserDefaultInt(str:String,ret:Int) -> Int{
        if (UserDefaults.standard.object(forKey: str) != nil){//keyが設定してなければretをセット
            return UserDefaults.standard.integer(forKey:str)
        }else{
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }
    func getUserDefaultBool(str:String,ret:Bool) -> Bool{
        if (UserDefaults.standard.object(forKey: str) != nil){
            return UserDefaults.standard.bool(forKey: str)
        }else{//keyが設定してなければretをセット
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }
    func getUserDefaultFloat(str:String,ret:Float) -> Float{
        if (UserDefaults.standard.object(forKey: str) != nil){
            return UserDefaults.standard.float(forKey: str)
        }else{//keyが設定してなければretをセット
            UserDefaults.standard.set(ret, forKey: str)
            return ret
        }
    }
    func setLedLevel(level:Float){
        if cameraMode==2{
            return
        }
        if let device = videoDevice{
            do {
                if device.hasTorch {
                    do {
                        // torch device lock on
                        try device.lockForConfiguration()
                        
                        if (level > 0.0){
                              do {
                                try device.setTorchModeOn(level: level)
                            } catch {
                                print("error")
                            }
                            
                        } else {
                            // flash LED OFF
                            // 注意しないといけないのは、0.0はエラーになるのでLEDをoffさせます。
                            device.torchMode = AVCaptureDevice.TorchMode.off
                        }
                        // torch device unlock
                        device.unlockForConfiguration()
                        
                    } catch {
                        print("Torch could not be used")
                    }
                }
            }
        }
    }
}
