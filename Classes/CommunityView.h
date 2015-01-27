//
//  CommunityView.h
//  vChess
//
//  Created by Sergey Seitov on 1/29/11.
//  Copyright 2011 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "XMPPFramework.h"

@class RequestIQ;

@protocol CommutityDelegate <NSObject>

- (void)messagePopover:(NSIndexPath*)index;

@end

@interface CommunityView : UITableView <UITableViewDataSource, UITableViewDelegate, 
	UIActionSheetDelegate, NSFetchedResultsControllerDelegate>
{	
	
	RequestIQ *answerRequest;
}

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (weak, nonatomic) id<CommutityDelegate> communityDelegate;

- (id<XMPPUser>)findUserByJID:(XMPPJID*)jid;
- (void)sendRequest:(RequestIQ*)request;
- (void)sendElement:(NSXMLElement*)element;

@end
