//
//  JSQMessagesToolbarButtonFactory+AdjustColorForSendButton.m
//  projecthang
//
//  Created by toeinriver on 8/20/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "JSQMessagesToolbarButtonFactory+AdjustColorForSendButton.h"
#import "UIColor+JSQMessages.h"
#import "UIImage+JSQMessages.h"
#import "NSBundle+JSQMessages.h"

@implementation JSQMessagesToolbarButtonFactory (AdjustColorForSendButton)

+ (UIButton *)defaultSendButtonItem
{
    UIColor* themeColor =[UIColor colorWithRed:249/255.0 green:102/255.0 blue:92/255.0 alpha:1];
    NSString *sendTitle = [NSBundle jsq_localizedStringForKey:@"send"];
    
    UIButton *sendButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [sendButton setTitle:sendTitle forState:UIControlStateNormal];
    [sendButton setTitleColor:themeColor forState:UIControlStateNormal];
    [sendButton setTitleColor:themeColor forState:UIControlStateHighlighted];
    [sendButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
    
    sendButton.titleLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    sendButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    sendButton.titleLabel.minimumScaleFactor = 0.85f;
    sendButton.contentMode = UIViewContentModeCenter;
    sendButton.backgroundColor = [UIColor clearColor];
    
    sendButton.tintColor = themeColor; //[UIColor jsq_messageBubbleBlueColor];
    
    CGFloat maxHeight = 32.0f;
    
    CGRect sendTitleRect = [sendTitle boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, maxHeight)
                                                   options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                                                attributes:@{ NSFontAttributeName : sendButton.titleLabel.font }
                                                   context:nil];
    
    sendButton.frame = CGRectMake(0.0f,
                                  0.0f,
                                  CGRectGetWidth(CGRectIntegral(sendTitleRect)),
                                  maxHeight);
    
    return sendButton;
}

@end
