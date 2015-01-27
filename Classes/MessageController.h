//
//  MessageController.h
//  vChess
//
//  Created by Sergey Seitov on 2/8/11.
//  Copyright 2011 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MessageController : UIViewController {

}

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) NSString *address;

- (IBAction)cancel:(id)sender;
- (IBAction)send:(id)sender;

@end
