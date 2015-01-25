//
//  RequestIQ.mm
//  vChess
//
//  Created by Sergey Seitov on 2/7/11.
//  Copyright 2011 V-Channel. All rights reserved.
//

#import "RequestIQ.h"
#import "Notifications.h"
#include "turn.h"

@interface AlertDataView : UIAlertView {
	
	id data;
}

@property (strong, nonatomic) id data;

@end

@implementation AlertDataView

@synthesize data;

@end

@implementation RequestIQ

@synthesize iqElement;
@synthesize iqId;

-(BOOL)parse:(XMPPIQ*)iq {

	NSLog(@"NO PARSE");
	return YES;
}

@end

@implementation GameRequestIQ

- (id)initForUser:(id<XMPPUser>)user myColor:(NSString*)color {
	
	if (self = [super init]) {
		iqId = [NSString stringWithFormat:@"CreateChess%d", arc4random()];
		myColor = [NSString stringWithString:color];
		iqElement = [XMPPIQ iqWithType:@"set" to:[[user primaryResource] jid] elementID:iqId];
		NSXMLElement *queryElement = [NSXMLElement elementWithName:@"create" xmlns:@"games:board"];
		[queryElement addAttributeWithName:@"type" stringValue:@"chess"];
		[queryElement addAttributeWithName:@"id" stringValue:[NSString stringWithFormat:@"ChessGame%d", arc4random()]];
		[queryElement addAttributeWithName:@"color" stringValue:color];
		[iqElement addChild:queryElement];
	}
	return self;
}

-(BOOL)parse:(XMPPIQ*)iq {
	
	[[iq childElement] addAttributeWithName:@"myColor" stringValue:myColor];
	[[NSNotificationCenter defaultCenter] postNotificationName:GameOfferNotification object:iq];
	return YES;
}

@end

@implementation GameRequestAnswerIQ

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	AlertDataView *alert = (AlertDataView*)alertView;
	XMPPIQ *answer;
	if (buttonIndex == 1) {
		answer = [XMPPIQ iqWithType:@"result" to:[alert.data valueForKey:@"opponent"] elementID:[alert.data valueForKey:@"responseId"]];
		NSXMLElement *queryElement = [NSXMLElement elementWithName:@"create" xmlns:@"games:board"];
		[queryElement addAttributeWithName:@"type" stringValue:@"chess"];
		[queryElement addAttributeWithName:@"id" stringValue:[alert.data valueForKey:@"gameId"]];
		[queryElement addAttributeWithName:@"color" stringValue:[alert.data valueForKey:@"color"]];
		[answer addChild:queryElement];
	} else {
		answer = [XMPPIQ iqWithType:@"error" to:[alert.data valueForKey:@"opponent"] elementID:[alert.data valueForKey:@"responseId"]];
	}
	[[NSNotificationCenter defaultCenter] postNotificationName:GameOfferAnswerNotification object:answer];
}

- (id)initWithRequest:(NSXMLElement*)request from:(id<XMPPUser>)from responseId:(NSString*)responseId {
	
	if (self = [super init]) {
		NSString *color = [NSString stringWithString:[request attributeStringValueForName:@"color"]];
		AlertDataView *alert = [[AlertDataView alloc] 
							  initWithTitle:[NSString stringWithFormat:@"Chess game invitation from %@", [from nickname]]
								message:[NSString stringWithFormat:@"Want you play %@?", [color isEqualToString:@"white"] ? @"BLACK" : @"WHITE"]
							  delegate:self
							  cancelButtonTitle:@"No" 
							  otherButtonTitles:@"Yes", nil];
		
		alert.data = [[NSMutableDictionary alloc] init];
		[alert.data setObject:responseId forKey:@"responseId"];
		[alert.data setObject:color forKey:@"color"];
		[alert.data setObject:[request attributeStringValueForName:@"id"] forKey:@"gameId"];
		[alert.data setObject:[[from primaryResource] jid] forKey:@"opponent"];
		
		[alert show];
	}
	return self;
}

@end

@implementation TurnRequestIQ

- (id)initFor:(id<XMPPUser>)opponent move:(NSString*)move gameId:(NSString*)gameId withDraw:(BOOL)draw {
	
	if (self = [super init]) {
		iqId = [NSString stringWithFormat:@"TurnChess%d", arc4random()];
		iqElement = [XMPPIQ iqWithType:@"set" to:[[opponent primaryResource] jid] elementID:iqId];
		NSXMLElement *moveElement = [NSXMLElement elementWithName:@"turn" xmlns:@"games:board"];
		[moveElement addAttributeWithName:@"type" stringValue:@"chess"];
		[moveElement addAttributeWithName:@"id" stringValue:gameId];
		NSXMLElement *posElement = [NSXMLElement elementWithName:@"move"];
		[posElement addAttributeWithName:@"pos" stringValue:move];
		if (draw) {
			[moveElement addChild:[NSXMLNode elementWithName:@"draw"]];
		}
		[moveElement addChild:posElement];
		[iqElement addChild:moveElement];
	}
	return self;
}

- (id)initForResign:(id<XMPPUser>)opponent gameId:(NSString*)gameId {
	
	if (self = [super init]) {
		iqId = [NSString stringWithFormat:@"TurnChess%d", arc4random()];
		iqElement = [XMPPIQ iqWithType:@"set" to:[[opponent primaryResource] jid] elementID:iqId];
		NSXMLElement *moveElement = [NSXMLElement elementWithName:@"turn" xmlns:@"games:board"];
		[moveElement addAttributeWithName:@"type" stringValue:@"chess"];
		[moveElement addAttributeWithName:@"id" stringValue:gameId];
		[moveElement addChild:[NSXMLNode elementWithName:@"resign"]];
		[iqElement addChild:moveElement];
	}
	return self;
}

- (id)initForAccept:(id<XMPPUser>)opponent gameId:(NSString*)gameId {
	
	if (self = [super init]) {
		iqId = [NSString stringWithFormat:@"TurnChess%d", arc4random()];
		iqElement = [XMPPIQ iqWithType:@"set" to:[[opponent primaryResource] jid] elementID:iqId];
		NSXMLElement *moveElement = [NSXMLElement elementWithName:@"turn" xmlns:@"games:board"];
		[moveElement addAttributeWithName:@"type" stringValue:@"chess"];
		[moveElement addAttributeWithName:@"id" stringValue:gameId];
		[moveElement addChild:[NSXMLNode elementWithName:@"accept"]];
		[iqElement addChild:moveElement];
	}
	return self;
}

- (id)initForReject:(id<XMPPUser>)opponent gameId:(NSString*)gameId {
	
	if (self = [super init]) {
		iqId = [NSString stringWithFormat:@"TurnChess%d", arc4random()];
		iqElement = [XMPPIQ iqWithType:@"set" to:[[opponent primaryResource] jid] elementID:iqId];
		NSXMLElement *moveElement = [NSXMLElement elementWithName:@"turn" xmlns:@"games:board"];
		[moveElement addAttributeWithName:@"type" stringValue:@"chess"];
		[moveElement addAttributeWithName:@"id" stringValue:gameId];
		[moveElement addChild:[NSXMLNode elementWithName:@"reject"]];
		[iqElement addChild:moveElement];
	}
	return self;
}

- (BOOL)parse:(XMPPIQ *)iq {
	return YES;
}

@end

@implementation TurnRequestAnswerIQ

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	AlertDataView *alert = (AlertDataView*)alertView;

	TurnRequestIQ *draw = nil;
	if (buttonIndex == 1) {
		draw  = [[TurnRequestIQ alloc] initForAccept:[alert.data objectForKey:@"opponent"] gameId:[alert.data objectForKey:@"gameId"]];
		[alert.data setObject:[NSNumber numberWithBool:YES] forKey:@"accept"];
	} else {
		draw  = [[TurnRequestIQ alloc] initForReject:[alert.data objectForKey:@"opponent"] gameId:[alert.data objectForKey:@"gameId"]];
	}
	[alert.data setObject:draw forKey:@"draw"];
	[[NSNotificationCenter defaultCenter] postNotificationName:OpponentTurnNotification object:nil userInfo:[[NSDictionary alloc] initWithDictionary:alert.data]];
}

- (id)initWithRequest:(NSXMLElement*)request from:(id<XMPPUser>)from responseId:(NSString*)responseId {
	
	if (self = [super init]) {
		iqElement = request;
		NSArray *resign = [request elementsForName:@"resign"];
		NSArray *accept = [request elementsForName:@"accept"];
		NSArray *reject = [request elementsForName:@"reject"];
		if (resign && [resign count] > 0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:OpponentResignNotification object:self];
		} else if (accept && [accept count] > 0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:OpponentDrawNotification object:self];
		} else if (reject && [reject count] > 0) {
			[[NSNotificationCenter defaultCenter] postNotificationName:OpponentDrawRejectNotification object:self];
		} else {
			NSArray *moves = [request elementsForName:@"move"];
			if (moves && [moves count] > 0) {
				NSMutableDictionary *info = [[NSMutableDictionary alloc] init];
				[info setObject:[request attributeStringValueForName:@"id"] forKey:@"gameId"];
				[info setObject:responseId forKey:@"responseId"];
				[info setObject:from forKey:@"opponent"];
				
				NSXMLElement *move = [moves objectAtIndex:0];
				NSCharacterSet *separator = [NSCharacterSet characterSetWithCharactersInString:@",;"];
				NSArray *posArray = [[move attributeStringValueForName:@"pos"] componentsSeparatedByCharactersInSet:separator];
				if ([posArray count] == 4) {
					int from = vchess::NUM_FROM_POS([[posArray objectAtIndex:0] intValue], [[posArray objectAtIndex:1] intValue]);
					[info setObject:[NSNumber numberWithInt:from] forKey:@"from"];
					int to = vchess::NUM_FROM_POS([[posArray objectAtIndex:2] intValue], [[posArray objectAtIndex:3] intValue]);
					[info setObject:[NSNumber numberWithInt:to] forKey:@"to"];
				}
				NSArray *draw = [request elementsForName:@"draw"];
				if (draw && [draw count] > 0) {
					AlertDataView *alert = [[AlertDataView alloc] 
											initWithTitle:@"Offerdraw"
											message:[NSString stringWithFormat:@"%@ proposes a draw. Accept the draw proposal?", [from nickname]]
											delegate:self
											cancelButtonTitle:@"No" 
											otherButtonTitles:@"Yes", nil];
					
					alert.data = info;
					[alert show];
				} else {
					[[NSNotificationCenter defaultCenter] postNotificationName:OpponentTurnNotification object:self userInfo:info];
				}
			}
		}
	}
	return self;
}

@end
