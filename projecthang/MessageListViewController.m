//
//  MessageListViewController.m
//  projecthang
//
//  Created by toeinriver on 9/7/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "MessageListViewController.h"
#import "DLImageLoader.h"
#import <objc/runtime.h>
#import "AppConstants.h"
#import "AFNetworking.h"

@implementation MessageListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _chatrooms = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    self.view.frame = CGRectMake(0, 0, screenWidth, 400);
    
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview: _tableView];
    
    self.navigationItem.title = @"Chat";
    UIColor* themeColor =[UIColor colorWithRed:249/255.0 green:102/255.0 blue:92/255.0 alpha:1];
    
    self.navigationController.navigationBar.backgroundColor = [UIColor whiteColor];
    self.navigationController.navigationBar.barTintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.titleTextAttributes = @{NSForegroundColorAttributeName: themeColor, NSFontAttributeName: [UIFont systemFontOfSize:20.0f]};
    self.navigationController.navigationBar.tintColor = themeColor;

    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kAppBaseURL]];
//        manager.requestSerializer = [AFJSONRequestSerializer serializer];
//        manager.responseSerializer = [AFJSONResponseSerializer serializer];
//        NSString *currentUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
//        NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
//        if (currentUserId) {
//            [parameters setObject:currentUserId forKey:@"current_id"];
//        }
//        NSString* path = @"/users";
//        [manager GET:[NSString stringWithFormat:@"%@%@", kAppBaseURL, path] parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
//            NSLog(@"JSON: %@", (NSDictionary *) responseObject);
//            NSArray* result = (NSArray *) responseObject;
//            for (int i=0; i<result.count; i++) {
//                Chatroom *chatroom = [[Chatroom alloc] init];
//                [_chatrooms addObject:chatroom];
//            }
//            NSLog(@"users %@", _chatrooms);
//            [_tableView reloadData];
//            [self adjustHeight:self.view forSubView:_tableView];
//        } failure:^(NSURLSessionTask *operation, NSError *error) {
//            NSLog(@"Error: %@", error);
//        }];
//    });
    Chatroom *chatroom = [[Chatroom alloc] init];
    chatroom.eventId = 1;
    chatroom.mvc = [[DemoMessagesViewController alloc] init];
    chatroom.organizer = [[User alloc] init];
    chatroom.organizer.id = 1;
    chatroom.organizer.picURL = @"https://ncache.ilbe.com/files/attach/new/20160529/14357299/702873610/8136393280/5f528ad0d6769600ef789878eeec86d3.png";
    chatroom.latestMessageText = @"Hello there!";
    [_chatrooms addObject:chatroom];
    
    Chatroom *chatroom2 = [[Chatroom alloc] init];
    chatroom2.eventId = 2;
    chatroom2.mvc = [[DemoMessagesViewController alloc] init];
    chatroom2.organizer = [[User alloc] init];
    chatroom2.organizer.id = 2;
    chatroom2.organizer.picURL = @"https://ncache.ilbe.com/files/attach/new/20160529/14357299/702873610/8136393280/5f528ad0d6769600ef789878eeec86d3.png";
    chatroom2.latestMessageText = @"Hello there!";
    [_chatrooms addObject:chatroom2];
    
    Chatroom *chatroom3 = [[Chatroom alloc] init];
    chatroom3.eventId = 3;
    chatroom3.mvc = [[DemoMessagesViewController alloc] init];
    chatroom3.organizer = [[User alloc] init];
    chatroom3.organizer.id = 3;
    chatroom3.organizer.picURL = @"https://ncache.ilbe.com/files/attach/new/20160529/14357299/702873610/8136393280/5f528ad0d6769600ef789878eeec86d3.png";
    chatroom3.latestMessageText = @"Hello there!";
    [_chatrooms addObject:chatroom3];
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _chatrooms.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.userInteractionEnabled = YES;
    NSDictionary *myInfo = @{@"chatroom": [_chatrooms objectAtIndex:indexPath.row]};
    [cell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openChatroom:)]];
    objc_setAssociatedObject(cell, @"myInfo", myInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    CGFloat cellIconImageViewTopMargin = 10;
    CGFloat cellIconImageViewLeftMargin = 10;
    CGFloat cellIconImageViewHeight = cell.frame.size.height;
    CGFloat cellIconImageViewWidth = cellIconImageViewHeight;
    UIImageView* cellIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(cellIconImageViewLeftMargin, cellIconImageViewTopMargin, cellIconImageViewWidth, cellIconImageViewHeight)];
    if (_chatrooms.count) {
        [[DLImageLoader sharedInstance] imageFromUrl:((Chatroom*)_chatrooms[indexPath.row]).organizer.picURL completed:^(NSError *error, UIImage *img) {
            if (error) {
                NSLog(@"error");
            }
            cellIconImageView.image =img;
            cellIconImageView.layer.cornerRadius = cellIconImageView.frame.size.width / 2;
            cellIconImageView.layer.borderWidth = 1.0f;
            cellIconImageView.layer.borderColor = [UIColor whiteColor].CGColor;
            cellIconImageView.clipsToBounds = YES;
        }];
        
    }
    [cell.contentView addSubview:cellIconImageView];
    
    CGFloat cellTextLabelLeftMargin = 10;
    CGFloat cellTextLabelWidth = 200;
    CGFloat cellTextLabelHeight = cell.contentView.frame.size.height;
    UILabel *cellTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(cellTextLabelLeftMargin + CGRectGetMaxX(cellIconImageView.frame), cellIconImageViewTopMargin, cellTextLabelWidth, cellTextLabelHeight)];
    cellTextLabel.text = ((Chatroom*)_chatrooms[indexPath.row]).latestMessageText;
    [cell.contentView addSubview:cellTextLabel];
    return cell;
}

- (void) adjustHeight:(UIView*) view forSubView: (UITableView*) tableView{
    _tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 600, self.tabBarController.tabBar.frame.size.height)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)openChatroom:(id)sender {
    NSDictionary* myInfo = objc_getAssociatedObject(((UITapGestureRecognizer*) sender).view, @"myInfo");
    Chatroom* chatroom = (Chatroom*) myInfo[@"chatroom"];
    [self.navigationController pushViewController:chatroom.mvc animated:YES];
    
    
}

- (void)viewWillAppear:(BOOL)animated {
    if (self.tabBarController.tabBar.hidden) {
        self.tabBarController.tabBar.hidden = NO;
    }
}


@end
