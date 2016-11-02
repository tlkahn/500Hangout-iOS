//
//  UIImage+FXImageBlur.h
//  
//
//  Created by toeinriver on 8/3/16.
//
//

#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>
#import <Accelerate/Accelerate.h>

@interface UIImage (FXImageBlur)
- (UIImage *)blurredImageWithRadius:(CGFloat)radius iterations:(NSUInteger)iterations tintColor:(UIColor *)tintColor;

@end
