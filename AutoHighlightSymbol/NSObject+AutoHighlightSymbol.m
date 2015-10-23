//
//  NSObject+AutoHighlightSymbol.m
//  AutoHighlightSymbol
//
//  Created by Nelson on 2015/10/23.
//  Copyright © 2015年 Nelson. All rights reserved.
//

#import "NSObject+AutoHighlightSymbol.h"
#import "NSObject+MethodSwizzler.h"
#import "HighlightManager.h"

@interface NSObject ()
- (void)_displayAutoHighlightTokens;
@end

@implementation NSObject (AutoHighlightSymbol)

+ (void)load {
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    [NSClassFromString(@"DVTLayoutManager") swizzleWithOriginalSelector:@selector(_displayAutoHighlightTokens) swizzledSelector:@selector(ahs_displayAutoHighlightTokens) isClassMethod:NO];
  });
}

#pragma mark - Method Swizzling

- (void)ahs_displayAutoHighlightTokens {
  [[HighlightManager sharedManager] renderHighlightColor];
  [self ahs_displayAutoHighlightTokens];
}

@end
