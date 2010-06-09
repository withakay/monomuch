//
//  MonomuchAppDelegate.m
//  Monomuch
//
//  Created by Jack Rutherford on 08/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MonomuchAppDelegate.h"
#import "MonomuchViewController.h"

@implementation MonomuchAppDelegate

@synthesize window;
@synthesize viewController;


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];

	return YES;
}


- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}


@end
