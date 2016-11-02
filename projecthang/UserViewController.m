//
//  UserViewController.m
//  projecthang
//
//  Created by toeinriver on 8/5/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "UserViewController.h"
#import "DLImageLoader.h"
#import "EventListViewController.h"
#import "DemoMessagesViewController.h"
#import "AFNetworking.h"
#import "AppConstants.h"
#import "User.h"

@interface UserViewController ()

@property (strong, atomic) User* user;

@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    _themeColor =[UIColor colorWithRed:249/255.0 green:102/255.0 blue:92/255.0 alpha:1];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenHeight - self.navigationController.navigationBar.frame.size.height - [UIApplication sharedApplication].statusBarFrame.size.height)];
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.dataSource = self;
    _tableView.delegate = self;
    self.navigationController.delegate = self;
    _user = [[User alloc] init];
    if (self.id) {
        _user.id = self.id;
    }
    else {
//        _user.id = [[NSUserDefaults standardUserDefaults] integerForKey:@"userId"];
        _user.id = 5;
    }
    
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kAppBaseURL]];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        NSString* path = @"/users";
        NSDictionary* parameters = @{@"id": @(_user.id)};
        [manager GET:[NSString stringWithFormat:@"%@%@", kAppBaseURL, path] parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            NSLog(@"JSON: %@", (NSDictionary *) responseObject);
            NSDictionary* result = ((NSArray *) responseObject)[0];
            if (result[@"fullName"] && ![NSStringFromClass([result[@"fullName"] class]) isEqualToString:@"NSNull"])  {
                _user.fullName = result[@"fullName"];
                
            }
            else {
                _user.fullName = @"";
            }
            if (result[@"photo_url"] && ![NSStringFromClass([result[@"photo_url"] class]) isEqualToString:@"NSNull"])  {
                _user.picURL = result[@"photo_url"];
                
            }
            else {
                _user.picURL = @"";
            }
            if (result[@"description"] && ![NSStringFromClass([result[@"description"] class]) isEqualToString:@"NSNull"])  {
                _user.details = result[@"photo_url"];
                
            }
            else {
                _user.details = @"";
            }
            [_tableView reloadData];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];

    
    [self.view addSubview:_tableView];


    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row == 0) {
        static NSString *identifier = @"topView";

        cell = [tableView dequeueReusableCellWithIdentifier:identifier];

            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
            _topView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenWidth)];
            UIImageView *bgImageView = [[UIImageView alloc] initWithFrame:_topView.frame];
            UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurEffectView.frame = _topView.frame;
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [_topView addSubview:bgImageView];
            [_topView addSubview:blurEffectView];

            CGFloat avatarImageViewWidth = 120;
            CGFloat avatarImageViewHeight = 120;
            CGFloat avatarImageViewTop = 0.5 * (blurEffectView.center.y - 0.5 * avatarImageViewHeight);
            CGFloat avatarImageViewLeft = blurEffectView.center.x - 0.5 * avatarImageViewWidth;
            UIImageView *avatarImageView = [[UIImageView alloc] initWithFrame:CGRectMake(avatarImageViewLeft, avatarImageViewTop , avatarImageViewWidth, avatarImageViewHeight)];
            avatarImageView.layer.cornerRadius = avatarImageView.frame.size.width / 2;
            avatarImageView.layer.borderWidth = 1.0f;
            avatarImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            avatarImageView.clipsToBounds = YES;
            [blurEffectView addSubview:avatarImageView];

            CGFloat nameTopMargin = 10;
            CGFloat nameTop = CGRectGetMaxY(avatarImageView.frame) + nameTopMargin;
            UILabel *name = [[UILabel alloc] initWithFrame:CGRectZero];
            name.text = _user.fullName;
            name.textColor = _themeColor;
            name.font = [name.font fontWithSize:16];
            [name sizeToFit];
            name.center = CGPointMake(avatarImageView.center.x, nameTop + name.frame.size.height/2);
            [blurEffectView addSubview:name];

            CGFloat descriptionTopMargin = 10;
            CGFloat descriptionTop = CGRectGetMaxY(name.frame) + descriptionTopMargin;
            CGFloat descriptionWidth = 0.7 * blurEffectView.frame.size.width;
            UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, descriptionWidth, 0)];
            description.text = _user.details;
            description.textColor = _themeColor;
            description.font = [description.font fontWithSize:12];
            description.numberOfLines = 0;
            description.lineBreakMode = NSLineBreakByWordWrapping;
            description.textAlignment = NSTextAlignmentCenter;
            [description sizeToFit];
            description.center = CGPointMake(name.center.x, descriptionTop + description.frame.size.height/2);
            [blurEffectView addSubview:description];

            NSString *avatarImageURL = [NSString stringWithFormat:_user.picURL, 400, 400];
            [[DLImageLoader sharedInstance] imageFromUrl:avatarImageURL completed:^(NSError *error, UIImage *img) {
                avatarImageView.image = img;
            }];

            NSString *bgImageURL = [NSString stringWithFormat:_user.picURL, 400, 400];
            [[DLImageLoader sharedInstance] imageFromUrl:bgImageURL completed:^(NSError *error, UIImage *img) {
                bgImageView.image = img;

            }];

            [cell.contentView addSubview:_topView];
        return cell;
    }
    else if (indexPath.row == 1) {
            static NSString *identifier = @"descriptionView";

            cell = [tableView dequeueReusableCellWithIdentifier:identifier];

                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
                CGFloat allEventsBtnTopMargin = 0;
                CGFloat allEventsBtnHeight = 40;
                UILabel* allEventsBtn = [[UILabel alloc] initWithFrame:CGRectMake(0, allEventsBtnTopMargin , _screenWidth, allEventsBtnHeight)];
                allEventsBtn.textAlignment = NSTextAlignmentCenter;
                allEventsBtn.textColor = _themeColor;
                allEventsBtn.font = [allEventsBtn.font fontWithSize:16];
                allEventsBtn.text = @"See all events";
                allEventsBtn.userInteractionEnabled = YES;
                [allEventsBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showAllEvents:)]];
                [cell.contentView addSubview:allEventsBtn];

                CGFloat followBtnTopMargin = 5;
                CGFloat followBtnHeight = 40;
                _followBtn = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(allEventsBtn.frame) + followBtnTopMargin , _screenWidth, followBtnHeight)];
                _followBtn.textAlignment = NSTextAlignmentCenter;
                _followBtn.textColor = _themeColor;
                _followBtn.font = [_followBtn.font fontWithSize:16];
                _followBtn.text = @"Follow";
                _followBtn.hidden = NO;
                _followBtn.userInteractionEnabled = YES;
                [_followBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleFollowing:)]];
                [cell.contentView addSubview:_followBtn];


                CGFloat unfollowBtnTopMargin = 5;
                CGFloat unfollowBtnHeight = 40;
                _unfollowBtn = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(allEventsBtn.frame) + unfollowBtnTopMargin , _screenWidth, unfollowBtnHeight)];
                _unfollowBtn.textAlignment = NSTextAlignmentCenter;
                _unfollowBtn.textColor = [UIColor colorWithRed:28/255.f green:183/255.f blue:180/255.f alpha:1];
                _unfollowBtn.font = [_unfollowBtn.font fontWithSize:16];
                _unfollowBtn.text = @"Following";
                _unfollowBtn.hidden = YES;
                _unfollowBtn.userInteractionEnabled = YES;
                [_unfollowBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleFollowing:)]];
                [cell.contentView addSubview:_unfollowBtn];

                CGFloat chatBtnTopMargin = 5;
                CGFloat chatBtnHeight = 40;
                UILabel* chatBtn = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_followBtn.frame) + chatBtnTopMargin , _screenWidth, chatBtnHeight)];
                chatBtn.textAlignment = NSTextAlignmentCenter;
                chatBtn.textColor = _themeColor;
                chatBtn.font = [chatBtn.font fontWithSize:16];
                chatBtn.text = @"Chat";
                chatBtn.userInteractionEnabled = YES;
                [chatBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startChat:)]];
                [cell.contentView addSubview:chatBtn];
        return cell;
    }
    return cell;
}

- (void) showAllEvents: (id) sender {
    EventListViewController * evc = [[EventListViewController alloc] init];
    [self.navigationController pushViewController:evc animated:YES];
}

- (void) toggleFollowing: (id) sender {
    _followBtn.hidden = !_followBtn.hidden;
    _unfollowBtn.hidden = !_unfollowBtn.hidden;
}

- (void) startChat: (id) sender {
    DemoMessagesViewController *vc = [DemoMessagesViewController messagesViewController];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    animated = NO;
    if (viewController == self) {
        self.tabBarController.tabBar.hidden = NO;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return _screenWidth;
    }
    else
        return 180.0f;
}

@end
