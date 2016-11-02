//
//  Event.m
//  projecthang
//
//  Created by Andrew Despres on 8/21/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "Event.h"

@implementation Event

#pragma mark - Parse Event Data

- (void) parseData:(NSDictionary *)data completion:(void (^)(BOOL success))completionBlock
{
    // DEBUG ONLY: Log raw event data
//    NSLog(@"%@", data);
    
    // Event data - source changes depending on API call
    NSDictionary *event;
    _enrolledUsers = [[NSMutableArray alloc] init];
    _interestedUsers = [[NSMutableArray alloc] init];
    
    // Determine the source of the event data
    if ([data objectForKey:@"event"]) {
        // This data is returned by calling /event?id=<eventID>
        event = data[@"event"];
    } else {
        // This data is returned by calling /events
        event = data;
    }
    
    // Parse each property and report null values
    if (event[@"allday"] != (NSString*)[NSNull null]) {
        _isAllDay = [event[@"allday"] boolValue];
    } else {
        _isPublic = NO;
        [self reportToAnalytics:@"invalid field allday"];
    }

    if (event[@"category_id"] != (NSString*)[NSNull null]) {
        _categoryID = [event[@"category_id"] intValue];
    } else {
        _categoryID = -1;
        [self reportToAnalytics:@"invalid field categoryID"];
    }

    if (event[@"created_at"] != (NSString*)[NSNull null]) {
        _createdDateTime = [self rfc3339StringToDateTime:event[@"created_at"]];
    } else {
        _createdDateTime = nil;
        [self reportToAnalytics:@"invalid field createdDateTime"];
    }

    if (event[@"max_attendee"] != (NSString*)[NSNull null]) {
        _maxAttendees = ((NSString *)event[@"max_attendee"]).intValue;
    } else {
        _maxAttendees = 0;
        [self reportToAnalytics:@"invalid field maxAttendees"];
    }

    if (event[@"description"] != (NSString*)[NSNull null]) {
        _description1 = ((NSString *)event[@"description"]);
    } else {
        _description1 = @"";
        [self reportToAnalytics:@"invalid field description1"];
    }

    if (event[@"end_time"] != (NSString*)[NSNull null]) {
        _endDateTime = [self rfc3339StringToDateTime:event[@"end_time"]];
    } else {
        _endDateTime = nil;
        [self reportToAnalytics:@"invalid field endDateTime"];
    }

    if (event[@"full_address"] != (NSString*)[NSNull null]) {
        _address = ((NSString *)event[@"full_address"]);
    } else {
        _address = @"";
        [self reportToAnalytics:@"invalid field address"];
    }

    if (event[@"geo_code_lat"] != (NSString*)[NSNull null]) {
        _latitude = [event[@"geo_code_lat"] floatValue];
    } else {
        _latitude = 0.00;
        [self reportToAnalytics:@"invalid field latitude"];
    }

    if (event[@"geo_code_lng"] != (NSString*)[NSNull null]) {
        _longitude = [event[@"geo_code_lng"] floatValue];
    } else {
        _longitude = 0.00;
        [self reportToAnalytics:@"invalid field longitude"];
    }

    if (event[@"id"] != (NSString*)[NSNull null]) {
        _eventID = ((NSString *)event[@"id"]).intValue;
    } else {
        _eventID = -1;
        [self reportToAnalytics:@"invalid field eventID"];
    }

    if (event[@"location_name"] != (NSString*)[NSNull null]) {
        _locationName = ((NSString *)event[@"location_name"]);
    } else {
        _locationName = @"";
        [self reportToAnalytics:@"invalid field locationName"];
    }

    if (event[@"organizer_id"] != (NSString*)[NSNull null]) {
        _hostID = ((NSString *)event[@"organizer_id"]).intValue;
    } else {
        _hostID = -1;
        [self reportToAnalytics:@"invalid field hostID"];
    }

    if (event[@"photo_id1"] != (NSString*)[NSNull null]) {
        _photoURL1 = ((NSString *)event[@"photo_id1"]);
    } else {
        _photoURL1 = @"";
        [self reportToAnalytics:@"invalid field photoURL1"];
    }

    if (event[@"photo_id2"] != (NSString*)[NSNull null]) {
        _photoURL2 = ((NSString *)event[@"photo_id2"]);
    } else {
        _photoURL2 = @"";
        [self reportToAnalytics:@"invalid field photoURL2"];
    }

    if (event[@"photo_id3"] != (NSString*)[NSNull null]) {
        _photoURL3 = ((NSString *)event[@"photo_id3"]);
    } else {
        _photoURL3 = @"";
        [self reportToAnalytics:@"invalid field photoURL3"];
    }

    if (event[@"photo_id4"] != (NSString*)[NSNull null]) {
        _photoURL4 = ((NSString *)event[@"photo_id4"]);
    } else {
        _photoURL4 = @"";
        [self reportToAnalytics:@"invalid field photoURL4"];
    }

    if (event[@"price"] != (NSString*)[NSNull null]) {
        _price = [event[@"price"] doubleValue];
    } else {
        _price = 0.00;
        [self reportToAnalytics:@"invalid field price"];
    }

    if (event[@"deposit"] != (NSString*)[NSNull null]) {
        _deposit = [event[@"deposit"] doubleValue];
    } else {
        _deposit = 0.00;
        [self reportToAnalytics:@"invalid field deposit"];
    }

    if (event[@"public"] != (NSString *)[NSNull null]) {
        _isPublic = [event[@"public"] boolValue];
    } else {
        [self reportToAnalytics:@"invalid field isPublic"];
        _isPublic = YES;
    }

    if (event[@"start_time"] != (NSString*)[NSNull null]) {
        _startDateTime = [self rfc3339StringToDateTime:event[@"start_time"]];
    } else {
        _startDateTime = nil;
        [self reportToAnalytics:@"invalid field startDateTime"];
    }

    if (event[@"title"] != (NSString*)[NSNull null]) {
        _title = ((NSString *)event[@"title"]);
    } else {
        _title = @"";
        [self reportToAnalytics:@"invalid field title"];
    }

    if (event[@"total_enrolls"] != (NSString*)[NSNull null]) {
        _enrolled = ((NSString *)event[@"total_enrolls"]).intValue;
    } else {
        _enrolled = -1;
        [self reportToAnalytics:@"invalid field enrolled"];
    }

    if (event[@"total_interests"] != (NSString*)[NSNull null]) {
        _followers = ((NSString *)event[@"total_interests"]).intValue;
    } else {
        _followers = -1;
        [self reportToAnalytics:@"invalid field followers"];
    }

    if (event[@"updated_at"] != (NSString*)[NSNull null]) {
        _updatedDateTime = [self rfc3339StringToDateTime:event[@"updated_at"]];
    } else {
        _updatedDateTime = nil;
        [self reportToAnalytics:@"invalid field updatedDateTime"];
    }
    if ((_hostAvatarURL == (NSString *)[NSNull null]) || ([_hostAvatarURL length] == 0)) {
        if (event[@"user_photo_url"] != (NSString *)[NSNull null]) {
            _hostAvatarURL = event[@"user_photo_url"];
        } else {
            [self reportToAnalytics:@"invalid field hostAvatarURL"];
            _hostAvatarURL = [[NSBundle mainBundle]
                              URLForResource: @"SmilingCat" withExtension:@"png"].absoluteString;
        }
    }

    if ((_hostFullName == (NSString *)[NSNull null]) || ([_hostFullName length] == 0)) {
        if (event[@"user_full_name"] != (NSString *)[NSNull null]) {
            _hostFullName = event[@"user_full_name"];
        } else {
            [self reportToAnalytics:@"invalid field hostFullName"];
            _hostFullName = @"Unknown User";
        }
    }

    if (event[@"vicinity"] != (NSString *)[NSNull null]) {
        _vicinty = event[@"vicinity"];
    } else {
        [self reportToAnalytics:@"invalid field vicinty"];
        _vicinty = @"Unknown Location";
    }
    
    // Array of enrolled users - only present if /event?id=<eventID> is called
    if (([data objectForKey:@"enrolled_users"]) && (_enrolled > 0)) {
        for (id key in data[@"enrolled_users"]) {
            NSNumber *value = key[@"enrolled_user_id"];
            [_enrolledUsers addObject:value];
        }
    }
    
    // Array of interested users - only present if /event?id=<eventID> is called
    if (([data objectForKey:@"interested_users"]) && ((long)_followers > 0)) {
        for (id key in data[@"interested_users"]) {
            NSNumber *value = key[@"interested_user_id"];
            [_interestedUsers addObject:value];
        }
    }
    
    // DEBUG ONLY: Data Passed into Class and Parsed
    NSLog(@"Data passed into Event class and parsed");
    
    // Send Callback
    if (completionBlock != nil) completionBlock(YES);
}

#pragma mark - Analytics

- (void) reportToAnalytics:(NSString*)message {
    NSLog(@"Data validation issue: %@", message);
}

#pragma mark - Date Formatter

- (NSDate *) rfc3339StringToDateTime:(NSString *)rfc3339String
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    [formatter setLocale:enUSPOSIXLocale];
    [formatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *dateTime = [formatter dateFromString:rfc3339String];

    return dateTime;
}

- (NSString *) formattedShortDate:(NSDate *)dateTime {
    NSString *dateTimeString;
    if (dateTime != nil) {
        NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
        assert(dateTimeFormatter != nil);
        [dateTimeFormatter setDateFormat:@"MMM d"];
        dateTimeString = [dateTimeFormatter stringFromDate:dateTime];
    }
    return dateTimeString;
}

- (NSString *) formattedShortTime:(NSDate *)dateTime {
    NSString *dateTimeString;
    if (dateTime != nil) {
        NSDateFormatter *dateTimeFormatter = [[NSDateFormatter alloc] init];
        assert(dateTimeFormatter != nil);
        dateTimeFormatter.timeStyle = NSDateFormatterShortStyle;
        dateTimeString = [dateTimeFormatter stringFromDate:dateTime];
    }
    return dateTimeString;
}

- (NSString *) formattedEventStartAndEndTime {
    NSString *dateTimeString;
    NSString *startDateString;
    NSString *startTimeString;
    NSString *endDateString;
    NSString *endTimeString;

    if ((_startDateTime != nil) && (_endDateTime != nil)) {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        assert(dateFormatter != nil);
        [dateFormatter setDateFormat:@"MMMM d, YYYY"];

        startDateString = [dateFormatter stringFromDate:_startDateTime];
        endDateString = [dateFormatter stringFromDate:_endDateTime];

        NSDateFormatter *timeFormatter = [[NSDateFormatter alloc] init];
        assert(timeFormatter != nil);
        [timeFormatter setDateFormat:@"h:mm a"];

        startTimeString = [timeFormatter stringFromDate:_startDateTime];
        endTimeString = [timeFormatter stringFromDate:_endDateTime];

        if ([startDateString isEqualToString:endDateString]) {
            dateTimeString = [NSString stringWithFormat:@"%@ to %@, %@", startTimeString, endTimeString, endDateString];
        } else {
            dateTimeString = [NSString stringWithFormat:@"%@, %@ to %@, %@", startTimeString, startDateString, endTimeString, endDateString];
        }
    }

    return dateTimeString;
}

#pragma mark - Log All Event Properties

- (void) logEvent {
    NSLog(@"isAllDay: %hhu -> (BOOL)", _isAllDay);
    NSLog(@"categoryID: %ld -> (NSInteger)", (long)_categoryID);
    NSLog(@"createdDateTime: %@ -> (NSDate)", _createdDateTime);
    NSLog(@"description1: %@ -> (NSString)", _description1);
    NSLog(@"description2: %@ -> (NSString)", _description2);
    NSLog(@"description3: %@ -> (NSString)", _description3);
    NSLog(@"description4: %@ -> (NSString)", _description4);
    NSLog(@"endDateTime: %@ -> (NSDate)", _endDateTime);
    NSLog(@"address: %@ -> (NSString)", _address);
    NSLog(@"latitude: %f -> (float)", _latitude);
    NSLog(@"longitude: %f -> (float)", _longitude);
    NSLog(@"eventID: %ld -> (NSInteger)", (long)_eventID);
    NSLog(@"locationName: %@ -> (NSString)", _locationName);
    NSLog(@"maxAttendees: %ld -> (NSInteger)", (long)_maxAttendees);
    NSLog(@"hostID: %ld -> (NSInteger)", (long)_hostID);
    NSLog(@"photoURL1: %@ -> (NSString)", _photoURL1);
    NSLog(@"photoURL2: %@ -> (NSString)", _photoURL2);
    NSLog(@"photoURL3: %@ -> (NSString)", _photoURL3);
    NSLog(@"photoURL4: %@ -> (NSString)", _photoURL4);
    NSLog(@"price: %f -> (double)", _price);
    NSLog(@"deposit: %f -> (double)", _deposit);
    NSLog(@"isPublic: %hhu -> (BOOL)", _isPublic);
    NSLog(@"startDateTime: %@ -> (NSDate)", _startDateTime);
    NSLog(@"title: %@ -> (NSString)", _title);
    NSLog(@"enrolled: %ld -> (NSInteger)", (long)_enrolled);
    NSLog(@"followers: %ld -> (NSInteger)", (long)_followers);
    NSLog(@"updateDateTime: %@ -> (NSDate)", _updatedDateTime);
    NSLog(@"hostAvatarURL: %@ -> (NSString)", _hostAvatarURL);
    NSLog(@"hostFullName: %@ -> (NSString)", _hostFullName);
    NSLog(@"vicinity: %@ -> (NSString)", _vicinty);
    NSLog(@"enrolledUsers: %@ -> (NSMutableArray)", _enrolledUsers);
    NSLog(@"interestedUsers: %@ -> (NSMutableArray)", _interestedUsers);
}

#pragma mark - Initialization

- (id)initWithData:(NSDictionary *)data
{
    self = [super init];
    if (self) {
        [self parseData:data completion: nil];
    }
    return self;
}

@end
