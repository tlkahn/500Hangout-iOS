//
//  User.h
//  projecthang
//
//  Created by toeinriver on 9/4/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "withPicURL.h"

@interface User : NSObject <withPicURL>

@property (strong, nonatomic) NSString* picURL;
@property (assign, nonatomic) NSUInteger id;
@property (strong, nonatomic) NSString* fullName;
@property (strong, nonatomic) NSString* details;
- (instancetype)initWithDict: (NSDictionary*) dict;

@end
