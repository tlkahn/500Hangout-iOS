//
//  FavoriteViewController.h
//  projecthang
//
//  Created by toeinriver on 8/5/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FavoriteViewController : UIViewController <UISearchBarDelegate, UIScrollViewDelegate>

@property (strong, nonatomic) UISegmentedControl *segmentControl;
@property (strong, nonatomic) UIView* mainView;

@end
