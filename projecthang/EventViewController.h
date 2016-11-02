//
//  EventViewController.h
//  projecthang
//
//  Created by toeinriver on 8/4/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ASHorizontalScrollView.h"
#import "DLImageLoader.h"
#import "Event.h"

@interface EventViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSOperationQueue *operationQueue;
}

@property (strong, nonatomic) Event *event;
@property (strong, nonatomic) NSString* redirectStatus;
@property (strong, nonatomic) NSString* id;
@property (strong, atomic) UILabel* enrollBtn;
@property (strong, nonatomic) UILabel* enrolledLabel;
@property (strong, atomic) UIButton* bookmarkBtn;
@property (strong, nonatomic) UILabel* bookmarkLabel;
@property (strong, nonatomic) UITableView* eventTable;
- (void) showInfoOnSuccessfulPayment;
- (void) showInfoOnFailedPayment;
@end
