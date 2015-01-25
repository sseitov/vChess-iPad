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

@interface CommunityView : UITableView <UITableViewDataSource, UITableViewDelegate, 
	UIActionSheetDelegate, UIPopoverControllerDelegate, NSFetchedResultsControllerDelegate>
{
	UIPopoverController *messagePopover;
	
	NSFetchedResultsController *fetchedResultsController;
	
	RequestIQ *answerRequest;
}

- (id<XMPPUser>)findUserByJID:(XMPPJID*)jid;
- (void)sendRequest:(RequestIQ*)request;
- (void)sendElement:(NSXMLElement*)element;

@end
