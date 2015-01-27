//
//  CommunityView.mm
//  vChess
//
//  Created by Sergey Seitov on 1/29/11.
//  Copyright 2011 V-Channel. All rights reserved.
//

#import "CommunityView.h"
#import "RequestIQ.h"
#import "vChessAppDelegate.h"
#import "Notifications.h"
#include "game.h"

@implementation CommunityView

- (vChessAppDelegate *)appDelegate
{
	return (vChessAppDelegate *)[[UIApplication sharedApplication] delegate];
}

- (void)awakeFromNib {
	
	self.dataSource = self;
	self.delegate = self;
	self.backgroundView = nil;
	self.backgroundColor = [UIColor clearColor];
	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleLogin:)
												 name:LoginNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleConnect:)
												 name:XMPPConnectNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleConnectError:)
												 name:XMPPConnectErrorNotification object:nil];	
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDisconnect:)
												 name:XMPPDisconnectNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleGameRequestAnswer:)
												 name:GameRequestAnswerNotification object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleTurnRequestAnswer:)
												 name:TurnRequestAnswerNotification object:nil];
}

- (void)errorConnection:(NSString*)error {
	
	NSString *message = error ? error : @"Network connection error.";
	UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Connection Error"
													message:message
												   delegate:nil
										  cancelButtonTitle:@"Ok"
										  otherButtonTitles:nil];
	[alert show];
}

- (id<XMPPUser>)findUserByJID:(XMPPJID*)jid {
	
	NSArray *users = [self fetchedResultsController].fetchedObjects;
	for (XMPPUserCoreDataStorageObject *user in users) {
		if ([user.jidStr isEqual:jid.bare]) {
			return user;
		}
	}
	return nil;
}
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
	if (_fetchedResultsController == nil)
	{
		NSManagedObjectContext *moc = [[self appDelegate] managedObjectContext_roster];
		
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorageObject"
		                                          inManagedObjectContext:moc];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
		_fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:moc
		                                                                 sectionNameKeyPath:@"sectionNum"
		                                                                          cacheName:nil];
		[_fetchedResultsController setDelegate:self];
		
		
		NSError *error = nil;
		if (![_fetchedResultsController performFetch:&error])
		{
			NSLog(@"Error performing fetch: %@", error);
		}
		
	}
	
	return _fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[self reloadData];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableViewDataSource Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	if ([[self appDelegate].xmppStream isConnected]) {
		return [[[self fetchedResultsController] sections] count];
	} else {
		return 0;
	}
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)sectionIndex {

	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        
		int section = [sectionInfo.name intValue];
		switch (section)
		{
			case 0  : return @"Available";
			case 1  : return @"Away";
			default : return @"Offline";
		}
	}
	
	return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex {
	
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
		return sectionInfo.numberOfObjects;
	}
	
	return 0;
}

- (void)configurePhotoForCell:(UITableViewCell *)cell user:(XMPPUserCoreDataStorageObject *)user
{
	// Our xmppRosterStorage will cache photos as they arrive from the xmppvCardAvatarModule.
	// We only need to ask the avatar module for a photo, if the roster doesn't have it.
	
	if (user.photo != nil)
	{
		cell.imageView.image = user.photo;
	}
	else
	{
		NSData *photoData = [[[self appDelegate] xmppvCardAvatarModule] photoDataForJID:user.jid];
		
		if (photoData != nil)
			cell.imageView.image = [UIImage imageWithData:photoData];
		else
			cell.imageView.image = [UIImage imageNamed:@"defaultPerson"];
	}
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
									  reuseIdentifier:CellIdentifier];
		cell.textLabel.numberOfLines = 2;
		cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
		cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14];
		cell.indentationLevel = 1;
	}
	
	NSArray *sections = [[self fetchedResultsController] sections];
	id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:indexPath.section];
	
	int section = [sectionInfo.name intValue];
	switch (section)
	{
		case 0  :
			cell.textLabel.textColor = [UIColor blackColor];
			cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
			cell.selectionStyle = UITableViewCellSelectionStyleBlue;
			break;
		default :
			cell.accessoryType = UITableViewCellAccessoryNone;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
			cell.textLabel.textColor = [UIColor grayColor];
			break;
	}
	
	XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	cell.textLabel.text = user.displayName;
	[self configurePhotoForCell:cell user:user];
	
	return cell;
}

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {

	NSString *color;
	NSIndexPath *index = [self indexPathForSelectedRow];
	switch (buttonIndex) {
		case 0:
			color = @"white";
			break;
		case 1:
			color = @"black";
			break;
		case 2:
			[self.communityDelegate messagePopover:index];
			return;
		default:
			return;
	}
	XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:index];
	GameRequestIQ *request = [[GameRequestIQ alloc] initForUser:user myColor:color];
	[self sendRequest:request];
	[self deselectRowAtIndexPath:index animated:YES];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [self cellForRowAtIndexPath:indexPath];
	XMPPUserCoreDataStorageObject *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	UIActionSheet *selection = [[UIActionSheet alloc]
								initWithTitle:[NSString stringWithFormat:@"Send game invitation to %@", [user displayName]]
								delegate:self
								cancelButtonTitle:nil
								destructiveButtonTitle:nil
								otherButtonTitles:
								@"I want to play WHITE",
								@"I want to play BLACK",
								@"Send text message", nil];
	[selection showFromRect:cell.bounds inView:cell animated:YES];
}

#pragma mark - Notification handlers

- (void)handleLogin:(NSNotification*)note {
	
	NSString *login = [note.userInfo objectForKey:@"login"];
	NSString *password = [note.userInfo objectForKey:@"password"];
	NSString *host = [note.userInfo objectForKey:@"host"];
	NSString *jid = [NSString stringWithFormat:@"%@/vChess", login];
	if (![[self appDelegate] connect:jid password:password host:host]) {
		[self errorConnection:nil];
	}
}

- (void)handleConnect:(NSNotification*)note {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:SuccessLoginNotification object:self];
	[self reloadData];
}

- (void)handleConnectError:(NSNotification*)note {
	
	[[NSNotificationCenter defaultCenter] postNotificationName:ErrorLoginNotification object:self];
	[self errorConnection:note.object];
}

- (void)handleDisconnect:(NSNotification*)note {
	
	[[self appDelegate] disconnect];
	[self reloadData];
}

- (void)handleGameRequestAnswer:(NSNotification*)note {
	
	XMPPIQ *iq = [note.userInfo objectForKey:@"iq"];
	id<XMPPUser> from = [self findUserByJID:[XMPPJID jidWithString:[iq attributeStringValueForName:@"from"]]];
	NSArray *childs = [iq elementsForName:@"create"];
	answerRequest = [[GameRequestAnswerIQ alloc] initWithRequest:[childs objectAtIndex:0] from:from responseId:[iq attributeStringValueForName:@"id"]];
}

- (void)handleTurnRequestAnswer:(NSNotification*)note {
	
	XMPPIQ *iq = [note.userInfo objectForKey:@"iq"];
	id<XMPPUser> from = [self findUserByJID:[XMPPJID jidWithString:[iq attributeStringValueForName:@"from"]]];
	NSArray *childs = [iq elementsForName:@"turn"];
	answerRequest = [[TurnRequestAnswerIQ alloc] initWithRequest:[childs objectAtIndex:0] from:from responseId:[iq attributeStringValueForName:@"id"]];
}

#pragma mark Send/Receive IQ

- (void)sendRequest:(RequestIQ*)request {
	
	[[self appDelegate].xmppRequests setObject:request forKey:request.iqId];
	[[self appDelegate].xmppStream sendElement:request.iqElement];
}

- (void)sendElement:(NSXMLElement*)element {
	
	[[self appDelegate].xmppStream sendElement:element];
}

@end
