//
//  MessageController.mm
//  vChess
//
//  Created by Sergey Seitov on 2/8/11.
//  Copyright 2011 V-Channel. All rights reserved.
//

#import "MessageController.h"
#import "Notifications.h"

@implementation MessageController

@synthesize address;

- (void)viewDidLoad
{	
    [super viewDidLoad];
	_textView.text = @"";
}

- (IBAction)cancel:(id)sender
{
	[[NSNotificationCenter defaultCenter] postNotificationName:SendMessageNotification object:self userInfo:nil];
}

- (IBAction)send:(id)sender
{
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:address, @"address", _textView.text, @"text", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:SendMessageNotification object:self userInfo:info];
}

@end
