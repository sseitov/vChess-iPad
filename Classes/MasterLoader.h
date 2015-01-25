//
//  MasterLoader.h
//  vChess
//
//  Created by Sergey Seitov on 10/2/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>

@class GameLoader;

@interface MasterLoader : UIViewController <UIPickerViewDelegate, 
	UIPickerViewDataSource, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> 
{

	IBOutlet UIPickerView	*mPickerView;
	IBOutlet UITextField	*mSearchBar;
	IBOutlet UITableView	*mGameTable;
		
	NSMutableDictionary		*mEcoCodes;
	NSDictionary			*mInfo;
	NSArray					*mMasterEco;
	NSMutableArray			*mGames;
}

@property (strong, nonatomic) NSArray		*mMasterEco;
@property (strong, nonatomic) UIPickerView	*mPickerView;

- (void)createEcoCodes;

@end
