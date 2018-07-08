//
//  CircleView.swift
//  Fushiki
//
//  Created by kuroda tatsuaki on 2018/07/07.
//  Copyright © 2018年 tatsuaki.kuroda. All rights reserved.
//

import Foundation
//
//  CircleView.swift
//  CircleView
//
//  Created by 寺尾正孝 on 2017/01/10.
//  Copyright © 2017年 寺尾正孝. All rights reserved.
//
import UIKit

@IBDesignable
class CircleView: UIView {
    
    // 塗りつぶし色
    @IBInspectable var fillColor: UIColor = UIColor.black
    
    // 枠線の色
    @IBInspectable var strokeColor: UIColor = UIColor.black
    
    // 枠線の幅
    @IBInspectable var strokeWidth: Float = 1.0
    
    override func draw(_ rect: CGRect) {
        // Viewに内接する円を塗りつぶしで描く
        self.drawFillCircle(rect: rect)
        
        // 線の50%がViewの外に出るので内接するために調整したCGRectを用意する
        let strokeRectSizeAdjustment = CGFloat(self.strokeWidth)
        let strokeRectSize = CGSize(width: rect.width - strokeRectSizeAdjustment, height: rect.height - strokeRectSizeAdjustment)
        let strokeRectPointAdjustment = strokeRectSizeAdjustment/2
        let strokeRectPoint = CGPoint(x: rect.origin.x + strokeRectPointAdjustment, y: rect.origin.y + strokeRectPointAdjustment)
        let strokeRect = CGRect(origin: strokeRectPoint, size: strokeRectSize)
        
        // Viewに内接する円を線で描く
        self.drawStrokeCircle(rect: strokeRect)
    }
    
    // 塗りつぶしで円を描く
    private func drawFillCircle(rect: CGRect) {
        // コンテキストの取得
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // 色の設定
        context.setFillColor(self.fillColor.cgColor)
        
        // 円を塗りつぶしで描く
        // 円は引数のCGRectに内接する
        context.fillEllipse(in: rect)
    }
    
    // 線で円を描く
    private func drawStrokeCircle(rect: CGRect) {
        // コンテキストの取得
        guard let context = UIGraphicsGetCurrentContext() else {
            return
        }
        
        // 色の設定
        context.setStrokeColor(self.strokeColor.cgColor)
        
        // 枠線の幅の設定
        context.setLineWidth(CGFloat(self.strokeWidth))
        
        // 円を線で描く
        // 円は引数のCGRectに内接するが50%がはみ出す
        context.strokeEllipse(in: rect)
    }
    
}
