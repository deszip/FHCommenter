//
//  FHCommenter.h
//  FHCommenterPlugin
//
//  Created by Zar doz on 14.12.12.
//  Copyright (c) 2012 FHOF. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface FHCommenter : NSObject {
    
}

@property (strong, nonatomic) NSTextView *targetTextView;
@property (strong, nonatomic) NSString *selectedText;
@property (assign, nonatomic) NSRange selectedRange;

- (void)selectionDidChange:(NSNotification *)notification;
- (void)toggleComment;

@end
