//
//  MonomuchAppDelegate.h
//  Monomuch
//
//  Created by Jack Rutherford on 08/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MonomuchViewController;

@interface MonomuchAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    MonomuchViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet MonomuchViewController *viewController;

@end

