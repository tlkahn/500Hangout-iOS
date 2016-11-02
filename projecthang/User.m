//
//  User.m
//  projecthang
//
//  Created by toeinriver on 9/4/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "User.h"

@implementation User

- (instancetype)init {
    self = [super init];
    self.id = 0;
    self.picURL = @"";
    self.fullName = @"";
    self.details = @"";
    return self;
}

- (instancetype)initWithDict: (NSDictionary*) dict {
    self = [super init];
    NSString* id = [dict objectForKey:@"id"];
    if (id && ![NSStringFromClass([id class]) isEqualToString:@"NSNull"]) {
        self.id = id.intValue;
    }
    else {
        self.id = 0;
    }
    NSString* photoURL = [dict objectForKey:@"photo_url"];
    if (photoURL && ![NSStringFromClass([photoURL class]) isEqualToString:@"NSNull"])  {
        self.picURL = photoURL;
    }
    else {
        self.picURL = @"";
    }
    NSString* fullName = [dict objectForKey:@"full_name"];
    if (fullName && ![NSStringFromClass([fullName class]) isEqualToString:@"NSNull"])  {
        self.fullName = fullName;
    }
    else {
        self.fullName = @"";
    }
    NSString* details = [dict objectForKey:@"description"];
    if (details && ![NSStringFromClass([fullName class]) isEqualToString:@"NSNull"])  {
        self.details = details;
    }
    else {
        self.details = @"";
    }
    
    return self;
}

@end
