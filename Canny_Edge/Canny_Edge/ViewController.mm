//
//  ViewController.m
//  Canny_Edge
//
//  Created by Sri Raghu Malireddi on 20/07/16.
//  Copyright © 2016 Sri Raghu Malireddi. All rights reserved.
//

#import "ViewController.h"

#ifdef __cplusplus
#include <opencv2/opencv.hpp>
#include <stdlib.h>
#endif

using namespace std;

@interface ViewController (){
    // Setup the view
    UIImageView *imageView_;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // Read in the image
    UIImage *image = [UIImage imageNamed:@"prince_book.jpg"];
    if (image == nil) cout << "Cannot read in the file prince_book.jpg!!" << endl;
    
    // Setup the display
    // Setup the your imageView_ view, so it takes up the entire App screen......
    imageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    // Important: add OpenCV_View as a subview
    [self.view addSubview:imageView_];
    
    // Ensure aspect ratio looks correct
    imageView_.contentMode = UIViewContentModeScaleAspectFit;
    
    // Another way to convert between cvMat and UIImage (using member functions)
    cv::Mat cvImage = [self cvMatFromUIImage:image];
    cv::Mat cvImage_r; cv::resize(cvImage, cvImage_r, cv::Size(cvImage.cols/6,cvImage.rows/6)); // reduce the image size for better edges
    cv::Mat gray; cv::cvtColor(cvImage_r, gray, CV_RGBA2GRAY); // Convert to grayscale
    cv::Mat display_im; cv::cvtColor(gray,display_im,CV_GRAY2BGR); // Get the display image
    
    //Code for Canny edge detection
    cv::Mat blur; cv::GaussianBlur(gray, blur, cv::Size(5,5), 1.2, 1.2);
    cv::Mat edges; cv::Canny(blur, edges, 55, 200);
    //cv::resize(edges, edges, cv::Size(cvImage.cols,cvImage.rows)); //reshape to original image size
    cv::cvtColor(edges, display_im, CV_GRAY2BGR);
    
    //Code for HoughLines detection
    cv::vector<cv::Vec2f> lines;
    cv::HoughLines(edges, lines, 1, CV_PI/180, 100);
    cout<<lines.size()<<endl;
    
    for(size_t i=0; i<lines.size(); i++){
        float rho = lines[i][0], theta = lines[i][1];
        cv::Point pt1,pt2;
        double a = cos(theta), b = sin(theta);
        double x0 = a*rho, y0 = b*rho;
        pt1.x = cvRound(x0 + 1000*(-b));
        pt1.y = cvRound(y0 + 1000*(a));
        pt2.x = cvRound(x0 - 1000*(-b));
        pt2.y = cvRound(y0 - 1000*(a));
        cv::line( display_im, pt1, pt2, cv::Scalar(0,0,255), 1, CV_AA);
    }
    
    
    
    // Switch colors to account for how UIImage and cv::Mat lay out their color channels differently
    cv::cvtColor(display_im, display_im, CV_BGRA2RGBA);
    
    // Finally setup the view to display
    imageView_.image = [self UIImageFromCVMat:display_im];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


// Member functions for converting from cvMat to UIImage
- (cv::Mat)cvMatFromUIImage:(UIImage *)image
{
    CGColorSpaceRef colorSpace = CGImageGetColorSpace(image.CGImage);
    CGFloat cols = image.size.width;
    CGFloat rows = image.size.height;
    
    cv::Mat cvMat(rows, cols, CV_8UC4); // 8 bits per component, 4 channels (color channels + alpha)
    
    CGContextRef contextRef = CGBitmapContextCreate(cvMat.data,                 // Pointer to  data
                                                    cols,                       // Width of bitmap
                                                    rows,                       // Height of bitmap
                                                    8,                          // Bits per component
                                                    cvMat.step[0],              // Bytes per row
                                                    colorSpace,                 // Colorspace
                                                    kCGImageAlphaNoneSkipLast |
                                                    kCGBitmapByteOrderDefault); // Bitmap info flags
    
    CGContextDrawImage(contextRef, CGRectMake(0, 0, cols, rows), image.CGImage);
    CGContextRelease(contextRef);
    
    return cvMat;
}
// Member functions for converting from UIImage to cvMat
-(UIImage *)UIImageFromCVMat:(cv::Mat)cvMat
{
    NSData *data = [NSData dataWithBytes:cvMat.data length:cvMat.elemSize()*cvMat.total()];
    CGColorSpaceRef colorSpace;
    
    if (cvMat.elemSize() == 1) {
        colorSpace = CGColorSpaceCreateDeviceGray();
    } else {
        colorSpace = CGColorSpaceCreateDeviceRGB();
    }
    
    CGDataProviderRef provider = CGDataProviderCreateWithCFData((__bridge CFDataRef)data);
    
    // Creating CGImage from cv::Mat
    CGImageRef imageRef = CGImageCreate(cvMat.cols,                                 //width
                                        cvMat.rows,                                 //height
                                        8,                                          //bits per component
                                        8 * cvMat.elemSize(),                       //bits per pixel
                                        cvMat.step[0],                            //bytesPerRow
                                        colorSpace,                                 //colorspace
                                        kCGImageAlphaNone|kCGBitmapByteOrderDefault,// bitmap info
                                        provider,                                   //CGDataProviderRef
                                        NULL,                                       //decode
                                        false,                                      //should interpolate
                                        kCGRenderingIntentDefault                   //intent
                                        );
    
    
    // Getting UIImage from CGImage
    UIImage *finalImage = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    CGDataProviderRelease(provider);
    CGColorSpaceRelease(colorSpace);
    
    return finalImage;
}


@end
