//
//  JSQAudioMediaViewAttributes+AdjustTintColor.m
//  projecthang
//
//  Created by toeinriver on 8/20/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "JSQAudioMediaViewAttributes+AdjustTintColor.h"
#import "UIImage+JSQMessages.h"
#import "UIColor+JSQMessages.h"

@implementation JSQAudioMediaViewAttributes (AdjustTintColor)

- (instancetype)init
{
    
    UIColor *tintColor = [UIColor colorWithRed:249/255.0 green:102/255.0 blue:92/255.0 alpha:1];
    AVAudioSessionCategoryOptions options = AVAudioSessionCategoryOptionDuckOthers
    | AVAudioSessionCategoryOptionDefaultToSpeaker
    | AVAudioSessionCategoryOptionAllowBluetooth;
    
    return [self initWithPlayButtonImage:[[UIImage jsq_defaultPlayImage] jsq_imageMaskedWithColor:tintColor]
                        pauseButtonImage:[[UIImage jsq_defaultPauseImage] jsq_imageMaskedWithColor:tintColor]
                               labelFont:[UIFont systemFontOfSize:12]
                   showFractionalSecodns:NO
                         backgroundColor:[UIColor jsq_messageBubbleLightGrayColor]
                               tintColor:tintColor
                           controlInsets:UIEdgeInsetsMake(6, 6, 6, 18)
                          controlPadding:6
                           audioCategory:@"AVAudioSessionCategoryPlayback"
                    audioCategoryOptions:options];
}


@end
