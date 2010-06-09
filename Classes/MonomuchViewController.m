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
	
	int topOffset = 1024-768;
		
	for (int y=0; y<self.gridHeight; y++) {
		for (int x=0; x<self.gridWidth; x++) {
			int buttonTag = TAG_BASE + ( (y*self.gridWidth)+(x) );
			
			//TODO: make the size adjust depending on the gridWidth and gridHeight
			
			UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect]; 
			[button setFrame:CGRectMake(20+(x*90.0f), 20+(y*90.0f)+topOffset, 80.0f, 80.0f)]; 
			[button setTag: buttonTag]; 
			 
			[button addTarget:self action:@selector(buttonPressDown:)forControlEvents:UIControlEventTouchDown]; 
			[button addTarget:self action:@selector(buttonPressUp:)forControlEvents:UIControlEventTouchUpInside]; 
			[self.view addSubview:button];
			NSLog(@"%d",buttonTag);
		}
	}
	
	NSLog(@"in port: %d", self.listenPortTextField.text.intValue);
	NSLog(@"out port: %d", self.hostPortTextField.text.intValue);
	
	[self connectOscPorts:nil];
	
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
	NSLog(@"button.tag: %d",tag);	
	int x = tag % 8;
	int y = (tag - x)/8;	
	NSLog( @"x: %d, y: %d, state: %d", x, y, state);
	logTextView.text = [NSString stringWithFormat: @"x: %d, y: %d, state: %d \n%@", x, y, state, logTextView.text];
	[self sendStateForButtonAtColumn: x andRow:y withState:state];
}

- (IBAction) buttonPressUp:(id)sender {
	NSLog(@"%s",__func__);	
	int tag = [(UIButton *)sender tag] - TAG_BASE;		
	int state = 0;	NSLog(@"button.tag: %d",tag);	
	int x = tag % 8;
	int y = (tag - x)/8;	
	NSLog( @"x: %d, y: %d, state: %d", x, y, state);
	logTextView.text = [NSString stringWithFormat: @"x: %d, y: %d, state: %d \n%@", x, y, state, logTextView.text];		
	[self sendStateForButtonAtColumn: x andRow:y withState:state];
}

- (void) sendStateForButtonAtColumn:(int)x andRow:(int)y withState:(int)state {	
	NSLog(@"%s",__func__);
	OSCMessage	*msg1 = nil;
	
	NSString *address = [[NSString alloc] initWithFormat: @"%@/press", prefixTextField.text];
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
			[button setHighlighted: YES];
		} else {
			[button setHighlighted: NO];
		}
			
	}
	
	
}

- (void) setStateForButtonWithMessage:(OSCMessage *)m {	
	NSLog(@"%s",__func__);
	[self setStateForButtonAtColumn:[[m valueAtIndex:0 ] intValue]
							 andRow:[[m valueAtIndex:1 ] intValue]
						  withState:[[m valueAtIndex:2 ] intValue]];
}

- (void) setStateForButtonsInColumnWithMessage:(OSCMessage *)m {
	int col = [[m valueAtIndex:0 ] intValue];
	int idx = 1;
	while ([m valueAtIndex: idx ] != nil) {
		NSLog(@"idx = %d", idx);
		for (int x=0; x<8; x++) {
			NSLog(@"x = %d", x);
			int state = [self getBitFromInt:[[m valueAtIndex:idx ] intValue] AtIndex: x];
			[self setStateForButtonAtColumn:col andRow:x withState:state];
		}
		idx++;
	}	
}

- (void) setStateForButtonsInRowWithMessage:(OSCMessage *)m {
	int row = [[m valueAtIndex:0 ] intValue];
	int idx = 1;
	while ([m valueAtIndex: idx ] != nil) {
		NSLog(@"idx = %d", idx);
		for (int x=0; x<8; x++) {
			NSLog(@"x = %d", x);
			int state = [self getBitFromInt:[[m valueAtIndex:idx ] intValue] AtIndex: x];
			[self setStateForButtonAtColumn:x andRow:row withState:state];
		}
		idx++;
	}	
}

// called by delegate on message

- (void) receivedOSCMessage:(OSCMessage *)m	{
	NSLog(@"%s",__func__);
	
	NSString *address = [m address];
	NSString *prefix = [[[NSString alloc] initWithString:prefixTextField.text] autorelease];
	
	NSLog(@"address: %@, value: %d %d %d", 
		  address, 
		  [[m valueAtIndex:0 ] intValue], 
		  [[m valueAtIndex:1 ] intValue], 
		  [[m valueAtIndex:2 ] intValue]);
	
	[logTextView performSelectorOnMainThread:@selector(setText:) 
								  withObject:[NSString stringWithFormat:@"received address: %@, value: %d %d %d ", address, [[m valueAtIndex:0 ] intValue], [[m valueAtIndex:1 ] intValue], [[m valueAtIndex:2 ] intValue]] 
							   waitUntilDone:NO];
	
	
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
	if([address isEqualToString:led]) {
		NSLog(@"predicate matched '%@'", address);
		[self performSelectorOnMainThread:@selector(setStateForButtonWithMessage:) withObject:m waitUntilDone:NO];
	}
	
	// led_row
	NSString *ledRow = [[[NSString alloc] initWithFormat:@"%@/%@", prefix, @"led_row"] autorelease];
	if([address isEqualToString:ledRow]) {
		NSLog(@"predicate matched '%@'", address);
		[self performSelectorOnMainThread:@selector(setStateForButtonsInRowWithMessage:) withObject:m waitUntilDone:NO];
	}
	
	// led_col
	NSString *ledCol = [[[NSString alloc] initWithFormat:@"%@/%@", prefix, @"led_col"] autorelease];
	if([address isEqualToString:ledCol]) {
		NSLog(@"predicate matched '%@'", address);
		[self performSelectorOnMainThread:@selector(setStateForButtonsInColumnWithMessage:) withObject:m waitUntilDone:NO];
	}
	
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
	if([address isEqualToString:ledCol]) {
		NSLog(@"predicate matched '%@'", address);
		
	}
	
	// clear [state]
	NSString *frame = [[[NSString alloc] initWithFormat:@"%@/%@", prefix, @"frame"] autorelease];
	if([address isEqualToString:ledCol]) {
		NSLog(@"predicate matched '%@'", address);
		
	}
	
	// sys/prefix [string]
	if([address isEqualToString:@"/sys/prefix"]) {
		NSLog(@"predicate matched '%@'", address);
		// we need to check if the first value of the message is a string or an int
	}
	
}


- (void)dealloc {
    [super dealloc];
}

@end
