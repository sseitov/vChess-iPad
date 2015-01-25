//
//  LoginController.h
//  vChess
//
//  Created by Sergey Seitov on 1/29/11.
//  Copyright 2011 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface LoginController : UIViewController {

	IBOutlet UITextField *login;
	IBOutlet UITextField *password;
	IBOutlet UISwitch *saveLogin;
	IBOutlet UIActivityIndicatorView *progress;
	IBOutlet UISegmentedControl *protocol;
}

- (IBAction)inputPassword;
- (IBAction)doLogin;
- (IBAction)switchAction;
- (IBAction)switchProtocol;

@end
