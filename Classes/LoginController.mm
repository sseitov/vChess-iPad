    //
//  LoginController.mm
//  vChess
//
//  Created by Sergey Seitov on 1/29/11.
//  Copyright 2011 V-Channel. All rights reserved.
//

#import "LoginController.h"
#import "Notifications.h"

enum  PROTOCOL {
	GTALK = 0,
	JABBER
};

@implementation LoginController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
		self.title = @"Community";
		[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleErrorLogin:)
													 name:ErrorLoginNotification object:nil];
   }
    return self;
}

- (void)viewDidLoad {
	
    [super viewDidLoad];
	
	saveLogin.on = [[NSUserDefaults standardUserDefaults] boolForKey:@"SavedLogin"];
	if (saveLogin.on) {
		login.text = [[NSUserDefaults standardUserDefaults] stringForKey:@"UserName"];
		protocol.selectedSegmentIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"Protocol"];
	}
	if (!login.text || [login.text isEqual:@""]) {
		[login becomeFirstResponder];
	} else {
		[password becomeFirstResponder];
	}
}

- (void)login {
	
	if (!login.text || [login.text isEqual:@""]) {
		[login becomeFirstResponder];
		return;
	}
	if (!password.text || [password.text isEqual:@""]) {
		[password becomeFirstResponder];
		return;
	}
	if (saveLogin.on) {
		[[NSUserDefaults standardUserDefaults] setObject:login.text forKey:@"UserName"];
	} else {
		[[NSUserDefaults standardUserDefaults] setObject:@"" forKey:@"UserName"];
	}
	[[NSUserDefaults standardUserDefaults] synchronize];
	
	[progress startAnimating];
	
	NSString *host = nil;	
	if (protocol.selectedSegmentIndex == GTALK) {
		host = @"talk.google.com";
	} else {
		NSArray *pair = [login.text componentsSeparatedByString:@"@"];
		if ([pair count] < 2) {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error account"
															message:@"Jabber account must be in user@host form."
														   delegate:nil
												  cancelButtonTitle:@"Ok"
												  otherButtonTitles:nil];
			[alert show];
			return;
		}
		host = [pair objectAtIndex:1];
	}

	NSMutableDictionary *info = [NSMutableDictionary dictionaryWithObject:@"login" forKey:@"type"];
	[info setObject:login.text forKey:@"login"];
	[info setObject:password.text forKey:@"password"];
	[info setObject:host forKey:@"host"];
	[[NSNotificationCenter defaultCenter] postNotificationName:LoginNotification object:self userInfo:info];
}

- (void)handleErrorLogin:(NSNotification*)note {
	
	[progress stopAnimating];
}

- (IBAction)switchAction {
	
	[[NSUserDefaults standardUserDefaults] setBool:saveLogin.on forKey:@"SavedLogin"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)switchProtocol {
	
	[[NSUserDefaults standardUserDefaults] setInteger:protocol.selectedSegmentIndex forKey:@"Protocol"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

- (IBAction)inputPassword {
	
	if (login.text && ![login.text isEqual:@""]) {
		[password becomeFirstResponder];
	}
}

- (IBAction)doLogin {
	
	[password resignFirstResponder];
	[self login];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
		interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		return YES;
	} else {
		return NO;
	}
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}


@end
