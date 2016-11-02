//
//  FileBrowserViewController.h
//  projecthang
//
//  Created by Andrew Despres on 9/6/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"
#import <BoxContentSDK/BOXContentSDK.h>
#import <XLForm/XLForm.h>

@interface FileBrowserViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, BOXAPIAccessTokenDelegate>

@property (assign, nonatomic) CGFloat screenWidth;
@property (strong, nonatomic) UIColor* themeColor;
@property (strong, nonatomic) UISegmentedControl *segmentControl;
@property (strong, nonatomic) GTLServiceDrive *service;

@end
