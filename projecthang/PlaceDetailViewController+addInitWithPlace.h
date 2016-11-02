//
//  PlaceDetailViewController+addInitWithPlace.h
//  projecthang
//
//  Created by toeinriver on 8/26/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "projecthang-Swift.h"
#import <GooglePlaces/GooglePlaces.h>
#import <GooglePlacePicker/GMSPlacePicker.h>
#import <GooglePlacePicker/GMSPlacePickerConfig.h>
#import <GooglePlacePicker/GooglePlacePicker.h>
#import <GooglePlaces/GMSPlacesClient.h>

@interface PlaceDetailViewController (addInitWithPlace)

- (nullable instancetype)initWithPlace:(nullable GMSPlace *) place;

@end
