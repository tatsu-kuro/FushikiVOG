//
//  OpenCVWrapper.h
//  Fushiki
//
//  Created by 黒田建彰 on 2021/01/29.
//  Copyright © 2021 tatsuaki.Fushiki. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
@interface OpenCVWrapper : NSObject

-(double) matching:(UIImage *)wide_img narrow:(UIImage *)narrow_img x:(int *)x_ret y:(int *)y_ret;
-(double) matching_gray:(UIImage *)wide_img narrow:(UIImage *)narrow_img x:(int *)x_ret y:(int *)y_ret;

-(UIImage *)GrayScale:(UIImage *)input_img;
-(UIImage *)pixel2image:(UIImage *)input_img csv:(NSString *)gyroCSV;

@end
