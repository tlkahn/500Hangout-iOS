//
//  ViewController.m
//  projecthang
//
//  Created by toeinriver on 7/28/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "ViewController.h"
#import "HANLocationManager.h"
#import <objc/runtime.h>
#import "AppConstants.h"
#import "EventCategory.h"
#import "SuperHost.h"
#import "Facility.h"
#import "withPicURL.h"

@interface ViewController ()
@property (strong, nonatomic) NSURL* baseURL;
@property (assign, nonatomic) float screenWidth;
@property (strong, nonatomic) UISearchBar* searchBar;
@property (strong, nonatomic) UILabel* label;
@property (strong, nonatomic) UILabel* txtLabel;
@property (strong, nonatomic) NSString* appTitle;
@property (strong, nonatomic) UIColor* themeColor;
@property (strong, nonatomic) HANLocationManager *locationManager;
@property (strong, nonatomic) NSMutableArray<EventCategory*>* eventCategories;
@property (strong, nonatomic) NSMutableArray<SuperHost*>* superHosts;
@property (strong, nonatomic) NSMutableArray<Facility*>* facilities;
@end

@implementation ViewController

//- (IBAction)fetch:(id)sender {
//    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:_baseURL];
//    manager.requestSerializer = [AFJSONRequestSerializer serializer];
//    manager.responseSerializer = [AFJSONResponseSerializer serializer];
//    NSString* path = @"/events";
//    [manager GET:[NSString stringWithFormat:@"%@%@", _baseURL.absoluteString, path] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//        NSLog(@"JSON: %@", (NSDictionary *) responseObject);
//    } failure:^(NSURLSessionTask *operation, NSError *error) {
//        NSLog(@"Error: %@", error);
//    }];
//}

float kCellHeight = 60.0f;

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 7;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (indexPath.row == 0) {
        static NSString *identifier = @"FirstRow";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            kCellHeight = _screenWidth;
            coverImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenWidth)];
            
            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(coverImageView.frame.size.height / 2 - 25, coverImageView.frame.size.width / 2 - 25, 50, 50)];
            spinner.color = _themeColor;
            [spinner startAnimating];
            [coverImageView addSubview:spinner];
            
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [[DLImageLoader sharedInstance] imageFromUrl:@"http://lorempixel.com/401/401" completed:^(NSError *error, UIImage *img) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [spinner removeFromSuperview];
                        coverImageView.image = img;
                    });
                }];
            });
                
            [cell.contentView addSubview:coverImageView];
            
            CGRect labelFrame = CGRectMake(10, coverImageView.frame.size.height - 90, _screenWidth, 40);
            UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
            
            label.text = @"Welcome to 500 Hangout";
            label.font = [UIFont systemFontOfSize:24];
            label.backgroundColor = [UIColor clearColor];
            label.textColor = [UIColor whiteColor];

            _label = label;
            
            UILabel* txtLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, coverImageView.frame.size.height - 65, _screenWidth-10, 60)];
            txtLabel.text = @"Find hangouts from local hosts and expeience life with people like yourself.";
            txtLabel.font = [UIFont systemFontOfSize:14];
            txtLabel.textColor = [UIColor whiteColor];
            txtLabel.backgroundColor = [UIColor clearColor];
            txtLabel.numberOfLines = 0;
            
            _txtLabel = txtLabel;
            
            [cell.contentView addSubview:txtLabel];
            
            CGRect bgRect = CGRectMake(0, coverImageView.frame.size.height - 100, _screenWidth, 100);
            UIBlurEffect* blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
            UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
            blurEffectView.frame = bgRect;
            blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [coverImageView addSubview:blurEffectView];
            [coverImageView addSubview:label];
            [coverImageView addSubview:txtLabel];

        }
        return cell;
        
    }
    else if (indexPath.row == 1) {
        static NSString *identifier = @"SecondRow";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            CGRect labelFrame = CGRectMake(10, 20, _screenWidth-20, 30);
            UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
            
            label.text = @"Editor's Picks";
            label.font = [UIFont systemFontOfSize:18];
            label.textColor = [UIColor blackColor];
            
            [cell.contentView addSubview:label];
        }
        
        return cell;
        
    }
    else if (indexPath.row == 3) {
        static NSString *identifier = @"ThirdRow";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            CGRect labelFrame = CGRectMake(10, 20, _screenWidth-20, 30);
            UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
            
            label.text = @"Super Hosts";
            label.font = [UIFont systemFontOfSize:18];
            label.textColor = [UIColor blackColor];
            
            [cell.contentView addSubview:label];
        }
        
        return cell;
        
    }
    else if (indexPath.row == 5) {
        static NSString *identifier = @"FifthRow";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            CGRect labelFrame = CGRectMake(10, 20, _screenWidth-20, 30);
            UILabel* label = [[UILabel alloc] initWithFrame:labelFrame];
            
            label.text = @"Top Facilities";
            label.font = [UIFont systemFontOfSize:18];
            label.textColor = [UIColor blackColor];
            
            [cell.contentView addSubview:label];
        }
        
        return cell;
        
    }
    else {
        static NSString *identifier = @"CellPortrait";
        
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        kCellHeight = _screenWidth;
        
        ASHorizontalScrollView *horizontalScrollView = [[ASHorizontalScrollView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, kCellHeight)];
        horizontalScrollView.leftMarginPx = 0;
        horizontalScrollView.miniAppearPxOfLastItem = 10;
        horizontalScrollView.uniformItemSize = CGSizeMake(_screenWidth - 20, _screenWidth-20);
        [horizontalScrollView setItemsMarginOnce];
        NSDictionary *rowDataMapping = @{
                                         @"2": _eventCategories,
                                         @"4": _superHosts,
                                         @"6": _facilities
                                         };
        NSArray<NSArray<withPicURL>*> *currentElems = [rowDataMapping objectForKey:[NSString stringWithFormat:@"%ld", (long)indexPath.row]];
        NSMutableArray *buttons = [NSMutableArray array];
        for (int i=0; i<currentElems.count; i++) {
            NSString *imageURL = currentElems[i].picURL;
            
            UIImageView *imageView = [[UIImageView alloc] init];
            
//            UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(horizontalScrollView.frame.size.height / 2 - 25, horizontalScrollView.frame.size.width / 2 - 25, 50, 50)];
//            spinner.color = _themeColor;
//            [spinner startAnimating];
//            [imageView addSubview:spinner];
            
            //                imageView.contentMode = UIViewContentModeScaleAspectFit;
            
            // DEMO IMAGE
            UIImage *image = [UIImage imageNamed:imageURL];
            imageView.image = image;
            imageView.userInteractionEnabled = YES;
            [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openEventsWithCategory:) ]];
            
            // PRODUCTION IMAGES
//            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//                [[DLImageLoader sharedInstance] imageFromUrl:imageURL completed:^(NSError *error, UIImage *img) {
//                    dispatch_async(dispatch_get_main_queue(), ^{
//                        [spinner removeFromSuperview];
//                        imageView.image = img;
//                        NSDictionary *myInfo = @{@"row": @(indexPath.row), @"elemClass": NSStringFromClass([currentElems[i] class]), @"id": @(currentElems[i].id)};
//                        objc_setAssociatedObject(imageView, @"myInfo", myInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
//                        imageView.userInteractionEnabled = YES;
//                        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openEventsWithCategory:) ]];
//                    });
//                }];
//            });
            
            [buttons addObject:imageView];
        }
        [horizontalScrollView addItems:buttons];
        [cell.contentView addSubview:horizontalScrollView];
        horizontalScrollView.translatesAutoresizingMaskIntoConstraints = false;
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:horizontalScrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1 constant:kCellHeight]];
        [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:horizontalScrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        
        return cell;
        
    }
}

- (void) openEventsWithCategory:(id) sender {
    NSDictionary* myInfo = objc_getAssociatedObject(((UITapGestureRecognizer *) sender).view, @"myInfo");
    NSLog(@"my Info: %@", myInfo);
    NSString* elemClass = (NSString*)myInfo[@"elemClass"];
    NSUInteger id = ((NSNumber*)myInfo[@"id"]).intValue;
    EventListViewController* elvc = [[EventListViewController alloc] initWithElemClass:elemClass Id:id];
    [self.navigationController pushViewController:elvc animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1 || indexPath.row == 3 || indexPath.row == 5) {
        return 45.0f;
    }
    else {
        return kCellHeight;
    }
    
}

- (IBAction)fetch:(id)sender {
    NSURL *url = [NSURL URLWithString:@"http://52.53.238.251:3001/auth/facebook"];
    if ([[UIApplication sharedApplication] canOpenURL:url]) {
        [[UIApplication sharedApplication] openURL:url];
    }
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _eventCategories = [[NSMutableArray alloc] init];
    _superHosts = [[NSMutableArray alloc] init];
    _facilities = [[NSMutableArray alloc] init];
    _locationManager = [HANLocationManager sharedInstance];
    [_locationManager startUpdatingLocation];
//    [[NSNotificationCenter defaultCenter] addObserver:self
//                                          selector:@selector(fetchEvents)
//                                          name:@"LocationManagerDidUpdateLocation"
//                                          object:nil];
    
    _baseURL = [NSURL URLWithString:kAppBaseURL];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenRect.size.width;
    self.screenWidth = screenWidth;
    
    _appTitle = @"500Hangout";
    _themeColor =[UIColor colorWithRed:249/255.0 green:102/255.0 blue:92/255.0 alpha:1];
    
    sampleTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 4 * self.view.frame.size.width + 50)];
    CGRect newFrame = CGRectMake( self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, 4 * self.view.frame.size.width + 50);
    self.view.frame = newFrame;
    self.edgesForExtendedLayout = UIRectEdgeNone;
    sampleTableView.delegate = self;
    sampleTableView.dataSource = self;
    sampleTableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    sampleTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:sampleTableView];
    
    
    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 50)];
    _searchBar.hidden = YES;
    _searchBar.backgroundColor = [UIColor clearColor];
    _searchBar.delegate = self;
    [self.view insertSubview:_searchBar atIndex:0];
    [self.view bringSubviewToFront:_searchBar];
    
    UIColor* themeColor =[UIColor colorWithRed:249/255.0 green:102/255.0 blue:92/255.0 alpha:1];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: themeColor, NSFontAttributeName: [UIFont systemFontOfSize:20.0f]};
    self.navigationController.navigationBar.tintColor = themeColor;

    self.navigationItem.title = _appTitle;
    
    UITabBarController *tabBarController = [self tabBarController];
    UITabBar *tabBar = tabBarController.tabBar;
    
    for (UITabBarItem  *tab in tabBar.items) {
//        tab.image = [tab.image imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
        tab.selectedImage = [tab.image imageWithRenderingMode: UIImageRenderingModeAlwaysOriginal];
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:_baseURL];
        manager.requestSerializer = [AFJSONRequestSerializer serializer];
        manager.responseSerializer = [AFJSONResponseSerializer serializer];
        NSString* path = @"/home";
        [manager GET:[NSString stringWithFormat:@"%@%@", _baseURL.absoluteString, path] parameters:nil progress:nil success:^(NSURLSessionTask *task, id responseObject) {
            NSDictionary* result = (NSDictionary *) responseObject;
            NSArray* eventCategories = (NSArray *)result[@"data"][0];
            NSArray* superHosts = (NSArray *)result[@"data"][1];
            NSArray* facilities = (NSArray *)result[@"data"][2];
            NSLog(@"event categories %@", eventCategories);
            
            for (int i=0; i < eventCategories.count; i++) {
                EventCategory *eventCategory = [[EventCategory alloc] initWithDict:(NSDictionary *)eventCategories[i]];
                [_eventCategories addObject:eventCategory];
            }
            NSLog(@"super hosts %@", superHosts);
            for (int i=0; i < superHosts.count; i++) {
                SuperHost *superhost = [[SuperHost alloc] initWithDict:(NSDictionary *)superHosts[i]];
                [_superHosts addObject:superhost];
            }
            NSLog(@"super hosts loaded: %@", _superHosts);
            NSLog(@"facilities %@", facilities);
            for (int i=0; i < facilities.count; i++) {
                Facility *facility = [[Facility alloc] initWithData:(NSDictionary *)facilities[i]];
                [_facilities addObject:facility];
            }
            NSLog(@"facilities loaded: %@", _facilities);
            [sampleTableView reloadData];
        } failure:^(NSURLSessionTask *operation, NSError *error) {
            NSLog(@"Error: %@", error);
        }];
    });
    
#pragma mark - Demo Event Categories
    for (int i = 1; i <= 5; i++) {
        EventCategory *eventCategory = [[EventCategory alloc] initForDemo:i];
        [_eventCategories addObject:eventCategory];
    }
    
#pragma mark - Demo Superhosts
    for (int i = 1; i <= 5; i++) {
        SuperHost *superhost = [[SuperHost alloc] initForDemo:i];
        [_superHosts addObject:superhost];
    }
    
#pragma mark - Demo Facilities
    for (int i = 1; i <= 5; i++) {
        Facility *facility = [[Facility alloc] initForDemo:i];
        [_facilities addObject:facility];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searching %@", searchBar.text);
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y < -50.0f) {
        if (_searchBar.hidden) {
            sampleTableView.center = CGPointMake(sampleTableView.center.x, sampleTableView.center.y + _searchBar.frame.size.height);
        }
        _searchBar.hidden = NO;
    }
    else if (scrollView.contentOffset.y > 50.0f) {
        if (!_searchBar.hidden) {
            sampleTableView.center = CGPointMake(sampleTableView.center.x, sampleTableView.center.y - _searchBar.frame.size.height);
        }
        [_searchBar resignFirstResponder];
        _searchBar.hidden = YES;
    }
}

@end
