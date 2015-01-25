//
//  RequestIQ.h
//  vChess
//
//  Created by Sergey Seitov on 2/7/11.
//  Copyright 2011 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "XMPPFramework.h"

@class RequestIQ;

@interface RequestIQ : NSObject {

	NSXMLElement *iqElement;
	NSString *iqId;
}

@property (strong, readonly, nonatomic) NSXMLElement *iqElement;
@property (strong, readonly, nonatomic) NSString *iqId;

- (BOOL)parse:(XMPPIQ*)iq;

@end

@interface GameRequestIQ : RequestIQ {
	
	NSString *myColor;
}

- (id)initForUser:(id<XMPPUser>)user myColor:(NSString*)color;

@end

@interface GameRequestAnswerIQ : RequestIQ<UIAlertViewDelegate> {
	
}

- (id)initWithRequest:(NSXMLElement*)request from:(id<XMPPUser>)from responseId:(NSString*)responseId;

@end

@interface TurnRequestIQ : RequestIQ {
	
}

- (id)initFor:(id<XMPPUser>)opponent move:(NSString*)move gameId:(NSString*)gameId withDraw:(BOOL)draw;
- (id)initForResign:(id<XMPPUser>)opponent gameId:(NSString*)gameId;
- (id)initForAccept:(id<XMPPUser>)opponent gameId:(NSString*)gameId;

@end

@interface TurnRequestAnswerIQ : RequestIQ<UIAlertViewDelegate> {
	
}

- (id)initWithRequest:(NSXMLElement*)request from:(id<XMPPUser>)from responseId:(NSString*)responseId;

@end
