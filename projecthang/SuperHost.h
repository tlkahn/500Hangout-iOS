//
//  SuperHost.h
//  projecthang
//
//  Created by toeinriver on 9/3/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "withPicURL.h"

@interface SuperHost : NSObject <withPicURL>

@property (assign, nonatomic) NSUInteger id;
@property (assign, nonatomic) NSUInteger userId;
@property (strong, nonatomic) NSString* picURL;
@property (strong, nonatomic) NSString* fullName;

- (instancetype)initWithDict: (NSDictionary*) dict;
- (instancetype)initForDemo: (NSUInteger) host;

@end
