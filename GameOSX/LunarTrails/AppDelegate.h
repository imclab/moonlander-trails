//
//  AppDelegate.h
//  LunarTrails
//
//  Created by Seb Lee-Delisle on 10/10/2012.
//  Copyright (c) 2012 Seb Lee-Delisle. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <WebKit/WebKit.h>
#import <CoreGraphics/CoreGraphics.h>

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (assign) IBOutlet NSWindow *window;
@property (assign) IBOutlet WebView *webber;


@end
