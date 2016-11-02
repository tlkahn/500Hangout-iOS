//
//  EventCategory.h
//  projecthang
//
//  Created by toeinriver on 9/3/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "withPicURL.h"

@interface EventCategory : NSObject <withPicURL>

@property (assign, nonatomic) NSUInteger id;
@property (strong, nonatomic) NSString* title;
@property (strong, nonatomic) NSString* picURL;

- (instancetype)initWithDict: (NSDictionary*) dict;
- (instancetype)initForDemo: (NSUInteger) category;

@end
