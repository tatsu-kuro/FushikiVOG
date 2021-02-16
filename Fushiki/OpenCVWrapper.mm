//
//  OpenCVWrapper.m
//  Fushiki
//
//  Created by 黒田建彰 on 2021/01/29.
//  Copyright © 2021 tatsuaki.Fushiki. All rights reserved.
//
#import <opencv2/opencv.hpp>
#import <opencv2/videoio.hpp>
#import <opencv2/video.hpp>
#import <opencv2/imgcodecs/ios.h>
#import "OpenCVWrapper.h"

@implementation OpenCVWrapper
-(double) matching:(UIImage *)wide_img narrow:(UIImage *)narrow_img x:(int *)x_ret y:(int *)y_ret
{
    cv::Mat wide_mat;
    cv::Mat narrow_mat;
    cv::Mat wide_gray_mat;
    cv::Mat narrow_gray_mat;
        cv::Mat return_mat;
        UIImageToMat(wide_img, wide_mat);
        UIImageToMat(narrow_img, narrow_mat);
//    cv::cvtColor(wide_mat,wide_gray_mat,CV_BGR2GRAY);
//    cv::cvtColor(narrow_mat,wide_gray_mat,CV_BGR2GRAY);

        // テンプレートマッチング
//        cv::cvtColor(wide_mat, wide_mat, CV_BGRA2GRAY);
//        cv::cvtColor(narrow_mat,narrow_mat,CV_BGR2GRAY);
          try
        {
            cv::matchTemplate(wide_mat, narrow_mat, return_mat, CV_TM_CCOEFF_NORMED);
           // ...
        }
        catch( cv::Exception& e )
        {
          //  const char* err_msg = e.what();
            return -2.0;
        }
        
        // 最大のスコアの場所を探す
        cv::Point max_pt;
        double maxVal;
        cv::minMaxLoc(return_mat, NULL, &maxVal, NULL, &max_pt);
        *x_ret = max_pt.x;
        *y_ret = max_pt.y;
        return maxVal;//恐らく見つかった時は　0.7　より大の模様
}
-(UIImage *)GrayScale:(UIImage *)image{
    // 変換用Matの宣言
    cv::Mat image_mat;
    cv::Mat gray_mat;
    // input_imageをcv::Mat型へ変換
    UIImageToMat(image, image_mat);
    cv::cvtColor(image_mat,gray_mat,CV_BGR2GRAY);
    image = MatToUIImage(gray_mat);
    return image;
}

-(UIImage *)pixel2image:(UIImage *)inputImg csv:(NSString *)gyroCSV{
    // 変換用Matの宣言
    int rows=inputImg.size.width;
    int cols=inputImg.size.height;
    int rgb[240*60*6];
    int cnt=0;

    NSArray *arr = [gyroCSV componentsSeparatedByString:@","];
    
    for(int i=0;i<arr.count-1;i++){
        rgb[i]=[arr[i] intValue];
    }
    cv::Mat inputMat;
    cv::Mat grayMat;
    UIImageToMat(inputImg, inputMat);
    //int step = inputMat.step;
    for (int row = 0; row < rows; row++) {//rows
        for (int col = 0; col <cols; col++) {//cols
            if(cnt<arr.count-1){
                int xy=row * cols * 4 + col * 4;
                // Blue
                inputMat.data[xy+0]=1;
                if (rgb[cnt]<0){
                    inputMat.data[xy+0]=0;
                    rgb[cnt]=-rgb[cnt];
                }
                //green
                inputMat.data[xy + 1] = rgb[cnt]/256;
                // red
                inputMat.data[xy + 2] = rgb[cnt]%256;
                //Reserved
                inputMat.data[xy + 3] = 255;
                cnt ++;
            }else{
                break;
            }
        }
        if (!(cnt<arr.count-1)){
            break;
        }
    }
    putText(inputMat,"GyroData",cvPoint(10,cols*3/5),cv::FONT_HERSHEY_SIMPLEX,4,cvScalar(0,0,0),15,CV_AA);
    inputImg = MatToUIImage(inputMat);
    return inputImg;
}
@end
