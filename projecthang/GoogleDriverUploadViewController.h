//
//  GoogleDriverUploadViewController.h
//  projecthang
//
//  Created by toeinriver on 9/6/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GTMOAuth2ViewControllerTouch.h"
#import "GTLDrive.h"

@interface GoogleDriverUploadViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) GTLServiceDrive *service;
@property (nonatomic, strong) UITextView *output;
@property (nonatomic, strong) UITableView *fileTableView;
@property (nonatomic, strong) GTLDriveFileList *fileList;
@property (assign, nonatomic) CGFloat screenWidth;
@property (strong, nonatomic) UIColor* themeColor;

@end
