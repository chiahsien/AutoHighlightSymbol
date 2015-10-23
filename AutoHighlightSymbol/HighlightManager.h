//
//  HighlightManager.h
//  AutoHighlightSymbol
//
//  Created by Nelson on 2015/10/23.
//  Copyright © 2015年 Nelson. All rights reserved.
//

#import <AppKit/AppKit.h>

@interface HighlightManager : NSObject
+ (instancetype)sharedManager;
- (void)renderHighlightColor;
@property (nonatomic, strong) NSColor *highlightColor;
@property (nonatomic, assign) BOOL highlightEnabled;
@end
