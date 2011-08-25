//
//  SettingsViewController.m
//  Monomuch
//
//  Created by Jack Rutherford on 13/06/2010.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import "SettingsViewController.h"


@implementation SettingsViewController

@synthesize hostAddressTextField;
@synthesize hostPortTextField;
@synthesize listenPortTextField;
@synthesize prefixTextField;
@synthesize iPadAddressLabel;

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	serviceBrowser = [[NSNetServiceBrowser alloc] init];
	[serviceBrowser setDelegate:self];
	//[serviceBrowser searchForBrowsableDomains];
	//[serviceBrowser searchForRegistrationDomains];
	//[serviceBrowser searchForServicesOfType:@"_services._dns-sd._udp." inDomain:@"local."];
	//@"_ipp._tcp" 
	[serviceBrowser searchForServicesOfType:@"_ipp._tcp" inDomain:@""];
	//[serviceBrowser searchForServicesOfType:@"_osc._udp." inDomain:@""];
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

- (IBAction) saveSettings:(id)sender {
	
}


- (void)dealloc {
    [super dealloc];
}

//	NSNetServiceBrowser delegate methods
- (void)netServiceBrowser:(NSNetServiceBrowser *)n didFindService:(NSNetService *)service moreComing:(BOOL)m	{
	NSLog(@"%s",__func__);	
	NSLog(@"%@", [service domain]);
	NSLog(@"%@", [service hostName]);
	NSLog(@"%@", [service name]);
	NSLog(@"%@", [service type]);
	[service retain];
	[service setDelegate:self];
	[service resolveWithTimeout:5];
	if(m)
	{
		NSLog(@"more coming");
	} else {
		NSLog(@"no more coming");
	}
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)n didNotSearch:(NSDictionary *)err	{
	NSLog(@"%s ... %@",__func__,err);
	NSLog(@"\t\terr, didn't search: %@",err);
}
- (void)netServiceBrowser:(NSNetServiceBrowser *)n didRemoveService:(NSNetService *)s moreComing:(BOOL)m	{
	NSLog(@"%s",__func__);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)n didFindDomain:(NSString *)d moreComing:(BOOL)m {
	NSLog(@"%s",__func__);
	NSLog(@"%@",d);
}


//	NSNetService delegate methods
- (void)netService:(NSNetService *)service didNotResolve:(NSDictionary *)err	{
	NSLog(@"%s",__func__);
	NSLog(@"\t\terr resolving domain: %@",err);
	[service release];
}

-(void)netServiceDidResolveAddress:(NSNetService *)service {
	NSLog(@"%s",__func__);
	NSString *name = nil;
	NSData *address = nil;
	struct sockaddr_in *socketAddress = nil;
	NSString *ipString = nil;
	int port;
	
	for(int i=0;i < [[service addresses] count]; i++ )
	{
		name = [service name];
		address = [[service addresses] objectAtIndex: i];
		socketAddress = (struct sockaddr_in *) [address bytes];
		ipString = [NSString stringWithFormat: @"%s", inet_ntoa(socketAddress->sin_addr)];
		port = socketAddress->sin_port;
		NSLog(@"Resolved: %@-->%@:%hu\n", [service hostName], ipString, port);
	}
	
	[service stop];
	[service release];
}


@end
