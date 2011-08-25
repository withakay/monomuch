//
//  AppViewController.h
//  Monomuch
//
//  Created by Jack Rutherford on 19/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MonomuchViewController;
@class SettingsViewController;

@interface AppViewController : UIViewController {
	MonomuchViewController *monomuchViewController;
	SettingsViewController *settingsViewController;
}

@property (retain, nonatomic) MonomuchViewController *monomuchViewController;
@property (retain, nonatomic) SettingsViewController *settingsViewController;

- (IBAction) switchViews:(id)sender;

@end
