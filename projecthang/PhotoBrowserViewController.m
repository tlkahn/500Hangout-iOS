//
//  PhotoBrowserViewController.m
//  projecthang
//
//  Created by toeinriver on 8/7/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "PhotoBrowserViewController.h"
#import "ASHorizontalScrollView.h"
#import "DLImageLoader.h"
#import "DLILCacheManager.h"
#import <objc/runtime.h>
#import "NativeEventFormViewController.h"
@import AWSS3;
#import "AppConstants.h"
@import SVProgressHUD;
#import <objc/runtime.h>

@interface PhotoBrowserViewController ()
@property (assign, nonatomic) CGFloat screenWidth;
@property (strong, nonatomic) UIColor* themeColor;
@property (strong, nonatomic) UITableView* tableView;
@property (strong, nonatomic) UILabel* addPhotoBtn;
@property (strong, nonatomic) UILabel* savePhotoBtn;
@property (strong, nonatomic) UILabel* cancelUploadBtn;
@property (strong, nonatomic) UILabel* pauseUploadBtn;
@property (strong, nonatomic) NSMutableArray* uploadedPhotos;
@property (strong, nonatomic) ASHorizontalScrollView* horizontalScrollView;
@property (strong, nonatomic) NSMutableArray<UIImage*>* selectedPhotos;
@property (strong, nonatomic) AWSS3TransferManagerUploadRequest* uploadRequest;
@property (assign, nonatomic) int currentProgress;
@property (strong, nonatomic) NSMutableArray* currentPhotos;
@property (assign, atomic) int currentIndexOfUploadImages;
@property (strong, atomic) NSMutableArray *buttons;
@end

@implementation PhotoBrowserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _currentProgress = 0;
    _currentIndexOfUploadImages = 0;
    if (!_currentPhotos || !_currentPhotos.count) {
        _currentPhotos = [[NSMutableArray alloc] init];
        [_currentPhotos addObjectsFromArray:objc_getAssociatedObject( ((UIViewController<XLFormRowDescriptorViewController>*)self).rowDescriptor.cellConfig, @"currentPhotos")];
    }
    _screenWidth = [UIScreen mainScreen].bounds.size.width;
    _themeColor =[UIColor colorWithRed:249/255.0 green:102/255.0 blue:92/255.0 alpha:1];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    _uploadedPhotos = [[NSMutableArray alloc] initWithArray:@[]];

    self.view.backgroundColor = [UIColor whiteColor];
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, 2 * _screenWidth)];
    _tableView.dataSource = self;
    _tableView.delegate = self;
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:_tableView];

    static dispatch_once_t once;
    dispatch_once(&once, ^{
        _selectedPhotos = [[NSMutableArray alloc] init];
    });

    NSError *error = nil;
    if (![[NSFileManager defaultManager] createDirectoryAtPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"]
                                   withIntermediateDirectories:YES
                                                    attributes:nil
                                                         error:&error]) {
        NSLog(@"reating 'upload' directory failed: [%@]", error);
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 0) {
        return _screenWidth;
    }
    else
        return 50;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    UITableViewCell *cell;

    if (indexPath.row == 0) {
        static NSString *identifier = @"CellPortrait";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            _horizontalScrollView = [[ASHorizontalScrollView alloc] initWithFrame:CGRectMake(0, 0, _screenWidth, _screenWidth)];
            _horizontalScrollView.leftMarginPx = 0;
            _horizontalScrollView.miniAppearPxOfLastItem = 10;
            _horizontalScrollView.uniformItemSize = CGSizeMake(_screenWidth - 20, _screenWidth-20);
            [_horizontalScrollView setItemsMarginOnce];
            _buttons = [NSMutableArray array];
            for (int i=0; i<_currentPhotos.count; i++) {
                NSURL *imagePath = (NSURL*)(_currentPhotos[i]);

                UIImageView *imageView = [[UIImageView alloc] init];
                imageView.clipsToBounds = YES;
                imageView.contentMode = UIViewContentModeScaleAspectFit;
                imageView.userInteractionEnabled = YES;
                NSDictionary *myInfo = @{@"row": @(i)};
                objc_setAssociatedObject(imageView, @"myInfo", myInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)]];

                UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:imagePath]];
                if (image) {
                    NSLog(@"%@", @"Image from previous successful AWS upload");
                    imageView.image = image;
                    IDMPhoto *photo;
                    photo = [IDMPhoto photoWithImage:image];
                    photo.caption = [NSString stringWithFormat:@"%d", indexPath.row];
                    [_uploadedPhotos addObject:photo];
                }
               [_buttons addObject:imageView];
            }
            [_horizontalScrollView addItems:_buttons];
            _horizontalScrollView.translatesAutoresizingMaskIntoConstraints = false;
            [cell.contentView addSubview:_horizontalScrollView];
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_horizontalScrollView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:0 constant:_screenWidth]];
            [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:_horizontalScrollView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeWidth multiplier:1 constant:0]];
        }
    }
    if (indexPath.row == 1) {
        static NSString *identifier = @"actionsOnPhotoView";

        cell = [tableView dequeueReusableCellWithIdentifier:identifier];

        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGFloat addPhotoBtnTopMargin = 0;
            CGFloat addPhotoBtnHeight = 40;
            _addPhotoBtn = [[UILabel alloc] initWithFrame:CGRectMake(0, addPhotoBtnTopMargin , self.screenWidth, addPhotoBtnHeight)];
            _addPhotoBtn.textAlignment = NSTextAlignmentCenter;
            _addPhotoBtn.textColor = self.themeColor;
            _addPhotoBtn.font = [_addPhotoBtn.font fontWithSize:16];
            _addPhotoBtn.text = @"Add new photos";
            _addPhotoBtn.userInteractionEnabled = YES;
            [_addPhotoBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(addNewPhotos:)]];
            [cell.contentView addSubview:_addPhotoBtn];
        }
    }
    else if (indexPath.row == 2) {
        static NSString *identifier = @"savePhotoView";

        cell = [tableView dequeueReusableCellWithIdentifier:identifier];

        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            CGFloat savePhotoBtnTopMargin = 0;
            CGFloat savePhotoBtnHeight = 40;
            _savePhotoBtn = [[UILabel alloc] initWithFrame:CGRectMake(0, savePhotoBtnTopMargin, self.screenWidth, savePhotoBtnHeight)];
            _savePhotoBtn.textAlignment = NSTextAlignmentCenter;
            _savePhotoBtn.textColor = self.themeColor;
            _savePhotoBtn.font = [_savePhotoBtn.font fontWithSize:16];
            _savePhotoBtn.text = @"Save";
            _savePhotoBtn.userInteractionEnabled = YES;
            [_savePhotoBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(savePhotos:)]];
            _savePhotoBtn.hidden = YES;
            [cell.contentView addSubview:_savePhotoBtn];

            _cancelUploadBtn = [[UILabel alloc] initWithFrame:CGRectMake(0 , savePhotoBtnTopMargin, self.screenWidth/2, savePhotoBtnHeight)];
            _cancelUploadBtn.textAlignment = NSTextAlignmentCenter;
            _cancelUploadBtn.textColor = self.themeColor;
            _cancelUploadBtn.font = [_cancelUploadBtn.font fontWithSize:16];
            _cancelUploadBtn.text = @"Cancel";
            _cancelUploadBtn.userInteractionEnabled = YES;
            _cancelUploadBtn.hidden= YES;
            [_cancelUploadBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancelUpload:)]];
            [cell.contentView addSubview:_cancelUploadBtn];

            _pauseUploadBtn = [[UILabel alloc] initWithFrame:CGRectMake(self.screenWidth/2 , savePhotoBtnTopMargin, self.screenWidth/2, savePhotoBtnHeight)];
            _pauseUploadBtn.textAlignment = NSTextAlignmentCenter;
            _pauseUploadBtn.textColor = self.themeColor;
            _pauseUploadBtn.font = [_pauseUploadBtn.font fontWithSize:16];
            _pauseUploadBtn.text = @"Pause";
            _pauseUploadBtn.userInteractionEnabled = YES;
            _pauseUploadBtn.hidden= YES;
            [_pauseUploadBtn addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(pauseUpload:)]];
            [cell.contentView addSubview:_pauseUploadBtn];


        }
    }

    return cell;
}

- (void)imageViewTapped:(id)sender {
    NSLog(@"image tapped");
    UIImageView *imageView = (UIImageView*)((UITapGestureRecognizer *) sender).view;
    NSDictionary* myInfo = objc_getAssociatedObject(imageView, @"myInfo");
    NSLog(@"myInfo: %@", myInfo);
    int currentIndex = (int) [(NSNumber *)[myInfo objectForKey:@"row"] intValue];
    NSRange r1, r2;
    r1.location = currentIndex;
    r1.length = [_uploadedPhotos count] - currentIndex;
    r2.location = 0;
    r2.length = [_uploadedPhotos count] - r1.length;
    NSArray *ps = [[_uploadedPhotos subarrayWithRange:r1] arrayByAddingObjectsFromArray:[_uploadedPhotos subarrayWithRange:r2]];
    IDMPhotoBrowser *browser = [[IDMPhotoBrowser alloc] initWithPhotos:ps animatedFromView:imageView]; // using initWithPhotos:animatedFromView: method to use the zoom-in animation
    browser.delegate = self;
    browser.displayActionButton = NO;
    browser.displayArrowButton = NO;
    browser.displayCounterLabel = YES;
    browser.usePopAnimation = YES;
    browser.scaleImage = imageView.image;
    browser.useWhiteBackgroundColor = YES;

    // Show
    [self presentViewController:browser animated:YES completion:nil];
}

- (void) addNewPhotos:(id)sender {
    NSLog(@"adding new photos");
    QBImagePickerController *imagePickerController = [QBImagePickerController new];
    imagePickerController.delegate = self;
    imagePickerController.allowsMultipleSelection = YES;
    imagePickerController.maximumNumberOfSelection = 6;
    imagePickerController.showsNumberOfSelectedItems = YES;

    [self presentViewController:imagePickerController animated:YES completion:^{

    }];
}

- (void)cancelUpload:(id)sender {
    NSLog(@"cancelling upload");
    [[_uploadRequest cancel] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            NSLog(@"The cancel request failed: [%@]", task.error);
        }
        [SVProgressHUD dismiss];
        _addPhotoBtn.hidden = NO;
        _savePhotoBtn.hidden = NO;
        _cancelUploadBtn.hidden = YES;
        _pauseUploadBtn.hidden = YES;
        self.navigationController.navigationBar.userInteractionEnabled = YES;
        self.tabBarController.tabBar.userInteractionEnabled = YES;
        for (int i=0; i< _buttons.count; i++) {
            ((UIImageView*)_buttons[i]).userInteractionEnabled = YES;
        }
        _horizontalScrollView.userInteractionEnabled = YES;
        return nil;
    }];

}

- (void) savePhotos:(id)sender {
    NSLog(@"saving photos");
#define AWSAccountID @"695018654605"
#define CognitoPoolID @"us-west-2:ec5a653b-9d85-4d47-bb94-1e94f20dbce6"
#define CognitoRoleAuth @"arn:aws:iam::695018654605:role/Cognito_soohangoutAuth_Role10"
#define CognitoRoleUnauth @"arn:aws:iam::695018654605:role/Cognito_soohangoutAuth_Role10"
#define S3PublicURLPrefix @"https://s3-us-west-1.amazonaws.com/soohangoutphotos/"
    _savePhotoBtn.hidden = YES;
    _pauseUploadBtn.hidden= NO;
    _addPhotoBtn.hidden = YES;
    _cancelUploadBtn.hidden = NO;
    self.navigationController.navigationBar.userInteractionEnabled = NO;
    self.tabBarController.tabBar.userInteractionEnabled = NO;
    for (int i=0; i< _buttons.count; i++) {
        ((UIImageView*)_buttons[i]).userInteractionEnabled = NO;
    }
    _horizontalScrollView.userInteractionEnabled = NO;
    if (_selectedPhotos.count) {
        [self uploadPhoto:(UIImage*) _selectedPhotos[0]];
    }
}

- (void)uploadPhoto:(UIImage*) image {
    NSString *fileName = [[[NSProcessInfo processInfo] globallyUniqueString] stringByAppendingString:@".png"];
    NSString *filePath = [[NSTemporaryDirectory() stringByAppendingPathComponent:@"upload"] stringByAppendingPathComponent:fileName];
    NSData * imageData = UIImagePNGRepresentation(image);
    NSError *error;
    BOOL success = [imageData writeToFile:filePath options:NSDataWritingAtomic error:&error];
    if (!success) {
        NSLog(@"writeToFile failed with error %@", error);
    }
    else {
        __weak PhotoBrowserViewController* weakSelf = self;
        weakSelf.uploadRequest = [AWSS3TransferManagerUploadRequest new];
        weakSelf.uploadRequest.body = [NSURL fileURLWithPath:filePath];
        weakSelf.uploadRequest.key = fileName;
        weakSelf.uploadRequest.bucket = S3BucketName;
        weakSelf.uploadRequest.ACL   = AWSS3ObjectCannedACLPublicRead;
        weakSelf.uploadRequest.uploadProgress = ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend) {
            int progress = floor(totalBytesSent * 100.0 / totalBytesExpectedToSend);
            if (weakSelf.currentProgress < progress) {
                weakSelf.currentProgress = progress;
            }
            NSLog(@"progress: %d", progress);
            NSLog(@"current progress: %d", weakSelf.currentProgress);
            [SVProgressHUD showProgress:(weakSelf.currentProgress/100.0) status:[NSString stringWithFormat:@"%d of %d", weakSelf.currentIndexOfUploadImages + 1, weakSelf.selectedPhotos.count]];
        };
        [self upload:weakSelf.uploadRequest];
    }
}

- (void)pauseUpload:(id)sender {
    NSString* title = ((UILabel*)((UITapGestureRecognizer*) sender).view).text;
    if ([title isEqualToString:@"Pause"]) {
        NSLog(@"pausing all uploads");
        if (_uploadRequest.state == AWSS3TransferManagerRequestStateRunning) {
            [[_uploadRequest pause] continueWithBlock:^id(AWSTask *task) {
                if (task.error) {
                    NSLog(@"The pause request failed: [%@]", task.error);
                }
                NSLog(@"Paused...");
                ((UILabel*)((UITapGestureRecognizer*) sender).view).text = @"Resume";
                return nil;
            }];
        }
        else {
            NSLog(@"transfer is already paused when pause button tapped");
        }
    }
    else {
        NSLog(@"resuming all uploads");
        if (_uploadRequest.state == AWSS3TransferManagerRequestStatePaused) {
            NSLog(@"Resuming...");
            [self upload:_uploadRequest];
            ((UILabel*)((UITapGestureRecognizer*) sender).view).text = @"Pause";
        }
        else {
            NSLog(@"transfer is already on but resume button tapped");
        }

    }

//    switch (_uploadRequest.state) {
//        case AWSS3TransferManagerRequestStateRunning:
//            [[_uploadRequest pause] continueWithBlock:^id(AWSTask *task) {
//                if (task.error) {
//                    NSLog(@"The pause request failed: [%@]", task.error);
//                }
//                NSLog(@"Paused...");
//                return nil;
//            }];
//            break;
//
//        case AWSS3TransferManagerRequestStatePaused:
//            NSLog(@"Resuming...");
//            [self upload:_uploadRequest];
//            break;
//
//        default:
//            break;
//    }

}

#pragma mark - AWS S3

- (void)upload:(AWSS3TransferManagerUploadRequest *)uploadRequest{
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    [[transferManager upload:uploadRequest] continueWithBlock:^id(AWSTask *task) {
        if (task.error) {
            if ([task.error.domain isEqualToString:AWSS3TransferManagerErrorDomain]) {
                switch (task.error.code) {
                    case AWSS3TransferManagerErrorCancelled:
                    case AWSS3TransferManagerErrorPaused:
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{

                        });
                    }
                        break;

                    default:
                        NSLog(@"Upload failed: [%@]", task.error);
                        [SVProgressHUD dismiss];
                        break;
                }
            } else {
                NSLog(@"Upload failed: [%@]", task.error);
                [SVProgressHUD dismiss];
            }
        }

        if (task.result) {
            dispatch_async(dispatch_get_main_queue(), ^{
                NSLog(@"Upload success. Task %@", task);
                if ([uploadRequest.body isKindOfClass:[NSURL class]]) {
                    [_currentPhotos addObject:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@", S3PublicURLPrefix, uploadRequest.key]]];
                    [((NativeEventFormViewController *)self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2]).currentPhotos addObject:[NSString stringWithFormat:@"%@%@", S3PublicURLPrefix, uploadRequest.key]];
                    [SVProgressHUD dismiss];
                    _currentProgress = 0;
                    if (++_currentIndexOfUploadImages < _selectedPhotos.count) {
                        [self uploadPhoto:_selectedPhotos[_currentIndexOfUploadImages]];
                    }
                    else {
                        _pauseUploadBtn.hidden= YES;
                        _addPhotoBtn.hidden = NO;
                        _cancelUploadBtn.hidden = YES;
                        _savePhotoBtn.hidden = NO;
                        self.navigationController.navigationBar.userInteractionEnabled = YES;
                        self.tabBarController.tabBar.userInteractionEnabled = YES;
                        for (int i=0; i< _buttons.count; i++) {
                            ((UIImageView*)_buttons[i]).userInteractionEnabled = YES;
                        }
                        _horizontalScrollView.userInteractionEnabled = YES;
                    }
                }
            });
        }

        return nil;
    }];
}

#pragma mark - QBImagePickerControllerDelegate

- (void)qb_imagePickerController:(QBImagePickerController *)imagePickerController didFinishPickingItems:(NSArray *)items {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSMutableArray *buttons = [NSMutableArray array];
    PHImageRequestOptions* requestOptions = [[PHImageRequestOptions alloc] init];
    requestOptions.resizeMode   = PHImageRequestOptionsResizeModeExact;
    requestOptions.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    requestOptions.synchronous = true;

    NSMutableArray* assets = [NSMutableArray arrayWithArray:items];
    PHImageManager *manager = [PHImageManager defaultManager];

    // assets contains PHAsset objects.

    for (PHAsset *asset in assets) {
        UIImageView *imageView = [[UIImageView alloc] init];
        imageView.clipsToBounds = YES;
        imageView.contentMode = UIViewContentModeScaleAspectFit;
        imageView.userInteractionEnabled = YES;
        [imageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageViewTapped:)]];

        [manager requestImageForAsset:asset
                           targetSize:PHImageManagerMaximumSize
                          contentMode:PHImageContentModeDefault
                              options:requestOptions
                        resultHandler:^void(UIImage *image, NSDictionary *info) {
                            imageView.image = image;
                            [buttons addObject:imageView];
                            [_selectedPhotos addObject:image];
                        }];

    }
    [_horizontalScrollView addItems:buttons];
    _savePhotoBtn.hidden = NO;
    _addPhotoBtn.hidden = YES;

}

- (void)qb_imagePickerControllerDidCancel:(QBImagePickerController *)imagePickerController {
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - IDMPhotoBrowser Delegate

- (void)photoBrowser:(IDMPhotoBrowser *)photoBrowser didShowPhotoAtIndex:(NSUInteger)pageIndex
{
//    id <IDMPhoto> photo = [photoBrowser photoAtIndex:pageIndex];
//    NSLog(@"Did show photoBrowser with photo index: %zu, photo caption: %@", (unsigned long)pageIndex, photo.caption);
}

- (void)photoBrowser:(IDMPhotoBrowser *)photoBrowser willDismissAtPageIndex:(NSUInteger)pageIndex
{
    id <IDMPhoto> photo = [photoBrowser photoAtIndex:pageIndex];
    NSLog(@"Will dismiss photoBrowser with photo index: %zu, photo caption: %@", (unsigned long)pageIndex, photo.caption);
}

- (void)photoBrowser:(IDMPhotoBrowser *)photoBrowser didDismissAtPageIndex:(NSUInteger)pageIndex
{
    id <IDMPhoto> photo = [photoBrowser photoAtIndex:pageIndex];
    NSLog(@"Did dismiss photoBrowser with photo index: %zu, photo caption: %@", (unsigned long)pageIndex, photo.caption);
}

- (void)photoBrowser:(IDMPhotoBrowser *)photoBrowser didDismissActionSheetWithButtonIndex:(NSUInteger)buttonIndex photoIndex:(NSUInteger)photoIndex
{
    id <IDMPhoto> photo = [photoBrowser photoAtIndex:photoIndex];
    NSLog(@"Did dismiss actionSheet with photo index: %zu, photo caption: %@", (unsigned long)photoIndex, photo.caption);

    NSString *title = [NSString stringWithFormat:@"Option %u", buttonIndex+1];
    NSLog(@"title: %@", title);
}

#pragma mark - UIViewController

- (void)viewWillDisappear:(BOOL)animated {
    
}

@end
