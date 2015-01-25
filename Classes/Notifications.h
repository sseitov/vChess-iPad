//
//  Notifications.h
//  vChess
//
//  Created by Sergey Seitov on 12.03.13.
//  Copyright (c) 2013 V-Channel. All rights reserved.
//

#import <Foundation/Foundation.h>

// Desk
extern NSString* const PlayNextNotification;
extern NSString* const PlayPreviuoseNotification;
extern NSString* const TurnNotification;

// MessageController
extern NSString* const SendMessageNotification;

// LoginController
extern NSString* const LoginNotification;
extern NSString* const SuccessLoginNotification;
extern NSString* const ErrorLoginNotification;

// RequestIQ
extern NSString* const GameOfferNotification;
extern NSString* const GameOfferAnswerNotification;
extern NSString* const OpponentTurnNotification;
extern NSString* const OpponentResignNotification;
extern NSString* const OpponentDrawNotification;
extern NSString* const OpponentDrawRejectNotification;

// TurnView
extern NSString* const SelectTurnNotification;

// vChessAppDelegate
extern NSString* const XMPPConnectNotification;
extern NSString* const XMPPConnectErrorNotification;
extern NSString* const XMPPDisconnectNotification;
extern NSString* const GameRequestAnswerNotification;
extern NSString* const TurnRequestAnswerNotification;

// vChessViewController
extern NSString* const LoadGameNotification;
