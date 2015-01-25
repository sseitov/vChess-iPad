//
//  vChessViewController.m
//  vChess
//
//  Created by Sergey Seitov on 11/28/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import "vChessViewController.h"
#import "Notifications.h"
#import "Desk.h"
#import "PanelView.h"
#import "GameManager.h"
#import "MasterLoader.h"
#import "StorageManager.h"
#import "TurnView.h"
#import "LoginController.h"
#import "CommunityView.h"
#import "TurnCell.h"
#import "ChessGame.h"

@interface vChessViewController (hidden)

- (bool)nextTurn;
- (bool)previouseTurn;
- (void)handlePlayNext:(NSNotification*)note;
- (void)handlePlayPreviouse:(NSNotification*)note;
- (NSString*)timeText;
- (void)finishGameWhite:(NSString*)white black:(NSString*)black;

@end

@implementation vChessViewController

@synthesize managerPopover;
@synthesize loginPopover;

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];	
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	panel.bInvert = YES;
	
	controlButtons.hidden = YES;
	gameFinishButtons.hidden = YES;
	
	whiteNameFont = whiteName.font;
	blackNameFont = blackName.font;
	whiteTime.text = @"";
	blackTime.text = @"";
	turnViews = [[NSMutableArray alloc] init];
	
	desk = [[Desk alloc] initWithFrame:CGRectMake(270, 170, 424, 500)];
	[self.view addSubview:desk];	

	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLoadGame:) 
												 name:LoadGameNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSuccessLogin:)
												 name:SuccessLoginNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleSelectTurn:)
												 name:SelectTurnNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayNext:) 
												 name:PlayNextNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handlePlayPreviouse:) 
												 name:PlayPreviuoseNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTurn:) 
												 name:TurnNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGameOffer:) 
												 name:GameOfferNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGameOfferAnswer:) 
												 name:GameOfferAnswerNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpponentTurn:) 
												 name:OpponentTurnNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpponentResign:) 
												 name:OpponentResignNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpponentDraw:) 
												 name:OpponentDrawNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOpponentDrawReject:)
												 name:OpponentDrawRejectNotification object:nil];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {

	if (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
		interfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		return YES;
	} else {
		return NO;
	}
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
	
	[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
	if (toInterfaceOrientation == UIInterfaceOrientationLandscapeLeft) {
		[desk rotate:YES];
	} else if (toInterfaceOrientation == UIInterfaceOrientationLandscapeRight) {
		[desk rotate:NO];
	}
}

#pragma mark - Game Manager

- (IBAction)navigate:(UISegmentedControl*)control {
	
	int index = control.selectedSegmentIndex;
	switch (index) {
		case PLAY_START:
			desk.playMode = PLAY_BACKWARD;
			[self handlePlayPreviouse:NULL];
			break;
		case PLAY_PREV:
			desk.playMode = NOPLAY;
			[self previouseTurn];
			break;
		case PLAY_STOP:
			desk.playMode = NOPLAY;
			break;
		case PLAY_NEXT:
			desk.playMode = NOPLAY;
			[self nextTurn];
			break;
		case PLAY_FINISH:
			desk.playMode = PLAY_FORWARD;
			[self handlePlayNext:NULL];
			break;
		default:
			break;
	}
}

- (IBAction)controlGame:(UISegmentedControl*)control {
	
	if (control.selectedSegmentIndex == 1) {
		TurnRequestIQ *turn = [[TurnRequestIQ alloc] initForResign:opponent gameId:onlineGameId];
		[community sendRequest:turn];
		if (opColor == vchess::CWHITE) {
			[self finishGameWhite:@"1" black:@"0"];
		} else {
			[self finishGameWhite:@"0" black:@"1"];
		}
	} else {
		TurnRequestIQ *request = [[TurnRequestIQ alloc] initFor:opponent move:@"" gameId:onlineGameId withDraw:YES];
		[community sendRequest:request];
	}
}

- (BOOL)popoverControllerShouldDismissPopover:(UIPopoverController *)popoverController {
	
	[popoverController dismissPopoverAnimated:YES];
	if (popoverController == managerPopover) {
		managerPopover = nil;
	} else {
		loginPopover = nil;
	}
	return YES;
}

- (IBAction)loadGame {
	
	if (managerPopover) {
		return;
	}
	UINavigationController *rootNav = [[UINavigationController alloc] initWithRootViewController:[[GameManager alloc] init] ];
	managerPopover = [[UIPopoverController alloc] initWithContentViewController:rootNav];
	managerPopover.delegate = self;
	[managerPopover presentPopoverFromBarButtonItem:loadButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)handleLoadGame:(NSNotification*)note {
	
	ChessGame *chessGame = (ChessGame*)note.object;

	try {
		TurnsArray turns;
		if ([StorageManager parseTurns:chessGame.turns into:&turns]) {
			vchess::Game* game = new vchess::Game(turns,
												  [chessGame.white UTF8String],
												  [chessGame.black UTF8String]);
			printf("SUCCESS\n");
			[managerPopover dismissPopoverAnimated:YES];
			managerPopover = nil;
			[self startShowGame:game];
		} else {
			UIAlertView *alert = [[UIAlertView alloc]
								  initWithTitle:@"Error"
								  message:@"Error load game"
								  delegate:nil
								  cancelButtonTitle:@"Ok"
								  otherButtonTitles:nil];
			[alert show];
		}
	} catch (std::exception& e) {
		UIAlertView *alert = [[UIAlertView alloc]
							  initWithTitle:@"Error"
							  message:[NSString stringWithFormat:@"%s", e.what()]
							  delegate:nil
							  cancelButtonTitle:@"Ok"
							  otherButtonTitles:nil];
		[alert show];
	}
}

- (NSString*)timeText {

	return [NSString stringWithFormat:@"%d:%.2d:%.2d", turnTime.hour, turnTime.min, turnTime.sec];	
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if (buttonIndex == 1) {		
		controlButtons.hidden = YES;
		gameFinishButtons.hidden = YES;
		for (int i=0; i<[turnViews count]; i++) {
			TurnView *turn = [turnViews objectAtIndex:i];
			[turn removeFromSuperview];
		}
		[turnViews removeAllObjects];
		onlineGameId = nil;
		gameTable.contentSize = CGSizeMake(gameTable.bounds.size.width, 0);
		gameTable.contentOffset = CGPointMake(0, 0);
		cellIndex = -1;
		currentCell = nil;
		desk.userInteractionEnabled = YES;
		[desk setGame:(new vchess::Game())];
		turnTime.hour = 0;
		turnTime.min = 0;
		turnTime.sec = 0;
		whiteName.text = @"WHITE";
		blackName.text = @"BLACK";
		whiteName.font = whiteNameFont;
		blackName.font = blackNameFont;
		whiteTime.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
		blackTime.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
		whiteTime.text = [self timeText];
		blackTime.text = [self timeText];
		timeLabel = whiteTime;
		turnTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
	}
}

- (void)timerFireMethod:(NSTimer*)theTimer {

	turnTime.sec++;
	if (turnTime.sec >= 60) {
		turnTime.sec = 0;
		turnTime.min++;
	}
	if (turnTime.min >= 60) {
		turnTime.min = 0;
		turnTime.hour++;
	}
	timeLabel.text = [self timeText];
}

- (IBAction)playOffline {
	
	if (managerPopover != nil) {
		[managerPopover dismissPopoverAnimated:YES];
		managerPopover = nil;
	} 
	
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Play Offline"
													message:@"Start New Game?"
												   delegate:self 
										  cancelButtonTitle:@"No" 
										  otherButtonTitles:@"Yes", nil];
	[alert show];
}

- (void)startShowGame:(vchess::Game*)game {
	
	NSLog(@"startGame");
	[desk setGame:game];
	[turnTimer invalidate];
	onlineGameId = nil;
	whiteName.text = @"WHITE";
	blackName.text = @"BLACK";
	whiteName.font = whiteNameFont;
	blackName.font = blackNameFont;
	whiteTime.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
	blackTime.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
	whiteTime.text = [NSString stringWithUTF8String:game->white().data()];
	blackTime.text = [NSString stringWithUTF8String:game->black().data()];
	std::vector<vchess::Turn> turns = game->turns();
	std::vector<vchess::Turn>::iterator it = turns.begin();
	gameTable.contentSize = CGSizeMake(gameTable.bounds.size.width, 0);
	gameTable.contentOffset = CGPointMake(0, 0);
	TurnView *turnView;
	while ((turnView = [turnViews lastObject])) {
		[turnView removeFromSuperview];
		[turnViews removeLastObject];
	}
	int num = 1;
	for (int i=0; i<[turnViews count]; i++) {
		TurnView *turn = [turnViews objectAtIndex:i];
		[turn removeFromSuperview];
	}
	while (it != turns.end()) {
		turnView = [[TurnView alloc] initWithFrame:CGRectMake(0, gameTable.contentSize.height, gameTable.bounds.size.width, TURNVIEW_HEIGHT) number:num/2+1];
		gameTable.contentSize = CGSizeMake(gameTable.bounds.size.width, gameTable.contentSize.height+TURNVIEW_HEIGHT+2);
		[gameTable addSubview:turnView];
		[turnViews addObject:turnView];
		[turnView addWhite:[NSString stringWithUTF8String:(*it).turnText.data()] interactive:YES];
		it++;
		num++;
		if (it == turns.end()) {
			break;
		}
		[turnView addBlack:[NSString stringWithUTF8String:(*it).turnText.data()] interactive:YES];
		it++;
		num++;
	}
	currentCell = nil;
	cellIndex = -1;
	controlButtons.hidden = NO;
	gameFinishButtons.hidden = YES;
	desk.userInteractionEnabled = NO;
}

#pragma mark - Turns control

- (void)handleTurn:(NSNotification*)note {
	
	TurnView *turnView;
	int num = [turnViews count] + 1;
	if (timeLabel == whiteTime) {
		turnView = [[TurnView alloc] initWithFrame:CGRectMake(0, gameTable.contentSize.height, gameTable.bounds.size.width, TURNVIEW_HEIGHT) number:num];
		gameTable.contentSize = CGSizeMake(gameTable.bounds.size.width, gameTable.contentSize.height+TURNVIEW_HEIGHT+2);
		[gameTable addSubview:turnView];
		[turnViews addObject:turnView];
		[turnView addWhite:note.object interactive:NO];
	} else {
		turnView = [turnViews lastObject];
		[turnView addBlack:note.object interactive:NO];
	}
	
	NSDictionary *pos = note.userInfo;
	NSString *moveText = @"";
	
	if (onlineGameId) {
		unsigned char x,y;
		int from = [[pos objectForKey:@"from"] intValue];
		vchess::POS_FROM_NUM(from, x, y);
		moveText = [moveText stringByAppendingFormat:@"%d,", x];
		moveText = [moveText stringByAppendingFormat:@"%d;", y];
		int to = [[pos objectForKey:@"to"] intValue];
		vchess::POS_FROM_NUM(to, x, y);
		moveText = [moveText stringByAppendingFormat:@"%d,", x];
		moveText = [moveText stringByAppendingFormat:@"%d", y];
	}
	
	if (timeLabel == whiteTime) {
		if (onlineGameId) {
			if (opColor == vchess::CBLACK) {
				TurnRequestIQ *request = [[TurnRequestIQ alloc] initFor:opponent move:moveText gameId:onlineGameId withDraw:(gameFinishButtons.selectedSegmentIndex == 0)];
				[community sendRequest:request];
				desk.userInteractionEnabled = NO;
				gameFinishButtons.userInteractionEnabled = NO;
			} else {
				desk.userInteractionEnabled = YES;
				gameFinishButtons.userInteractionEnabled = YES;
			}
		}
		timeLabel = blackTime;
	} else {
		if (onlineGameId) {
			if (opColor == vchess::CBLACK) {
				desk.userInteractionEnabled = YES;
				gameFinishButtons.userInteractionEnabled = YES;
			} else {
				TurnRequestIQ *request = [[TurnRequestIQ alloc] initFor:opponent move:moveText gameId:onlineGameId withDraw:(gameFinishButtons.selectedSegmentIndex == 0)];
				[community sendRequest:request];
				desk.userInteractionEnabled = NO;
				gameFinishButtons.userInteractionEnabled = NO;
			}
		}
		timeLabel = whiteTime;
	}
	timeLabel.text = [self timeText];
}

- (void)changeCellIndex:(int)index {
	
	TurnView *turn = [turnViews objectAtIndex:index/2];
	[currentCell setSelected:NO];
	if (index % 2) {
		currentCell = turn.blackButton;
	} else {
		currentCell = turn.whiteButton;
	}
	[currentCell setSelected:YES];
	cellIndex = index;
}

- (void)handlePlayNext:(NSNotification*)note {
	
	if ([self nextTurn] == NO) {
		controlButtons.selectedSegmentIndex = PLAY_STOP;
	}
}

- (void)handlePlayPreviouse:(NSNotification*)note {
	
	if ([self previouseTurn] == NO) {
		controlButtons.selectedSegmentIndex = PLAY_STOP;
	}
}

- (bool)nextTurn {
	
	int index = (cellIndex + 1);
	if (index/2 < [turnViews count]) {
		[self changeCellIndex:index];
	}
	return [desk turnForwardAnimated:YES];
}

- (bool)previouseTurn {
	
	if (cellIndex > 0) {
		[self changeCellIndex:(cellIndex-1)];
	} else {
		[currentCell setSelected:NO];
		cellIndex = -1;
	}
	return [desk turnBackAnimated:YES];
}

- (void)handleSelectTurn:(NSNotification*)note {
	
	[currentCell setSelected:NO];
	currentCell = note.object;
	int num = [[note.userInfo valueForKey:@"number"] intValue] - 1;
	TurnView *turn = [turnViews objectAtIndex:num];
	int index = num*2;
	if (currentCell == turn.blackButton) {
		index++;
	}
	int count = abs(index - cellIndex);
	for (int i=0; i<count; i++) {
		if (index > cellIndex) {
			[desk turnForwardAnimated:NO];
		} else {
			[desk turnBackAnimated:NO];
		}
	}
	cellIndex = index;
}

#pragma mark - Community

- (IBAction)enterCommunity {
	
	if (loginPopover) {
		return;
	}
	UINavigationController *rootNav = [[UINavigationController alloc] initWithRootViewController:[[LoginController alloc] initWithNibName:@"LoginController" bundle:nil] ];
	loginPopover = [[UIPopoverController alloc] initWithContentViewController:rootNav];
	loginPopover.delegate = self;
	loginPopover.popoverContentSize = CGSizeMake(260, 240);
	[loginPopover presentPopoverFromBarButtonItem:loginButton permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
}

- (void)handleSuccessLogin:(NSNotification*)note {
	
	if (loginPopover) {
		[loginPopover dismissPopoverAnimated:YES];
	}
	loginPopover = nil;
}

- (IBAction)quitCommunity {
	
	if (loginPopover) {
		[loginPopover dismissPopoverAnimated:YES];
	}
	loginPopover = nil;
	[[NSNotificationCenter defaultCenter] postNotificationName:XMPPDisconnectNotification object:self];
}

- (void)startOnlineGame {
	
	std::string white;
	std::string black;
	if (opColor == vchess::CWHITE) {
		white = [[opponent nickname] UTF8String];
		black = "mySelf";
	} else {
		white = "mySelf";
		black = [[opponent nickname] UTF8String];
	}

	vchess::Game *game = new vchess::Game(white, black);
	[desk setGame:game];
	
	controlButtons.hidden = YES;
	gameFinishButtons.hidden = NO;
	gameFinishButtons.selectedSegmentIndex = -1;
	
	for (int i=0; i<[turnViews count]; i++) {
		TurnView *turn = [turnViews objectAtIndex:i];
		[turn removeFromSuperview];
	}
	[turnViews removeAllObjects];
	gameTable.contentSize = CGSizeMake(gameTable.bounds.size.width, 0);
	gameTable.contentOffset = CGPointMake(0, 0);
	cellIndex = -1;
	currentCell = nil;
	
	whiteName.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
	blackName.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
	whiteName.text = [NSString stringWithUTF8String:game->white().data()];
	blackName.text = [NSString stringWithUTF8String:game->black().data()];
	
	turnTime.hour = 0;
	turnTime.min = 0;
	turnTime.sec = 0;
	
	whiteTime.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
	blackTime.font = [UIFont fontWithName:@"Helvetica-Bold" size:24];
	whiteTime.text = [self timeText];
	blackTime.text = [self timeText];
	timeLabel = whiteTime;
	turnTimer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(timerFireMethod:) userInfo:nil repeats:YES];
	if (opColor == vchess::CBLACK) {
		desk.userInteractionEnabled = YES;
	}
	gameFinishButtons.userInteractionEnabled = NO;
}

- (void)handleGameOffer:(NSNotification*)note {
	
	XMPPIQ *offer = (XMPPIQ*)note.object;
	opponent = [community findUserByJID: [XMPPJID jidWithString:[offer attributeStringValueForName:@"from"]] ];
	if ([offer isErrorIQ]) {
		UIAlertView *alert = [[UIAlertView alloc] 
							  initWithTitle:@"Chess game invitation error."
							  message:[NSString stringWithFormat:@"%@ refused your invitation!", [opponent nickname]]
							  delegate:nil
							  cancelButtonTitle:@"Ok"  
							  otherButtonTitles:nil];
		[alert show];
		opponent = nil;
		onlineGameId = nil;
	} else {
		NSXMLElement *what = [offer childElement];
		NSString *myColor = [what attributeStringValueForName:@"myColor"];
		if ([myColor isEqual:@"white"]) {
			opColor = vchess::CBLACK;
		} else {
			opColor = vchess::CWHITE;
		}
		onlineGameId = [[NSString alloc] initWithString:[what attributeStringValueForName:@"id"]];
		[self startOnlineGame];
	}
}

- (void)handleGameOfferAnswer:(NSNotification*)note {
	
	XMPPIQ *offer = (XMPPIQ*)note.object;
	[community sendElement:offer];
	if ([offer isResultIQ]) {
		NSXMLElement *what = [offer childElement];
		opponent = [community findUserByJID: [XMPPJID jidWithString:[offer attributeStringValueForName:@"to"]] ];
		NSString *color = [what attributeStringValueForName:@"color"];
		if ([color isEqual:@"white"]) {
			opColor = vchess::CWHITE;
		} else {
			opColor = vchess::CBLACK;
		}
		onlineGameId = [[NSString alloc] initWithString:[what attributeStringValueForName:@"id"]];
		[self startOnlineGame];
	}	
}

- (void)handleOpponentTurn:(NSNotification*)note {

	NSString *gameId = [note.userInfo objectForKey:@"gameId"];
	NSString *reponseId = [note.userInfo valueForKey:@"responseId"];
	TurnRequestIQ *draw = [note.userInfo objectForKey:@"draw"];
	if ([gameId isEqualToString:onlineGameId]) {		
		if (draw) {
			if ([[note.userInfo objectForKey:@"accept"] boolValue]) {
				[self finishGameWhite:@"1/2" black:@"1/2"];
			}
			[community sendRequest:draw];
		} else {
			int from = [[note.userInfo objectForKey:@"from"] intValue];
			int to = [[note.userInfo objectForKey:@"to"] intValue];
			[desk makeTurn:[desk figureAt:[NSNumber numberWithInt:from]] from:from to:to animated:YES];
			XMPPIQ *answer = [XMPPIQ iqWithType:@"result" to:[[opponent primaryResource] jid] elementID:reponseId];
			NSXMLElement *queryElement = [NSXMLElement elementWithName:@"create" xmlns:@"games:board"];
			[queryElement addAttributeWithName:@"type" stringValue:@"chess"];
			[queryElement addAttributeWithName:@"id" stringValue:gameId];
			[answer addChild:queryElement];
			[community sendElement:answer];
		}
	}
}

- (void)handleOpponentDraw:(NSNotification*)note {
	
	TurnRequestAnswerIQ *request = (TurnRequestAnswerIQ*)note.object;
	NSString *gameId = [request.iqElement attributeStringValueForName:@"id"];
	if ([gameId isEqualToString:onlineGameId]) {
		[self finishGameWhite:@"1/2" black:@"1/2"];
	}
}

- (void)handleOpponentDrawReject:(NSNotification*)note {
	
	TurnRequestAnswerIQ *request = (TurnRequestAnswerIQ*)note.object;
	NSString *gameId = [request.iqElement attributeStringValueForName:@"id"];
	if ([gameId isEqualToString:onlineGameId]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Response"
														message:@"Opponent reject offerdraw!"
													   delegate:nil
											  cancelButtonTitle:@"Ok"
											  otherButtonTitles:nil];
		[alert show];
		gameFinishButtons.selectedSegmentIndex = -1;
	}
}

- (void)handleOpponentResign:(NSNotification*)note {
	
	TurnRequestAnswerIQ *request = (TurnRequestAnswerIQ*)note.object;
	NSString *gameId = [request.iqElement attributeStringValueForName:@"id"];
	if ([gameId isEqualToString:onlineGameId]) {
		if (opColor == vchess::CWHITE) {
			[self finishGameWhite:@"0" black:@"1"];
		} else {
			[self finishGameWhite:@"1" black:@"0"];
		}
	}
}

- (void)finishGameWhite:(NSString*)white black:(NSString*)black {
	
	[turnTimer invalidate];
	turnTimer = nil;
	onlineGameId = nil;
	whiteTime.text = white;
	blackTime.text = black;
	desk.userInteractionEnabled = NO;
	gameFinishButtons.hidden = YES;
}

@end
