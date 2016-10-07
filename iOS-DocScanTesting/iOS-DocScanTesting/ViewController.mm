//
//  ViewController.m
//  iOS-DocScanTesting
//
//  Created by Sri Raghu Malireddi on 19/09/16.
//  Copyright © 2016 Sri Raghu Malireddi. All rights reserved.
//

#import "ViewController.h"

#ifdef __cplusplus
#import <opencv2/opencv.hpp>
#import "opencv2/highgui/ios.h"
#endif

// Include iostream and std namespace so we can mix C++ code in here
#include <iostream>
using namespace std;
using namespace cv;

const int WIDTH_A4 = 1654, HEIGHT_A4 = 2339;
vector<cv::Point2f> SCAN_A4,PIC_PAPER;
Mat DOCUMENT = Mat::zeros(HEIGHT_A4,WIDTH_A4,CV_8UC3);
const Scalar GREEN = Scalar(0,255,0);

@interface ViewController () {
    // Setup the view
    UIImageView *imageView_;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 1. Setup the your imageView_ view, so it takes up the entire App screen......
    imageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    imageView_.contentMode = UIViewContentModeScaleAspectFit;
    
    // 2. Important: add OpenCV_View as a subview
    [self.view addSubview:imageView_];
    
    // 3.Read in the image (of the famous Lena)
    UIImage *image = [UIImage imageNamed:@"page.jpg"];
    if(image != nil) imageView_.image = image; // Display the image if it is there....
    else cout << "Cannot read in the file" << endl;
    
    // 4. Next convert to a cv::Mat
    Mat cvImage; UIImageToMat(image, cvImage);
    Mat gray; cvtColor(cvImage,gray, CV_BGRA2GRAY);
    blur(gray,gray,cv::Size(3,3));
    Mat edge; Canny(gray, edge, 50, 255);
    
    vector<vector<cv::Point> > contours, rectContours;
    findContours(edge, contours, CV_RETR_LIST, CV_CHAIN_APPROX_SIMPLE);
    
    cout<<contours.size()<<endl;
    RNG rng(12345);
    Mat drawing = Mat::zeros( edge.size(), CV_8UC3 );
    for( int i = 0; i< contours.size(); i++ )
    {
        Scalar color = Scalar( rng.uniform(0, 255), rng.uniform(0,255), rng.uniform(0,255) );
        vector<Vec4i> hierarchy; drawContours( drawing, contours, i, color, 2, 8, hierarchy, 0, cv::Point() );
    }
    imageView_.image = MatToUIImage(drawing); double maxArea = 0;vector<cv::Point> paper;
    for(int i=0; i<contours.size();i++) {
        double peri = arcLength(contours[i], true);
        vector<cv::Point> approx; approxPolyDP(contours[i], approx, 0.02*peri, true);
        if(approx.size()==4) {
            double approxArea = contourArea(approx);
            if(approxArea>maxArea) {
                maxArea = approxArea;
                paper = approx;
            }
        }
    }
    rectContours.push_back(paper);
    cout<<rectContours.size()<<endl;
    vector<Vec4i> hierarchy; drawContours( cvImage, rectContours, 0, GREEN, 2, 8, hierarchy, 0, cv::Point());
    imageView_.image = MatToUIImage(cvImage);
    
    struct sortY {
        bool operator() (cv::Point pt1, cv::Point pt2) { return (pt1.y < pt2.y);}
    } mySortY;
    struct sortX {
        bool operator() (cv::Point pt1, cv::Point pt2) { return (pt1.x < pt2.x);}
    } mySortX;
    cout<<paper[0]<<paper[1]<<paper[2]<<paper[3]<<endl;
    std::sort(paper.begin(),paper.end(),mySortY);
    cout<<paper[0]<<paper[1]<<paper[2]<<paper[3]<<endl;
    std::sort(paper.begin(),paper.begin()+2,mySortX);
    cout<<paper[0]<<paper[1]<<paper[2]<<paper[3]<<endl;
    std::sort(paper.begin()+2,paper.end(),mySortX);
    cout<<paper[0]<<paper[1]<<paper[2]<<paper[3]<<endl;
    
    SCAN_A4.push_back(cv::Point2f(0,0));
    SCAN_A4.push_back(cv::Point2f(WIDTH_A4-1,0));
    SCAN_A4.push_back(cv::Point2f(0,HEIGHT_A4-1));
    SCAN_A4.push_back(cv::Point2f(WIDTH_A4-1,HEIGHT_A4-1));
    
    PIC_PAPER.push_back(cv::Point2f(paper[0].x,paper[0].y));
    PIC_PAPER.push_back(cv::Point2f(paper[1].x,paper[1].y));
    PIC_PAPER.push_back(cv::Point2f(paper[2].x,paper[2].y));
    PIC_PAPER.push_back(cv::Point2f(paper[3].x,paper[3].y));
    
    Mat transMat = getPerspectiveTransform(PIC_PAPER,SCAN_A4);
    warpPerspective(cvImage, DOCUMENT, transMat, DOCUMENT.size());
    imageView_.image = MatToUIImage(DOCUMENT);
    
    // 5. Now apply some OpenCV operations
//    cv::Mat gray; cv::cvtColor(cvImage, gray, CV_RGBA2GRAY); // Convert to grayscale
//    cv::Mat gauBlur; cv::GaussianBlur(gray, gauBlur, cv::Size(5,5), 1.2, 1.2); // Apply Gaussian blur
//    cv::Mat edges; cv::Canny(gauBlur, edges, 0, 50); // Estimate edge map using Canny edge detector
//    
//    // 6. Finally display the result
//    imageView_.image = MatToUIImage(edges);
//    
//    // 7. The image is already loaded and 'gray' is the grayscale version of image
//    // Now, load the face detector
//    // Part of the code taken from : https://www.objc.io/issues/21-camera-and-photos/face-recognition-with-opencv/
//    CascadeClassifier face_cascade; //Cascade Classifier for detecting the face
//    NSString *faceCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt" ofType:@"xml"];
//    const CFIndex CASCADE_NAME_LEN = 2048;
//    char *CASCADE_NAME = (char *) malloc(CASCADE_NAME_LEN);
//    CFStringGetFileSystemRepresentation( (CFStringRef)faceCascadePath, CASCADE_NAME, CASCADE_NAME_LEN);
//    if(!face_cascade.load(CASCADE_NAME)) {
//        cout << "Unable to load the face detector!!!!" << endl;
//        exit(-1);
//    }
//    //Load the eye detector
//    CascadeClassifier eye_cascade; //Cascade Classifier for detecting the eyes
//    NSString *eyeCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_eye" ofType:@"xml"];
//    CFStringGetFileSystemRepresentation( (CFStringRef)eyeCascadePath, CASCADE_NAME, CASCADE_NAME_LEN);
//    if(!eye_cascade.load(CASCADE_NAME)) {
//        cout << "Unable to load the eye detector!!!!" << endl;
//        exit(-1);
//    }
//    
//    // 8. Detect faces
//    vector<cv::Rect> faces;
//    face_cascade.detectMultiScale( gray, faces, 1.1, 2, 0 | CV_HAAR_SCALE_IMAGE, cv::Size(30, 30));
//    
//    //Detect eyes
//    vector<cv::Rect> eyes;
//    eye_cascade.detectMultiScale(gray, eyes);
//    
//    // 9. See if any faces were detected
//    cout << "Detected " << faces.size() << " faces!!!! " << endl;
//    //See if any eyes were detected
//    cout<< "Detected " << eyes.size() << " eyes!!!!" << endl;
//    
//    // 10. Display the result
//    cv::Mat display_im;
//    if(gray.channels() == 3) display_im = gray.clone(); // Why do we need to clone here?
//    else cv::cvtColor(gray,display_im,CV_GRAY2RGB); // The display image
//    
//    // If faces are detected then loop through and display bounding boxes
//    if(faces.size() > 0) {
//        for(int i=0; i<faces.size(); i++) {
//            rectangle(display_im, faces[i], RED, 5); //Observe that the displaying color format is not following BGR pattern
//        }
//    }
//    
//    // If eyes are detected then loop through and display bounding circles
//    if(eyes.size() > 0) {
//        //cout<<eyes[0]<<" "<<eyes[0].size()<<eyes[0].x + eyes[0].width/2<<" "<<eyes[0].y+eyes[0].height/2<<endl;
//        for(int i=0; i<eyes.size(); i++) {
//            cv::Point center(eyes[i].x + eyes[i].width/2, eyes[i].y+eyes[i].height/2);
//            int radius = cvRound((eyes[i].width+eyes[i].height)/4);
//            cv::circle(display_im, center, radius, GREEN, 5); //Observe that the displaying color format is not following BGR pattern
//        }
//    }
//    
//    imageView_.image = MatToUIImage(display_im);
//    
    // ALL DONE :)
}
@end
