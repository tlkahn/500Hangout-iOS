//
//  UserListViewController.h
//  
//
//  Created by toeinriver on 8/5/16.
//
//

#import <UIKit/UIKit.h>
#import "User.h"

@interface UserListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>
@property (strong, nonatomic) UIViewController *parentVC;
@property (strong, nonatomic) UITableView* tableView;
@property (strong, nonatomic) NSMutableArray<User*>* users;
@end
