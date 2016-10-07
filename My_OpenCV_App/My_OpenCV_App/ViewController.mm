//
//  ViewController.m
//  My_OpenCV_App
//
//  Created by Sri Raghu Malireddi on 14/07/16.
//  Copyright © 2016 Sri Raghu Malireddi. All rights reserved.
//

#import "ViewController.h"

// Include iostream and std namespace so we can mix C++ code in here
#include <iostream>
using namespace std;

@interface ViewController () {
    //Setup the view
    UIImageView *imageView_;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    // 1. Setup the your OpenCV view, so it takes up the entire App screen......
    imageView_ = [[UIImageView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.frame.size.width, self.view.frame.size.height)];
    imageView_.contentMode = UIViewContentModeScaleAspectFit;
    
    // 2. Important: add OpenCV_View as a subview
    [self.view addSubview:imageView_];
    
    // 3.Read in the image (of the famous Lena)
    UIImage *image = [UIImage imageNamed:@"raghu.jpg"];
    if(image != nil) imageView_.image = image; // Display the image if it is there....
    else cout << "Cannot read in the file" << endl;
    
    // ALL DONE :)
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
