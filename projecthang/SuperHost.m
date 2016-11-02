//
//  SuperHost.m
//  projecthang
//
//  Created by toeinriver on 9/3/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "SuperHost.h"

@implementation SuperHost

- (instancetype)initWithDict: (NSDictionary*) dict {
    NSLog(@"passed in super host json object: %@", dict);
    NSArray* nullFields = @[@"<null>", @"null"];
    self = [super init];
    if (dict[@"id"] && ![NSStringFromClass([dict[@"id"] class]) isEqualToString:@"NSNull"] && ((NSString *)dict[@"id"]).intValue) {
        self.id = ((NSString *)dict[@"id"]).intValue;
    }
    else {
        self.id = -1;
        NSLog(@"invalid category id from JSON: %@", dict[@"id"]);
    }
    if (dict[@"user_id"] && ![NSStringFromClass([dict[@"id"] class]) isEqualToString:@"NSNull"] && ((NSString *)dict[@"user_id"]).intValue && ![nullFields containsObject:((NSString *)dict[@"user_id"])]) {
        self.userId = ((NSString *)dict[@"user_id"]).intValue;
    }
    else {
        self.userId = -1;
        NSLog(@"invalid category title from JSON: %@", dict[@"user_id"]);
    }
    if (dict[@"photo_url"] && ![NSStringFromClass([dict[@"id"] class]) isEqualToString:@"NSNull"] && ((NSString *)dict[@"photo_url"]).length && ![nullFields containsObject:((NSString *)dict[@"photo_url"])]) {
        self.picURL = [((NSString *)dict[@"photo_url"]) copy];
    }
    else {
        self.picURL = @"";
        NSLog(@"invalid category pic_url from JSON: %@", dict[@"photo_url"]);
    }
    return self;
}

- (instancetype)initForDemo: (NSUInteger) host {
    self = [super init];
    self.id = host;
    self.userId = host;
    
    
    if (host == 1) {
        self.fullName = @"Host 1";
        self.picURL = @"category1";
    }
    
    if (host == 2) {
        self.fullName = @"Host 2";
        self.picURL = @"category2";
    }
    
    if (host == 3) {
        self.fullName = @"Host 3";
        self.picURL = @"category3";
    }
    
    if (host == 4) {
        self.fullName = @"Host 4";
        self.picURL = @"category4";
    }
    
    if (host == 5) {
        self.fullName = @"Host 5";
        self.picURL = @"category5";
    }
    
    return self;
}

@end
