//
//  Event.h
//  projecthang
//
//  Created by Andrew Despres on 8/21/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Event : NSObject
@property Boolean isAllDay;
@property NSInteger categoryID;
@property NSDate *createdDateTime;
@property NSString *description1;
@property NSString *description2;
@property NSString *description3;
@property NSString *description4;
@property NSDate *endDateTime;
@property NSString *address;
@property float latitude;
@property float longitude;
@property NSInteger eventID;
@property NSString *locationName;
@property NSInteger maxAttendees;
@property NSInteger hostID;
@property NSString *photoURL1;
@property NSString *photoURL2;
@property NSString *photoURL3;
@property NSString *photoURL4;
@property double price;
@property double deposit;
@property Boolean isPublic;
@property NSDate *startDateTime;
@property NSString *title;
@property NSInteger enrolled;
@property NSInteger followers;
@property NSDate *updatedDateTime;
@property NSString *hostAvatarURL;
@property NSString *hostFullName;
@property NSString *vicinty;
@property NSMutableArray *enrolledUsers;
@property NSMutableArray *interestedUsers;

- (id)initWithData:(NSDictionary *)data;
- (void)parseData:(NSDictionary *)data completion:(void (^)(BOOL success))completionBlock;
- (void) logEvent;
- (NSString *)formattedShortDate:(NSDate *)dateTime;
- (NSString *)formattedShortTime:(NSDate *)dateTime;
- (NSString *)formattedEventStartAndEndTime;
@end
