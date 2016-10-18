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

@implementation HighlightManager

#pragma mark - Properties

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
    _manager.highlightColor = [NSColor colorWithCalibratedRed:0 green:0 blue:0 alpha:0];
    _manager.highlightEnabled = NO;
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
  NSUInteger length = [[[textView textStorage] string] length];
  NSRange range = NSMakeRange(0, 0);

  for (NSUInteger i = 0; i < length; i += range.length) {
    NSDictionary *dic = [layoutManager temporaryAttributesAtCharacterIndex:i effectiveRange:&range];
    id color = dic[NSBackgroundColorAttributeName];
    if ([self.highlightColor isEqual:color]) {
      [layoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName
                            forCharacterRange:range];
    }
  }

  [textView setNeedsDisplay:YES];
}

- (void)applyNewHighlightColor {
  DVTSourceTextView *textView = [self currentSourceTextView];
  DVTLayoutManager *layoutManager = (DVTLayoutManager *)textView.layoutManager;

  // We want to highlight multiple instances of selected symbol.
  if (layoutManager.autoHighlightTokenRanges.count < 2) {
    return;
  }

  [layoutManager.autoHighlightTokenRanges enumerateObjectsUsingBlock:^(NSValue *range, NSUInteger idx, BOOL *stop) {
    [layoutManager addTemporaryAttribute:NSBackgroundColorAttributeName
                                   value:self.highlightColor
                       forCharacterRange:[range rangeValue]];
  }];

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
