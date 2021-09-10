//
//  MailViewController.swift
//  Fushiki
//
//  Created by 黒田建彰 on 2021/02/06.
//  Copyright © 2021 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import AssetsLibrary
import MessageUI
class ImagePickerController: UIViewController,MFMailComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    @IBOutlet weak var exitButton: UIButton!
    @IBOutlet weak var mailButton: UIButton!
    var picker: UIImagePickerController!
    var button: UIButton!
    var mailImage:UIImage!
    @IBAction func onMailButton() {
        print("mailButton")
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        let str="\(formatter.string(from: Date())).jpg"
        self.startMailer(videoView:mailImage,imageName:str)
    }
    
    func startMailer(videoView:UIImage, imageName:String) {
        let mailViewController = MFMailComposeViewController()
  
        mailViewController.mailComposeDelegate = self
        mailViewController.setSubject("iPhone-VOG")
        let imageDataq = videoView.jpegData(compressionQuality: 1.0)
        mailViewController.addAttachmentData(imageDataq!, mimeType: "image/jpg", fileName: imageName)
        present(mailViewController, animated: true, completion: nil)
    }
  
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {//errorの時に通る
        
        switch result {
        case .cancelled:
            print("cancel")
        case .saved:
            print("save")
        case .sent:
            print("send")
        case .failed:
            print("fail")
        @unknown default:
            print("unknown error")
        }
        self.dismiss(animated: true, completion: nil)
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white

        picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = UIImagePickerController.SourceType.photoLibrary
        picker.allowsEditing = false // Whether to make it possible to edit the size etc after selecting the image
        // set picker's navigationBar appearance
        picker.view.backgroundColor = .white
        picker.navigationBar.isTranslucent = false
        picker.navigationBar.barTintColor = .blue
        picker.navigationBar.tintColor = .white
        picker.navigationBar.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white
        ] // Title color
        button = UIButton()
        button.addTarget(self, action: #selector(touchUpInside(_:)), for: UIControl.Event.touchUpInside)
        let size = view.frame.width * 0.48
        button.setTitle("", for: UIControl.State.normal)
        button.frame.size = CGSize(width: size, height: size)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28)
        button.center = view.center
        button.backgroundColor = .clear
        view.addSubview(button)
        touchUpInside(button)
        setButtons()
        self.setNeedsStatusBarAppearanceUpdate()
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    override var prefersStatusBarHidden: Bool {
        return true
    }
    func setButtons(){
        let album = CameraAlbumEtc()//name:"Fushiki")
        let ww:CGFloat=view.bounds.width
        let wh:CGFloat=view.bounds.height
        let sp=ww/120//間隙
        let bw=(ww-sp*10)/7//ボタン幅
        let bh=bw*170/440
        let by = wh - bh - sp
        album.setButtonProperty(mailButton,x: sp*2,y:by, w:bw,h:bh,UIColor.darkGray)
        album.setButtonProperty(exitButton,x: sp*8+bw*6,y:by, w:bw,h:bh,UIColor.darkGray)
        view.bringSubviewToFront(mailButton)
        view.bringSubviewToFront(exitButton)
    }
    @objc func touchUpInside(_ sender: UIButton) {
        // show picker modal
        present(picker, animated: true, completion: nil)
    }

    // MARK: ImageVicker Delegate Methods
    // called when image picked
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        if let editedImage:UIImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            button.setBackgroundImage(editedImage, for: .normal)
            mailImage=editedImage
            print("1:kkohadocchi")//sentaku no toki koko wo tooru
        } else if let originalImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            button.setBackgroundImage(originalImage, for: .normal)
            print("2:korehadocchi")//dokokawakaranai
        }
        dismiss(animated: true, completion: nil)
    }

    // called when cancel select image
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // close picker modal
        print("cancel")
//        mailButton.isEnabled=false//cancel の時はmailbuttonは効かなくする
        dismiss(animated: true, completion: nil)
        dismiss(animated: true, completion: nil)
    }
}
