//
//  SettingsViewController.h
//  Monomuch
//
//  Created by Jack Rutherford on 13/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <sys/socket.h>
#include <arpa/inet.h>

@interface SettingsViewController : UIViewController {
	IBOutlet UITextField		*hostAddressTextField;	
	IBOutlet UITextField		*hostPortTextField;	
	IBOutlet UITextField		*listenPortTextField;	
	IBOutlet UITextField		*prefixTextField;
	IBOutlet UILabel			*iPadAddressLabel;
	
	NSNetServiceBrowser			*serviceBrowser;
	
	// Keeps track of available domains
    NSMutableArray *domains;	
    // Keeps track of search status
    BOOL searching;

}

@property (nonatomic, retain) UITextField	*hostAddressTextField;
@property (nonatomic, retain) UITextField	*hostPortTextField;
@property (nonatomic, retain) UITextField	*listenPortTextField;
@property (nonatomic, retain) UITextField	*prefixTextField;
@property (nonatomic, retain) UILabel		*iPadAddressLabel;

//	NSNetServiceBrowser delegate methods
- (void)netServiceBrowser:(NSNetServiceBrowser *)n didFindService:(NSNetService *)x moreComing:(BOOL)m;
- (void)netServiceBrowser:(NSNetServiceBrowser *)n didNotSearch:(NSDictionary *)err;
- (void)netServiceBrowser:(NSNetServiceBrowser *)n didRemoveService:(NSNetService *)s moreComing:(BOOL)m;
- (void)netServiceBrowser:(NSNetServiceBrowser *)n didFindDomain:(NSString *)d moreComing:(BOOL)m;

//- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)n;
//- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)n;
//- (void)netServiceBrowser:(NSNetServiceBrowser *)n didRemoveDomain:(NSString *)d moreComing:(BOOL)moreComing;

//	NSNetService delegate methods
- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)err;
- (void)netServiceDidResolveAddress:(NSNetService *)service;

- (IBAction) saveSettings:(id)sender;

@end
