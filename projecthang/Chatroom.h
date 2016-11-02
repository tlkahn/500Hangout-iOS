//
//  Chatroom.h
//  projecthang
//
//  Created by toeinriver on 9/7/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DemoMessagesViewController.h"
#import "User.h"

@interface Chatroom : NSObject

@property (assign, nonatomic) NSUInteger eventId;
@property (strong, nonatomic) DemoMessagesViewController* mvc;
@property (strong, nonatomic) User* organizer;
@property (strong, nonatomic) NSString* latestMessageText;

@end
