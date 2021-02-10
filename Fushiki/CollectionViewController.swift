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

class CollectionViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    let album = CameraAlbumEtc(name:"Fushiki")

    let photos = ["ett","sankaku","sikaku", "okp","okn"]
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        print("phots.count",photos.count)
        return album.stillAsset.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
       
        let width: CGFloat = view.frame.width / 3 - 2
        let height: CGFloat = width
        print("cgsize:*****")
        return CGSize(width: width, height: height)
    }
    fileprivate var imageManager = PHCachingImageManager()
    fileprivate var targetSize = CGSize.zero

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        // "Cell" はストーリーボードで設定したセルのID
        let testCell:UICollectionViewCell =
            collectionView.dequeueReusableCell(withReuseIdentifier: "cell",
                                               for: indexPath)
        // Tag番号を使ってImageViewのインスタンス生成
        var imageCell:UIImageView?
        
        let photoAsset = album.stillAsset[indexPath.item]
        imageManager.requestImage(for: photoAsset, targetSize: targetSize, contentMode: .aspectFill, options: nil) { (image, info) -> Void in
            imageCell = UIImageView(image: image)
            imageCell!.frame.size = testCell.frame.size
            imageCell!.contentMode = .scaleAspectFill
            imageCell!.clipsToBounds = true
        }
        
        let imageView = testCell.contentView.viewWithTag(1) as! UIImageView
        // 画像配列の番号で指定された要素の名前の画像をUIImageとする
        let cellImage = imageCell// UIImage(named: photos[indexPath.row])
        // UIImageをUIImageViewのimageとして設定
        imageView.image = cellImage?.image
        return testCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        print(indexPath.row)
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
    
    @IBOutlet weak var exitButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()
        album.loadPhotos()
        setButtons()
        collectionView.delegate = self
    }
}
