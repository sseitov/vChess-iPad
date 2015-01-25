//
//  Notifications.m
//  vChess
//
//  Created by Sergey Seitov on 12.03.13.
//  Copyright (c) 2013 V-Channel. All rights reserved.
//

#import "Notifications.h"

// Desk
NSString* const PlayNextNotification = @"PlayNextNotification";
NSString* const PlayPreviuoseNotification = @"PlayPreviuoseNotification";
NSString* const TurnNotification = @"TurnNotification";

// MessageController
NSString* const SendMessageNotification = @"SendMessageNotification";

// LoginController
NSString* const LoginNotification = @"LoginNotification";
NSString* const SuccessLoginNotification = @"SuccessLoginNotification";
NSString* const ErrorLoginNotification = @"ErrorLoginNotification";

// RequestIQ
NSString* const GameOfferNotification = @"GameOfferNotification";
NSString* const GameOfferAnswerNotification = @"GameOfferAnswerNotification";
NSString* const OpponentTurnNotification = @"OpponentTurnNotification";
NSString* const OpponentResignNotification = @"OpponentResignNotification";
NSString* const OpponentDrawNotification = @"OpponentDrawNotification";
NSString* const OpponentDrawRejectNotification = @"OpponentDrawRejectNotification";

// TurnView
NSString* const SelectTurnNotification = @"SelectTurnNotification";

// vChessAppDelegate
NSString* const XMPPConnectNotification = @"XMPPConnectNotification";
NSString* const XMPPConnectErrorNotification = @"XMPPConnectErrorNotification";
NSString* const XMPPDisconnectNotification = @"XMPPDisconnectNotification";
NSString* const GameRequestAnswerNotification = @"GameRequestAnswerNotification";
NSString* const TurnRequestAnswerNotification = @"TurnRequestAnswerNotification";

// vChessViewController
NSString* const LoadGameNotification = @"LoadGameNotification";
