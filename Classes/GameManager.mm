//
//  GameManager.m
//  vChess
//
//  Created by Sergey Seitov on 6/29/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import "GameManager.h"
#import "MasterLoader.h"
#import "StorageManager.h"
#import "NVUIGradientButton.h"

@implementation GameManager

@synthesize masterPackages;

#pragma mark View lifecycle

- (NSURL*)docURL {
	return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSURL*)gameServerURL {
	
	return [NSURL URLWithString:@"http://vchannel.sourceforge.net/packages"];
}

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
	self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTable)];
	self.masterPackages = [[NSArray alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"packages" withExtension:@"plist"]];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
	return 2;
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {

	return section ? @"Master's Games" : @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return section ? self.masterPackages.count : [StorageManager sharedStorageManager].userPackages.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"masterCell" forIndexPath:indexPath];
	cell.textLabel.textColor = [UIColor blackColor];
	cell.textLabel.text = indexPath.section ? [self.masterPackages objectAtIndex:indexPath.row] : [[StorageManager sharedStorageManager].userPackages objectAtIndex:indexPath.row];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	
	return cell;
}


#pragma mark Table view delegate

- (void)editTable {
	
	if(self.editing) {
		[self setEditing:NO animated:NO];
		[self.tableView reloadData];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(editTable)];
	} else {
		[self setEditing:YES animated:YES];
		[self.tableView reloadData];
		self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(editTable)];
	}
}

- (void)finishDownload:(NSNumber*)count {

	if ([count intValue] <= 0) {
		UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Error"
															message:@"Error load archive"
														   delegate:nil
												  cancelButtonTitle:@"Ok"
												  otherButtonTitles:nil];
		[alertView show];
	}
	[self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
	
	return section ? 44.0 : 64;
}

- (void)loadArchive {
	
	ChessComLoader *loader = [[ChessComLoader alloc] init];
	loader.delegate = self;
	UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:loader];
	navController.navigationBar.barStyle = UIBarStyleBlack;
	navController.modalPresentationStyle = UIModalPresentationFullScreen;
	navController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:navController animated:YES completion:^(void) {}];
}

- (void)loaderDidFinish:(UIViewController*)loader {

	[self.tableView reloadData];
	[loader dismissViewControllerAnimated:YES completion:^(){}];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
	
	if (section) {
		return nil;
	} else {
		UIView *header = [[UIView alloc] initWithFrame:CGRectZero];
		NVUIGradientButton *button = [[NVUIGradientButton alloc] initWithFrame:CGRectMake(10, 10, 300, 44)
																		 style:NVUIGradientButtonStyleDefault];
		button.text = @"Download from Chess.com";
		button.textColor = [UIColor whiteColor];
		button.textShadowColor = [UIColor darkGrayColor];
		button.tintColor = [UIColor colorWithRed:0 green:95.0/255.0 blue:189.0/255.0 alpha:1];
		[button addTarget:self action:@selector(loadArchive) forControlEvents:UIControlEventTouchDown];
		
		[header addSubview:button];
		return header;
	}
}
/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

	NSString *package = indexPath.section ? [self.masterPackages objectAtIndex:indexPath.row] : [[StorageManager sharedStorageManager].userPackages objectAtIndex:indexPath.row];
	MasterLoader *manager = [[MasterLoader alloc] initWithNibName:@"MasterLoader" bundle:nil];;
	manager.title = package;
	manager.mMasterEco = [[StorageManager sharedStorageManager] ecoInPackage:package];
	[manager.mPickerView reloadAllComponents];
	[self.navigationController pushViewController:manager animated:YES];
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
	NSString *package = indexPath.section ? [self.masterPackages objectAtIndex:indexPath.row] : [[StorageManager sharedStorageManager].userPackages objectAtIndex:indexPath.row];
	MasterLoader *manager = [segue destinationViewController];
	manager.title = package;
	manager.mMasterEco = [[StorageManager sharedStorageManager] ecoInPackage:package];
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
	
	if (self.editing && indexPath.section == 0) {
		return UITableViewCellEditingStyleDelete;
	} else {
		return UITableViewCellEditingStyleNone;
	}
}

- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSArray *packages = [[StorageManager sharedStorageManager] userPackages];
		NSString *package = [packages objectAtIndex:indexPath.row];
		[[StorageManager sharedStorageManager] removePackage:package];
		[aTableView reloadData];
    }
}

#pragma mark Memory management

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
}

@end

