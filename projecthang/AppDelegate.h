//
//  AppDelegate.h
//  projecthang
//
//  Created by toeinriver on 7/28/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import <UIKit/UIKit.h>
@class LoginViewController;
#import "LoginViewController.h"
#import "EventViewController.h"
#import "AppConstants.h"
@import AWSCore;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, atomic) LoginViewController* loginVC;
@property (strong, atomic) EventViewController* eVC;
@property (strong, atomic) UILabel* enrollBtn;
@property (strong, atomic) UIButton* bookmarkBtn;
@end

