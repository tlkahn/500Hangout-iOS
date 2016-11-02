//
//  ProfileViewController.m
//  projecthang
//
//  Created by toeinriver on 8/5/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "ProfileViewController.h"
#import "EventListViewController.h"
#import "NativeEventFormViewController.h"

@interface ProfileViewController ()
@property (strong, nonatomic) UILabel* createEventBtn;
@property (strong, nonatomic) UILabel* hostedEventsBtn;
@property (strong, nonatomic) UILabel* enrolledEventsBtn;
@property (strong, nonatomic) UILabel* bookmarkedEventsBtn;
@property (strong, nonatomic) EventListViewController* eventsViewController;
@end

@implementation ProfileViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    UIColor* themeColor =[UIColor colorWithRed:249/255.0 green:102/255.0 blue:92/255.0 alpha:1];
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: themeColor, NSFontAttributeName: [UIFont systemFontOfSize:20.0f]};
    self.navigationController.navigationBar.tintColor = self.themeColor;
    self.navigationItem.title = @"My Profile";
    [self adjustHeight:self.view forSubView:self.tableView];
}

- (void) adjustHeight:(UIView*) view forSubView: (UITableView*) tableView{
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, super.screenWidth, self.tabBarController.tabBar.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell;
    if (indexPath.row == 1) {
        static NSString *identifier = @"descriptionView";

        cell = [tableView dequeueReusableCellWithIdentifier:identifier];

        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGFloat createEventBtnTopMargin = 0;
            CGFloat createEventBtnHeight = 40;
            self.createEventBtn = [[UILabel alloc] initWithFrame:CGRectMake(0, createEventBtnTopMargin , self.screenWidth, createEventBtnHeight)];
            self.createEventBtn.textAlignment = NSTextAlignmentCenter;
            self.createEventBtn.textColor = self.themeColor;
            self.createEventBtn.font = [self.createEventBtn.font fontWithSize:16];
            self.createEventBtn.text = @"Create New Event";
            self.createEventBtn.userInteractionEnabled = YES;
            [self.createEventBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(createNewEvent:)]];
            [cell.contentView addSubview:self.createEventBtn];

            CGFloat hostedEventsBtnTopMargin = 5;
            CGFloat hostedEventsBtnHeight = 40;
            self.hostedEventsBtn = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.createEventBtn.frame) + hostedEventsBtnTopMargin , self.screenWidth, hostedEventsBtnHeight)];
            self.hostedEventsBtn.textAlignment = NSTextAlignmentCenter;
            self.hostedEventsBtn.textColor = self.themeColor;
            self.hostedEventsBtn.font = [self.hostedEventsBtn.font fontWithSize:16];
            self.hostedEventsBtn.text = @"Events Hosted";
            self.hostedEventsBtn.hidden = NO;
            self.hostedEventsBtn.userInteractionEnabled = YES;
            [self.hostedEventsBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEventsHosted:)]];
            [cell.contentView addSubview:self.hostedEventsBtn];

            CGFloat enrolledEventsBtnTopMargin = 5;
            CGFloat enrolledEventsBtnHeight = 40;
            self.enrolledEventsBtn = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.hostedEventsBtn.frame) + enrolledEventsBtnTopMargin , self.screenWidth, enrolledEventsBtnHeight)];
            self.enrolledEventsBtn.textAlignment = NSTextAlignmentCenter;
            self.enrolledEventsBtn.textColor = self.themeColor;
            self.enrolledEventsBtn.font = [self.enrolledEventsBtn.font fontWithSize:16];
            self.enrolledEventsBtn.text = @"Events Enrolled";
            self.enrolledEventsBtn.hidden = NO;
            self.enrolledEventsBtn.userInteractionEnabled = YES;
            [self.enrolledEventsBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEventsEnrolled:)]];
            [cell.contentView addSubview:self.enrolledEventsBtn];

            CGFloat bookmarkedEventsBtnTopMargin = 5;
            CGFloat bookmarkedEventsBtnHeight = 40;
            UILabel* bookmarkedEventsBtn = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.enrolledEventsBtn.frame) + bookmarkedEventsBtnTopMargin , self.screenWidth, bookmarkedEventsBtnHeight)];
            bookmarkedEventsBtn.textAlignment = NSTextAlignmentCenter;
            bookmarkedEventsBtn.textColor = self.themeColor;
            bookmarkedEventsBtn.font = [bookmarkedEventsBtn.font fontWithSize:16];
            bookmarkedEventsBtn.text = @"Events Bookmarked";
            bookmarkedEventsBtn.userInteractionEnabled = YES;
            [bookmarkedEventsBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showEventsBookmarked:)]];
            [cell.contentView addSubview:bookmarkedEventsBtn];
    }
        return cell;
    }
    return [super tableView:tableView cellForRowAtIndexPath:indexPath];

}
- (void) createNewEvent:(id)sender {
    NSLog(@"creating a new event");
    NativeEventFormViewController *nefvc = [[NativeEventFormViewController alloc] init];
    [self.navigationController pushViewController:nefvc animated:YES];
}


- (void) showEventsHosted:(id)sender {
    if (!_eventsViewController) {
        _eventsViewController = [[EventListViewController alloc] init];
        _eventsViewController.parentVC = self;
    }
    [self.navigationController pushViewController:_eventsViewController animated:YES];
}

- (void) showEventsEnrolled:(id)sender {
    if (!_eventsViewController) {
        _eventsViewController = [[EventListViewController alloc] init];
        _eventsViewController.parentVC = self;
    }
    [self.navigationController pushViewController:_eventsViewController animated:YES];
}

- (void) showEventsBookmarked:(id)sender {
    if (!_eventsViewController) {
        _eventsViewController = [[EventListViewController alloc] init];
        _eventsViewController.parentVC = self;
    }
    [self.navigationController pushViewController:_eventsViewController animated:YES];
}

@end
