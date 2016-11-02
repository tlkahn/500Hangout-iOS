//
//  PhotoBrowserViewController.h
//  projecthang
//
//  Created by toeinriver on 8/7/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IDMPhotoBrowser.h"
#import <OHQBImagePicker/QBImagePicker.h>
#import <XLForm/XLForm.h>

@interface PhotoBrowserViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, IDMPhotoBrowserDelegate, QBImagePickerControllerDelegate, XLFormRowDescriptorViewController>

@property (nonatomic) XLFormRowDescriptor * rowDescriptor;

@end
