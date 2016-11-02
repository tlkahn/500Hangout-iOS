//
//  GoogleDriverUploadViewController.m
//  projecthang
//
//  Created by toeinriver on 9/6/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "GoogleDriverUploadViewController.h"

static NSString *const kKeychainItemName = @"500Hangout";
static NSString *const kClientID = @"755222394175-sor882283n79k8kaudf3g9cdb7hkjgvo.apps.googleusercontent.com";

@implementation GoogleDriverUploadViewController

- (void)viewDidLoad {
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _themeColor =[UIColor colorWithRed:249/255.0 green:102/255.0 blue:92/255.0 alpha:1];
    
    self.view.backgroundColor = [UIColor whiteColor];
    // Create a Table View to display content
    _fileTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    _fileTableView.contentInset = UIEdgeInsetsMake(0, 0, 113, 0);
    _fileTableView.delegate = self;
    _fileTableView.dataSource = self;
    _fileTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_fileTableView];
    
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
}

// When the view appears, ensure that the Drive API service is authorized, and perform API calls.
- (void)viewDidAppear:(BOOL)animated {
    if (!self.service.authorizer.canAuthorize) {
        // Not yet authorized, request authorization by pushing the login UI onto the UI stack.
        [self presentViewController:[self createAuthController] animated:YES completion:nil];
        
    } else {
        [self fetchFiles];
    }
}

// Construct a query to get names and IDs of 10 files using the Google Drive API.
- (void)fetchFiles {
    //    self.output.text = @"Getting files...";
    GTLQueryDrive *query =
    [GTLQueryDrive queryForFilesList];
    query.pageSize = 10;
    query.fields = @"nextPageToken, files(id, name)";
    [self.service executeQuery:query
                      delegate:self
             didFinishSelector:@selector(displayResultWithTicket:finishedWithObject:error:)];
}

// Read File
- (void)readFile:(GTLDriveFile *) file {
    //    NSLog(@"filename[identifier]: %@ [%@]", file.name, file.identifier);
    NSString *url = [NSString stringWithFormat:@"https://www.googleapis.com/drive/v3/files/%@?alt=media", file.identifier];
    GTMSessionFetcher *fetcher = [_service.fetcherService fetcherWithURLString:url];
    
    [fetcher beginFetchWithCompletionHandler:^(NSData *data, NSError *error) {
        if (error == nil) {
            NSLog(@"Retrieved file content");
            // Do something with data
        } else {
            NSString* errMsg = [[NSString alloc] initWithData:data
                                                     encoding:NSUTF8StringEncoding];
            NSLog(@"An error occurred: %@", errMsg);
        }
    }];
}

// Process the response and display output.
- (void)displayResultWithTicket:(GTLServiceTicket *)ticket
             finishedWithObject:(GTLDriveFileList *)response
                          error:(NSError *)error {
    if (error == nil) {
        NSMutableString *filesString = [[NSMutableString alloc] init];
        if (response.files.count > 0) {
            [filesString appendString:@"Files:\n"];
            for (GTLDriveFile *file in response.files) {
                [filesString appendFormat:@"%@ (%@)\n", file.name, file.identifier];
            }
        } else {
            [filesString appendString:@"No files found."];
        }
        //        self.output.text = filesString;
        _fileList = response;
        [_fileTableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
    } else {
        [self showAlert:@"Error" message:error.localizedDescription];
    }
}


// Creates the auth controller for authorizing access to Drive API.
- (GTMOAuth2ViewControllerTouch *)createAuthController {
    GTMOAuth2ViewControllerTouch *authController;
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    NSArray *scopes = [NSArray arrayWithObjects:kGTLAuthScopeDriveMetadataReadonly, nil];
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

// MARK: - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_fileList.files count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 40;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    
    // Formatting constants
    CGFloat labelHeight = 20;
    CGFloat iconTextMargin = 5;
    
    // Cell
    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // File
    GTLDriveFile *file = _fileList.files[indexPath.row];
    
    UILabel *fileName = [[UILabel alloc] initWithFrame:CGRectMake(64, 0, _screenWidth - 64, 40)];
    fileName.text = file.name;
    [cell.contentView addSubview:fileName];
    
    UILabel *fileType = [[UILabel alloc] initWithFrame:CGRectMake(16, 4, 32, 32)];
    fileType.backgroundColor = _themeColor;
    fileType.text = file.fullFileExtension;
    [cell.contentView addSubview:fileType];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GTLDriveFile *file = _fileList.files[indexPath.row];
    [self readFile:file];
}

@end
