//
//  EventCategory.m
//  projecthang
//
//  Created by toeinriver on 9/3/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "EventCategory.h"
#import "AppConstants.h"

@implementation EventCategory

- (instancetype)initWithDict: (NSDictionary*) dict {
    NSLog(@"passed in event category json object: %@", dict);
    NSArray* nullFields = @[@"<null>", @"null"];
    self = [super init];
    if (dict[@"id"] && ((NSString *)dict[@"id"]).intValue) {
        self.id = ((NSString *)dict[@"id"]).intValue;
    }
    else {
        self.id = -1;
        NSLog(@"invalid category id from JSON: %@", dict[@"id"]);
    }
    if (dict[@"title"] && ((NSString *)dict[@"title"]).length && ![nullFields containsObject:((NSString *)dict[@"title"])]) {
        self.title = (NSString *)[(NSString *)dict[@"title"] copy];
    }
    else {
        self.title = @"";
        NSLog(@"invalid category title from JSON: %@", dict[@"title"]);
    }
    if (dict[@"pic_url"] && ((NSString *)dict[@"pic_url"]).length && ![nullFields containsObject:((NSString *)dict[@"pic_url"])]) {
        self.picURL = [((NSString *)dict[@"pic_url"]) copy];
    }
    else {
        self.picURL = @"";
        NSLog(@"invalid category pic_url from JSON: %@", dict[@"pic_url"]);
    }
    return self;
}

- (instancetype)initForDemo: (NSUInteger) category {
    self = [super init];
    self.id = category;
    
    if (category == 1) {
        self.title = @"Category 1";
        self.picURL = @"category1";
    }
    
    if (category == 2) {
        self.title = @"Category 2";
        self.picURL = @"category2";
    }
    
    if (category == 3) {
        self.title = @"Category 3";
        self.picURL = @"category3";
    }
    
    if (category == 4) {
        self.title = @"Category 4";
        self.picURL = @"category4";
    }
    
    if (category == 5) {
        self.title = @"Category 5";
        self.picURL = @"category5";
    }
    
    return self;
}

@end
