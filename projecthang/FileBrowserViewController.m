//
//  FileBrowserViewController.m
//  projecthang
//
//  Created by Andrew Despres on 9/6/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "AppConstants.h"
#import "FileBrowserViewController.h"
#import "AFNetworking.h"
#import "SVProgressHUD+ChangeDefaultMinimumTimeInterval.h"
#import "GoogleDriverUploadViewController.h"
#import "projecthang-Swift.h"

static NSString *const kKeychainItemName = @"500Hangout";
static NSString *const kClientID = @"755222394175-sor882283n79k8kaudf3g9cdb7hkjgvo.apps.googleusercontent.com";
//static NSString *const kClientID = @"764770796756-88c1c810sjqqa4hh51mkhuk2laov8d35.apps.googleusercontent.com";

@implementation FileBrowserViewController

#pragma mark - View
- (void)viewDidLoad {
    [super viewDidLoad];
    
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _themeColor =[UIColor colorWithRed:249/255.0 green:102/255.0 blue:92/255.0 alpha:1];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Attachments";
    
    CGFloat segmentControlHeight = 40;
    _segmentControl = [[UISegmentedControl alloc] initWithItems:@[@"iCloud", @"Skydrive", @"Dropbox"]];
    _segmentControl.frame = CGRectMake(0, 0 , _screenWidth, segmentControlHeight);
    _segmentControl.tintColor = _themeColor;
    [_segmentControl addTarget:self action:@selector(segmentControlChanged:) forControlEvents:UIControlEventValueChanged];

    [self.view addSubview:_segmentControl];
    
    // Create a UITextView to display output.
//    self.output = [[UITextView alloc] initWithFrame:self.view.bounds];
//    self.output.editable = false;
//    self.output.contentInset = UIEdgeInsetsMake(20.0, 0.0, 20.0, 0.0);
//    self.output.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    [self.view addSubview:self.output];
    
    // Initialize the Drive API service & load existing credentials from the keychain if available.
    _service = [[GTLServiceDrive alloc] init];
    _service.authorizer =
    [GTMOAuth2ViewControllerTouch authForGoogleFromKeychainForName:kKeychainItemName
                                                          clientID:kClientID
                                                      clientSecret:nil];
    // Initialize the Box API service
    [self uploadFileToBox];
}


#pragma mark - Memory Management
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void) segmentControlChanged: (id) sender {
    UISegmentedControl * segmentedControl = (UISegmentedControl *)sender;
    NSInteger selectedIndex = segmentedControl.selectedSegmentIndex;
    NSLog(@"you have selected %lu", (long)selectedIndex);
    if (selectedIndex == 0) {
    }
    else if (selectedIndex == 1) {
        
    }
    else if (selectedIndex == 2) {
        DropboxFileListViewController * dvc = [[DropboxFileListViewController alloc] init];
        [self.navigationController pushViewController:dvc animated:YES];
    }
}


// Creates the auth controller for authorizing access to Drive API.
- (GTMOAuth2ViewControllerTouch *)createAuthController {
    GTMOAuth2ViewControllerTouch *authController;
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
//    NSArray *scopes = [NSArray arrayWithObjects:kGTLAuthScopeDriveMetadataReadonly, nil];
    NSArray *scopes = [NSArray arrayWithObjects:kGTLAuthScopeDriveReadonly, nil];
    authController = [[GTMOAuth2ViewControllerTouch alloc]
                      initWithScope:[scopes componentsJoinedByString:@" "]
                      clientID:kClientID
                      clientSecret:nil
                      keychainItemName:kKeychainItemName
                      delegate:self
                      finishedSelector:@selector(viewController:finishedWithAuth:error:)];
    return authController;
}

// Handle completion of the authorization process, and update the Drive API
// with the new credentials.
- (void)viewController:(GTMOAuth2ViewControllerTouch *)viewController
      finishedWithAuth:(GTMOAuth2Authentication *)authResult
                 error:(NSError *)error {
    if (error != nil) {
        [self showAlert:@"Authentication Error" message:error.localizedDescription];
        self.service.authorizer = nil;
    }
    else {
        self.service.authorizer = authResult;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

// Helper for showing an alert
- (void)showAlert:(NSString *)title message:(NSString *)message {
    UIAlertController *alert =
    [UIAlertController alertControllerWithTitle:title
                                        message:message
                                 preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *ok =
    [UIAlertAction actionWithTitle:@"OK"
                             style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
     {
         [alert dismissViewControllerAnimated:YES completion:nil];
     }];
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
    
}


#pragma mark - Box API

- (void)uploadFileToBox {
    BOXContentClient *client = [BOXContentClient clientForNewSession];
    [client setAccessTokenDelegate:self];
    
    // Test File
    NSString *localFilePath = [[NSBundle mainBundle] pathForResource:@"Home" ofType:@"png"];
    NSLog(@"File Path: %@", localFilePath);
    
    // Upload file(s) to Box
    BOXFileUploadRequest *uploadRequest = [client fileUploadRequestToFolderWithID:0 fromLocalFilePath:localFilePath];
    uploadRequest.fileName = @"example-file.png";
    [uploadRequest performRequestWithProgress:^(long long totalBytesTransferred, long long totalBytesExpectedToTransfer) {
        
    } completion:^(BOXFile *file, NSError *error) {
        NSLog(@"file: %@", file);
    }];
}

- (void)fetchAccessTokenWithCompletion:(void (^)(NSString *, NSDate *, NSError *))completion {
    NSString *accessToken = @"xt6VITVIJIWZdspdlfvchEnKirJ3QNmF";
    completion(accessToken, [NSDate dateWithTimeIntervalSinceNow:100], nil);
}

#pragma mark - File Management

- (void)postUpload {
    // Initiate Properties for POST
    NSString *boxFileID;
    NSString *fileName;
    NSString *fileSize;
    NSString *fileURL;
    NSString *eventID;
    
    // Prepare Data for POST
    NSString *parameters = [NSString stringWithFormat:@"{\"boxFileId\":\"%@\", \"fileName\":%@, \"fileSize\":\"%@\", \"fileURL\":\"%@\", \"eventID\":\"%@\"}", boxFileID, fileName, fileSize, fileURL, eventID];
    
    NSLog(@"PARAMETERS: %@", parameters);
    
    NSError *error;
    NSData *objectData = [parameters dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *json = [NSJSONSerialization JSONObjectWithData:objectData options:NSJSONReadingMutableContainers error:&error];
    
    NSLog(@"JSON: %@", json);
    
    // POST JSON Data
    AFHTTPSessionManager *manager = [[AFHTTPSessionManager alloc] initWithBaseURL:[NSURL URLWithString:kAppBaseURL]];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    NSString* path = @"/uploads";
    [manager POST:[NSString stringWithFormat:@"%@%@", kAppBaseURL, path] parameters:json progress:nil success:^(NSURLSessionTask *task, id responseObject) {
        [SVProgressHUD showSuccessWithStatus:@"Event saved"];
    } failure:^(NSURLSessionTask *operation, NSError *error) {
        NSLog(@"Error: %@", error);
        [SVProgressHUD showErrorWithStatus:error.localizedDescription];
    }];
}

@end
