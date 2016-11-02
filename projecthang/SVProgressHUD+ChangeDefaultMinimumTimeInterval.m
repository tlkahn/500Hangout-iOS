//
//  SVProgressHUD+ChangeDefaultMinimumTimeInterval.m
//  projecthang
//
//  Created by toeinriver on 8/20/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "SVProgressHUD+ChangeDefaultMinimumTimeInterval.h"

@implementation SVProgressHUD (ChangeDefaultMinimumTimeInterval)

+ (NSTimeInterval)displayDurationForString:(NSString*)string {
    return 2.0f;
}

@end
