//
//  HANLocationManager.h
//  projecthang
//
//  Created by Andrew Despres on 8/21/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface HANLocationManager : NSObject <CLLocationManagerDelegate>

+ (HANLocationManager *) sharedInstance;

@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;

- (void)startUpdatingLocation;
- (CLLocation *)locationFromLatitude:(float)latitude :(float)longitude;
- (NSString *)getDistanceFromLocation:(CLLocation*)location;

@end
