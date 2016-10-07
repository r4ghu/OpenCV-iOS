//
//  ViewController.m
//  My_Camera_App
//
//  Created by Sri Raghu Malireddi on 15/07/16.
//  Copyright © 2016 Sri Raghu Malireddi. All rights reserved.
//

#import "ViewController.h"

// Include stdlib.h and std namespace so we can mix C++ code in here
#include <stdlib.h>
using namespace std;
using namespace cv;

//Define some colors here
const Scalar RED = Scalar(255,0,0);
const Scalar PINK = Scalar(255,130,230);
const Scalar BLUE = Scalar(0,0,255);
const Scalar LIGHTBLUE = Scalar(160,255,255);
const Scalar GREEN = Scalar(0,255,0);
const Scalar WHITE = Scalar(255,255,255);

@interface ViewController () {
    UIImageView *liveView_; // Live output from the camera
    UIImageView *resultView_; // Preview view of everything...
    UIButton *takephotoButton_, *goliveButton_; // Button to initiate OpenCV processing of image
    CvPhotoCamera *photoCamera_; // OpenCV wrapper class to simplfy camera access through AVFoundation
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // 1. Setup the your OpenCV view, so it takes up the entire App screen......
    int view_width = self.view.frame.size.width;
    int view_height = (640*view_width)/480; // Work out the viw-height assuming 640x480 input
    int view_offset = (self.view.frame.size.height - view_height)/2;
    liveView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, view_offset, view_width, view_height)];
    [self.view addSubview:liveView_]; // Important: add liveView_ as a subview
    //resultView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, 960, 1280)];
    resultView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, view_offset, view_width, view_height)];
    [self.view addSubview:resultView_]; // Important: add resultView_ as a subview
    resultView_.hidden = true; // Hide the view
    
    // 2. First setup a button to take a single picture
    takephotoButton_ = [self simpleButton:@"Take Photo" buttonColor:[UIColor redColor]];
    // Important part that connects the action to the member function buttonWasPressed
    [takephotoButton_ addTarget:self action:@selector(buttonWasPressed) forControlEvents:UIControlEventTouchUpInside];
    
    // 3. Setup another button to go back to live video
    goliveButton_ = [self simpleButton:@"Go Live" buttonColor:[UIColor greenColor]];
    // Important part that connects the action to the member function buttonWasPressed
    [goliveButton_ addTarget:self action:@selector(liveWasPressed) forControlEvents:UIControlEventTouchUpInside];
    [goliveButton_ setHidden:true]; // Hide the button
    
    // 4. Initialize the camera parameters and start the camera (inside the App)
    photoCamera_ = [[CvPhotoCamera alloc] initWithParentView:liveView_];
    photoCamera_.delegate = self;
    
    // This chooses whether we use the front or rear facing camera
    photoCamera_.defaultAVCaptureDevicePosition = AVCaptureDevicePositionFront;
    
    // This is used to set the image resolution
    photoCamera_.defaultAVCaptureSessionPreset = AVCaptureSessionPreset640x480;
    
    // This is used to determine the device orientation
    photoCamera_.defaultAVCaptureVideoOrientation = AVCaptureVideoOrientationPortrait;
    
    // This starts the camera capture
    [photoCamera_ start];
    
}

//===============================================================================================
// This member function is executed when the button is pressed
- (void)buttonWasPressed {
    [photoCamera_ takePicture];
}
//===============================================================================================
// This member function is executed when the button is pressed
- (void)liveWasPressed {
    [takephotoButton_ setHidden:false]; [goliveButton_ setHidden:true]; // Switch visibility of buttons
    resultView_.hidden = true; // Hide the result view again
    [photoCamera_ start];
}
//===============================================================================================
// To be compliant with the CvPhotoCameraDelegate we need to implement these two methods
- (void)photoCamera:(CvPhotoCamera *)photoCamera capturedImage:(UIImage *)image
{
    [photoCamera_ stop];
    resultView_.hidden = false; // Turn the hidden view on
    
    // You can apply your OpenCV code HERE!!!!!
    // If you want, you can ignore the rest of the code base here, and simply place
    // your OpenCV code here to process images.
    cv::Mat cvImage; UIImageToMat(image, cvImage);
    cv::Mat gray; cv::cvtColor(cvImage, gray, CV_RGBA2GRAY); // Convert to grayscale
    
    // Load the face detector
    // Part of the code taken from : https://www.objc.io/issues/21-camera-and-photos/face-recognition-with-opencv/
    CascadeClassifier face_cascade; //Cascade Classifier for detecting the face
    NSString *faceCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_frontalface_alt" ofType:@"xml"];
    const CFIndex CASCADE_NAME_LEN = 2048;
    char *CASCADE_NAME = (char *) malloc(CASCADE_NAME_LEN);
    CFStringGetFileSystemRepresentation( (CFStringRef)faceCascadePath, CASCADE_NAME, CASCADE_NAME_LEN);
    if(!face_cascade.load(CASCADE_NAME)) {
        cout << "Unable to load the face detector!!!!" << endl;
        exit(-1);
    }
    //Load the eye detector
    CascadeClassifier eye_cascade; //Cascade Classifier for detecting the eyes
    NSString *eyeCascadePath = [[NSBundle mainBundle] pathForResource:@"haarcascade_eye" ofType:@"xml"];
    CFStringGetFileSystemRepresentation( (CFStringRef)eyeCascadePath, CASCADE_NAME, CASCADE_NAME_LEN);
    if(!eye_cascade.load(CASCADE_NAME)) {
        cout << "Unable to load the eye detector!!!!" << endl;
        exit(-1);
    }
    
    // 8. Detect faces
    vector<cv::Rect> faces;
    face_cascade.detectMultiScale( gray, faces, 1.1, 2, 0 | CV_HAAR_SCALE_IMAGE, cv::Size(30, 30));
    
    //Detect eyes
    vector<cv::Rect> eyes;
    eye_cascade.detectMultiScale(gray, eyes);
    
    // 9. See if any faces were detected
    cout << "Detected " << faces.size() << " faces!!!! " << endl;
    //See if any eyes were detected
    cout<< "Detected " << eyes.size() << " eyes!!!!" << endl;
    
    // 10. Display the result
    cv::Mat display_im;
    if(gray.channels() == 3) display_im = gray.clone(); // Why do we need to clone here?
    else cv::cvtColor(gray,display_im,CV_GRAY2RGB); // The display image
    
    // If faces are detected then loop through and display bounding boxes
    if(faces.size() > 0) {
        for(int i=0; i<faces.size(); i++) {
            rectangle(display_im, faces[i], RED); //Observe that the displaying color format is not following BGR pattern
        }
    }
    
    // If eyes are detected then loop through and display bounding circles
    if(eyes.size() > 0) {
        //cout<<eyes[0]<<" "<<eyes[0].size()<<eyes[0].x + eyes[0].width/2<<" "<<eyes[0].y+eyes[0].height/2<<endl;
        for(int i=0; i<eyes.size(); i++) {
            cv::Point center(eyes[i].x + eyes[i].width/2, eyes[i].y+eyes[i].height/2);
            int radius = cvRound((eyes[i].width+eyes[i].height)/4);
            cv::circle(display_im, center, radius, GREEN); //Observe that the displaying color format is not following BGR pattern
        }
    }
    
    UIImage *resImage = MatToUIImage(display_im);
    
    // Special part to ensure the image is rotated properly when the image is converted back
    resultView_.image =  [UIImage imageWithCGImage:[resImage CGImage]
                                             scale:1.0
                                       orientation: UIImageOrientationLeftMirrored];
    [takephotoButton_ setHidden:true]; [goliveButton_ setHidden:false]; // Switch visibility of buttons
}
- (void)photoCameraCancel:(CvPhotoCamera *)photoCamera
{
    
}
//===============================================================================================
// Simple member function to initialize buttons in the bottom of the screen so we do not have to
// bother with storyboard, and can go straight into vision on mobiles
//
- (UIButton *) simpleButton:(NSString *)buttonName buttonColor:(UIColor *)color
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom]; // Initialize the button
    // Bit of a hack, but just positions the button at the bottom of the screen
    int button_width = 200; int button_height = 50; // Set the button height and width (heuristic)
    // Botton position is adaptive as this could run on a different device (iPAD, iPhone, etc.)
    int button_x = (self.view.frame.size.width - button_width)/2; // Position of top-left of button
    int button_y = self.view.frame.size.height - 80; // Position of top-left of button
    button.frame = CGRectMake(button_x, button_y, button_width, button_height); // Position the button
    [button setTitle:buttonName forState:UIControlStateNormal]; // Set the title for the button
    [button setTitleColor:color forState:UIControlStateNormal]; // Set the color for the title
    
    [self.view addSubview:button]; // Important: add the button as a subview
    //[button setEnabled:bflag]; [button setHidden:(!bflag)]; // Set visibility of the button
    return button; // Return the button pointer
}

//===============================================================================================
// Standard memory warning component added by Xcode
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
