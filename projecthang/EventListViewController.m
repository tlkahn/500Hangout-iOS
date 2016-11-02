//
//  EventListViewController.m
//  projecthang
//
//  Created by toeinriver on 8/4/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "EventListViewController.h"
#import "EventViewController.h"
#import "UserViewController.h"
#import "DLImageLoader.h"
#import "AFNetworking.h"
#import "HANLocationManager.h"
#import "Event.h"
#import <objc/runtime.h>
#import "AppConstants.h"

@interface EventListViewController ()
@property (strong, nonatomic) NSURL* baseURL;
@property (strong, nonatomic) NSArray* events;
@property (assign, nonatomic) CGFloat screenWidth;
@property (strong, nonatomic) UIColor* themeColor;
@property (strong, nonatomic) HANLocationManager *locationManager;
@property (strong, atomic) EventViewController *evc;
@end

@implementation EventListViewController

#pragma mark - initializers

- (instancetype) initWithElemClass:(NSString*)elemClass Id:(NSUInteger) id{
    self = [super init];
    self.elemClass = elemClass;
    self.id = id;
    return self;
}

#pragma mark - uiview

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Events";
    _baseURL = [NSURL URLWithString:kAppBaseURL];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    _screenWidth = screenRect.size.width;
    _eventsTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, self.view.bounds.size.height) style:UITableViewStylePlain];
    _eventsTableView.contentInset = UIEdgeInsetsMake(0, 0, 113, 0);
    _eventsTableView.delegate = self;
    _eventsTableView.dataSource = self;
    _themeColor =[UIColor colorWithRed:249/255.0 green:102/255.0 blue:92/255.0 alpha:1];
    [self.view addSubview:_eventsTableView];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    _locationManager = [HANLocationManager sharedInstance];
    
    operationQueue = [NSOperationQueue new];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(fetchEvents) object:nil];
    [operationQueue addOperation:operation];
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.tabBarController.tabBar.hidden) {
        self.tabBarController.tabBar.hidden = NO;
    }
}

// MARK: - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

// MARK: - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_events count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _screenWidth;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CellPortrait";

    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];

    // Formatting constants
    CGFloat labelHeight = 20;
    CGFloat iconTextMargin = 5;
    
    // Parse Event from List of Events
    Event *event = [[Event alloc] initWithData:_events[indexPath.row]];
    
    // Cell
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // Event Image
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenWidth)];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(_screenWidth / 2 - 25, _screenWidth / 2 - 50, 50, 50)];
    spinner.color = _themeColor;
    [spinner startAnimating];
    [imageView addSubview:spinner];
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[DLImageLoader sharedInstance] imageFromUrl:event.photoURL1 completed:^(NSError *error, UIImage *img) {
            if (error) {
                NSLog(@"error: %@", error);
                return;
            }
            dispatch_async(dispatch_get_main_queue(), ^{
                [spinner removeFromSuperview];
                imageView.image = img;
                objc_setAssociatedObject(imageView, @"event", event, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                imageView.userInteractionEnabled = YES;
                [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openEventWithId:) ]];
            });
        }];
    });
    
    CGFloat bgRectHeight = 60;
    CGRect bgRect = CGRectMake(0, imageView.frame.size.height - bgRectHeight, _screenWidth, bgRectHeight);
    UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = bgRect;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [imageView addSubview:blurEffectView];
    [cell.contentView addSubview:imageView];

    // Time until Event
    UIView *time = [[UIView alloc] initWithFrame:CGRectMake(10, (bgRectHeight - labelHeight)/2, 70, labelHeight)];
    UIImageView *timeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, labelHeight, labelHeight)];
    timeImageView.image = [UIImage imageNamed:@"Clock"];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(timeImageView.frame.origin.x + timeImageView.frame.size.width + iconTextMargin, 0, time.frame.size.width - timeImageView.frame.size.width - iconTextMargin, labelHeight)];
    if (event.startDateTime != nil) {
        label.text = [event formattedShortDate:event.startDateTime];
        label.textColor = _themeColor;
        [label setFont:[label.font fontWithSize:10]];
        [time addSubview:timeImageView];
        [time addSubview:label];
        [blurEffectView addSubview:time];
    }

    // Location of Event
    UIView *place = [[UIView alloc] initWithFrame:CGRectMake(time.frame.origin.x + time.frame.size.width + 10, (bgRectHeight - labelHeight)/2, 100, labelHeight)];
    UIImageView *placeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, labelHeight, labelHeight)];
    placeImageView.image = [UIImage imageNamed:@"Place"];
    UILabel *placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(placeImageView.frame.origin.x + placeImageView.frame.size.width + iconTextMargin, 0, place.frame.size.width - placeImageView.frame.size.width - iconTextMargin, labelHeight)];
    
    if (_locationManager.currentLocation != nil ) {
        CLLocation *location = [_locationManager locationFromLatitude:event.latitude :event.longitude];
        NSString *distance = [_locationManager getDistanceFromLocation:location];
        placeLabel.text = [NSString stringWithFormat:@"%@", distance];
    } else {
        placeLabel.text = event.vicinty;
    }
    
    placeLabel.textColor = _themeColor;
    [placeLabel setFont:[placeLabel.font fontWithSize:10]];
    [place addSubview:placeImageView];
    [place addSubview:placeLabel];
    [blurEffectView addSubview:place];
    
    // Number of Attendees
    CGFloat attendantsViewWidth = 50;
    UIView *attendants = [[UIView alloc] initWithFrame:CGRectMake(_screenWidth - 100, (bgRectHeight - labelHeight)/2, attendantsViewWidth, labelHeight)];
    UIImageView * groupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, labelHeight, labelHeight)];
    groupImageView.image = [UIImage imageNamed:@"Profile"];
    [attendants addSubview:groupImageView];
    UILabel* groupNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(groupImageView.frame.origin.x+groupImageView.frame.size.width+iconTextMargin, 0, labelHeight, labelHeight)];
    groupNumberLabel.text = [NSString stringWithFormat:@"%i", event.enrolled];
    groupNumberLabel.textColor = _themeColor;
    groupNumberLabel.font = [groupNumberLabel.font fontWithSize:10];
    [attendants addSubview:groupNumberLabel];
    [blurEffectView addSubview:attendants];

    // Fans of Event
    UIView *fans = [[UIView alloc] initWithFrame:CGRectMake(attendants.frame.origin.x + attendants.frame.size.width, (bgRectHeight - labelHeight)/2, attendantsViewWidth, labelHeight)];
    UIImageView * fansImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, labelHeight, labelHeight)];
    fansImageView.image = [UIImage imageNamed:@"Heart"];
    [fans addSubview:fansImageView];
    UILabel* fansNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(fansImageView.frame.origin.x+fansImageView.frame.size.width+iconTextMargin, 0, labelHeight, labelHeight)];
    fansNumberLabel.text = [NSString stringWithFormat:@"%i", event.followers];
    fansNumberLabel.textColor = _themeColor;
    fansNumberLabel.font = [groupNumberLabel.font fontWithSize:10];
    [fans addSubview:fansNumberLabel];
    [blurEffectView addSubview:fans];

    // Organizer's Avatar
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(25, 25, 60, 60)];
    [[DLImageLoader sharedInstance] imageFromUrl:event.hostAvatarURL completed:^(NSError *error, UIImage *img) {
        if (error) {
            NSLog(@"error: %@", error);
            return;
        }
        avatarView.image = img;
        avatarView.layer.cornerRadius = avatarView.frame.size.width / 2;
        avatarView.layer.borderWidth = 1.0f;
        avatarView.layer.borderColor = [UIColor whiteColor].CGColor;
        avatarView.clipsToBounds = YES;
        avatarView.userInteractionEnabled = NO;
//        [avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUser:)]];
//        NSDictionary *myInfo = @{@"row": @(indexPath.row)};
//        objc_setAssociatedObject(imageView, @"myInfo", myInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openEventWithId:) ]];
    }];
    [imageView addSubview:avatarView];

    return cell;
}

// MARK: - AFNetworking

- (void) fetchEvents {
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:_baseURL];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString* path = @"/events";
    NSDictionary* parameters;
    if ([self.elemClass isEqualToString:@"EventCategory"]) {
        parameters = @{@"category_id": @(self.id)};
    }
    if ([self.elemClass isEqualToString:@"SuperHost"]) {
        parameters = @{@"organizer_id": @(self.id)};
    }
    if ([self.elemClass isEqualToString:@"Facility"]) {
        parameters = @{@"event_id": @(self.id)};
    }
    NSLog(@"parameters: %@", parameters);
    [manager GET:[NSString stringWithFormat:@"%@%@", _baseURL.absoluteString, path] parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSLog(@"JSON: %@", (NSDictionary *) responseObject);
        _events = (NSArray *) responseObject;
        [_eventsTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:YES];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

// MARK: - Navigation

- (void) openEventWithId:(id)sender {
    NSLog(@"%@", objc_getAssociatedObject(((UITapGestureRecognizer *)sender).view, @"event"));
    _evc = [[EventViewController alloc] init];
    _evc.event = objc_getAssociatedObject(((UITapGestureRecognizer *)sender).view, @"event");
    _evc.hidesBottomBarWhenPushed = YES;
    if (!self.navigationController) {
        [self.parentVC.navigationController pushViewController:_evc animated:YES];
    }
    else {
        [self.navigationController pushViewController:_evc animated:YES];
    }
}

- (void) scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.parentVC && [self.parentVC conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.parentVC respondsToSelector:@selector(scrollViewDidScroll:)]) {
        UIView <UIScrollViewDelegate>* uv =  (UIView <UIScrollViewDelegate>* ) self.parentVC;
        [uv scrollViewDidScroll:scrollView];
    }
}

- (void) showUser:(id)sender {
    NSLog(@"%@", objc_getAssociatedObject(((UITapGestureRecognizer *)sender).view, @"myInfo"));
    UserViewController *vc = [[UserViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
