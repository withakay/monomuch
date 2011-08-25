//
//  MonomuchAppDelegate.h
//  Monomuch
//
//  Created by Jack Rutherford on 08/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AppViewController;

@interface MonomuchAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	AppViewController *appViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet AppViewController *appViewController;


@end

