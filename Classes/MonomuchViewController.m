//
//  MonomuchViewController.m
//  Monomuch
//
//  Created by Jack Rutherford on 08/06/2010.
//  Copyright __MyCompanyName__ 2010. All rights reserved.
//

#import "MonomuchViewController.h"

@implementation MonomuchViewController

@synthesize hostAddressTextField;
@synthesize hostPortTextField;
@synthesize listenPortTextField;
@synthesize prefixTextField;
@synthesize gridWidth;
@synthesize gridHeight;
@synthesize iPadAddressLabel;

// this provides an offset for the buttons tag as the default value for any views tag is 0. A UIButton is a view.
int const TAG_BASE = 10000;

- (id)initWithCoder:(NSCoder *)aDecoder {
	NSLog(@"%s",__func__);
	if(self = [super initWithCoder:(NSCoder *)aDecoder]) {
		//	make an osc manager- i'm using "MyOSCManager" because i'm using a custom in-port
		manager = [[OSCManager alloc] init];
		//	by default, the osc manager's delegate will be told when osc messages are received
		[manager setDelegate:self];
		
		self.gridWidth = 8;
		self.gridHeight = 8;
	}
	return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	NSLog(@"%s",__func__);
    [super viewDidLoad];	
	
	self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"BrushedMetal.png"]];
	
	iPadAddressLabel.text = [self getIPAddress];
	
	int topOffset = (1024-768);	
	// create the button grid
	for (int y=0; y<self.gridHeight; y++) {
		for (int x=0; x<self.gridWidth; x++) {
			int buttonTag = TAG_BASE + ( (y*self.gridWidth)+(x) );
			
			//TODO: make the size adjust depending on the gridWidth and gridHeight
			
			UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom]; 
			[button setFrame:CGRectMake(9+(x*96.1f), (y*96.0f)+topOffset-12, 80.0f, 80.0f)]; 			
			
			// Initialize the gradient layer
			CAGradientLayer *gradientLayer = [[CAGradientLayer alloc] init];
			// Set its bounds to be the same of its parent
			[gradientLayer setBounds:[button bounds]];
			// Center the layer inside the parent layer
			[gradientLayer setPosition:
			 CGPointMake([button bounds].size.width/2,
						 [button bounds].size.height/2)];
			
			// Insert the layer at position zero to make sure the 
			// text of the button is not obscured
			[[button layer] insertSublayer:gradientLayer atIndex:0];
			
			// Set the layer's corner radius
			[[button layer] setCornerRadius:8.0f];
			// Turn on masking
			[[button layer] setMasksToBounds:YES];
			// Display a border around the button 
			// with a 1.0 pixel width
			//[[button layer] setBorderWidth:2.0f];	
			
			
			//[button setBackgroundColor:[UIColor lightGrayColor]];
			[button setBackgroundImage:[UIImage imageNamed:@"button_overlay.png"] forState:UIControlStateNormal];
			[button setAlpha:0.1f];
			
			[button setTag: buttonTag]; 
			 
			[button addTarget:self action:@selector(buttonPressDown:)forControlEvents:UIControlEventTouchDown]; 
			[button addTarget:self action:@selector(buttonPressUp:)forControlEvents:UIControlEventTouchUpInside]; 
			[self.view addSubview:button];
			//NSLog(@"%d",buttonTag);
		}
	}
	
	NSLog(@"in port: %d", self.listenPortTextField.text.intValue);
	NSLog(@"out port: %d", self.hostPortTextField.text.intValue);
	
	
}

- (IBAction)connectOscPorts:(id)sender {
	// listen port
	inPort = [manager 
			  createNewInputForPort:self.listenPortTextField.text.intValue];
	// host port
	outPort = [manager 
			   createNewOutputToAddress:self.hostAddressTextField.text atPort:self.hostPortTextField.text.intValue];
	if (outPort == nil)
		NSLog(@"\t\terror creating output B");	
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return YES;
}

- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}

- (int) getBitFromInt:(int)i AtIndex: (int)idx {
	if(idx == 0) {
		return i & 1;
	}else {
		return (i & (1 << idx)) >> idx;
	} 
}

- (IBAction) buttonPressDown:(id)sender	{
	NSLog(@"%s",__func__);	
	int tag = [(UIButton *)sender tag] - TAG_BASE;	
	int state = 1;
	//NSLog(@"button.tag: %d",tag);	
	int x = tag % 8;
	int y = (tag - x)/8;	
	//NSLog( @"x: %d, y: %d, state: %d", x, y, state);
	//logTextView.text = [NSString stringWithFormat: @"x: %d, y: %d, state: %d \n%@", x, y, state, logTextView.text];
	[self sendStateForButtonAtColumn: x andRow:y withState:state];
}

- (IBAction) buttonPressUp:(id)sender {
	NSLog(@"%s",__func__);	
	int tag = [(UIButton *)sender tag] - TAG_BASE;		
	int state = 0;	NSLog(@"button.tag: %d",tag);	
	int x = tag % 8;
	int y = (tag - x)/8;	
	//NSLog( @"x: %d, y: %d, state: %d", x, y, state);
	//logTextView.text = [NSString stringWithFormat: @"x: %d, y: %d, state: %d \n%@", x, y, state, logTextView.text];		
	[self sendStateForButtonAtColumn: x andRow:y withState:state];
}

- (void) sendStateForButtonAtColumn:(int)x andRow:(int)y withState:(int)state {	
	NSLog(@"%s",__func__);
	OSCMessage	*msg1 = nil;
	
	NSString *address = [[[NSString alloc] initWithFormat: @"%@/press", prefixTextField.text] autorelease];
	NSLog(@"sending to address '%@'", address);
	msg1 = [OSCMessage createWithAddress:address];
	[msg1 addInt:x];
	[msg1 addInt:y];
	[msg1 addInt:state];
	[outPort sendThisMessage:msg1];
}

- (void) setStateForButtonAtColumn:(int)x andRow:(int)y withState:(int)state {	
	NSLog(@"%s",__func__);
	
	// first calculate the tag
	int buttonTag = TAG_BASE + ((y*8)+(x));
	NSLog(@"buttonTag: %d", buttonTag);
	UIButton *button = (UIButton *)[self.view viewWithTag:buttonTag];
	
	if(button == nil)
	{
		NSLog(@"button with tag %d could not be found", buttonTag);
	} else {
		if(state==1) {
			[button setAlpha:1.0f];
			
		} else {
			//[button setHighlighted: NO];
			[button setAlpha:0.1f];
		}
			
	}
	
	
}

- (void) setStateForButtonWithMessage:(OSCMessage *)m {	
	//NSLog(@"%s",__func__);
	[self setStateForButtonAtColumn:[[m valueAtIndex:0 ] intValue]
							 andRow:[[m valueAtIndex:1 ] intValue]
						  withState:[[m valueAtIndex:2 ] intValue]];
}

- (void) setStateForButtonsInColumnWithMessage:(OSCMessage *)m {
	int col = [[m valueAtIndex:0 ] intValue];
	for (int idx=1; idx < [m valueCount]; idx++) {
		//NSLog(@"idx = %d", idx);
		for (int x=0; x<8; x++) {
			//NSLog(@"x = %d", x);
			int state = [self getBitFromInt:[[m valueAtIndex:idx ] intValue] AtIndex: x];
			[self setStateForButtonAtColumn:col andRow:x withState:state];
		}
	}	
}

- (void) setStateForButtonsInRowWithMessage:(OSCMessage *)m {
	int row = [[m valueAtIndex:0 ] intValue];
	for (int idx=1; idx < [m valueCount]; idx++) {
		//NSLog(@"idx = %d", idx);
		for (int x=0; x<8; x++) {
			//NSLog(@"x = %d", x);
			int state = [self getBitFromInt:[[m valueAtIndex:idx ] intValue] AtIndex: x];
			[self setStateForButtonAtColumn:x andRow:row withState:state];
		}
	}	
}

/*
 Functionally identical to
 
 /40h/led_col 0 A
 /40h/led_col 1 B
 /40h/led_col 2 C
 /40h/led_col 3 D
 /40h/led_col 4 E
 /40h/led_col 5 F
 /40h/led_col 6 G
 /40h/led_col 7 H
 */
- (void) setStateForButtonsInFrameWithMessage:(OSCMessage *)m {
	for (int idx=0; idx < [m valueCount]; idx++) {
		// idx is column
		for (int x=0; x<8; x++) {
			NSLog(@"x = %d", x);
			int state = [self getBitFromInt:[[m valueAtIndex:idx ] intValue] AtIndex: x];
			[self setStateForButtonAtColumn:idx andRow:x withState:state];
		}
	}
}

- (void) clearButtonsWithMessage:(OSCMessage *)m {
	
}

- (void) setPrefixWithMessage:(OSCMessage *)m {
	prefixTextField.text = [[m value] stringValue];
}

// called by delegate on message

- (void) receivedOSCMessage:(OSCMessage *)m	{
	//NSLog(@"%s",__func__);
	NSString *prefix = [[[NSString alloc] initWithString:prefixTextField.text] autorelease];
	/*
	NSString *logMsg = [[[NSString alloc] init] autorelease];
	int idx = 0;
	while (idx < [m valueCount]) {
		//NSLog(@"%d", idx);
		//NSLog(@"%d", [[m valueAtIndex: idx ] intValue]);
		logMsg = [logMsg stringByAppendingFormat:@"%d, ", [[m valueAtIndex: idx ] intValue]];
		idx++;
	}
	
	NSLog(@"address: %@, value: %@", 
		  address, 
		  logMsg);
	//[logMsg release];
	
	[logTextView performSelectorOnMainThread:@selector(setText:) 
								  withObject:[NSString stringWithFormat:@"received message from address: %@, with value(s): %@", 
											  address, 
											  logMsg] 
							   waitUntilDone:NO];
	*/
	/*
	//OSCValue *value = [m value];
	NSString *format = [[[NSString alloc] initWithFormat:@"%@/%@", prefix, @"press"] autorelease];
	NSPredicate *pred = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", format];
	if([pred evaluateWithObject:address]) {
		NSLog(@"predicate matched '%@'", address);
	}
	/*
	NSString *led = [[[NSString alloc] initWithFormat:@"%@/%@", prefix, @"led"] autorelease];
	NSLog(@"format '%@'", led);
	NSPredicate *pred2 = [NSPredicate predicateWithFormat:@"SELF BEGINSWITH %@", led];
	if([pred2 evaluateWithObject:address]) {
		NSLog(@"predicate matched '%@'", address);
		[self performSelectorOnMainThread:@selector(setStateForButtonWithMessage:) withObject:m waitUntilDone:NO];
	}*/
	
	// led
	NSString *led = [[[NSString alloc] initWithFormat:@"%@/%@", prefix, @"led"] autorelease];
	if([[m address] isEqualToString:led]) {
		//NSLog(@"predicate matched '%@'", address);
		[self performSelectorOnMainThread:@selector(setStateForButtonWithMessage:) withObject:m waitUntilDone:NO];
	}
	//[led release];
	
	// led_row
	NSString *ledRow = [[[NSString alloc] initWithFormat:@"%@/%@", prefix, @"led_row"] autorelease];
	if([[m address] isEqualToString:ledRow]) {
		//NSLog(@"predicate matched '%@'", address);
		[self performSelectorOnMainThread:@selector(setStateForButtonsInRowWithMessage:) withObject:m waitUntilDone:NO];
	}
	//[ledRow release];
	
	// led_col
	NSString *ledCol = [[[NSString alloc] initWithFormat:@"%@/%@", prefix, @"led_col"] autorelease];
	if([[m address] isEqualToString:ledCol]) {
		//NSLog(@"predicate matched '%@'", address);
		[self performSelectorOnMainThread:@selector(setStateForButtonsInColumnWithMessage:) withObject:m waitUntilDone:NO];
	}
	//[ledCol release];
	
	// frame [A B C D E F G H]
	/*
	 /40h/led_col 0 A
	 /40h/led_col 1 B
	 /40h/led_col 2 C
	 /40h/led_col 3 D
	 /40h/led_col 4 E
	 /40h/led_col 5 F
	 /40h/led_col 6 G
	 /40h/led_col 7 H
	 /40h/frame [x y] [A B C D E F G H]
	 update a display, offset by x and y.
	 */
	NSString *frame = [[[NSString alloc] initWithFormat:@"%@/%@", prefix, @"frame"] autorelease];
	if([[m address] isEqualToString:frame]) {
		//NSLog(@"matched '%@'", address);
		[self performSelectorOnMainThread:@selector(setStateForButtonsInFrameWithMessage:) withObject:m waitUntilDone:NO];
	}
	//[frame release];
	
	// clear [state]
	NSString *state = [[[NSString alloc] initWithFormat:@"%@/%@", prefix, @"state"] autorelease];
	if([[m address] isEqualToString:state]) {
		//NSLog(@"matched '%@'", address);
		[self performSelectorOnMainThread:@selector(clearButtonsWithMessage:) withObject:m waitUntilDone:NO];
	}
	//[state release];
	
	// sys/prefix [string]
	if([[m address] isEqualToString:@"/sys/prefix"]) {
		//NSLog(@"matched '%@'", address);
		[self performSelectorOnMainThread:@selector(setPrefixWithMessage:) withObject:m waitUntilDone:NO];
	}
	
}

- (NSString *)getIPAddress {
	NSString *address = @"error";
	struct ifaddrs *interfaces = NULL;
	struct ifaddrs *temp_addr = NULL;
	int success = 0;
	
	// retrieve the current interfaces – returns 0 on success
	success = getifaddrs(&interfaces);
	if (success == 0) {
		// Loop through linked list of interfaces
		temp_addr = interfaces;
		while(temp_addr != NULL) {
			if(temp_addr->ifa_addr->sa_family == AF_INET) {
				// Check if interface is en0 which is the wifi connection on the iPhone
				if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"]) {
					// Get NSString from C String
					address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
				}
			}			
			temp_addr = temp_addr->ifa_next;
		}
	}	
	// Free memory
	freeifaddrs(interfaces);	
	return address;
}

- (void)dealloc {
    [super dealloc];
}

@end
