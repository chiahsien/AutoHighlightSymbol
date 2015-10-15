//
//  AutoHighlightSymbol.h
//  AutoHighlightSymbol
//
//  Created by Nelson on 2015/10/7.
//  Copyright © 2015年 Nelson. All rights reserved.
//

#import <AppKit/AppKit.h>

@class AutoHighlightSymbol;

static AutoHighlightSymbol *sharedPlugin;

@interface AutoHighlightSymbol : NSObject

+ (instancetype)sharedPlugin;
+ (BOOL)isEnabled;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle *bundle;
@end
