//
//  UserListViewController.m
//  
//
//  Created by toeinriver on 8/5/16.
//
//

#import "UserListViewController.h"
#import "DLImageLoader.h"
#import "UserViewController.h"
#import <objc/runtime.h>
#import "AppConstants.h"
#import "AFNetworking.h"
#import "FavoriteViewController.h"


@interface UserListViewController ()

@property (assign, nonatomic) CGFloat screenWidth;
@property (assign, nonatomic) CGFloat screenHeight;
@property (strong, nonatomic) UserViewController* uvc;

@end

@implementation UserListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _users = [[NSMutableArray alloc] init];
    // Do any additional setup after loading the view.
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _screenHeight = [UIScreen mainScreen].bounds.size.height;
    self.view.frame = CGRectMake(0, 0, _screenWidth, 400);
    _tableView = [[UITableView alloc] initWithFrame:self.view.frame];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview: _tableView];
    dispatch_async(dispatch_get_main_queue(), ^{
        AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kAppBaseURL]];
            manager.requestSerializer = [AFJSONRequestSerializer serializer];
            manager.responseSerializer = [AFJSONResponseSerializer serializer];
            NSString *currentUserId = [[NSUserDefaults standardUserDefaults] objectForKey:@"userId"];
            NSMutableDictionary* parameters = [[NSMutableDictionary alloc] init];
            if (currentUserId) {
                [parameters setObject:currentUserId forKey:@"current_id"];
            }
            NSString* path = @"/users";
            [manager GET:[NSString stringWithFormat:@"%@%@", kAppBaseURL, path] parameters:parameters progress:nil success:^(NSURLSessionTask *task, id responseObject) {
                NSLog(@"JSON: %@", (NSDictionary *) responseObject);
                NSArray* result = (NSArray *) responseObject;
                for (int i=0; i<result.count; i++) {
                    User *user = [[User alloc] initWithDict:result[i]];
                    [_users addObject:user];
                }
                NSLog(@"users %@", _users);
                [_tableView reloadData];
                [self adjustHeight:self.view forSubView:_tableView];
            } failure:^(NSURLSessionTask *operation, NSError *error) {
                NSLog(@"Error: %@", error);
            }];
    });
    
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _users.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.userInteractionEnabled = YES;
        NSDictionary *myInfo = @{@"user": [_users objectAtIndex:indexPath.row]};
        [cell addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openUser:)]];
        objc_setAssociatedObject(cell, @"myInfo", myInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        CGFloat cellIconImageViewTopMargin = 10;
        CGFloat cellIconImageViewLeftMargin = 10;
//        CGFloat cellIconImageViewBottomMargin = 10;
        CGFloat cellIconImageViewHeight = cell.frame.size.height;
        CGFloat cellIconImageViewWidth = cellIconImageViewHeight;
        UIImageView* cellIconImageView = [[UIImageView alloc] initWithFrame:CGRectMake(cellIconImageViewLeftMargin, cellIconImageViewTopMargin, cellIconImageViewWidth, cellIconImageViewHeight)];
        if (_users.count) {
            NSLog(@"photo url: %@", ((User*)_users[indexPath.row]).picURL);
            [[DLImageLoader sharedInstance] imageFromUrl:((User*)_users[indexPath.row]).picURL completed:^(NSError *error, UIImage *img) {
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
        cellTextLabel.text = ((User*)_users[indexPath.row]).fullName;
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

- (void)openUser:(id)sender {
    NSDictionary* myInfo = objc_getAssociatedObject(((UITapGestureRecognizer*) sender).view, @"myInfo");
    NSLog(@"open user: %@", myInfo);
    _uvc = [[UserViewController alloc] init];
    _uvc.id = ((User*)(myInfo[@"user"])).id;
    if (!self.navigationController) {
        [self.parentVC.navigationController pushViewController:_uvc animated:YES];
    }
    else {
        [self.navigationController pushViewController:_uvc animated:YES];
    }
    
    
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.parentVC && [self.parentVC conformsToProtocol:@protocol(UIScrollViewDelegate)] && [self.parentVC respondsToSelector:@selector(scrollViewDidScroll:)]) {
        UIViewController <UIScrollViewDelegate> *vc = (UIViewController <UIScrollViewDelegate> *) self.parentVC;
        [vc scrollViewDidScroll:scrollView];
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
