//
//  MonomuchAppDelegate.m
//  Monomuch
//
//  Created by Jack Rutherford on 08/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MonomuchAppDelegate.h"
#import "AppViewController.h"

@implementation MonomuchAppDelegate

@synthesize window;
@synthesize appViewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    [window addSubview:appViewController.view];
    [window makeKeyAndVisible];

	return YES;
}



- (void)dealloc {
    [appViewController release];
    [window release];
    [super dealloc];
}


@end
