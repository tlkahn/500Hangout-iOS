//
//  NativeEventNavigationViewController.m
//  XLForm ( https://github.com/xmartlabs/XLForm )
//
//  Copyright (c) 2015 Xmartlabs ( http://xmartlabs.com )
//
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import "XLForm/XLForm.h"
#import "XLForm/XLFormRowDescriptor.h"
#import "DateAndTimeValueTrasformer.h"
#import "NativeEventFormViewController.h"
#import <OHQBImagePicker/QBImagePicker.h>
#import "PhotoBrowserViewController.h"
#import "FileBrowserViewController.h"
#import "projecthang-Swift.h"
#import <GoogleMapsBase/GoogleMapsBase.h>
#import <GoogleMaps/GMSServices.h>
#import <GooglePlaces/GooglePlaces.h>
#import <GooglePlacePicker/GMSPlacePicker.h>
#import <GooglePlacePicker/GMSPlacePickerConfig.h>
#import <GooglePlacePicker/GooglePlacePicker.h>
#import <GooglePlaces/GMSPlacesClient.h>
#import "PlaceDetailViewController+addInitWithPlace.h"
#import "AppConstants.h"
#import "AFNetworking.h"
#import <objc/runtime.h>
#import <SVProgressHUD/SVProgressHUD.h>


@implementation NativeEventNavigationViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    [self.view setTintColor:[UIColor redColor]];
}

@end

@interface NativeEventFormViewController ()

@end

@implementation NativeEventFormViewController

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initializeForm];
    }
    return self;
}

- (instancetype)init
{
    self = [super init];
//    if (self) {
//        [self initializeForm];
//    }
    return self;
}


- (void)initializeForm
{
    self.currentPhotos = [[NSMutableArray alloc] init];
    self.isEditing = NO;
//    self.event = [[Event alloc] init];
    
    NSLog(@"Event Object: %@", _event);
    
    XLFormDescriptor * form;
    XLFormSectionDescriptor * section;
    XLFormRowDescriptor * row;
    
    form = [XLFormDescriptor formDescriptorWithTitle:self.title];
    
    // Section 1 - Title, Category and PrivaTe Event
    section = [XLFormSectionDescriptor formSection];
    [form addFormSection:section];
    
    // Title
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"title" rowType:XLFormRowDescriptorTypeText];
    [row.cellConfig setObject:[UIFont systemFontOfSize:17.f] forKey:@"textField.font"];
    [row.cellConfigAtConfigure setObject:@"Title" forKey:@"textField.placeholder"];
    if (_event != nil) { row.value = _event.title; }
    row.required = YES;
    [section addFormRow:row];
    
    // Category
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"category" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Category"];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Arts"];
    [row.cellConfig setObject:[UIFont systemFontOfSize:17.f] forKey:@"textLabel.font"];
    if (_event != nil) {
        switch (_event.categoryID) {
            case 0: row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Arts"]; break;
            case 1: row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Classes and Workshops"]; break;
            case 2: row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Clubs"]; break;
            case 3: row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Networking"]; break;
            case 4: row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Parties"]; break;
            case 5: row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Sports and Fitness"]; break;
            default: break;
        }
    }
    row.selectorTitle = @"Category";
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Arts"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Classes and Workshops"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Clubs"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Networking"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Parties"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Sports and Fitness"],
                            ];
    [section addFormRow:row];
    
    // Public Event
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"isPublic" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Public Event"];
    row.value = @1;
    [row.cellConfig setObject:[UIFont systemFontOfSize:17.f] forKey:@"textLabel.font"];
    if (_event != nil) { row.value = @(_event.isPublic ? 1 : 0); }
    [section addFormRow:row];
    
    // Section 2 - Maximum Number of Attendees
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Maximum Number of Attendees"];
    [form addFormSection:section];
    
    // Maximum Number of Attendees
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"maxAttendees" rowType:XLFormRowDescriptorTypeDecimal];
//    [row.cellConfigAtConfigure setObject:@"Maximum Number of Attendees" forKey:@"textField.placeholder"];
    [row.cellConfig setObject:[UIFont systemFontOfSize:17.f] forKey:@"textField.font"];
    if (_event != nil) { row.value = [NSString stringWithFormat:@"%i", _event.maxAttendees]; }
    [section addFormRow:row];
    
    // Section 3 - All Day Event, Start Time, End Time and Repeating
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Time"];
    [form addFormSection:section];
    
    // All Day Event
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"isAllDay" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"All Day Event"];
    [row.cellConfig setObject:[UIFont systemFontOfSize:17.f] forKey:@"textLabel.font"];
    row.value = @0;
    if (_event != nil) { row.value = @(_event.isAllDay ? 1 : 0); }
    [section addFormRow:row];
    
    // Starts
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"startTime" rowType:XLFormRowDescriptorTypeDateTimeInline title:@"Starts"];
    row.value = [NSDate dateWithTimeIntervalSinceNow:60*60*24];
    [row.cellConfig setObject:[UIFont systemFontOfSize:17.f] forKey:@"textLabel.font"];
    if (_event != nil) { row.value = _event.startDateTime; }
    [section addFormRow:row];
    
    // Ends
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"endTime" rowType:XLFormRowDescriptorTypeDateTimeInline title:@"Ends"];
    row.value = [NSDate dateWithTimeIntervalSinceNow:60*60*25];
    [row.cellConfig setObject:[UIFont systemFontOfSize:17.f] forKey:@"textLabel.font"];
    if (_event != nil) { row.value = _event.endDateTime; }
    [section addFormRow:row];
    
    // Repeat
    // row = [XLFormRowDescriptor formRowDescriptorWithTag:@"repeat" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Repeat"];
    // row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Never"];
    // row.selectorTitle = @"Repeat";
    // row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"Never"],
    //                         [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"Every Day"],
    //                         [XLFormOptionsObject formOptionsObjectWithValue:@(2) displayText:@"Every Week"],
    //                         [XLFormOptionsObject formOptionsObjectWithValue:@(3) displayText:@"Every 2 Weeks"],
    //                         [XLFormOptionsObject formOptionsObjectWithValue:@(4) displayText:@"Every Month"],
    //                         [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"Every Year"],
    //                         ];
    // [section addFormRow:row];
    
    // Section 4 - Location
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Location"];
    [form addFormSection:section];
    
    // Location
    _locationRow = [XLFormRowDescriptor formRowDescriptorWithTag:@"location" rowType:XLFormRowDescriptorTypeButton title:@"Pick Location"];
    _locationRow.selectorTitle = @"Location";
    [_locationRow.cellConfig setObject:[UIFont systemFontOfSize:17.f] forKey:@"textLabel.font"];
    
    if (_event != nil) { _locationRow.title = _event.address; }
    
    _locationRow.action.viewControllerClass = [PlaceDetailViewController class];
    _locationRow.action.formBlock = ^(XLFormRowDescriptor * __nonnull sender) {
        NSString *kPlacesAPIKey = @"AIzaSyCKKkP4eo8FEGSAhPBU9gpYOUgSKiGPtwM";
        NSString *kMapsAPIKey = @"AIzaSyCkQhCB7_xTWaeUTdBG3-xNxar0jfjbzzs";
        [GMSPlacesClient provideAPIKey:kPlacesAPIKey];
        [GMSServices provideAPIKey:kMapsAPIKey];
        GMSPlacePicker* placePicker;
        
        if (_event != nil) {
            CLLocationCoordinate2D coordinateSW;
            coordinateSW.latitude = (CLLocationDegrees)_event.latitude - 0.5;
            coordinateSW.longitude = (CLLocationDegrees)_event.longitude - 0.5;
            CLLocationCoordinate2D coordinateNE;
            coordinateNE.latitude = (CLLocationDegrees)_event.latitude + 0.5;
            coordinateNE.longitude = (CLLocationDegrees)_event.longitude + 0.5;
            GMSCoordinateBounds *viewport = [[GMSCoordinateBounds alloc] initWithCoordinate:coordinateSW coordinate:coordinateNE];
            GMSPlacePickerConfig* config = [[GMSPlacePickerConfig alloc] initWithViewport:viewport];
            placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
        } else {
            GMSPlacePickerConfig* config = [[GMSPlacePickerConfig alloc] initWithViewport:nil];
            placePicker = [[GMSPlacePicker alloc] initWithConfig:config];
        }
        
        [placePicker pickPlaceWithCallback:^(GMSPlace *place, NSError* error){
            if (place) {
                // Create the next view controller we are going to display and present it.
                PlaceDetailViewController* nextScreen = [[PlaceDetailViewController alloc] initWithPlace:place];
                [self.navigationController pushViewController:nextScreen animated:YES];
            } else if (error) {
                NSLog(@"An error occurred while picking a place: \(error)");
            } else {
                NSLog(@"Looks like the place picker was canceled by the user");
            }
        }];
    };
    [section addFormRow:_locationRow];
    
    // Location Name
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"locationName" rowType:XLFormRowDescriptorTypeText];
    [row.cellConfigAtConfigure setObject:@"Location Name" forKey:@"textField.placeholder"];
    row.hidden = @1;
    [row.cellConfig setObject:[UIFont systemFontOfSize:17.f] forKey:@"textField.font"];
    if (_event != nil) {
        row.hidden = @0;
        row.value = _event.locationName;
    }
    [section addFormRow:row];
    
    // Section 5 - Photos
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Cover Photos"];
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"photos" rowType:XLFormRowDescriptorTypeButton title:@"Choose Photos"];
    row.selectorTitle = @"Photos";
    [row.cellConfig setObject:[UIFont systemFontOfSize:17.f] forKey:@"textLabel.font"];
    
    if (_event != nil) {
        if ([_event.photoURL1 length] != 0) { [_currentPhotos addObject:[NSURL URLWithString:_event.photoURL1]]; }
        if ([_event.photoURL2 length] != 0) { [_currentPhotos addObject:[NSURL URLWithString:_event.photoURL2]]; }
        if ([_event.photoURL3 length] != 0) { [_currentPhotos addObject:[NSURL URLWithString:_event.photoURL3]]; }
        if ([_event.photoURL4 length] != 0) { [_currentPhotos addObject:[NSURL URLWithString:_event.photoURL4]]; }
        NSLog(@"existing photos: %@", _currentPhotos);
        objc_setAssociatedObject(row.cellConfig, @"currentPhotos", _currentPhotos, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    row.action.viewControllerClass = [PhotoBrowserViewController class];
    [section addFormRow:row];
    
    // Section 6 - Free Event, Price and Deposit
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Price"];
    [form addFormSection:section];
    
    // Free Event
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"isFree" rowType:XLFormRowDescriptorTypeBooleanSwitch title:@"Free Event"];
    row.value = @0;
    [row.cellConfig setObject:[UIFont systemFontOfSize:17.f] forKey:@"textLabel.font"];
    if (_event != nil) { row.value = @(_event.price == 0 ? 1 : 0); }
    [section addFormRow:row];
    
    // Event Price
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"price" rowType:XLFormRowDescriptorTypeDecimal];
    [row.cellConfigAtConfigure setObject:@"Ticket Price" forKey:@"textField.placeholder"];
    [row.cellConfig setObject:[UIFont systemFontOfSize:17.f] forKey:@"textField.font"];
    if (_event != nil) { row.hidden = @(_event.price == 0 ? 1 : 0); }
    if (_event != nil) {
        if ((int)_event.price != 0) { row.value = [NSString stringWithFormat:@"%.02f", _event.price]; }
    }
    [section addFormRow:row];
    
    // Deposit Amount
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"deposit" rowType:XLFormRowDescriptorTypeSelectorPush title:@"Deposit"];
    row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"No Deposit Required"];
    row.selectorTitle = @"Deposit";
    [row.cellConfig setObject:[UIFont systemFontOfSize:17.f] forKey:@"textLabel.font"];
    if (_event != nil) { row.hidden = @(_event.price == 0 ? 1 : 0); }
    if (_event != nil) {
        NSString *depositString = [NSString stringWithFormat:@"$%i.00", (int)_event.deposit];
        switch ((int)_event.deposit) {
            case 0: row.value = [XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"No Deposit Required"]; break;
            default: row.value = [XLFormOptionsObject formOptionsObjectWithValue:@((int)_event.deposit) displayText:depositString]; break;
        }
    }
    row.selectorOptions = @[[XLFormOptionsObject formOptionsObjectWithValue:@(0) displayText:@"No Deposit Required"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(1) displayText:@"$1.00"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(5) displayText:@"$5.00"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(10) displayText:@"$10.00"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(15) displayText:@"$15.00"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(20) displayText:@"$20.00"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(25) displayText:@"$25.00"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(30) displayText:@"$30.00"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(35) displayText:@"$35.00"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(40) displayText:@"$40.00"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(45) displayText:@"$45.00"],
                            [XLFormOptionsObject formOptionsObjectWithValue:@(50) displayText:@"$50.00"]
                            ];
    [section addFormRow:row];
    
    // Section 7 - Event Description
    section = [XLFormSectionDescriptor formSectionWithTitle:@"Description"];
    [form addFormSection:section];
    
    // Event Description
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"description" rowType:XLFormRowDescriptorTypeTextView];
    [row.cellConfig setObject:[UIFont systemFontOfSize:17.f] forKey:@"textView.font"];
//    [row.cellConfigAtConfigure setObject:@"Description" forKey:@"textView.placeholder"];
    if (_event != nil) { row.value = _event.description1; }
    [section addFormRow:row];
    
    // Section 8 - Attachments
     section = [XLFormSectionDescriptor formSectionWithTitle:@"Attachments"
                                             sectionOptions:XLFormSectionOptionCanReorder | XLFormSectionOptionCanInsert | XLFormSectionOptionCanDelete];
    section.multivaluedTag = @"textFieldRow";
    [form addFormSection:section];
    
    row = [XLFormRowDescriptor formRowDescriptorWithTag:@"files" rowType:XLFormRowDescriptorTypeButton title:@"Browse for File"];
    [row.cellConfig setObject:[UIFont systemFontOfSize:17.f] forKey:@"textLabel.font"];
    row.action.viewControllerClass = [FileBrowserViewController class];
    [section addFormRow:row];
    
    self.form = form;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelPressed:)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(savePressed:)];

    if(_isEditing) {
        self.title = @"Edit Event";
    } else {
        self.title = @"Add Event";
    }
    [self initializeForm];
}

#define kOFFSET_FOR_KEYBOARD 80.0

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = self.view.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    self.view.frame = rect;
    
    [UIView commitAnimations];
}

-(void)keyboardWillShow {
    // Animate the current view out of the way
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide {
    if (self.view.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (self.view.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}



#pragma mark - XLFormDescriptorDelegate

-(void)formRowDescriptorValueHasChanged:(XLFormRowDescriptor *)rowDescriptor oldValue:(id)oldValue newValue:(id)newValue
{
    [super formRowDescriptorValueHasChanged:rowDescriptor oldValue:oldValue newValue:newValue];

    // Category
    if ([rowDescriptor.tag isEqualToString:@"category"]){
        XLFormRowDescriptor * categoryDescriptor = [self.form formRowWithTag:@"category"];
        [self updateFormRow:categoryDescriptor];
    }
    
    // All Day Event
    else if ([rowDescriptor.tag isEqualToString:@"isAllDay"]){
        XLFormRowDescriptor * startDateDescriptor = [self.form formRowWithTag:@"startTime"];
        XLFormRowDescriptor * endDateDescriptor = [self.form formRowWithTag:@"endTime"];
        XLFormDateCell * dateStartCell = (XLFormDateCell *)[[self.form formRowWithTag:@"startTime"] cellForFormController:self];
        XLFormDateCell * dateEndCell = (XLFormDateCell *)[[self.form formRowWithTag:@"endTime"] cellForFormController:self];
        if ([[rowDescriptor.value valueData] boolValue] == YES){
            startDateDescriptor.valueTransformer = [DateValueTrasformer class];
            endDateDescriptor.valueTransformer = [DateValueTrasformer class];
            [dateStartCell setFormDatePickerMode:XLFormDateDatePickerModeDate];
            [dateEndCell setFormDatePickerMode:XLFormDateDatePickerModeDate];
        }
        else{
            startDateDescriptor.valueTransformer = [DateTimeValueTrasformer class];
            endDateDescriptor.valueTransformer = [DateTimeValueTrasformer class];
            [dateStartCell setFormDatePickerMode:XLFormDateDatePickerModeDateTime];
            [dateEndCell setFormDatePickerMode:XLFormDateDatePickerModeDateTime];
        }
        [self updateFormRow:startDateDescriptor];
        [self updateFormRow:endDateDescriptor];
    }
    
    // Starts
    else if ([rowDescriptor.tag isEqualToString:@"startTime"]){
        XLFormRowDescriptor * startDateDescriptor = [self.form formRowWithTag:@"startTime"];
        XLFormRowDescriptor * endDateDescriptor = [self.form formRowWithTag:@"endTime"];
        if ([startDateDescriptor.value compare:endDateDescriptor.value] == NSOrderedDescending) {
            // startDateDescriptor is later than endDateDescriptor
            endDateDescriptor.value =  [[NSDate alloc] initWithTimeInterval:(60*60*24) sinceDate:startDateDescriptor.value];
            [endDateDescriptor.cellConfig removeObjectForKey:@"detailTextLabel.attributedText"];
            [self updateFormRow:endDateDescriptor];
        }
    }
    
    // Ends
    else if ([rowDescriptor.tag isEqualToString:@"endTime"]){
        XLFormRowDescriptor * startDateDescriptor = [self.form formRowWithTag:@"startTime"];
        XLFormRowDescriptor * endDateDescriptor = [self.form formRowWithTag:@"endTime"];
        XLFormDateCell * dateEndCell = (XLFormDateCell *)[endDateDescriptor cellForFormController:self];
        if ([startDateDescriptor.value compare:endDateDescriptor.value] == NSOrderedDescending) {
            // startDateDescriptor is later than endDateDescriptor
            [dateEndCell update]; // force detailTextLabel update
            NSDictionary *strikeThroughAttribute = [NSDictionary dictionaryWithObject:@1
                                                                               forKey:NSStrikethroughStyleAttributeName];
            NSAttributedString* strikeThroughText = [[NSAttributedString alloc] initWithString:dateEndCell.detailTextLabel.text attributes:strikeThroughAttribute];
            [endDateDescriptor.cellConfig setObject:strikeThroughText forKey:@"detailTextLabel.attributedText"];
            [self updateFormRow:endDateDescriptor];
        }
        else{
            [endDateDescriptor.cellConfig removeObjectForKey:@"detailTextLabel.attributedText"];
            [self updateFormRow:endDateDescriptor];
        }
    }
    
    // Location
    else if ([rowDescriptor.tag isEqualToString:@"location"]){
        GMSPlace *location = newValue;
        NSString *fullAddress = location.formattedAddress;
        NSString *locationName = location.name;
        
        XLFormRowDescriptor * locationDescriptor = [self.form formRowWithTag:@"location"];
        locationDescriptor.title = fullAddress;
        [self updateFormRow:locationDescriptor];
        
        XLFormRowDescriptor * locationNameDescriptor = [self.form formRowWithTag:@"locationName"];
        locationNameDescriptor.value = locationName;
        locationNameDescriptor.hidden = @0;
        [self updateFormRow:locationNameDescriptor];
    }
    
    // Free Event
    else if ([rowDescriptor.tag isEqualToString:@"isFree"]){
        XLFormRowDescriptor * priceDescriptor = [self.form formRowWithTag:@"price"];
        if (priceDescriptor.isHidden) {
            priceDescriptor.hidden = @0;
        } else {
            priceDescriptor.hidden = @1;
        }
        [self updateFormRow:priceDescriptor];
        
        XLFormRowDescriptor * depositDescriptor = [self.form formRowWithTag:@"deposit"];
        if (depositDescriptor.isHidden) {
            depositDescriptor.hidden = @0;
        } else {
            depositDescriptor.hidden = @1;
        }
        [self updateFormRow:depositDescriptor];
    }
    
    // Deposit
    else if ([rowDescriptor.tag isEqualToString:@"deposit"]){
        XLFormRowDescriptor * depositDescriptor = [self.form formRowWithTag:@"deposit"];
        [self updateFormRow:depositDescriptor];
    }
    [self deselectFormRow:rowDescriptor];
}

-(void)cancelPressed:(UIBarButtonItem * __unused)button
{
    [self.navigationController popViewControllerAnimated:YES];
}


-(void)savePressed:(UIBarButtonItem * __unused)button
{
    NSArray * validationErrors = [self formValidationErrors];
    if (validationErrors.count > 0){
        [self showFormValidationError:[validationErrors firstObject]];
        return;
    }
    
    operationQueue = [NSOperationQueue new];
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self selector:@selector(postEvent) object:nil];
    [operationQueue addOperation:operation];
    
    [self.tableView endEditing:YES];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)postEvent
{
    // Location Object
    GMSPlace *location = [self.form formRowWithTag:@"location"].value;
    CLLocationCoordinate2D coordinates = location.coordinate;
    
    // Option Objects
    XLFormOptionsObject *xfoCategory = [self formValues][@"category"];
    
    // Initiate Properties for POST
    NSString *title = [self.form formRowWithTag:@"title"].value;
    NSString *organizerId = [[NSUserDefaults standardUserDefaults] stringForKey:@"userId"];
    NSString *description = [self.form formRowWithTag:@"description"].value;
    CLLocationDegrees geoCodeLat = coordinates.latitude;
    CLLocationDegrees geoCodeLng = coordinates.longitude;
    NSString *vicinity = location.addressComponents[2].name;
    NSString *fullAddress = location.formattedAddress;
    NSNumber *isPublic = [self.form formRowWithTag:@"isPublic"].value;
    NSNumber *categoryId = xfoCategory.valueData;
    NSNumber *deposit = [self validateDeposit];
    NSString *locationName = [self.form formRowWithTag:@"locationName"].value;
    NSNumber *isRepeating = @0;
    NSNumber *isAllDay = [self.form formRowWithTag:@"isAllDay"].value;
    NSNumber *price = [self validatePrice];
    NSNumber *maxAttendee = [self.form formRowWithTag:@"maxAttendees"].value;
    NSString *photoId1 = [self publicPhotoURLFromArrayAtPosition:0];
    NSString *photoId2 = [self publicPhotoURLFromArrayAtPosition:1];
    NSString *photoId3 = [self publicPhotoURLFromArrayAtPosition:2];
    NSString *photoId4 = [self publicPhotoURLFromArrayAtPosition:3];
    NSString *startTime = [self isoDateTime:[self.form formRowWithTag:@"startTime"].value];
    NSString *endTime = [self isoDateTime:[self.form formRowWithTag:@"endTime"].value];
    
    // Prepare Data for POST
    NSString *parameters = [NSString stringWithFormat:@"{\"title\":\"%@\", \"organizer_id\":%@, \"description\":\"%@\", \"geo_code_lat\":%f, \"geo_code_lng\":%f, \"vicinity\":\"%@\", \"full_address\":\"%@\", \"public\":%@, \"category_id\":%@, \"deposit\":%@, \"location_name\":\"%@\", \"repeating\":%@, \"allday\":%@, \"price\":%@, \"max_attendee\":%@, \"photo_id1\":\"%@\", \"photo_id2\":\"%@\", \"photo_id3\":\"%@\", \"photo_id4\":\"%@\", \"start_time\":\"%@\", \"end_time\":\"%@\"}", title, organizerId, description, geoCodeLat, geoCodeLng, vicinity, fullAddress, isPublic, categoryId, deposit, locationName, isRepeating, isAllDay, price, maxAttendee, photoId1, photoId2, photoId3, photoId4, startTime, endTime];
    
    NSLog(@"PARAMETERS: %@", parameters);
    
    NSError *error;
    NSData *objectData = [parameters dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&error];
    
    NSLog(@"JSON: %@", json);
    
    // POST JSON Data
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kAppBaseURL]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString* path = @"/events";
    [manager POST:[NSString stringWithFormat:@"%@%@", kAppBaseURL, path] parameters:json progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"Event saved"];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

- (NSString *)isoDateTime:(NSDate *)dateTime {
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    NSDateFormatter *isoFormatter = [[NSDateFormatter alloc] init];
    [isoFormatter setLocale:enUSPOSIXLocale];
    [isoFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.000Z"];
    [isoFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *isoDateTime = [isoFormatter stringFromDate:dateTime];
    return isoDateTime;
}

- (NSString *)publicPhotoURLFromArrayAtPosition:(NSInteger)position {
    if (position < [_currentPhotos count]) {
        return _currentPhotos[position];
    }
    return @"";
}

- (NSInteger)countOfUploadedImagePublicURLs {
    return [_currentPhotos count];
}

- (NSNumber *)validateDeposit {
    NSNumber *isFree = [self.form formRowWithTag:@"isFree"].value;
    XLFormOptionsObject *xfoDeposit = [self formValues][@"deposit"];
    
    if (![isFree isEqual:@1]) {
        return xfoDeposit.valueData;
    }
    return @0;
}

- (NSNumber *)validatePrice {
    NSNumber *isFree = [self.form formRowWithTag:@"isFree"].value;
    NSNumber *price = [self.form formRowWithTag:@"price"].value;
    
    if (![isFree isEqual:@1]) {
        return price;
    }
    return @0;
}

@end