//
//  EventViewController.m
//  projecthang
//
//  Created by toeinriver on 8/4/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "EventViewController.h"
#import "DemoMessagesViewController.h"
#import "LoginViewController.h"
#import "UserViewController.h"
#import "NativeEventFormViewController.h"
#import "HANLocationManager.h"
#import "SVProgressHUD.h"
#import "AppConstants.h"
#import "AFNetworking.h"
@import GoogleMaps;

@interface EventViewController ()

@property (assign, nonatomic) CGFloat screenWidth;
@property (strong, nonatomic) UIColor* themeColor;
@property (strong, nonatomic) HANLocationManager *locationManager;
@property (assign, nonatomic) BOOL paymentSuccess;

@property (strong, nonatomic) UILabel *registerBtn;
@property (strong, nonatomic) GMSMapView *mapView;
@property (strong, nonatomic) GMSCameraPosition *camera;

@end

@implementation EventViewController

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _themeColor =[UIColor colorWithRed:249/255.0 green:102/255.0 blue:92/255.0 alpha:1];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (self.event) {
        self.id = [NSString stringWithFormat:@"%d", self.event.eventID];
    }

    self.view.backgroundColor = [UIColor whiteColor];
    
    UIBarButtonItem *shareButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                    target:self
                                    action:@selector(shareEvent)];
    self.navigationItem.rightBarButtonItem = shareButton;
    
    CGRect tableFrame = CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height);
    _eventTable = [[UITableView alloc] initWithFrame:tableFrame];
    _eventTable.dataSource = self;
    _eventTable.delegate = self;
    _eventTable.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _eventTable.separatorStyle = UITableViewCellSeparatorStyleNone;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(appplicationIsActive:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationEnteredForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [self.view addSubview:_eventTable];
    _locationManager = [HANLocationManager sharedInstance];
    
    operationQueue = [NSOperationQueue new];
    NSInvocationOperation *getEvent = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getEvent) object:nil];
    [operationQueue addOperation:getEvent];
    
    [self initializeMapView];
}

- (void)viewWillAppear:(BOOL)animated {
    if (!self.tabBarController.tabBar.hidden) {
        self.tabBarController.tabBar.hidden = YES;
    }
}

- (void)viewDidAppear:(BOOL)animated {
    if ([self.redirectStatus isEqualToString:@"paymentSuccess"]) {
        self.redirectStatus = @"";
        [SVProgressHUD showSuccessWithStatus:@"Success"];
    }
    
    _registerBtn = [self uiRegisterButton];
    [self.view addSubview:_registerBtn];
    
    [UIView animateWithDuration:0.25 animations:^{
        _registerBtn.frame = CGRectMake(0, CGRectGetMaxY(self.view.bounds) - 49, _screenWidth, 49);
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIView animateWithDuration:0.25 animations:^{
        _registerBtn.frame = CGRectMake(0, CGRectGetMaxY(self.view.bounds), _screenWidth, 49);
    }];
}

#pragma mark - Multitasking

- (void)appplicationIsActive:(NSNotification *)notification {
    NSLog(@"Application Did Become Active");
    if (_paymentSuccess) {
        NSAssert(_enrollBtn == ((AppDelegate *)[UIApplication sharedApplication].delegate).enrollBtn, @"enrollBtn address remain prestine..");
        ((AppDelegate *)[UIApplication sharedApplication].delegate).enrollBtn.hidden = YES;
        CGFloat enrollingLabelHeight = 40;
        UILabel* enrollingLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, ((AppDelegate *)[UIApplication sharedApplication].delegate).enrollBtn.frame.origin.y , _screenWidth, enrollingLabelHeight)];
        enrollingLabel.textAlignment = NSTextAlignmentCenter;
        enrollingLabel.textColor = [UIColor colorWithRed:28/255.f green:183/255.f blue:180/255.f alpha:1];;
        enrollingLabel.font = [enrollingLabel.font fontWithSize:16];
        enrollingLabel.text = @"Enrolled";
        enrollingLabel.userInteractionEnabled = NO;
        [((AppDelegate *)[UIApplication sharedApplication].delegate).enrollBtn.superview addSubview:enrollingLabel];
        enrollingLabel.hidden = NO;
        _enrolledLabel = enrollingLabel;
    }
}

- (void)applicationEnteredForeground:(NSNotification *)notification {
    NSLog(@"Application Entered Foreground");
}

#pragma mark - Memory Management

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    static NSString *identifier = @"cell";
    UITableViewCell *cell;
    cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    if(!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
//    if (indexPath.row == 0) {
//        ASHorizontalScrollView *horizontalScrollView = [[ASHorizontalScrollView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenWidth)];
//        horizontalScrollView.leftMarginPx = 0;
//        horizontalScrollView.miniAppearPxOfLastItem = 10;
//        horizontalScrollView.uniformItemSize = CGSizeMake(_screenWidth - 20, _screenWidth-20);
//        [horizontalScrollView setItemsMarginOnce];
//
//        NSMutableArray *buttons = [NSMutableArray array];
////            for (int i=1; i<20; i++) {
////                NSString *imageURL = [NSString stringWithFormat:@"http://lorempixel.com/%d/%d", 400 + i, 400 + i];
////
////                UIImageView *imageView = [[UIImageView alloc] init];
////                imageView.clipsToBounds = YES;
////                imageView.contentMode = UIViewContentModeScaleAspectFit;
////                [[DLImageLoader sharedInstance] imageFromUrl:imageURL completed:^(NSError *error, UIImage *img) {
////                    imageView.image =img;
////                }];
////
////                [buttons addObject:imageView];
////            }
//
//        NSMutableArray *photoURLs = [NSMutableArray array];
//        [photoURLs addObject:_event.photoURL1];
//        [photoURLs addObject:_event.photoURL2];
//        [photoURLs addObject:_event.photoURL3];
//        [photoURLs addObject:_event.photoURL4];
//
//        for (NSString *url in photoURLs) {
//            if (url != (NSString*)[NSNull null] && [url lengthOfBytesUsingEncoding:NSUTF8StringEncoding] ) {
//                NSLog(@"photo: %@", url);
//                UIImageView *imageView = [[UIImageView alloc] init];
//                imageView.clipsToBounds = YES;
//                imageView.contentMode = UIViewContentModeScaleAspectFit;
//
//                UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(imageView.frame.size.height / 2 - 25, imageView.frame.size.width / 2 - 25, 50, 50)];
//                spinner.color = _themeColor;
//                [spinner startAnimating];
//                [imageView addSubview:spinner];
//
//                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                    [[DLImageLoader sharedInstance] imageFromUrl:url completed:^(NSError *error, UIImage *img) {
//                        dispatch_async(dispatch_get_main_queue(), ^{
//                            [spinner removeFromSuperview];
//                            imageView.image = img;
//                        });
//                    }];
//                });
//                [buttons addObject:imageView];
//            }
//        }
//
//        [horizontalScrollView addItems:buttons];
//
//        horizontalScrollView.translatesAutoresizingMaskIntoConstraints = false;
//        [cell.contentView addSubview:horizontalScrollView];
//        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:horizontalScrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:_screenWidth]];
//        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:horizontalScrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
//
//        CGFloat bgRectHeight = 60;
//        CGRect bgRect = CGRectMake(0, _screenWidth - bgRectHeight, _screenWidth, bgRectHeight);
//        UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
//        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
//        blurEffectView.frame = bgRect;
////            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
////            [cell.contentView addSubview:blurEffectView];
//
//        CGFloat labelHeight = 20;
//        CGFloat iconTextMargin = 5;
//
//        UIView *time = [[UIView alloc] initWithFrame:CGRectMake(10, (bgRectHeight - labelHeight)/2, 70, labelHeight)];
//        UIImageView *timeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, labelHeight, labelHeight)];
//        timeImageView.image = [UIImage imageNamed:@"Clock"];
//        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(timeImageView.frame.origin.x + timeImageView.frame.size.width + iconTextMargin, 0, time.frame.size.width - timeImageView.frame.size.width - iconTextMargin, labelHeight)];
//        label.text = [_event formattedShortDate:_event.startDateTime];
//        label.textColor = [UIColor whiteColor];
//        [label setFont:[label.font fontWithSize:10]];
//        [time addSubview:timeImageView];
//        [time addSubview:label];
//        [blurEffectView addSubview:time];
//
//        CLLocation *location = [_locationManager locationFromLatitude:_event.latitude :_event.longitude];
//        NSString *distance = [_locationManager getDistanceFromLocation:location];
//        UIView *place = [[UIView alloc] initWithFrame:CGRectMake(time.frame.origin.x + time.frame.size.width + 10, (bgRectHeight - labelHeight)/2, 100, labelHeight)];
//        UIImageView *placeImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, labelHeight, labelHeight)];
//        placeImageView.image = [UIImage imageNamed:@"Place"];
//        UILabel *placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(placeImageView.frame.origin.x + placeImageView.frame.size.width + iconTextMargin, 0, place.frame.size.width - placeImageView.frame.size.width - iconTextMargin, labelHeight)];
//        placeLabel.text = [NSString stringWithFormat:@"%@", distance];
//        placeLabel.textColor = [UIColor whiteColor];
//        [placeLabel setFont:[placeLabel.font fontWithSize:10]];
//        [place addSubview:placeImageView];
//        [place addSubview:placeLabel];
//        [blurEffectView addSubview:place];
//
//        CGFloat attendantsViewWidth = 50;
//        UIView *attendants = [[UIView alloc] initWithFrame:CGRectMake(_screenWidth - 100, (bgRectHeight - labelHeight)/2, attendantsViewWidth, labelHeight)];
//        UIImageView * groupImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, labelHeight, labelHeight)];
//        groupImageView.image = [UIImage imageNamed:@"Profile"];
//        [attendants addSubview:groupImageView];
//
//        UILabel* groupNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(groupImageView.frame.origin.x+groupImageView.frame.size.width+iconTextMargin, 0, labelHeight, labelHeight)];
//        groupNumberLabel.text = [NSString stringWithFormat:@"%li", (long)_event.enrolled];
//        groupNumberLabel.textColor = [UIColor whiteColor];
//        groupNumberLabel.font = [groupNumberLabel.font fontWithSize:10];
//        [attendants addSubview:groupNumberLabel];
//        [blurEffectView addSubview:attendants];
//
//        UIView *fans = [[UIView alloc] initWithFrame:CGRectMake(attendants.frame.origin.x + attendants.frame.size.width, (bgRectHeight - labelHeight)/2, attendantsViewWidth, labelHeight)];
//        UIImageView * fansImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, labelHeight, labelHeight)];
//        fansImageView.image = [UIImage imageNamed:@"Heart"];
//        [fans addSubview:fansImageView];
//        UILabel* fansNumberLabel = [[UILabel alloc] initWithFrame:CGRectMake(fansImageView.frame.origin.x+fansImageView.frame.size.width+iconTextMargin, 0, labelHeight, labelHeight)];
//        fansNumberLabel.text = [NSString stringWithFormat:@"%li", (long)_event.followers];
//        fansNumberLabel.textColor = [UIColor whiteColor];
//        fansNumberLabel.font = [groupNumberLabel.font fontWithSize:10];
//        [fans addSubview:fansNumberLabel];
//        [blurEffectView addSubview:fans];
//
//        [cell.contentView addSubview:blurEffectView];
//
//        NSLog(@"Row 0 Loaded");
//        [cell layoutIfNeeded];
//    }
//    
//    if (indexPath.row == 1) {
//        NSString *hostID = [NSString stringWithFormat:@"%li", (long)_event.hostID];
//        NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"];

//        CGFloat titleLeftMargin = 10;
//        CGFloat titleTopMargin = 10;
//        CGFloat titleProportionToScreen = 0.7;
//        CGFloat titleHeight = 80;
//        UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(titleLeftMargin, titleTopMargin, titleProportionToScreen * _screenWidth, titleHeight)];
//        title.lineBreakMode = NSLineBreakByWordWrapping;
//        title.numberOfLines = 0;
//        title.text = _event.title;
//        title.font = [title.font fontWithSize:16];
//        [title sizeToFit];
//
//        CGFloat descriptionTopMargin = 5;
//        UILabel *price = [[UILabel alloc] initWithFrame:CGRectMake(titleLeftMargin, CGRectGetMaxY(title.frame) + descriptionTopMargin, titleProportionToScreen * _screenWidth, titleHeight)];
//        price.text = [NSString stringWithFormat:@"Full price: $%.2f", _event.price];
//        price.font = [price.font fontWithSize:12];
//        [price sizeToFit];
//
//        CGFloat avatarViewRightMargin = 10;
//        CGFloat avatarViewShrinkRatio = 0.6;
//        CGFloat avatarViewLength = (1-titleProportionToScreen) * _screenWidth * avatarViewShrinkRatio;
//        UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(_screenWidth - avatarViewLength - avatarViewRightMargin, titleTopMargin, avatarViewLength, avatarViewLength)];
//        [[DLImageLoader sharedInstance] imageFromUrl:_event.hostAvatarURL completed:^(NSError *error, UIImage *img) {
//            avatarView.image = img;
//
//        }];
//        avatarView.layer.cornerRadius = avatarView.frame.size.width / 2;
//        avatarView.layer.borderWidth = 1.0f;
//        avatarView.layer.borderColor = [UIColor whiteColor].CGColor;
//        avatarView.clipsToBounds = YES;
//        avatarView.userInteractionEnabled = YES;
//        [avatarView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showUser:)]];
//
//
//        CGFloat avatarTitleHeight = 20;
//        UILabel *avatarTitle = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMinX(avatarView.frame), CGRectGetMaxY(avatarView.frame), avatarView.frame.size.width, avatarTitleHeight)];
//        avatarTitle.font = [avatarTitle.font fontWithSize:12];
//        avatarTitle.lineBreakMode = NSLineBreakByWordWrapping;
//        avatarTitle.numberOfLines = 0;
//        avatarTitle.text = _event.hostFullName;
//        avatarTitle.textAlignment = NSTextAlignmentCenter;
//        [avatarTitle sizeToFit];
//        if (avatarTitle.frame.size.width < avatarView.frame.size.width) {
//            avatarTitle.center = CGPointMake(avatarTitle.center.x + (avatarView.frame.size.width - avatarTitle.frame.size.width)/2, avatarTitle.center.y);
//        }
//
//        [cell.contentView addSubview:title];
//        [cell.contentView addSubview:price];
//        [cell.contentView addSubview:avatarView];
//        [cell.contentView addSubview:avatarTitle];
//
//        UIView *previous = price;
//        UILabel *deposit = [[UILabel alloc] initWithFrame:CGRectMake(titleLeftMargin, CGRectGetMaxY(previous.frame) + descriptionTopMargin, titleProportionToScreen * _screenWidth, titleHeight)];
//        deposit.text = [NSString stringWithFormat:@"Deposit required: $%.2f", _event.deposit];
//        deposit.font = [deposit.font fontWithSize:12];
//        deposit.textColor = _themeColor;
//        [deposit sizeToFit];
//        [cell.contentView addSubview:deposit];
//        previous = deposit;
//
//        UILabel *eventTime = [[UILabel alloc] initWithFrame:CGRectMake(titleLeftMargin, CGRectGetMaxY(previous.frame) + descriptionTopMargin, _screenWidth - avatarViewRightMargin - avatarViewLength, titleHeight)];
//        eventTime.lineBreakMode = NSLineBreakByWordWrapping;
//        eventTime.numberOfLines = 0;
//        eventTime.text = [_event formattedEventStartAndEndTime];
//        eventTime.font = [eventTime.font fontWithSize:12];
//        eventTime.textColor = _themeColor;
//        [eventTime sizeToFit];
//        [cell.contentView addSubview:eventTime];
//        previous = eventTime;
//
//        UILabel *eventPlace = [[UILabel alloc] initWithFrame:CGRectMake(titleLeftMargin, CGRectGetMaxY(previous.frame) + descriptionTopMargin, _screenWidth - avatarViewRightMargin - avatarViewLength, titleHeight)];
//        eventPlace.lineBreakMode = NSLineBreakByWordWrapping;
//        eventPlace.numberOfLines = 0;
//        eventPlace.text = _event.locationName;
//        eventPlace.font = [eventPlace.font fontWithSize:12];
//        eventPlace.textColor = _themeColor;
//        [eventPlace sizeToFit];
//        [cell.contentView addSubview:eventPlace];
//        previous = eventPlace;
//
//        UILabel *description = [[UILabel alloc] initWithFrame:CGRectMake(titleLeftMargin, CGRectGetMaxY(previous.frame) + descriptionTopMargin, _screenWidth - avatarViewRightMargin - titleLeftMargin, titleHeight)];
//        description.lineBreakMode = NSLineBreakByWordWrapping;
//        description.numberOfLines = 0;
//        NSString * htmlString = [NSString stringWithFormat:@"%@%@%@", @"<html><body>", _event.description1, @"</body></html>"];
//        NSLog(@"event description %@", htmlString);
//        NSAttributedString * attrStr = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUTF8StringEncoding] options:@
//        { NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType }
//                                                             documentAttributes:nil error:nil];
//        description.attributedText = attrStr;
//        description.font = [UIFont systemFontOfSize:12];
//        [description sizeToFit];
//        [cell.contentView addSubview:description];
//        previous = description;
//
//        // Enroll Button
//        CGFloat enrollBtnTopMargin = 5;
//        CGFloat enrollBtnHeight = 40;
//        UILabel* enrollBtn = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(previous.frame) + enrollBtnTopMargin , _screenWidth, enrollBtnHeight)];
//        enrollBtn.textAlignment = NSTextAlignmentCenter;
//        enrollBtn.textColor = _themeColor;
//        enrollBtn.font = [enrollBtn.font fontWithSize:16];
//        if([self userHasEnrolledInEvent]) {
//            enrollBtn.text = @"You Are Registered For This Event";
//            enrollBtn.userInteractionEnabled = NO;
//        } else {
//            enrollBtn.text = @"Enroll";
//            enrollBtn.userInteractionEnabled = YES;
//            [enrollBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startEnroll:)]];
//        }
//        [cell.contentView addSubview:enrollBtn];
//
//        if (_event.enrolled < _event.maxAttendees) {
//            enrollBtn.hidden = NO;
//            previous = enrollBtn;
//        } else {
//            enrollBtn.hidden = YES;
//        }
//
//        // Bookmark Button
//        CGFloat bookmarkBtnTopMargin = 5;
//        CGFloat bookmarkBtnHeight = 40;
//        UILabel* bookmarkBtn = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(previous.frame) + bookmarkBtnTopMargin , _screenWidth, bookmarkBtnHeight)];
//        bookmarkBtn.textAlignment = NSTextAlignmentCenter;
//        bookmarkBtn.textColor = _themeColor;
//        bookmarkBtn.font = [bookmarkBtn.font fontWithSize:16];
//        if ([self userHasBookmarkedEvent]) {
//            bookmarkBtn.text = @"Bookmarked";
//            bookmarkBtn.userInteractionEnabled = NO;
//        } else {
//            bookmarkBtn.text = @"Bookmark";
//            bookmarkBtn.userInteractionEnabled = YES;
//            [bookmarkBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bookmarkEvent:)]];
//        }
//        [cell.contentView addSubview:bookmarkBtn];
//        previous = bookmarkBtn;
//
//        // Chat Button
//        CGFloat chatBtnTopMargin = 5;
//        CGFloat chatBtnHeight = 40;
//        UILabel* chatBtn = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(previous.frame) + chatBtnTopMargin , _screenWidth, chatBtnHeight)];
//        chatBtn.textAlignment = NSTextAlignmentCenter;
//        chatBtn.textColor = _themeColor;
//        chatBtn.font = [chatBtn.font fontWithSize:16];
//        chatBtn.text = @"Chat";
//        chatBtn.userInteractionEnabled = YES;
//        [chatBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startChat:)]];
//        [cell.contentView addSubview:chatBtn];
//        previous = chatBtn;
//
//        // Edit Button -- Only show if event is owned by active user
//        CGFloat editBtnTopMargin = 5;
//        CGFloat editBtnHeight = 40;
//        UILabel* editBtn = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(previous.frame) + editBtnTopMargin , _screenWidth, editBtnHeight)];
//        editBtn.textAlignment = NSTextAlignmentCenter;
//        editBtn.textColor = _themeColor;
//        editBtn.font = [editBtn.font fontWithSize:16];
//        editBtn.text = @"Edit Event";
//        editBtn.userInteractionEnabled = YES;
//        [editBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startEdit:)]];
////            if ([hostID isEqualToString:userID]) { [cell.contentView addSubview:editBtn]; }
//        [cell.contentView addSubview:editBtn]; // DEBUG ONLY
//
//        /* Fix for cell.contentView height */
//        CGRect originalFrame = cell.contentView.frame;  // original contentView frame -- the default row height is 44
//        CGFloat totalHeight = 20;                       // this is a running total of all heights for ui elements placed along the y-axis plus a 20 point margin
//        totalHeight += title.frame.size.height;
//        totalHeight += price.frame.size.height;
//        totalHeight += deposit.frame.size.height;
//        totalHeight += eventTime.frame.size.height;
//        totalHeight += eventPlace.frame.size.height;
//        totalHeight += description.frame.size.height;
//        totalHeight += enrollBtn.frame.size.height;
//        totalHeight += bookmarkBtn.frame.size.height;
//        totalHeight += chatBtn.frame.size.height;
////            if ([hostID isEqualToString:userID]) { totalHeight += editBtn.frame.size.height; }
//        totalHeight += editBtn.frame.size.height;
//        cell.contentView.frame = CGRectMake(originalFrame.origin.x, originalFrame.origin.y, originalFrame.size.width, originalFrame.size.height + totalHeight);    // create a new frame for cell.contentView -- this is referenced in tableView:heightForRowAtIndexPath
//    }
    
    NSString *hostID = [NSString stringWithFormat:@"%li", (long)_event.hostID];
    NSString *userID = [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"];
    NSInteger positionX;
    NSInteger positionY;
    
    
    ASHorizontalScrollView *photosScroll = [self uiPhotosScroll];
    [cell.contentView addSubview:photosScroll];
    photosScroll.translatesAutoresizingMaskIntoConstraints = false;
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:photosScroll attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:_screenWidth]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:photosScroll attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
    
    positionX = 0;
    positionY = CGRectGetMaxY(photosScroll.frame) - 64;
    UIView *price = [self uiPriceView:positionX y: positionY];
    [cell.contentView addSubview:price];
    
    
    if (![hostID isEqualToString:userID]) {
        positionX = _screenWidth - 102;
        positionY = CGRectGetMaxY(photosScroll.frame) - 18;
        UIButton *chatButton = [self uiChatButton:positionX y: positionY];
        [cell.contentView addSubview:chatButton];
        
        positionX = _screenWidth - 56;
        positionY = CGRectGetMaxY(photosScroll.frame) - 18;
        UIButton *favoriteButton = [self uiFavoriteButton:positionX y:positionY];
        [cell.contentView addSubview:favoriteButton];
    } else {
        positionX = _screenWidth - 56;
        positionY = CGRectGetMaxY(photosScroll.frame) - 18;
        UIButton *editButton = [self uiEditButton:positionX y:positionY];
        [cell.contentView addSubview:editButton];
    }
    
    positionX = 20;
    positionY = CGRectGetMaxY(photosScroll.frame) + 30;
    UILabel *title = [self uiTitleLabel:positionX y:positionY];
    [cell.contentView addSubview:title];
    
    positionX = 20;
    positionY = CGRectGetMaxY(title.frame) + 20;
    UILabel *hr1 = [self uiHorizontalRule:positionX y:positionY];
    [cell.contentView addSubview:hr1];
    
    positionX = 20;
    positionY = CGRectGetMaxY(hr1.frame) + 20;
    UIView *host = [self uiHostViewWithAvatar:positionX y:positionY];
    [cell.contentView addSubview:host];
    
    positionX = 20;
    positionY = CGRectGetMaxY(host.frame) + 20;
    UILabel *hr2 = [self uiHorizontalRule:positionX y:positionY];
    [cell.contentView addSubview:hr2];
    
    positionX = 20;
    positionY = CGRectGetMaxY(hr2.frame) + 20;
    UIView *description = [self uiDescriptionLabel:positionX y:positionY];
    [cell.contentView addSubview:description];
    
    positionX = 20;
    positionY = CGRectGetMaxY(description.frame) + 20;
    UILabel *hr3 = [self uiHorizontalRule:positionX y:positionY];
    [cell.contentView addSubview:hr3];
    
    positionX = 20;
    positionY = CGRectGetMaxY(hr3.frame) + 20;
    UIView *time = [self uiTimeView:positionX y:positionY];
    [cell.contentView addSubview:time];
    
    positionX = 20;
    positionY = CGRectGetMaxY(time.frame) + 20;
    UILabel *hr4 = [self uiHorizontalRule:positionX y:positionY];
    [cell.contentView addSubview:hr4];
    
    positionX = 20;
    positionY = CGRectGetMaxY(hr4.frame) + 20;
    UILabel *locationName = [self uiLocationLabel:positionX y:positionY];
    [cell.contentView addSubview:locationName];
    
    positionX = 0;
    positionY = CGRectGetMaxY(locationName.frame) + 20;
    _mapView = [self uiMapView:positionX y:positionY];
    [cell.contentView addSubview:_mapView];
    
    positionX = 20;
    positionY = CGRectGetMaxY(_mapView.frame) + 20;
    UILabel *address = [self uiAddressLabel:positionX y:positionY];
    [cell.contentView addSubview:address];
    
    positionX = 20;
    positionY = CGRectGetMaxY(address.frame) + 20;
    UILabel *hr5 = [self uiHorizontalRule:positionX y:positionY];
    [cell.contentView addSubview:hr5];
    
    positionX = 20;
    positionY = CGRectGetMaxY(hr5.frame) + 20;
    UIView *attendees = [self uiAttendeesView:positionX y:positionY];
    [cell.contentView addSubview:attendees];
    
    positionX = 20;
    positionY = CGRectGetMaxY(attendees.frame) + 20;
    UILabel *hr6 = [self uiHorizontalRule:positionX y:positionY];
    [cell.contentView addSubview:hr6];
    
    positionX = 20;
    positionY = CGRectGetMaxY(hr6.frame) + 20;
    UIView *followers = [self uiFollowersView:positionX y:positionY];
    [cell.contentView addSubview:followers];
    
    positionX = 20;
    positionY = CGRectGetMaxY(followers.frame) + 20;
    UILabel *hr7 = [self uiHorizontalRule:positionX y:positionY];
    [cell.contentView addSubview:hr7];
    
    positionX = 20;
    positionY = CGRectGetMaxY(hr7.frame) + 20;
    UIView *deposit = [self uiDepositView:positionX y:positionY];
    [cell.contentView addSubview:deposit];
    
    
#pragma mark - Fix for Variable Row Height
    CGRect originalFrame = cell.contentView.frame;  // original contentView frame -- the default row height is 44
    CGFloat totalHeight = 69;                       // this is a running total of all heights for ui elements placed along the y-axis plus a 69 point margin
    totalHeight += CGRectGetMaxY(deposit.frame);  // this should be the last element in the cell
    cell.contentView.frame = CGRectMake(originalFrame.origin.x, originalFrame.origin.y, originalFrame.size.width, originalFrame.size.height + totalHeight);    // create a new frame for cell.contentView -- this is referenced in tableView:heightForRowAtIndexPath
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    // Get the cell so we can measure the contentView
    UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
    return cell.contentView.frame.size.height;
}

#pragma mark - UI Elements

- (ASHorizontalScrollView *) uiPhotosScroll {
    ASHorizontalScrollView *horizontalScrollView = [[ASHorizontalScrollView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenWidth)];
    horizontalScrollView.leftMarginPx = 0;
    horizontalScrollView.miniAppearPxOfLastItem = 0;
    horizontalScrollView.uniformItemSize = CGSizeMake(_screenWidth, _screenWidth);
//    [horizontalScrollView setItemsMarginOnce];

    NSMutableArray *buttons = [NSMutableArray array];
    NSMutableArray *photoURLs = [NSMutableArray array];
    [photoURLs addObject:_event.photoURL1];
    [photoURLs addObject:_event.photoURL2];
    [photoURLs addObject:_event.photoURL3];
    [photoURLs addObject:_event.photoURL4];

    for (NSString *url in photoURLs) {
        if (url != (NSString*)[NSNull null] && [url lengthOfBytesUsingEncoding:NSUTF8StringEncoding] ) {
            NSLog(@"photo: %@", url);
            UIImageView *imageView = [[UIImageView alloc] init];
            
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(imageView.frame.size.height / 2 - 25, imageView.frame.size.width / 2 - 25, 50, 50)];
            spinner.color = _themeColor;
            [spinner startAnimating];
            [imageView addSubview:spinner];

            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[DLImageLoader sharedInstance] imageFromUrl:url completed:^(NSError *error, UIImage *img) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [spinner removeFromSuperview];
                        imageView.image = img;
                    });
                }];
            });
            [buttons addObject:imageView];
        }
    }

    [horizontalScrollView addItems:buttons];
    
    return horizontalScrollView;
}

- (UIButton *) uiChatButton: (NSInteger)x y:(NSInteger)y {
    UIImage *image = [[UIImage imageNamed:@"chat_24pt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, 36, 36)];
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 18;
    [button setImage:image forState:UIControlStateNormal];
    [button setTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
    button.layer.masksToBounds = NO;
    button.layer.shadowOffset = CGSizeMake(0, 1);
    button.layer.shadowRadius = 0.5;
    button.layer.shadowOpacity = 0.1;
    button.adjustsImageWhenHighlighted = NO;
    button.userInteractionEnabled = YES;
    [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(startChat:)]];
    
    return button;
}

- (UILabel *) uiShareButton: (NSInteger)x y:(NSInteger)y {
    NSTextAttachment *shareIcon = [[NSTextAttachment alloc] init];
    shareIcon.image = [UIImage imageNamed:@"Heart"];
    shareIcon.bounds = CGRectMake(6, 0, 24, 24);
    
    UILabel *shareBtn = [[UILabel alloc] initWithFrame:CGRectMake(x, y, 36, 36)];
    shareBtn.attributedText = [NSAttributedString attributedStringWithAttachment:shareIcon];
    shareBtn.backgroundColor = [UIColor whiteColor];
    shareBtn.layer.cornerRadius = 18;
    shareBtn.layer.masksToBounds = YES;
    shareBtn.userInteractionEnabled = YES;
//    [shareBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bookmarkEvent:)]];

    return shareBtn;
}

- (UIButton *) uiFavoriteButton: (NSInteger)x y:(NSInteger)y {
    UIImage *image;
    
    if ([self userHasBookmarkedEvent]) {
        image = [[UIImage imageNamed:@"favorite_solid_24pt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    } else {
        image = [[UIImage imageNamed:@"favorite_border_24pt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, 36, 36)];
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 18;
    [button setImage:image forState:UIControlStateNormal];
    
    if ([self userHasBookmarkedEvent]) {
        [button setTintColor:_themeColor];
    } else {
        [button setTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
    }
    
    button.layer.masksToBounds = NO;
    button.layer.shadowOffset = CGSizeMake(0, 1);
    button.layer.shadowRadius = 0.5;
    button.layer.shadowOpacity = 0.1;
    button.adjustsImageWhenHighlighted = NO;
    button.userInteractionEnabled = YES;
    [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleFavorite:)]];
    
    return button;
}

- (UIButton *) uiEditButton: (NSInteger)x y:(NSInteger)y {
    UIImage *image = [[UIImage imageNamed:@"edit_24pt"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *button = [[UIButton alloc] initWithFrame:CGRectMake(x, y, 36, 36)];
    button.backgroundColor = [UIColor whiteColor];
    button.layer.cornerRadius = 18;
    [button setImage:image forState:UIControlStateNormal];
    [button setTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
    button.layer.masksToBounds = NO;
    button.layer.shadowOffset = CGSizeMake(0, 1);
    button.layer.shadowRadius = 0.5;
    button.layer.shadowOpacity = 0.1;
    button.adjustsImageWhenHighlighted = NO;
    button.userInteractionEnabled = YES;
//    [button addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(bookmarkEvent:)]];
    
    return button;
}

- (UILabel *) uiTitleLabel: (NSInteger)x y:(NSInteger)y {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, _screenWidth - 40, 24)];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.text = _event.title;
    [label setFont:[UIFont boldSystemFontOfSize:24]];
//    label.font = [label.font fontWithSize:24];
    [label sizeToFit];
    
    return label;
}

- (UIView *) uiPriceView: (NSInteger)x y:(NSInteger)y {
    UIView *priceView = [[UIView alloc] initWithFrame:CGRectMake(x, y, 150, 36)];
    priceView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.3];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(20, 7, 130, 36)];
    label.lineBreakMode = NSLineBreakByClipping;
    label.numberOfLines = 0;
    label.text = [NSString stringWithFormat:@"$ %0.0f", _event.price];
    label.textColor = [UIColor whiteColor];
    label.font = [label.font fontWithSize:18];
    [label sizeToFit];
    
    [priceView setFrame:CGRectMake(x, y, label.frame.size.width + 30, 36)];
    [priceView addSubview:label];
    
    return priceView;
}

- (UIView *) uiHostViewWithAvatar: (NSInteger)x y:(NSInteger)y {
    UIView *hostView = [[UIView alloc] initWithFrame:CGRectMake(x, y, _screenWidth - 40, 48)];
    
    UILabel *hostLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 4, 150, 36)];
    hostLabel.lineBreakMode = NSLineBreakByClipping;
    hostLabel.numberOfLines = 0;
    hostLabel.text = @"Hosted by";
    hostLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    hostLabel.font = [hostLabel.font fontWithSize:12];
    [hostLabel sizeToFit];
    
    [hostView addSubview:hostLabel];
    
    UILabel *hostNameLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, 150, 36)];
    hostNameLabel.lineBreakMode = NSLineBreakByClipping;
    hostNameLabel.numberOfLines = 0;
    hostNameLabel.text = _event.hostFullName;
    hostNameLabel.font = [hostNameLabel.font fontWithSize:16];
    [hostNameLabel sizeToFit];
    
    [hostView addSubview:hostNameLabel];
    
    UIImageView *avatarView = [[UIImageView alloc] initWithFrame:CGRectMake(hostView.frame.size.width - 48, 0, 48, 48)];
    [[DLImageLoader sharedInstance] imageFromUrl:_event.hostAvatarURL completed:^(NSError *error, UIImage *image) {
        avatarView.image = image;
    }];
    avatarView.layer.cornerRadius = avatarView.frame.size.width / 2;
    avatarView.clipsToBounds = YES;
    avatarView.userInteractionEnabled = YES;
    
    [hostView addSubview:avatarView];
    
    return hostView;
}

- (UILabel *) uiDescriptionLabel: (NSInteger)x y:(NSInteger)y {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, _screenWidth - 40, 16)];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.text = _event.description1;
    label.font = [label.font fontWithSize:16];
    [label sizeToFit];
    
    return label;
}

- (UIView *) uiTimeView: (NSInteger)x y:(NSInteger)y {
    UIView *timeView = [[UIView alloc] initWithFrame:CGRectMake(x, y, _screenWidth - 40, 48)];
    
    UILabel *startTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, timeView.frame.size.width / 2, 36)];
    startTimeLabel.lineBreakMode = NSLineBreakByClipping;
    startTimeLabel.numberOfLines = 0;
    startTimeLabel.text = [NSString stringWithFormat:@"%@", [_event formattedShortTime:_event.startDateTime]];
    startTimeLabel.textAlignment = NSTextAlignmentCenter;
    startTimeLabel.font = [startTimeLabel.font fontWithSize:24];
    
    [timeView addSubview:startTimeLabel];
    
    UILabel *startLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 36, timeView.frame.size.width / 2, 12)];
    startLabel.lineBreakMode = NSLineBreakByClipping;
    startLabel.numberOfLines = 0;
    startLabel.text = [NSString stringWithFormat:@"%@", [_event formattedShortDate:_event.startDateTime]];
    startLabel.textAlignment = NSTextAlignmentCenter;
    startLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    startLabel.font = [startLabel.font fontWithSize:12];
    
    [timeView addSubview:startLabel];
    
    UILabel *endTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeView.frame.size.width / 2, 0, timeView.frame.size.width / 2, 36)];
    endTimeLabel.lineBreakMode = NSLineBreakByClipping;
    endTimeLabel.numberOfLines = 0;
    endTimeLabel.text = [NSString stringWithFormat:@"%@", [_event formattedShortTime:_event.endDateTime]];
    endTimeLabel.textAlignment = NSTextAlignmentCenter;
    endTimeLabel.font = [endTimeLabel.font fontWithSize:24];
    
    [timeView addSubview:endTimeLabel];
    
    UILabel *endLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeView.frame.size.width / 2, 36, timeView.frame.size.width / 2, 12)];
    endLabel.lineBreakMode = NSLineBreakByClipping;
    endLabel.numberOfLines = 0;
    endLabel.text = [NSString stringWithFormat:@"%@", [_event formattedShortDate:_event.endDateTime]];
    endLabel.textAlignment = NSTextAlignmentCenter;
    endLabel.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    endLabel.font = [endLabel.font fontWithSize:12];
    
    [timeView addSubview:endLabel];
    
    return timeView;
}

- (UILabel *) uiLocationLabel: (NSInteger)x y:(NSInteger)y {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, _screenWidth - 40, 18)];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.text = _event.locationName;
    label.textAlignment = NSTextAlignmentCenter;
    [label setFont:[UIFont boldSystemFontOfSize:18]];
    
    return label;
}

- (GMSMapView *) uiMapView: (NSInteger)x y:(NSInteger)y {
    GMSMapView *mapView = [GMSMapView mapWithFrame:CGRectMake(x, y, _screenWidth, _screenWidth) camera:_camera];
    [mapView.settings setAllGesturesEnabled:NO];
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = _camera.target;
    marker.snippet = _event.locationName;
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = mapView;
    
    return mapView;
}

- (UILabel *) uiAddressLabel: (NSInteger)x y:(NSInteger)y {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, _screenWidth - 40, 18)];
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 0;
    label.text = _event.address;
    label.textAlignment = NSTextAlignmentCenter;
    [label setFont:[UIFont boldSystemFontOfSize:18]];
    
    return label;
}

- (UIView *) uiAttendeesView: (NSInteger)x y:(NSInteger)y {
    UIView *attendeesView = [[UIView alloc] initWithFrame:CGRectMake(x, y, _screenWidth - 40, 36)];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    image.image = [UIImage imageNamed:@"attendees_36pt"];
    image.image = [image.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [image setTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
    
    [attendeesView addSubview:image];
    
    UILabel *attendeesLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, 0, attendeesView.frame.size.width / 2 - 48, 36)];
    attendeesLabel.lineBreakMode = NSLineBreakByClipping;
    attendeesLabel.numberOfLines = 0;
    attendeesLabel.text = @"Attendees";
    attendeesLabel.textAlignment = NSTextAlignmentLeft;
    attendeesLabel.font = [attendeesLabel.font fontWithSize:18];
    
    [attendeesView addSubview:attendeesLabel];
    
    UILabel *attendees = [[UILabel alloc] initWithFrame:CGRectMake(attendeesView.frame.size.width / 2, 0, attendeesView.frame.size.width / 2, 36)];
    attendees.lineBreakMode = NSLineBreakByClipping;
    attendees.numberOfLines = 0;
    attendees.text = [NSString stringWithFormat:@"%li", _event.enrolled];
    attendees.textAlignment = NSTextAlignmentRight;
    attendees.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    attendees.font = [attendees.font fontWithSize:18];
    
    [attendeesView addSubview:attendees];
    
    return attendeesView;
}

- (UIView *) uiFollowersView: (NSInteger)x y:(NSInteger)y {
    UIView *followersView = [[UIView alloc] initWithFrame:CGRectMake(x, y, _screenWidth - 40, 36)];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    image.image = [UIImage imageNamed:@"favorite_solid_36pt"];
    image.image = [image.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [image setTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
    
    [followersView addSubview:image];
    
    UILabel *followersLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, 0, followersView.frame.size.width / 2 - 48, 36)];
    followersLabel.lineBreakMode = NSLineBreakByClipping;
    followersLabel.numberOfLines = 0;
    followersLabel.text = @"Followers";
    followersLabel.textAlignment = NSTextAlignmentLeft;
    followersLabel.font = [followersLabel.font fontWithSize:18];
    
    [followersView addSubview:followersLabel];
    
    UILabel *followers = [[UILabel alloc] initWithFrame:CGRectMake(followersView.frame.size.width / 2, 0, followersView.frame.size.width / 2, 36)];
    followers.lineBreakMode = NSLineBreakByClipping;
    followers.numberOfLines = 0;
    followers.text = [NSString stringWithFormat:@"%li", _event.followers];
    followers.textAlignment = NSTextAlignmentRight;
    followers.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    followers.font = [followers.font fontWithSize:18];
    
    [followersView addSubview:followers];
    
    return followersView;
}

- (UIView *) uiDepositView: (NSInteger)x y:(NSInteger)y {
    UIView *depositView = [[UIView alloc] initWithFrame:CGRectMake(x, y, _screenWidth - 40, 36)];
    
    UIImageView *image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 36, 36)];
    image.image = [UIImage imageNamed:@"deposit_36pt"];
    image.image = [image.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    [image setTintColor:[UIColor colorWithRed:0 green:0 blue:0 alpha:0.2]];
    
    [depositView addSubview:image];
    
    UILabel *depositLabel = [[UILabel alloc] initWithFrame:CGRectMake(48, 0, depositView.frame.size.width / 2, 36)];
    depositLabel.lineBreakMode = NSLineBreakByClipping;
    depositLabel.numberOfLines = 0;
    depositLabel.text = @"Deposit Required";
    depositLabel.textAlignment = NSTextAlignmentLeft;
    depositLabel.font = [depositLabel.font fontWithSize:18];
    
    [depositView addSubview:depositLabel];
    
    UILabel *deposit = [[UILabel alloc] initWithFrame:CGRectMake(depositView.frame.size.width / 2, 0, depositView.frame.size.width / 2, 36)];
    deposit.lineBreakMode = NSLineBreakByClipping;
    deposit.numberOfLines = 0;
    deposit.text = [NSString stringWithFormat:@"$ %0.0f", _event.deposit];
    deposit.textAlignment = NSTextAlignmentRight;
    deposit.textColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.4];
    deposit.font = [deposit.font fontWithSize:18];
    
    [depositView addSubview:deposit];
    
    return depositView;
}

- (UILabel *)uiRegisterButton {
    UILabel *registerBtn = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.view.bounds), _screenWidth, 49)];
    registerBtn.backgroundColor = _themeColor;
    registerBtn.text = @"Register";
    registerBtn.textAlignment = NSTextAlignmentCenter;
    registerBtn.textColor = [UIColor whiteColor];
    [registerBtn setFont:[UIFont boldSystemFontOfSize:16]];
    return registerBtn;
}

- (UILabel *)uiHorizontalRule: (NSInteger)x y:(NSInteger)y {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(x, y, _screenWidth - 40, 1)];
    label.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.1];
    
    return label;
}

#pragma mark - UI Methods

- (void) startChat: (id) sender {
    DemoMessagesViewController *vc = [DemoMessagesViewController messagesViewController];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) startEnroll: (id) sender {
    NSLog(@"enrolling");
    _enrollBtn = (UILabel*)((UITapGestureRecognizer*) sender).view;
    ((AppDelegate *)[UIApplication sharedApplication].delegate).enrollBtn = _enrollBtn;
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]) {
        ((AppDelegate *)[UIApplication sharedApplication].delegate).eVC = self;
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@%@%@", kAppBaseURL, @"/checkout?event_id=", self.id, @"&fromMobile=true"]]];
    }
    else {
        LoginViewController *vc = [[LoginViewController alloc] init];
        vc.evc = self;
        vc.currentAction = @"enroll";
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void) startEdit: (id) sender {
    NativeEventFormViewController *vc = [[NativeEventFormViewController alloc] init];
    vc.isEditing = YES;
    vc.event = _event;
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) bookmarkEvent: (id) sender {
    _bookmarkBtn = (UILabel*)((UITapGestureRecognizer*) sender).view;
    ((AppDelegate *)[UIApplication sharedApplication].delegate).bookmarkBtn = _bookmarkBtn;
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]) {
        ((AppDelegate *)[UIApplication sharedApplication].delegate).eVC = self;
        NSLog(@"adding bookmark");
        NSLog(@"Event ID: %@", [NSString stringWithFormat:@"%i", _event.eventID]);
        NSLog(@"User ID: %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]);
        
        operationQueue = [NSOperationQueue new];
        NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(postData) object:nil];
        [operationQueue addOperation:operation];
    } else {
        LoginViewController *vc = [[LoginViewController alloc] init];
        vc.evc = self;
        vc.currentAction = @"bookmark";
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void) toggleFavorite: (id) sender {
    _bookmarkBtn = (UIButton*)((UITapGestureRecognizer*) sender).view;
    ((AppDelegate *)[UIApplication sharedApplication].delegate).bookmarkBtn = _bookmarkBtn;
    
    if ([[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]) {
        ((AppDelegate *)[UIApplication sharedApplication].delegate).eVC = self;
        NSLog(@"toggling favorite");
        NSLog(@"Event ID: %@", [NSString stringWithFormat:@"%li", (long)_event.eventID]);
        NSLog(@"User ID: %@", [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"]);
        
        operationQueue = [NSOperationQueue new];
        NSInvocationOperation *operation;
        if (![self userHasBookmarkedEvent]) {
            NSLog(@"moving to add favorite");
            operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(addFavorite) object:nil];
        } else {
            NSLog(@"moving to remove favorite");
            operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(removeFavorite) object:nil];
        }
        [operationQueue addOperation:operation];
    } else {
        LoginViewController *vc = [[LoginViewController alloc] init];
        vc.evc = self;
        vc.currentAction = @"bookmark";
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - AFNetworking
- (void) getEvent {
    NSLog(@"getEvent called");
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kAppBaseURL]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString *path = @"/event";
    [manager GET:[NSString stringWithFormat:@"%@%@?id=%i", kAppBaseURL, path, _event.eventID] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSLog(@"JSON: %@", (NSDictionary *) responseObject);
        [_event parseData:responseObject completion:^(BOOL success) {
            if (success) {
                NSLog(@"Success! Data Reloaded");
//                [_eventTable performSelectorOnMainThread:@selector(reloadSections:withRowAnimation:NO) withObject:nil waitUntilDone:NO];
                [_eventTable performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
            }
        }];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
}

- (void) postData {
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"];
    NSString *eid = [NSString stringWithFormat:@"%li", (long)_event.eventID];
    NSString *paramString = [NSString stringWithFormat:@"{\"user_id\":%@,\"event_id\":%@}", uid, eid];
    NSError *error;
    NSData *objectData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&error];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kAppBaseURL]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString* path = @"/interests";
    [manager POST:[NSString stringWithFormat:@"%@%@", kAppBaseURL, path] parameters:json progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if([responseObject[@"message"]  isEqual: @"record already exists"]) {
            [SVProgressHUD showInfoWithStatus:@"It looks like you've already bookmarked this event. You must be very excited!"];
        } else {
            [SVProgressHUD showInfoWithStatus:@"This event has been successfully bookmarked."];
            operationQueue = [NSOperationQueue new];
            NSInvocationOperation *getEvent = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getEvent) object:nil];
            [operationQueue addOperation:getEvent];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [SVProgressHUD showErrorWithStatus:@"Something went wrong! This event has not been bookmarked."];
    }];
}

- (void) addFavorite {
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"];
    NSString *eid = [NSString stringWithFormat:@"%li", (long)_event.eventID];
    NSString *paramString = [NSString stringWithFormat:@"{\"user_id\":%@,\"event_id\":%@}", uid, eid];
    NSError *error;
    NSData *objectData = [paramString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&error];
    
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kAppBaseURL]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString* path = @"/interests";
    [manager POST:[NSString stringWithFormat:@"%@%@", kAppBaseURL, path] parameters:json progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        if([responseObject[@"message"]  isEqual: @"record already exists"]) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"I'm Seeing Double" message:@"It looks like you've already bookmarked this event. You must be very excited!" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Bookmark Added" message:@"This event has been successfully bookmarked." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alert show];
            
            operationQueue = [NSOperationQueue new];
            NSInvocationOperation *getEvent = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(getEvent) object:nil];
            [operationQueue addOperation:getEvent];
        }
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Something went wrong! This event has not been bookmarked." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
    }];
}

- (void) removeFavorite {
    
}

- (void) showUser: (id) sender {
    UserViewController *vc = [[UserViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

- (void) showInfoOnSuccessfulPayment {
    [SVProgressHUD showSuccessWithStatus:@"Payment Success"];
    self.paymentSuccess = YES;
}


- (void) showInfoOnFailedPayment {
    [SVProgressHUD showErrorWithStatus:@"Payment Failed"];
}

#pragma mark - Share Event

- (void) shareEvent {
    // TODO: - What data do we want to share?
    // Right now only the event title and address is being shared.
    UIActivityViewController *activityViewController = [[UIActivityViewController alloc] initWithActivityItems:@[_event.title, _event.address] applicationActivities:nil];
    [self presentViewController:activityViewController animated:YES completion:nil];
}

#pragma mark - UI Validation

- (BOOL) userHasEnrolledInEvent {
    NSLog(@"Enrolled Users: %@", _event.enrolledUsers);
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"];
    if ([_event.enrolledUsers containsObject:uid]) {
        return YES;
    }
    return NO;
}

- (BOOL) userHasBookmarkedEvent {
    NSString *uid = [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"];
    if ([_event.interestedUsers containsObject:uid]) {
        return YES;
    }
    return NO;
}

#pragma mark - Google Maps

- (void) initializeMapView {
    NSString *kMapsAPIKey = @"AIzaSyCkQhCB7_xTWaeUTdBG3-xNxar0jfjbzzs";
    [GMSServices provideAPIKey:kMapsAPIKey];
    _camera = [GMSCameraPosition cameraWithLatitude:_event.latitude longitude:_event.longitude zoom:14];
}

@end
