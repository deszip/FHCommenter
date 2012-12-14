//
//  FHCommenter.m
//  FHCommenterPlugin
//
//  Created by Zar doz on 14.12.12.
//  Copyright (c) 2012 FHOF. All rights reserved.
//

#import "FHCommenter.h"

@implementation FHCommenter

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static id sharedPlugin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedPlugin = [[self alloc] init];
    });
}

- (id)init
{
    if ((self = [super init])) {
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(applicationDidFinishLaunching:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)applicationDidFinishLaunching: (NSNotification*) notification
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(selectionDidChange:)
                                                 name:NSTextViewDidChangeSelectionNotification
                                               object:nil];
    
    NSMenuItem* editMenuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (editMenuItem) {
        [[editMenuItem submenu] addItem:[NSMenuItem separatorItem]];
        
        NSMenuItem* newMenuItem = [[NSMenuItem alloc] initWithTitle:@"Block comment"
                                                             action:@selector(toggleComment)
                                                      keyEquivalent:@"/"];
        
        [newMenuItem setTarget:self];
        [newMenuItem setKeyEquivalentModifierMask:(NSCommandKeyMask)];
        [[editMenuItem submenu] addItem:newMenuItem];
        [newMenuItem release];
    }
}

- (void)selectionDidChange:(NSNotification *)notification
{
    if ([[notification object] isKindOfClass:[NSTextView class]]) {
        self.targetTextView = (NSTextView *)[notification object];
        
        NSArray* selectedRanges = [self.targetTextView selectedRanges];
        if (selectedRanges.count == 0) {
            return;
        }
        
        self.selectedRange = [[selectedRanges objectAtIndex:0] rangeValue];
        self.selectedText = [self.targetTextView.textStorage.string substringWithRange:self.selectedRange];
    }
}

- (void)toggleComment
{
    if (self.selectedRange.length == 0) return;
    
    NSString *replacement = @"";
    NSString *trimmed = [self.selectedText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    
    if ([[trimmed substringToIndex:2] isEqualToString:@"/*"] &&
        [[trimmed substringFromIndex:trimmed.length - 2] isEqualToString:@"*/"]) {
        replacement = [trimmed substringWithRange:NSMakeRange(2, trimmed.length - 2)];
    } else if ([trimmed rangeOfString:@"/*"].location != NSNotFound ||
               [trimmed rangeOfString:@"*/"].location != NSNotFound) {
        replacement = [trimmed stringByReplacingOccurrencesOfString:@"/*" withString:@""];
        replacement = [replacement stringByReplacingOccurrencesOfString:@"*/" withString:@""];
    } else {
        replacement = [NSString stringWithFormat:@"/*\n%@\n*/", self.selectedText];
    }
    
    [self.targetTextView insertText:replacement replacementRange:self.selectedRange];
}

@end
