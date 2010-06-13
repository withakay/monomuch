//
//  MonomuchViewController.h
//  Monomuch
//
//  Created by Jack Rutherford on 08/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#include <ifaddrs.h>
#include <arpa/inet.h>
#import "VVOSC.h"
#import "MonomeButton.h"

@interface MonomuchViewController : UIViewController {
	OSCManager					*manager;
	OSCInPort					*inPort;
	OSCOutPort					*outPort;	//	this is the port that will actually be sending the data
	
	IBOutlet UIButton			*resetButton;	
	IBOutlet UITextView			*logTextView;	
	IBOutlet UITextField		*hostAddressTextField;	
	IBOutlet UITextField		*hostPortTextField;	
	IBOutlet UITextField		*listenPortTextField;	
	IBOutlet UITextField		*prefixTextField;
	IBOutlet UILabel			*iPadAddressLabel;
	
	int							gridWidth;
	int							gridHeight;
}

@property (nonatomic, retain) UITextField *hostAddressTextField;
@property (nonatomic, retain) UITextField *hostPortTextField;
@property (nonatomic, retain) UITextField *listenPortTextField;
@property (nonatomic, retain) UITextField *prefixTextField;
@property (nonatomic, retain) UILabel *iPadAddressLabel;
@property (nonatomic) int gridWidth;
@property (nonatomic) int gridHeight;

- (IBAction) buttonPressDown:(id)sender;
- (IBAction) buttonPressUp:(id)sender;
- (IBAction) connectOscPorts: (id)sender;
- (void) sendStateForButtonAtColumn:(int)x andRow: (int) y withState: (int) state;
- (void) setStateForButtonAtColumn:(int)x andRow: (int) y withState: (int) state;
- (void) setStateForButtonWithMessage:(OSCMessage *)m;
- (void) setStateForButtonsInColumnWithMessage:(OSCMessage *)m;
- (void) setStateForButtonsInRowWithMessage:(OSCMessage *)m;
- (void) setStateForButtonsInFrameWithMessage:(OSCMessage *)m;
- (void) clearButtonsWithMessage:(OSCMessage *)m;
- (void) setPrefixWithMessage:(OSCMessage *)m;

- (NSString *)getIPAddress;

extern int const TAG_BASE;

@end

