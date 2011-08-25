    //
//  AppViewController.m
//  Monomuch
//
//  Created by Jack Rutherford on 19/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "AppViewController.h"
#import "MonomuchViewController.h"
#import "SettingsViewController.h"

@implementation AppViewController

@synthesize monomuchViewController;
@synthesize settingsViewController;



/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	SettingsViewController *settings = [[SettingsViewController alloc] initWithNibName:@"SettingsViewController" bundle:nil];
	self.settingsViewController = settings;
	[settings release];
	
	MonomuchViewController *monomuch = [[MonomuchViewController alloc] initWithNibName:@"MonomuchViewController" bundle:nil];
	self.monomuchViewController = monomuch;
	[monomuch release];
	
	// default view is the settings view for now.
	[self.view insertSubview:self.settingsViewController.view atIndex:0];
}

- (IBAction) switchViews:(id)sender {
	[UIView beginAnimations:@"View Flip" context:nil];
	[UIView	setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDuration:0.75];
	
	if(self.monomuchViewController.view.superview == nil)
	{
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromRight forView:self.view cache:YES];
		[self.monomuchViewController viewWillAppear:YES];
		[self.settingsViewController viewWillDisappear:YES];
		[settingsViewController.view removeFromSuperview];
		[self.view insertSubview:monomuchViewController.view atIndex:0];
		[self.settingsViewController viewDidDisappear:YES];
		[self.monomuchViewController viewDidAppear:YES];
	} else {		
		[UIView setAnimationTransition:UIViewAnimationTransitionFlipFromLeft forView:self.view cache:YES];
		[self.settingsViewController viewWillAppear:YES];
		[self.monomuchViewController viewWillDisappear:YES];
		[monomuchViewController.view removeFromSuperview];
		[self.view insertSubview:settingsViewController.view atIndex:0];
		[self.monomuchViewController viewDidDisappear:YES];
		[self.settingsViewController viewDidAppear:YES];
		
	}
	[UIView commitAnimations];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Overriden to allow any orientation.
    return YES;
}


- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}


- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}


@end
