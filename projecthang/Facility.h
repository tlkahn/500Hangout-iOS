//
//  Facility.h
//  projecthang
//
//  Created by toeinriver on 9/3/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "Event.h"
#import "Facility.h"
#import "withPicURL.h"

@interface Facility : Event <withPicURL>

@property (assign, nonatomic) NSUInteger score;
@property (strong, nonatomic) NSString* picURL;
@property (assign, nonatomic) NSUInteger id;

- (instancetype) initForDemo: (NSUInteger) facility;

@end
