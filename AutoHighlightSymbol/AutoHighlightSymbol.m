//
//  AutoHighlightSymbol.m
//  AutoHighlightSymbol
//
//  Created by Nelson on 2015/10/7.
//  Copyright © 2015年 Nelson. All rights reserved.
//

#import "AutoHighlightSymbol.h"

#import "DVTLayoutManager.h"
#import "DVTSourceTextView.h"
#import "IDEEditor.h"
#import "IDEEditorArea.h"
#import "IDEEditorContext.h"
#import "IDEWorkspaceWindowController.h"

static NSString *const AHSEnabledKey = @"com.nelson.AutoHighlightSymbol.shouldBeEnabled";
static NSString *const AHSHighlightColorKey = @"com.nelson.AutoHighlightSymbol.highlightColor";

@interface AutoHighlightSymbol ()
@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong) NSMutableArray *ranges;
@property (nonatomic, strong) NSColor *highlightColor;
@end

@implementation AutoHighlightSymbol

#pragma mark - Properties

- (NSMutableArray *)ranges {
  if (!_ranges) {
    _ranges = [NSMutableArray array];
  }
  return _ranges;
}

- (NSColor *)highlightColor {
  if (!_highlightColor) {
    NSArray *arr = [[NSUserDefaults standardUserDefaults] objectForKey:AHSHighlightColorKey];
    if (arr) {
      CGFloat r = [arr[0] floatValue];
      CGFloat g = [arr[1] floatValue];
      CGFloat b = [arr[2] floatValue];
      CGFloat a = [arr[3] floatValue];
      _highlightColor = [NSColor colorWithCalibratedRed:r green:g blue:b alpha:a];
    } else {
      _highlightColor = [NSColor colorWithCalibratedRed:1.000 green:0.412 blue:0.093 alpha:0.750];
    }
  }
  return _highlightColor;
}

#pragma mark - Public Methods

+ (instancetype)sharedPlugin {
  return sharedPlugin;
}

+ (BOOL)isEnabled {
  return [[NSUserDefaults standardUserDefaults] boolForKey:AHSEnabledKey];
}

- (void)dealloc {
  [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (id)initWithBundle:(NSBundle *)plugin {
  if (self = [super init]) {
    // reference to plugin's bundle, for resource access
    self.bundle = plugin;
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(applicationDidFinishLaunching:)
                                                 name:NSApplicationDidFinishLaunchingNotification
                                               object:nil];
  }
  return self;
}

#pragma mark - Private Methods

+ (void)setIsEnabled:(BOOL)enabled {
  [[NSUserDefaults standardUserDefaults] setBool:enabled forKey:AHSEnabledKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Notification Handling

- (void)applicationDidFinishLaunching:(NSNotification *)noti {
  // Create menu items, initialize UI, etc.
  NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
  if (menuItem) {
    [[menuItem submenu] addItem:[NSMenuItem separatorItem]];

    NSString *title = [AutoHighlightSymbol isEnabled] ? @"Disable Auto Highlight Symbol" : @"Enable Auto Highlight Symbol";
    NSMenuItem *highlightMenuItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(toggleHighlight:) keyEquivalent:@""];
    [highlightMenuItem setTarget:self];
    [[menuItem submenu] addItem:highlightMenuItem];

    NSMenuItem *colorMenuItem = [[NSMenuItem alloc] initWithTitle:@"Edit Highlight Color" action:@selector(setupColor:) keyEquivalent:@""];
    [colorMenuItem setTarget:self];
    [[menuItem submenu] addItem:colorMenuItem];
  }

  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(selectedExpressionDidChange:)
                                               name:@"DVTSourceExpressionSelectedExpressionDidChangeNotification"
                                             object:nil];
}

- (void)selectedExpressionDidChange:(NSNotification *)noti {
  if (![AutoHighlightSymbol isEnabled]) {
    return;
  }

  DVTSourceTextView *textView = [self currentSourceTextView];
  DVTLayoutManager *layoutManager = (DVTLayoutManager *)textView.layoutManager;

  for (NSValue *range in self.ranges) {
    [layoutManager removeTemporaryAttribute:NSBackgroundColorAttributeName
                          forCharacterRange:[range rangeValue]];
  }
  [self.ranges removeAllObjects];

  [layoutManager.autoHighlightTokenRanges enumerateObjectsUsingBlock:^(NSValue *range, NSUInteger idx, BOOL *stop) {
    [self.ranges addObject:range];
    [layoutManager addTemporaryAttribute:NSBackgroundColorAttributeName
                                   value:self.highlightColor
                       forCharacterRange:[range rangeValue]];
  }];

  [textView setNeedsDisplay:YES];
}

#pragma mark - Menu Item Action

- (void)toggleHighlight:(NSMenuItem *)item {
  [AutoHighlightSymbol setIsEnabled:![AutoHighlightSymbol isEnabled]];
  item.title = [AutoHighlightSymbol isEnabled] ? @"Disable Auto Highlight Symbol" : @"Enable Auto Highlight Symbol";
}

- (void)setupColor:(NSMenuItem *)item {
  NSColorPanel *panel = [NSColorPanel sharedColorPanel];
  panel.color = self.highlightColor;
  panel.target = self;
  panel.action = @selector(colorPanelColorDidChange:);
  [panel orderFront:nil];

  // Observe the closing of the color panel so we can remove ourself from the target.
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(colorPanelWillClose:)
                                               name:NSWindowWillCloseNotification
                                             object:nil];
}

#pragma mark - Color Picker Handling

- (void)colorPanelWillClose:(NSNotification *)notification {
  NSColorPanel *panel = [NSColorPanel sharedColorPanel];
  if (panel == notification.object) {
    panel.target = nil;
    panel.action = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSWindowWillCloseNotification
                                                  object:nil];
  }
}

- (void)colorPanelColorDidChange:(id)sender {
  NSColorPanel *panel = (NSColorPanel *)sender;

  if (!panel.color) {
    return;
  }

  self.highlightColor = panel.color;

  CGFloat red = 0;
  CGFloat green = 0;
  CGFloat blue = 0;
  CGFloat alpha = 0;

  [self.highlightColor getRed:&red green:&green blue:&blue alpha:&alpha];

  NSArray *array = @[@(red), @(green), @(blue), @(alpha)];
  [[NSUserDefaults standardUserDefaults] setObject:array forKey:AHSHighlightColorKey];
  [[NSUserDefaults standardUserDefaults] synchronize];
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
