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

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		UIBarButtonItem *leftButton = [[UIBarButtonItem alloc]
									   initWithTitle:@"Cancel" 
									   style:UIBarButtonItemStyleBordered 
									   target:self
									   action:@selector(cancel)];
		self.navigationItem.leftBarButtonItem = leftButton;
		UIBarButtonItem *rightButton = [[UIBarButtonItem alloc]
										initWithTitle:@"Send" 
										style:UIBarButtonItemStyleBordered 
										target:self
										action:@selector(send)];
		self.navigationItem.rightBarButtonItem = rightButton;
		
        self.title = @"Message";
    }
    return self;
}

- (void)cancel {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:SendMessageNotification object:self userInfo:nil];
}

- (void)send {
	
	NSDictionary *info = [NSDictionary dictionaryWithObjectsAndKeys:address, @"address", ((UITextView*)self.view).text, @"text", nil];
	[[NSNotificationCenter defaultCenter] postNotificationName:SendMessageNotification object:self userInfo:info];
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	((UITextView*)self.view).text = @"";
}

@end
