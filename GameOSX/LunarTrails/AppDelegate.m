//
//  AppDelegate.m
//  LunarTrails
//
//  Created by Seb Lee-Delisle on 10/10/2012.
//  Copyright (c) 2012 Seb Lee-Delisle. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

@synthesize webber;
@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	
	NSString *urlString = @"http://moonlander.seb.ly";
	
	NSString* filePath = [[NSBundle mainBundle] pathForResource:@"index"
									ofType:@"html"
							   inDirectory:@"Resources"];
	
	NSURL* fileURL = [NSURL fileURLWithPath:filePath];
	
	//[[webber mainFrame] loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlString]]];
	
	
	NSURLRequest* request = [NSURLRequest requestWithURL:fileURL];
	[[webber mainFrame] loadRequest:request];
	
	
	
	
	
}


@end
