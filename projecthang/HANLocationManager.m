//
//  HANLocationManager.m
//  projecthang
//
//  Created by Andrew Despres on 8/21/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "HANLocationManager.h"

@implementation HANLocationManager

+ (HANLocationManager *) sharedInstance
{
    static HANLocationManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

- (id)init
{
    self = [super init];
    if (self != nil) {
        self.locationManager = [[CLLocationManager alloc] init];
        [self.locationManager requestWhenInUseAuthorization];
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = kCLHeadingFilterNone;
        self.locationManager.delegate = self;
    }
    
    return self;
}

- (void)startUpdatingLocation
{
    NSLog(@"Starting location updates");
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location service failed with error: %@", error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    CLLocation *location = [locations lastObject];
    NSLog(@"Latitude %+.6f, Longitude %+.6f\n", location.coordinate.latitude, location.coordinate.longitude);
    self.currentLocation = location;
    [self.locationManager stopUpdatingLocation];
    [[NSNotificationCenter defaultCenter]
     postNotificationName:@"LocationManagerDidUpdateLocation"
     object:self];
}

- (CLLocation *)locationFromLatitude:(float)latitude :(float)longitude {
    CLLocation *location = [[CLLocation alloc] initWithLatitude:(CLLocationDegrees)latitude
                                                      longitude:(CLLocationDegrees)longitude];
    return location;
}

- (NSString *)getDistanceFromLocation:(CLLocation*)location {
    CLLocationDistance distanceInMiles = [self.currentLocation distanceFromLocation:location] * 0.000621371;
    return [NSString stringWithFormat:@"%.1f mi", distanceInMiles];
}

@end
