//
//  TurnView.mm
//  vChess
//
//  Created by Sergey Seitov on 12/11/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import "TurnView.h"
#import "TurnCell.h"
#import "Notifications.h"

@implementation TurnView

@synthesize Number;
@synthesize whiteButton;
@synthesize blackButton;

- (id)initWithFrame:(CGRect)frame number:(int)number {
    
    self = [super initWithFrame:frame];
    if (self) {
        Number = [[UILabel alloc] initWithFrame:CGRectMake(5, 10, 30, TURNVIEW_HEIGHT - 20)];
		Number.backgroundColor = [UIColor clearColor];
		Number.opaque = NO;
		Number.text = [[NSNumber numberWithInt:number] stringValue];
		[self addSubview:Number];
		whiteButton = nil;
		blackButton = nil;
    }
    return self;
}

- (void)addWhite:(NSString*)turn interactive:(BOOL)interactive {
	
	CGRect rect = CGRectMake(40, 5, (self.bounds.size.width - 70)/2, TURNVIEW_HEIGHT - 10);
	whiteButton = [[TurnCell alloc] initCell:turn withFrame:rect];
	if (interactive) {
		UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
		[whiteButton addGestureRecognizer:singleTap];
	}
	[self addSubview:whiteButton];
}

- (void)addBlack:(NSString*)turn interactive:(BOOL)interactive {
	
	CGRect rect = CGRectMake(40 + (self.bounds.size.width - 60)/2 + 5, 5, (self.bounds.size.width - 70)/2, TURNVIEW_HEIGHT - 10);
	blackButton = [[TurnCell alloc] initCell:turn withFrame:rect];
	if (interactive) {
		UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleSingleTap:)];
		[blackButton addGestureRecognizer:singleTap];
	}
	[self addSubview:blackButton];
}

- (void)handleSingleTap:(UIGestureRecognizer*)gesture {

	TurnCell *sender = (TurnCell*)gesture.view;
	[sender setSelected:YES];
	NSDictionary *info = [NSDictionary dictionaryWithObject:Number.text forKey:@"number"];
	[[NSNotificationCenter defaultCenter] postNotificationName:SelectTurnNotification object:sender userInfo:info];
}

@end
