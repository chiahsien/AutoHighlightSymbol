//
//  HighlightManager.m
//  AutoHighlightSymbol
//
//  Created by Nelson on 2015/10/23.
//  Copyright © 2015年 Nelson. All rights reserved.
//

#import "HighlightManager.h"

#import "DVTLayoutManager.h"
#import "DVTSourceTextView.h"
#import "IDEEditor.h"
#import "IDEEditorArea.h"
#import "IDEEditorContext.h"
#import "IDEWorkspaceWindowController.h"

@interface HighlightManager ()
@property (nonatomic, strong) NSMutableArray *ranges;
@end

@implementation HighlightManager

#pragma mark - Properties

- (NSMutableArray *)ranges {
  if (!_ranges) {
    _ranges = [NSMutableArray array];
  }
  return _ranges;
}

- (void)setHighlightEnabled:(BOOL)highlightEnabled {
  if (_highlightEnabled == highlightEnabled) {
    return;
  }
  _highlightEnabled = highlightEnabled;
  if (highlightEnabled) {
    [self applyNewHighlightColor];
  } else {
    [self removeOldHighlightColor];
  }
}

#pragma mark - Public Methods

+ (instancetype)sharedManager {
  static HighlightManager *_manager = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    _manager = [[HighlightManager alloc] init];
    _manager.highlightEnabled = NO;
    _manager.highlightColor = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0];
  });
  return _manager;
}

- (void)renderHighlightColor {
  if (self.highlightEnabled) {
    [self removeOldHighlightColor];
    [self applyNewHighlightColor];
  }
}

#pragma mark - Highlight Rendering

- (void)removeOldHighlightColor {
  DVTSourceTextView *textView = [self currentSourceTextView];
  DVTLayoutManager *layoutManager = (DVTLayoutManager *)textView.layoutManager;

  for (NSValue *range in self.ranges) {
    [layoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName
                          forCharacterRange:[range rangeValue]];
  }
  [self.ranges removeAllObjects];

  [textView setNeedsDisplay:YES];
}

- (void)applyNewHighlightColor {
  DVTSourceTextView *textView = [self currentSourceTextView];
  DVTLayoutManager *layoutManager = (DVTLayoutManager *)textView.layoutManager;

  [layoutManager.autoHighlightTokenRanges enumerateObjectsUsingBlock:^(NSValue *range, NSUInteger idx, BOOL *stop) {
    [layoutManager addTemporaryAttribute:NSBackgroundColorAttributeName
                                   value:self.highlightColor
                       forCharacterRange:[range rangeValue]];
  }];
  [self.ranges addObjectsFromArray:layoutManager.autoHighlightTokenRanges];

  [textView setNeedsDisplay:YES];
}

#pragma mark - Get IDE Editor View
// Code from https://github.com/fortinmike/XcodeBoost/blob/master/XcodeBoost/MFPluginController.m

- (IDEEditor *)currentEditor {
  NSWindowController *mainWindowController = [[NSApp mainWindow] windowController];
  if ([mainWindowController isKindOfClass:NSClassFromString(@"IDEWorkspaceWindowController")]) {
    IDEWorkspaceWindowController *workspaceController = (IDEWorkspaceWindowController *)mainWindowController;
    IDEEditorArea *editorArea = [workspaceController editorArea];
    IDEEditorContext *editorContext = [editorArea lastActiveEditorContext];
    return [editorContext editor];
  }
  return nil;
}

- (DVTSourceTextView *)currentSourceTextView {
  IDEEditor *currentEditor = [self currentEditor];

  if ([currentEditor isKindOfClass:NSClassFromString(@"IDESourceCodeEditor")]) {
    return (DVTSourceTextView *)[(id) currentEditor textView];
  }

  if ([currentEditor isKindOfClass:NSClassFromString(@"IDESourceCodeComparisonEditor")]) {
    return [(id) currentEditor performSelector:NSSelectorFromString(@"keyTextView")];
  }

  return nil;
}

@end
