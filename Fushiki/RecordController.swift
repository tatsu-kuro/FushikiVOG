//
//  RecordController.swift
//  Fushiki
//
//  Created by 黒田建彰 on 2021/01/11.
//  Copyright © 2021 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import AVFoundation
import Photos
class RecordController: NSObject, AVCaptureFileOutputRecordingDelegate {
    
    var videoDevice: AVCaptureDevice?
    var captureSession: AVCaptureSession!
    var fileOutput = AVCaptureMovieFileOutput()
    let TempFilePath: String = "\(NSTemporaryDirectory())temp.mp4"
    var soundIdx:SystemSoundID = 0
    func recordStart(){
        initSession(fps: 30)
        try? FileManager.default.removeItem(atPath: TempFilePath)
        let fileURL = NSURL(fileURLWithPath: TempFilePath)
        fileOutput.startRecording(to: fileURL as URL, recordingDelegate: self)
    }
    func recordStop(){
        fileOutput.stopRecording()
    }
    func setVideoFormat(desiredFps: Double)->Bool {
        var retF:Bool=false
        // 取得したフォーマットを格納する変数
        var selectedFormat: AVCaptureDevice.Format! = nil
        // そのフレームレートの中で一番大きい解像度を取得する
        var maxWidth: Int32 = 0
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
//                print(dimensions.width,dimensions.height)
                if desiredFps == range.maxFrameRate && width == 1280{//}>= maxWidth {
                    selectedFormat = format
                    maxWidth = width
 //                   getDesiedformat=true
                    print(range.maxFrameRate,dimensions.width,dimensions.height)
 //                   break
                }
            }
        }
//ipod touch 1280x720 1440*1080
//SE 960x540 1280x720 1920x1080
//11 192x144 352x288 480x360 640x480 1024x768 1280x720 1440x1080 1920x1080 3840x2160
//1280に設定すると上手く行く。合成のところには1920x1080で飛んでくるようだ。？
        // フォーマットが取得できていれば設定する
        if selectedFormat != nil {
            do {
                try videoDevice!.lockForConfiguration()
                videoDevice!.activeFormat = selectedFormat
                videoDevice!.activeVideoMaxFrameDuration = CMTimeMake(1, Int32(desiredFps))
                videoDevice!.unlockForConfiguration()
                
                let description = selectedFormat.formatDescription as CMFormatDescription    // フォーマットの説明
                let dimensions = CMVideoFormatDescriptionGetDimensions(description)  // 幅・高さ情報を抜き出す
                let iCapNYSWidth = dimensions.width
                let iCapNYSHeight = dimensions.height
                print("フォーマット・フレームレートを設定 : \(desiredFps) fps・\(iCapNYSWidth) px x \(iCapNYSHeight) px")
                
                retF=true
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
        return retF
    }
    func initSession(fps:Double) {
        // カメラ入力 : 背面カメラ
        videoDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front)
        let videoInput = try! AVCaptureDeviceInput.init(device: videoDevice!)

        if setVideoFormat(desiredFps: fps)==false{
            print("error******")
        }
        // AVCaptureSession生成
        captureSession = AVCaptureSession()
        captureSession.addInput(videoInput)
 
        // ファイル出力設定
        fileOutput = AVCaptureMovieFileOutput()
        captureSession.addOutput(fileOutput)
        
        let videoDataOuputConnection = fileOutput.connection(with: .video)
        let orientation = UIDevice.current.orientation
        videoDataOuputConnection!.videoOrientation = AVCaptureVideoOrientation(rawValue: orientation.rawValue)!
        // セッションを開始する (録画開始とは別)
        captureSession.startRunning()
    }
    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {
        if let soundUrl = URL(string:
                          "/System/Library/Audio/UISounds/end_record.caf"/*photoShutter.caf*/){
            AudioServicesCreateSystemSoundID(soundUrl as CFURL, &soundIdx)
            AudioServicesPlaySystemSound(soundIdx)
        }
        print("終了ボタン、最大を超えた時もここを通る")
        let album = AlbumController(name:"fushiki")
        PHPhotoLibrary.shared().performChanges({ [self] in
            //let assetRequest = PHAssetChangeRequest.creationRequestForAsset(from: avAsset)
            let assetRequest = PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: outputFileURL)!
//            let albumChangeRequest = PHAssetCollectionChangeRequest(for: (self.fushikiAlbum)!)
            let albumChangeRequest = PHAssetCollectionChangeRequest(for: album.getPHAssetcollection())
            let placeHolder = assetRequest.placeholderForCreatedAsset
            albumChangeRequest?.addAssets([placeHolder!] as NSArray)
            //imageID = assetRequest.placeholderForCreatedAsset?.localIdentifier
            print("file add to album")
        }) { [self] (isSuccess, error) in
            if isSuccess {
                // 保存した画像にアクセスする為のimageIDを返却
                //completionBlock(imageID)
                print("success")
//                self.saved2album=true
            } else {
                //failureBlock(error)
                print("fail")
                //                print(error)
//                self.saved2album=true
            }
            //            _ = try? FileManager.default.removeItem(atPath: self.TempFilePath)
        }
//        performSegue(withIdentifier: "fromRecordToMain", sender: self)
    }
}
