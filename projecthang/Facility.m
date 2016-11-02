//
//  Facility.m
//  projecthang
//
//  Created by toeinriver on 9/3/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "Facility.h"

@implementation Facility

- (id)initWithData:(NSDictionary *)data {
    self = [super initWithData:data];
    NSUInteger score = ((NSString *)data[@"score"]).intValue;
    if (data[@"score"] && score) {
        self.score = score;
    }
    else {
        self.score = -1;
    }
    if (self.photoURL1) {
        self.picURL = self.photoURL1;
    }
    else {
        self.picURL = @"";
    }
    if (self.eventID) {
        self.id = self.eventID;
    }
    else {
        self.id = -1;
    }
    return self;
}

- (instancetype)initForDemo: (NSUInteger) facility {
    self = [super init];
    self.id = facility;
    
    
    if (facility == 1) {
        self.score = 5;
        self.picURL = @"category1";
    }
    
    if (facility == 2) {
        self.score = 5;
        self.picURL = @"category2";
    }
    
    if (facility == 3) {
        self.score = 5;
        self.picURL = @"category3";
    }
    
    if (facility == 4) {
        self.score = 5;
        self.picURL = @"category4";
    }
    
    if (facility == 5) {
        self.score = 5;
        self.picURL = @"category5";
    }
    
    return self;
}

@end
