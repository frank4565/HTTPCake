//
//  HCAppDelegate.h
//  HTTPCake
//
//  Created by Cheng Junlu on 5/24/13.
//  Copyright (c) 2013 Nerv Dev. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface HCAppDelegate : NSObject <NSApplicationDelegate>

@property (unsafe_unretained) IBOutlet NSWindow *dumpWindow;
@property (assign) IBOutlet NSWindow *window;
@property (weak) IBOutlet NSTextField *urlTextField;
@property (weak) IBOutlet NSButton *getButton;
@property (weak) IBOutlet NSButton *postButton;
@property (weak) IBOutlet NSTableView *requestHeadersTableView;
@property (weak) IBOutlet NSTableView *parametersTableView;
@property (unsafe_unretained) IBOutlet NSTextView *responseTextView;
@property (unsafe_unretained) IBOutlet NSTextView *responseHeadersTextView;
@property (weak) IBOutlet NSButton *openFileButton;
@property (weak) IBOutlet NSTableView *requestsTableView;
@property (weak) IBOutlet NSButton *snifferButton;

@end
