//
//  AutoHighlightSymbol.m
//  AutoHighlightSymbol
//
//  Created by Nelson on 2015/10/7.
//  Copyright © 2015年 Nelson. All rights reserved.
//

#import "AutoHighlightSymbol.h"
#import "HighlightManager.h"

static NSString *const AHSEnabledKey = @"com.nelson.AutoHighlightSymbol.shouldBeEnabled";

@interface AutoHighlightSymbol ()
@property (nonatomic, strong, readwrite) NSBundle *bundle;
@property (nonatomic, strong) NSMenuItem *highlightMenuItem;
@property (nonatomic, strong) NSMenuItem *colorMenuItem;
@end

@implementation AutoHighlightSymbol

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
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(menuDidChange:)
                                                 name:NSMenuDidChangeItemNotification
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
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NSApplicationDidFinishLaunchingNotification
                                                object:nil];
}

// Code from https://github.com/FuzzyAutocomplete/FuzzyAutocompletePlugin/blob/master/FuzzyAutocomplete/FuzzyAutocomplete.m
- (void)menuDidChange:(NSNotification *)notification {
  [[NSNotificationCenter defaultCenter] removeObserver:self
                                                  name:NSMenuDidChangeItemNotification
                                                object:nil];
  [self createMenuItem];
  [[NSNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(menuDidChange:)
                                               name:NSMenuDidChangeItemNotification
                                             object:nil];
}

#pragma mark - Menu Item and Action

- (void)createMenuItem {
  NSString *title = @"Auto Highlight Symbol";
  NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Editor"];

  if (menuItem && ![menuItem.submenu itemWithTitle:title]) {
    [menuItem.submenu addItem:[NSMenuItem separatorItem]];

    NSMenuItem *highlightMenuItem = [[NSMenuItem alloc] initWithTitle:title action:@selector(toggleHighlight:) keyEquivalent:@""];
    highlightMenuItem.target = self;
    [menuItem.submenu addItem:highlightMenuItem];
    self.highlightMenuItem = highlightMenuItem;

    NSMenuItem *colorMenuItem = [[NSMenuItem alloc] initWithTitle:@"Edit Highlight Color" action:NULL keyEquivalent:@""];
    colorMenuItem.target = self;
    colorMenuItem.action = ([AutoHighlightSymbol isEnabled] ? @selector(setupColor:) : NULL);
    [menuItem.submenu addItem:colorMenuItem];
    self.colorMenuItem = colorMenuItem;

    [self enableHighlight:[AutoHighlightSymbol isEnabled]];
  }
}

- (void)toggleHighlight:(NSMenuItem *)item {
  [AutoHighlightSymbol setIsEnabled:![AutoHighlightSymbol isEnabled]];
  [self enableHighlight:[AutoHighlightSymbol isEnabled]];
}

- (void)enableHighlight:(BOOL)enabled {
  [HighlightManager sharedManager].highlightEnabled = enabled;
  self.highlightMenuItem.state = (enabled ? NSOnState : NSOffState);
  self.colorMenuItem.action = (enabled ? @selector(setupColor:) : NULL);
}

- (void)setupColor:(NSMenuItem *)item {
  NSColorPanel *panel = [NSColorPanel sharedColorPanel];
  panel.color = [HighlightManager sharedManager].highlightColor;
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

  [HighlightManager sharedManager].highlightColor = panel.color;
  [[HighlightManager sharedManager] renderHighlightColor];
}

@end
