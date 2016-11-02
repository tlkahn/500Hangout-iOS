//
//  LoginViewController.h
//  projecthang
//
//  Created by Andrew Despres on 8/15/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "EventViewController.h"

@interface LoginViewController : UIViewController
@property (assign, nonatomic) CGFloat screenHeight;
@property (assign, nonatomic) CGFloat screenWidth;
@property (strong, nonatomic) UIColor* themeColor;
@property (strong, nonatomic) UIView* topView;
@property (strong, nonatomic) EventViewController* evc;
@property (strong, nonatomic) NSString* currentAction;
- (void) checkoutAfterSuccessfulLogin;
- (void) popAfterSuccessfulPayment;
- (void) showInfoOnFailedPayment;
@end
