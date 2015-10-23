//
//  NSObject+MethodSwizzler.m
//  AutoHighlightSymbol
//
//  Created by Nelson on 2015/10/23.
//  Copyright © 2015年 Nelson. All rights reserved.
//

#import "NSObject+MethodSwizzler.h"
#import <objc/runtime.h>

@implementation NSObject (MethodSwizzler)

+ (void)swizzleWithOriginalSelector:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector isClassMethod:(BOOL)isClassMethod {
  Class cls = [self class];

  Method originalMethod;
  Method swizzledMethod;

  if (isClassMethod) {
    originalMethod = class_getClassMethod(cls, originalSelector);
    swizzledMethod = class_getClassMethod(cls, swizzledSelector);
  } else {
    originalMethod = class_getInstanceMethod(cls, originalSelector);
    swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
  }

  if (!originalMethod) {
    NSLog(@"Error: originalMethod is nil, did you spell it incorrectly? %@", originalMethod);
    return;
  }

  method_exchangeImplementations(originalMethod, swizzledMethod);
}

@end
