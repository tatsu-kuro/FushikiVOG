//
//  MailViewController.swift
//  Fushiki
//
//  Created by 黒田建彰 on 2021/02/06.
//  Copyright © 2021 tatsuaki.Fushiki. All rights reserved.
//

import UIKit
import Photos
import AssetsLibrary
import MessageUI
class CheckBoxView: UIView {
    var selected = false
    init(frame: CGRect,selected: Bool) {
        super.init(frame:frame)
        self.selected = selected
        self.backgroundColor = UIColor.clear
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func draw(_ rect: CGRect) {
        let ovalColor:UIColor
        let ovalFrameColor:UIColor
        let checkColor:UIColor
        
//        let RectCheck = CGRectMake(5, 5, rect.width - 10, rect.height - 10)
        let RectCheck = CGRect(x:5,y:5,width:rect.width - 10,height:rect.height - 10)
        if self.selected {
            ovalColor = UIColor(red: 85/255, green: 185/255, blue: 1/255, alpha: 1)
            ovalFrameColor = UIColor.black
            checkColor = UIColor.white
        }else{
            ovalColor = UIColor(red: 150/255, green: 150/255, blue: 150/255, alpha: 0.2)
            ovalFrameColor = UIColor(red: 50/255, green: 50/255, blue: 50/255, alpha: 0.3)
            checkColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.5)
        }
        
        // 円 -------------------------------------
        let oval = UIBezierPath(ovalIn: RectCheck)
        
        // 塗りつぶし色の設定
        ovalColor.setFill()
        // 内側の塗りつぶし
        oval.fill()
        //枠の色
        ovalFrameColor.setStroke()
        //枠の太さ
        oval.lineWidth = 2
        // 描画
        oval.stroke()
        
        let xx = RectCheck.origin.x
        let yy = RectCheck.origin.y
        let width = RectCheck.width
        let height = RectCheck.height
        
        // チェックマークの描画 ----------------------
        let checkmark = UIBezierPath()
        //起点
        checkmark.move(to: CGPoint(x:xx + width / 6, y:yy + height / 2))
        //帰着点
        checkmark.addLine(to: CGPoint(x:xx + width / 3, y:yy + height * 7 / 10))
        checkmark.addLine(to: CGPoint(x:xx + width * 5 / 6, y:yy + height * 1 / 3))
        // 色の設定
        checkColor.setStroke()
        // ライン幅
        checkmark.lineWidth = 6
        // 描画
        checkmark.stroke()
    }
}
class CollectionViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout,UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    var reloadGoFlag:Bool = false
    
    @IBOutlet weak var mailButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    let album = CameraAlbumEtc(name:"Fushiki")
    var timer:Timer?
    
    @IBAction func onMailButton(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self
        present(picker, animated: true)
        self.present(picker, animated: true)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[.originalImage] as? UIImage {
            // imageView.image = selectedImage
        }
        self.dismiss(animated: true)
    }
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        self.dismiss(animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {

        return album.stillImage.count
    }
    @IBAction func addImageButtonAction(_ sender: Any) {
      
    }
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        let width: CGFloat = view.frame.width / 3 - 2
        let height: CGFloat = width
//        print("cgsize:*****")
        return CGSize(width: width, height: height)
    }
    fileprivate var imageManager = PHCachingImageManager()
    fileprivate var targetSize = CGSize.zero
    var actRow:Int = -1
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // "Cell" はストーリーボードで設定したセルのID
        let cell:UICollectionViewCell =
            collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                               for: indexPath)
        // Tag番号を使ってImageViewのインスタンス生成
        let imageCell = album.stillImage[indexPath.item]
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        // 画像配列の番号で指定された要素の名前の画像をUIImageとする
//        let cellImage = imageCell// UIImage(named: photos[indexPath.row])
        // UIImageをUIImageViewのimageとして設定
        imageView.image = imageCell.image
        var falseBox = CheckBoxView(frame: CGRect(x:40, y:20, width:30, height:30), selected: false)
        if indexPath.row == self.actRow {
            falseBox = CheckBoxView(frame: CGRect(x:40, y:20, width:30, height:30), selected: true)
        }
        cell.contentView.addSubview(falseBox)
        return cell
    }
    /*
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // "Cell" はストーリーボードで設定したセルのID
        let cell:UICollectionViewCell =
            collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                               for: indexPath)
        // Tag番号を使ってImageViewのインスタンス生成
        var imageCell:UIImageView?
        
        let photoAsset = album.stillAsset[indexPath.item]
        imageManager.requestImage(for: photoAsset, targetSize: targetSize, contentMode: .aspectFill, options: nil) { (image, info) -> Void in
            imageCell = UIImageView(image: image)
            imageCell!.frame.size = cell.frame.size
            imageCell!.contentMode = .scaleToFill //.scaleAspectFit// .scaleAspectFill
            imageCell!.clipsToBounds = false//true
        }
        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
        // 画像配列の番号で指定された要素の名前の画像をUIImageとする
//        let cellImage = imageCell// UIImage(named: photos[indexPath.row])
        // UIImageをUIImageViewのimageとして設定
        imageView.image = imageCell?.image
        var falseBox = CheckBoxView(frame: CGRect(x:40, y:20, width:30, height:30), selected: false)
        if indexPath.row == self.actRow {
            falseBox = CheckBoxView(frame: CGRect(x:40, y:20, width:30, height:30), selected: true)
        }
        cell.contentView.addSubview(falseBox)
        return cell
    }
    */
    func collectionView(collectionView: UICollectionView, didHighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItem(at: indexPath as IndexPath)!
        cell.backgroundColor = UIColor.clear // タップしているときの色にする
    }

    func collectionView(collectionView: UICollectionView, didUnhighlightItemAtIndexPath indexPath: NSIndexPath) {
        let cell = collectionView.cellForItem(at: indexPath as IndexPath)!
        cell.backgroundColor = UIColor.darkGray  // 元の色にする
    }
    
    //cellを選択した時
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let cell:UICollectionViewCell =
//            collectionView.dequeueReusableCell(withReuseIdentifier: "cell",for: indexPath)
        if actRow == indexPath.row {
            actRow = -1
        }else{
            actRow = indexPath.row
        }
        reloadGoFlag = true
//        let cell:UICollectionViewCell =
//            collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
//                                               for: indexPath)
//        // Tag番号を使ってImageViewのインスタンス生成
//        let imageCell = album.stillImage[indexPath.item]
//        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
//        // 画像配列の番号で指定された要素の名前の画像をUIImageとする
////        let cellImage = imageCell// UIImage(named: photos[indexPath.row])
//        // UIImageをUIImageViewのimageとして設定
//        imageView.image = imageCell.image
//        var falseBox = CheckBoxView(frame: CGRect(x:40, y:20, width:30, height:30), selected: true)
////        if indexPath.row == self.actRow {
////            falseBox = CheckBoxView(frame: CGRect(x:40, y:20, width:30, height:30), selected: true)
////        }
//        cell.contentView.addSubview(falseBox)
//
        
        
        
        
        
//        cell.backgroundColor = .red
////        cell.selectedBackgroundView = dateManager.cellSelectedBackgroundView(UIColor.lightGrayColor())
//        let imageCell = album.stillImage[indexPath.item]
//        let imageView = cell.contentView.viewWithTag(1) as! UIImageView
//        // 画像配列の番号で指定された要素の名前の画像をUIImageとする
////        let cellImage = imageCell// UIImage(named: photos[indexPath.row])
//        // UIImageをUIImageViewのimageとして設定
//        imageView.image = imageCell.image
////        var falseBox = CheckBoxView(frame: CGRect(x:40, y:20, width:30, height:30), selected: false)
////        if indexPath.row == self.actRow {
//           let falseBox = CheckBoxView(frame: CGRect(x:40, y:20, width:30, height:30), selected: true)
////        }
//        cell.contentView.addSubview(falseBox)
//        //       setButtons()
////
//        collectionView.reloadData()
        print(indexPath.row)
//        print(album.stillAsset.count)
    }
    
    func setButtons()
    {
        let ww=view.bounds.width
        let wh=view.bounds.height
        let bw=ww*0.9/7
        let bh=bw*170/440
        let sp=ww*0.1/10
        let by=wh-bh-sp
        print("setbuttons")
        
        //        defaultButton.frame=CGRect(x:bw*5+sp*7,y:by,width:bw,height:bh)
        exitButton.frame=CGRect(x:bw*6+sp*8,y:by,width:bw,height:bh)
        // Do any additional setup after loading the view.
    }
//    fileprivate let kCellReuseIdentifier = "Cell"
    fileprivate let kColumnCnt: Int = 1
    fileprivate let kCellSpacing: CGFloat = 2
    var stillImage = Array<UIImage>()
    @IBOutlet weak var exitButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        actRow=2
        if album.stillAsset.count == 0 {
        album.loadPhotos()
        album.getImages()
        }
        setButtons()
//        collectionView.delegate = self
        print(album.stillImage.count)
        timer = Timer.scheduledTimer(timeInterval: 0.5, target: self, selector: #selector(self.update), userInfo: nil, repeats: true)
    }
    @objc func update(tm: Timer) {
        if reloadGoFlag == true{
            reloadGoFlag = false
            collectionView.reloadData()
        }
    }
    
    func killTimer(){
        if timer?.isValid == true {
            timer!.invalidate()
        }
    }
}
