//
//  LoginViewController.m
//  projecthang
//
//  Created by Andrew Despres on 8/15/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "LoginViewController.h"
#import "SVProgressHUD.h"
#import "AppConstants.h"

@interface LoginViewController ()

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _themeColor =[UIColor colorWithRed:249/255.0 green:102/255.0 blue:92/255.0 alpha:1];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    ((AppDelegate *)[UIApplication sharedApplication].delegate).loginVC = self;
    [self loginView];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) loginView {
//    UIImageView *backgroundImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight)];
//    backgroundImageView.image = [UIImage imageNamed:@"bgLogin.jpg"];
//    backgroundImageView.alpha = 0.3;
//    [self.view addSubview:backgroundImageView];

//    UIImageView *logoImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_screenWidth/2 - 50, 32, 100, 100)];
//    logoImageView.image = [UIImage imageNamed:@"Home"];
//    [self.view addSubview:logoImageView];

//    UIView *usernameSpacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
//    UIImageView *usernameImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 24, 24)];
//    usernameImageView.image = [UIImage imageNamed:@"ic_face"];
//    usernameImageView.alpha = 0.5;
//    [usernameSpacerView addSubview:usernameImageView];
//
//    CGFloat usernameTopMargin = 36;
//    CGFloat usernameHeight = 40;
//    UITextField* username = [[UITextField alloc] initWithFrame:CGRectMake(32, CGRectGetMaxY(logoImageView.frame) + usernameTopMargin, _screenWidth - 64, usernameHeight)];
//    username.placeholder = @"Username";
//    [username setLeftViewMode:UITextFieldViewModeAlways];
//    [username setLeftView:usernameSpacerView];
//    [self.view addSubview:username];
//
//    UIView *passwordSpacerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
//    UIImageView *passwordImageView = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 24, 24)];
//    passwordImageView.image = [UIImage imageNamed:@"ic_lock"];
//    passwordImageView.alpha = 0.5;
//    [passwordSpacerView addSubview:passwordImageView];
//
//    CGFloat passwordTopMargin = 5;
//    CGFloat passwordHeight = 40;
//    UITextField* password = [[UITextField alloc] initWithFrame:CGRectMake(32, CGRectGetMaxY(username.frame) + passwordTopMargin, _screenWidth - 64, passwordHeight)];
//    password.placeholder = @"Password";
//    [password setLeftViewMode:UITextFieldViewModeAlways];
//    [password setLeftView:passwordSpacerView];
//    [self.view addSubview:password];
//
//    CALayer *usernameBorder = [CALayer layer];
//    usernameBorder.frame = CGRectMake(0.0f, username.frame.size.height - 1, username.frame.size.width, 1.0f);
//    usernameBorder.backgroundColor = [UIColor blackColor].CGColor;
//    [username.layer addSublayer:usernameBorder];
//
//    CALayer *passwordBorder = [CALayer layer];
//    passwordBorder.frame = CGRectMake(0.0f, password.frame.size.height - 1, password.frame.size.width, 1.0f);
//    passwordBorder.backgroundColor = [UIColor blackColor].CGColor;
//    [password.layer addSublayer:passwordBorder];

//    CGFloat loginBtnTopMargin = 15;
    CGFloat loginFBBtnHeight = 40;
    UILabel* loginFBBtn = [[UILabel alloc] initWithFrame:CGRectMake(32, _screenWidth * 0.5 , _screenWidth - 64, loginFBBtnHeight)];
    loginFBBtn.backgroundColor = _themeColor;
    loginFBBtn.layer.cornerRadius = 4;
    loginFBBtn.clipsToBounds = true;
    loginFBBtn.textAlignment = NSTextAlignmentCenter;
    loginFBBtn.textColor = [UIColor whiteColor];
    loginFBBtn.font = [loginFBBtn.font fontWithSize:16];
    loginFBBtn.text = @"Log in by Facebook";
    loginFBBtn.userInteractionEnabled = YES;
    [loginFBBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openFBAuth:)]];
    [self.view addSubview:loginFBBtn];

    CGFloat loginPaypalBtnTopMargin = 15;
    CGFloat loginPaypalBtnHeight = 40;
    UILabel* loginPaypalBtn = [[UILabel alloc] initWithFrame:CGRectMake(32, CGRectGetMaxY(loginFBBtn.frame) + loginPaypalBtnTopMargin, _screenWidth - 64, loginPaypalBtnHeight)];
    loginPaypalBtn.backgroundColor = _themeColor;
    loginPaypalBtn.layer.cornerRadius = 4;
    loginPaypalBtn.clipsToBounds = true;
    loginPaypalBtn.textAlignment = NSTextAlignmentCenter;
    loginPaypalBtn.textColor = [UIColor whiteColor];
    loginPaypalBtn.font = [loginPaypalBtn.font fontWithSize:16];
    loginPaypalBtn.text = @"Login by Paypal";
    loginPaypalBtn.userInteractionEnabled = YES;
    [loginPaypalBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPaypalAuth:)]];
    [self.view addSubview:loginPaypalBtn];

    // CGFloat forgotPasswordBtnTopMargin = 5;
    // CGFloat forgotPasswordBtnHeight = 40;
    // UILabel* forgotPasswordBtn = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(loginBtn.frame) + forgotPasswordBtnTopMargin , _screenWidth, forgotPasswordBtnHeight)];
    // forgotPasswordBtn.textAlignment = NSTextAlignmentCenter;
    // forgotPasswordBtn.textColor = _themeColor;
    // forgotPasswordBtn.font = [forgotPasswordBtn.font fontWithSize:12];
    // forgotPasswordBtn.text = @"Forgot Password?";
    // forgotPasswordBtn.userInteractionEnabled = YES;
    //    [loginBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startChat:)]];
    // [self.view addSubview:forgotPasswordBtn];

//    CGFloat loginToggleBtnHeight = 40;
//    UILabel* loginToggleBtn = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.frame) - 170, _screenWidth, loginToggleBtnHeight)];
//    loginToggleBtn.textAlignment = NSTextAlignmentCenter;
//    loginToggleBtn.textColor = _themeColor;
//    loginToggleBtn.font = [forgotPasswordBtn.font fontWithSize:12];
//    loginToggleBtn.text = @"Don't have an account? Sign up";
//    loginToggleBtn.userInteractionEnabled = YES;
    //    [loginBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startChat:)]];
//    [self.view addSubview:loginToggleBtn];
}

- (void) openFBAuth:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@", kAppBaseURL ,@"/auth/facebook?fromMobile=true"]]];
}

- (void) openPaypalAuth:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString: [NSString stringWithFormat:@"%@%@", kAppBaseURL ,@"/auth/paypal?fromMobile=true"]]];
}

- (void) checkoutAfterSuccessfulLogin {
    [SVProgressHUD showWithStatus:@"Logged In. Going to paypal now"];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@", kAppBaseURL ,@"/checkout?event_id=", _evc.id, @"&fromMobile=true"]]];
    });
}

- (void) popAfterSuccessfulPayment {
    [SVProgressHUD show];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
            _evc.redirectStatus = @"paymentSuccess";
            [self.navigationController popViewControllerAnimated:YES];
            [_evc.view setNeedsDisplay];
        });
    });
    
}

- (void) showInfoOnFailedPayment {
    [SVProgressHUD showErrorWithStatus:@"Payment Failed"];
}

@end
