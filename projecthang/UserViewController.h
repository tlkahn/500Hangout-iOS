//
//  UserViewController.h
//  projecthang
//
//  Created by toeinriver on 8/5/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UserViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UINavigationControllerDelegate>
@property (assign, nonatomic) CGFloat screenWidth;
@property (assign, nonatomic) CGFloat screenHeight;
@property (strong, nonatomic) UIColor* themeColor;
@property (strong, nonatomic) UIView* topView;
@property (strong, nonatomic) UITableView* tableView;
@property (strong, nonatomic) UILabel* followBtn;
@property (strong, nonatomic) UILabel* unfollowBtn;
@property (assign, atomic) NSUInteger id;
@end
