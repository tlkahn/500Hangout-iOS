//
//  UIFont+SystemFontOverride.m
//  projecthang
//
//  Created by toeinriver on 8/31/16.
//  Copyright © 2016 toeinriver. All rights reserved.
//

#import "UIFont+SystemFontOverride.h"

@implementation UIFont (SystemFontOverride)

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-protocol-method-implementation"

+ (UIFont *)systemFontOfSize:(CGFloat)fontSize {
    return [UIFont fontWithName:@"din-regular" size:fontSize];
}

#pragma clang diagnostic pop

@end
