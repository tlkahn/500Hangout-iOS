//
//  MessageListViewController.h
//  projecthang
//
//  Created by toeinriver on 9/7/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Chatroom.h"

@interface MessageListViewController : UIViewController<UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) UITableView* tableView;
@property (strong, nonatomic) NSMutableArray<Chatroom*>* chatrooms;
@end
