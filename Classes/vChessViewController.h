//
//  vChessViewController.h
//  vChess
//
//  Created by Sergey Seitov on 11/28/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPUser.h"
#import "RequestIQ.h"

@class Desk;
@class PanelView;
@class TurnCell;
@class CommunityView;

enum CONTROL_BUTTON {
	PLAY_START,
	PLAY_PREV,
	PLAY_STOP,
	PLAY_NEXT,
	PLAY_FINISH
};

struct TURN_TIME {
	int hour;
	int min;
	int sec;
};

@interface vChessViewController : UIViewController <UIPopoverControllerDelegate, UIAlertViewDelegate> {

	Desk	*desk;
	IBOutlet UISegmentedControl *controlButtons;
	IBOutlet UISegmentedControl *gameFinishButtons;
	IBOutlet UILabel	*whiteName;
	IBOutlet UILabel	*blackName;
	IBOutlet UILabel	*whiteTime;
	IBOutlet UILabel	*blackTime;
	IBOutlet UIScrollView *gameTable;
	IBOutlet CommunityView *community;
	IBOutlet PanelView *panel;
	IBOutlet UIBarButtonItem *loginButton;
	IBOutlet UIBarButtonItem *loadButton;
	IBOutlet UIBarButtonItem *playButton;
	
	NSMutableArray *turnViews;
	TurnCell *currentCell;
	int cellIndex;
		
	NSTimer *turnTimer;
	TURN_TIME turnTime;
	UILabel *timeLabel;
	UIFont *whiteNameFont;
	UIFont *blackNameFont;
	
	id<XMPPUser> opponent;
	unsigned char opColor;
	NSString *onlineGameId;
}

@property (nonatomic, strong, readonly) UIPopoverController *managerPopover;
@property (nonatomic, strong, readonly) UIPopoverController *loginPopover;

- (IBAction)navigate:(UISegmentedControl*)control;
- (IBAction)controlGame:(UISegmentedControl*)control;
- (IBAction)loadGame;
- (IBAction)playOffline;
- (IBAction)enterCommunity;
- (IBAction)quitCommunity;

@end

