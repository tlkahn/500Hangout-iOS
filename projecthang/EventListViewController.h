//
//  EventListViewController.h
//  projecthang
//
//  Created by toeinriver on 8/4/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventListViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIScrollViewDelegate>
{
    NSOperationQueue *operationQueue;
}

@property (strong, nonatomic) UIViewController *parentVC;
@property (strong, nonatomic) UITableView* eventsTableView;
@property (strong, atomic) NSString* elemClass;
@property (assign, atomic) NSUInteger id;
- (instancetype) initWithElemClass:(NSString*)elemClass Id:(NSUInteger) id;
@end
