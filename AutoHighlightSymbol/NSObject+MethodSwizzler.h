//
//  NSObject+MethodSwizzler.h
//  AutoHighlightSymbol
//
//  Created by Nelson on 2015/10/23.
//  Copyright © 2015年 Nelson. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (MethodSwizzler)

+ (void)swizzleWithOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector isClassMethod:(BOOL)isClassMethod;

@end
