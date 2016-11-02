//
//  FavoriteViewController.m
//  projecthang
//
//  Created by toeinriver on 8/5/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "FavoriteViewController.h"
#import "EventListViewController.h"
#import "UserListViewController.h"

@interface FavoriteViewController ()

@property (strong, nonatomic) UISearchBar *searchBar;
@property (assign, nonatomic) CGFloat screenWidth;
@property (assign, nonatomic) CGFloat screenHeight;
@property (strong, nonatomic) UIColor* themeColor;
@property (strong, nonatomic) EventListViewController *eventList;
@property (strong, nonatomic) UserListViewController *userList;
@property (strong, nonatomic) NSArray *segmentMapping;

@end

@implementation FavoriteViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _themeColor =[UIColor colorWithRed:249/255.0 green:102/255.0 blue:92/255.0 alpha:1];
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: _themeColor, NSFontAttributeName: [UIFont systemFontOfSize:20.0f]};
    self.navigationController.navigationBar.tintColor = self.themeColor;
    self.navigationController.navigationBar.topItem.title = @"Favorites";
    
//    CGFloat searchBarHeight = 50;
//    _searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame), _screenWidth, searchBarHeight)];
//    _searchBar.backgroundColor = [UIColor clearColor];
//    _searchBar.delegate = self;
//    _searchBar.hidden = YES;
//    [self.view insertSubview:_searchBar atIndex:0];
//    [self.view bringSubviewToFront:_searchBar];
    
//    CGFloat segmentControlTopMargin = 0;
    CGFloat segmentControlHeight = 40;
    _segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"Hosts", @"Events"]];
    _segmentControl.frame = CGRectMake(0, CGRectGetMaxY(self.navigationController.navigationBar.frame) , _screenWidth, segmentControlHeight);
    _segmentControl.tintColor = _themeColor;
    [_segmentControl addTarget:self action:@selector(segmentControlChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:_segmentControl];
    
    CGFloat mainViewTopmargin = 10;
    _mainView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_segmentControl.frame) + mainViewTopmargin, _screenWidth, _screenHeight - self.tabBarController.tabBar.frame.size.height - _segmentControl.frame.size.height - self.navigationController.navigationBar.frame.size.height)];
    [self.view addSubview:_mainView];
    
    _segmentControl.selectedSegmentIndex = 0;
    _userList = [[UserListViewController alloc] init];
    _eventList = [[EventListViewController alloc] init];
    
    [_mainView addSubview: _userList.view];
    [_mainView addSubview: _eventList.view];
    
    _userList.view.hidden = NO;
    _eventList.view.hidden = YES;
    _userList.parentVC = self;
    _eventList.parentVC = self;
    
   
}

- (void) segmentControlChanged: (id) sender {
    UISegmentedControl * segmentedControl = (UISegmentedControl *)sender;
    NSLog(@"you have selected %ld", (long)segmentedControl.selectedSegmentIndex);
    _userList.view.hidden = !_userList.view.hidden;
    _eventList.view.hidden = !_eventList.view.hidden;
    if (!_eventList.view.hidden) {
        [self adjustHeight:_mainView forSubView:_eventList.eventsTableView];
    }
    else {
        [self adjustHeight:_mainView forSubView:_userList.tableView];
    }
    
}

- (void) adjustHeight:(UIView*) view forSubView: (UITableView*) tableView{
    tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, self.tabBarController.tabBar.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searching %@", searchBar.text);
    
    
}

//- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
//    NSLog(@"scrolled");
//    if (scrollView.contentOffset.y < -50.0f) {
//        if (_searchBar.hidden) {
//            _segmentControl.center = CGPointMake(_segmentControl.center.x, _segmentControl.center.y + _searchBar.frame.size.height);
//            _mainView.center = CGPointMake(_mainView.center.x, _mainView.center.y + _searchBar.frame.size.height);
//            
//        }
//        _searchBar.hidden = NO;
//    }
//    else if (scrollView.contentOffset.y > 50.0f) {
//        if (!_searchBar.hidden) {
//            _segmentControl.center = CGPointMake(_segmentControl.center.x, _segmentControl.center.y - _searchBar.frame.size.height);
//            _mainView.center = CGPointMake(_mainView.center.x, _mainView.center.y - _searchBar.frame.size.height);
//
//        }
//        [_searchBar resignFirstResponder];
//        _searchBar.hidden = YES;
//    }
//}


@end
