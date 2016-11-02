//
//  ViewController.h
//  projecthang
//
//  Created by toeinriver on 7/28/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AFNetworking.h"
#import "ASHorizontalScrollView.h"
#import "DLImageLoader.h"
#import "UIColor+Hexadecimal.h"
#import "EventListViewController.h"

@interface ViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UISearchBarDelegate> {
    UITableView *sampleTableView;
    UIImageView *coverImageView;
}


@end

