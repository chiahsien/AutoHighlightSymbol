//
//  NSObject_Extension.m
//  AutoHighlightSymbol
//
//  Created by Nelson on 2015/10/7.
//  Copyright © 2015年 Nelson. All rights reserved.
//

#import "NSObject_Extension.h"
#import "AutoHighlightSymbol.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin {
  static dispatch_once_t onceToken;
  NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
  if ([currentApplicationName isEqual:@"Xcode"]) {
    dispatch_once(&onceToken, ^{
      sharedPlugin = [[AutoHighlightSymbol alloc] initWithBundle:plugin];
    });
  }
}

@end
