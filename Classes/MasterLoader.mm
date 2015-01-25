//
//  MasterLoader.mm
//  vChess
//
//  Created by Sergey Seitov on 10/2/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import "MasterLoader.h"
#import "StorageManager.h"
#import "Notifications.h"
#import "ChessGame.h"
#include <string>

@implementation MasterLoader

@synthesize mMasterEco;
@synthesize mPickerView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        [self createEcoCodes];
		mGames = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidLoad {
	
	[super viewDidLoad];
	if (mMasterEco && [mMasterEco count] > 0) {
		NSString *eco = [mMasterEco objectAtIndex:0];
		[mGames removeAllObjects];
		[mGames addObjectsFromArray:[[StorageManager sharedStorageManager] gamesWithEco:eco inPackage:self.title]];
		[mGameTable reloadData];
	}
}

- (void)viewDidAppear:(BOOL)animated {

	[super viewDidAppear:animated];
	NSString *eco = [mMasterEco objectAtIndex:[mPickerView selectedRowInComponent:0]];
	[mGames removeAllObjects];
	[mGames addObjectsFromArray:[[StorageManager sharedStorageManager] gamesWithEco:eco inPackage:self.title]];
	[mGameTable reloadData];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
	
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)didReceiveMemoryWarning {
	
    [super didReceiveMemoryWarning];
}

- (void)viewDidUnload {

    [super viewDidUnload];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	
	return [mMasterEco count];
}

- (UIView *)pickerView:(UIPickerView *)thePickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	
	if (view == nil) {
		view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 32)];
	}
	NSString *code = [mMasterEco objectAtIndex:row];
	NSString *val = [mEcoCodes valueForKey:code];
	
	UILabel *label1 = (UILabel*)[view viewWithTag:1];
	if (label1 == nil) {
		label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 32)];
		label1.backgroundColor = [UIColor clearColor];
		label1.textColor = [UIColor brownColor];
		label1.adjustsFontSizeToFitWidth = true;
		label1.font = [UIFont fontWithName:@"Verdana-Bold" size:16];
		label1.textAlignment = UITextAlignmentLeft;
		label1.tag = 1;
		label1.text = code;
		[view addSubview:label1];
	} else {
		label1.text = code;
	}
	
	if (val) {
		UILabel *label2 = (UILabel*)[view viewWithTag:2];
		if (label2 == nil) {
			label2 = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 240, 32)];
			label2.backgroundColor = [UIColor clearColor];
			label2.textColor = [UIColor blackColor];
			label2.adjustsFontSizeToFitWidth = true;
			label2.font = [UIFont fontWithName:@"Verdana-Bold" size:12];
			label2.textAlignment = UITextAlignmentCenter;
			label2.numberOfLines = 2;
			label2.tag = 2;
			label2.text = val;
			[view addSubview:label2];
		} else {
			label2.text = val;
		}
	} else {
		UILabel *label2 = (UILabel*)[view viewWithTag:2];
		if (label2) {
			[label2 removeFromSuperview];
		}
	}
	
	return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {

	NSString *eco = [mMasterEco objectAtIndex:row];
	[mGames removeAllObjects];
	[mGames addObjectsFromArray:[[StorageManager sharedStorageManager] gamesWithEco:eco inPackage:self.title]];
	[mGameTable reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[mSearchBar resignFirstResponder];
	std::string searchText([[textField.text uppercaseString] UTF8String]);
	NSInteger index = [mMasterEco indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
		NSString *str = (NSString*)obj;
		std::string text([str UTF8String]);
		if (idx >= [mMasterEco count]) {
			*stop = YES;
		} else {
			if (text >= searchText) {
				*stop = YES;
				return YES;
			}
		}
		return NO;
	}];
	textField.text = @"";
	if (index != NSNotFound) {
		[mPickerView selectRow:index inComponent:0 animated:YES];
	} else {
		[mPickerView selectRow:([mMasterEco count] - 1) inComponent:0 animated:YES];
	}

	return YES;
}

- (void)createEcoCodes {
	
	mEcoCodes = [[NSMutableDictionary alloc] init];
	[mEcoCodes setValue:@"Polish Opening; Sokolsky's Opening" forKey:@"A00"];
	[mEcoCodes setValue:@"Larsen Attack" forKey:@"A01"];
	[mEcoCodes setValue:@"Bird's Opening" forKey:@"A02"];
	[mEcoCodes setValue:@"Bird's Opening. Dutch Variation" forKey:@"A03"];
	[mEcoCodes setValue:@"King's Indian Attack" forKey:@"A04"];
	[mEcoCodes setValue:@"King's Indian Attack" forKey:@"A05"];
	[mEcoCodes setValue:@"King's Indian Attack" forKey:@"A06"];
	[mEcoCodes setValue:@"King's Indian Attack" forKey:@"A07"];
	[mEcoCodes setValue:@"King's Indian Attack" forKey:@"A08"];
	[mEcoCodes setValue:@"King's Indian Attack" forKey:@"A09"];
	[mEcoCodes setValue:@"English Opening" forKey:@"A10"];
	[mEcoCodes setValue:@"Reti Opening" forKey:@"A11"];
	[mEcoCodes setValue:@"Reti Opening" forKey:@"A12"];
	[mEcoCodes setValue:@"English Opening" forKey:@"A13"];
	[mEcoCodes setValue:@"English Opening" forKey:@"A14"];
	[mEcoCodes setValue:@"English Opening" forKey:@"A15"];
	[mEcoCodes setValue:@"English Opening" forKey:@"A16"];
	[mEcoCodes setValue:@"English Opening. Hedgehog Variation" forKey:@"A17"];
	[mEcoCodes setValue:@"English Opening" forKey:@"A18"];
	[mEcoCodes setValue:@"English Opening" forKey:@"A19"];
	[mEcoCodes setValue:@"English Opening. Reversed Sicilian" forKey:@"A20"];
	[mEcoCodes setValue:@"English Opening. Reversed Sicilian" forKey:@"A21"];
	[mEcoCodes setValue:@"English Opening. Reversed Sicilian" forKey:@"A22"];
	[mEcoCodes setValue:@"English Opening. Reversed Sicilian" forKey:@"A23"];
	[mEcoCodes setValue:@"English Opening. Reversed Sicilian" forKey:@"A24"];
	[mEcoCodes setValue:@"English Opening. Reversed Sicilian" forKey:@"A25"];
	[mEcoCodes setValue:@"English Opening. Reversed Sicilian" forKey:@"A26"];
	[mEcoCodes setValue:@"English Opening. Reversed Sicilian" forKey:@"A27"];
	[mEcoCodes setValue:@"English Opening. Reversed Sicilian" forKey:@"A28"];
	[mEcoCodes setValue:@"English Opening. Reversed Sicilian" forKey:@"A29"];
	[mEcoCodes setValue:@"English Opening. Hedgehod Variation" forKey:@"A30"];
	[mEcoCodes setValue:@"English Opening. Hedgehod Variation" forKey:@"A31"];
	[mEcoCodes setValue:@"English Opening. Symmetrical Variation" forKey:@"A32"];
	[mEcoCodes setValue:@"English Opening. Symmetrical Variation" forKey:@"A33"];
	[mEcoCodes setValue:@"English Opening. Symmetrical Variation" forKey:@"A34"];
	[mEcoCodes setValue:@"English Opening. Symmetrical Variation" forKey:@"A35"];
	[mEcoCodes setValue:@"English Opening. Symmetrical Variation" forKey:@"A36"];
	[mEcoCodes setValue:@"English Opening. Symmetrical Variation" forKey:@"A37"];
	[mEcoCodes setValue:@"English Opening. Symmetrical Variation" forKey:@"A38"];
	[mEcoCodes setValue:@"English Opening. Symmetrical Variation" forKey:@"A39"];
	[mEcoCodes setValue:@"Englund Gambit" forKey:@"A40"];
	[mEcoCodes setValue:@"Modern Defense" forKey:@"A41"];
	[mEcoCodes setValue:@"Modern Defense" forKey:@"A42"];
	[mEcoCodes setValue:@"Old Benoni Defense" forKey:@"A43"];
	[mEcoCodes setValue:@"Old Benoni Defense" forKey:@"A44"];
	[mEcoCodes setValue:@"Trompovsky Attack" forKey:@"A45"];
	[mEcoCodes setValue:@"Queen's Pawn Game" forKey:@"A46"];
	[mEcoCodes setValue:@"Queen's Indian Defense" forKey:@"A47"];
	[mEcoCodes setValue:@"Torre Attack" forKey:@"A48"];
	[mEcoCodes setValue:@"Torre Attack" forKey:@"A49"];
	[mEcoCodes setValue:@"Queen's Indian Defense" forKey:@"A50"];
	[mEcoCodes setValue:@"Budapest Gambit" forKey:@"A51"];
	[mEcoCodes setValue:@"Budapest Gambit. Main Line" forKey:@"A52"];
	[mEcoCodes setValue:@"Old Indian Defense" forKey:@"A53"];
	[mEcoCodes setValue:@"Old Indian Defense" forKey:@"A54"];
	[mEcoCodes setValue:@"Old Indian Defense" forKey:@"A55"];
	[mEcoCodes setValue:@"Czech Benoni Defense" forKey:@"A56"];
	[mEcoCodes setValue:@"Benko (Volga) Gambit" forKey:@"A57"];
	[mEcoCodes setValue:@"Benko (Volga) Gambit. Accepted" forKey:@"A58"];
	[mEcoCodes setValue:@"Benko (Volga) Gambit" forKey:@"A59"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A60"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A61"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A62"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A63"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A64"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A65"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A66"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A67"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A68"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A69"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A70"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A71"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A72"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A73"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A74"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A75"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A76"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A77"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A78"];
	[mEcoCodes setValue:@"Modern Benoni Defense" forKey:@"A79"];
	[mEcoCodes setValue:@"Dutch Defense" forKey:@"A80"];
	[mEcoCodes setValue:@"Dutch Defense" forKey:@"A81"];
	[mEcoCodes setValue:@"Dutch Defense. Staunton Gambit" forKey:@"A82"];
	[mEcoCodes setValue:@"Dutch Defense. Mainline" forKey:@"A83"];
	[mEcoCodes setValue:@"Dutch Defense" forKey:@"A84"];
	[mEcoCodes setValue:@"Dutch Defense" forKey:@"A85"];
	[mEcoCodes setValue:@"Dutch Defense" forKey:@"A86"];
	[mEcoCodes setValue:@"Dutch Defense. Leningrad" forKey:@"A87"];
	[mEcoCodes setValue:@"Dutch Defense. Leningrad" forKey:@"A88"];
	[mEcoCodes setValue:@"Dutch Defense. Leningrad" forKey:@"A89"];
	[mEcoCodes setValue:@"Dutch Defense. Leningrad" forKey:@"A90"];
	[mEcoCodes setValue:@"Dutch Defense" forKey:@"A91"];
	[mEcoCodes setValue:@"Dutch Defense" forKey:@"A92"];
	[mEcoCodes setValue:@"Dutch Defense" forKey:@"A93"];
	[mEcoCodes setValue:@"Dutch Defense" forKey:@"A94"];
	[mEcoCodes setValue:@"Dutch Defense" forKey:@"A95"];
	[mEcoCodes setValue:@"Dutch Defense" forKey:@"A96"];
	[mEcoCodes setValue:@"Dutch Defense" forKey:@"A97"];
	[mEcoCodes setValue:@"Dutch Defense" forKey:@"A98"];
	[mEcoCodes setValue:@"Dutch Defense" forKey:@"A99"];
	[mEcoCodes setValue:@"Nimzowitsch Defense; Owens Defense" forKey:@"B00"];
	[mEcoCodes setValue:@"Scandinavian Defense" forKey:@"B01"];
	[mEcoCodes setValue:@"Alekhine's Defense" forKey:@"B02"];
	[mEcoCodes setValue:@"Alekhine's Defense. Four Pawns Attack" forKey:@"B03"];
	[mEcoCodes setValue:@"Alekhine's Defense" forKey:@"B04"];
	[mEcoCodes setValue:@"Alekhine's Defense" forKey:@"B05"];
	[mEcoCodes setValue:@"Modern Defense" forKey:@"B06"];
	[mEcoCodes setValue:@"Pirc Defense" forKey:@"B07"];
	[mEcoCodes setValue:@"Pirc Defense. Classical Variation" forKey:@"B08"];
	[mEcoCodes setValue:@"Pirc Defense. Austrian Attack" forKey:@"B09"];
	[mEcoCodes setValue:@"Caro-Kann Defense" forKey:@"B10"];
	[mEcoCodes setValue:@"Caro-Kann Defense. Two Knights' Defense" forKey:@"B11"];
	[mEcoCodes setValue:@"Caro-Kann Defense. 3.c5 Attack" forKey:@"B12"];
	[mEcoCodes setValue:@"Caro-Kann Defense" forKey:@"B13"];
	[mEcoCodes setValue:@"Caro-Kann Defense. Panov Attack" forKey:@"B14"];
	[mEcoCodes setValue:@"Caro-Kann Defense" forKey:@"B15"];
	[mEcoCodes setValue:@"Caro-Kann Defense" forKey:@"B16"];
	[mEcoCodes setValue:@"Caro-Kann Defense" forKey:@"B17"];
	[mEcoCodes setValue:@"Caro-Kann Defense" forKey:@"B18"];
	[mEcoCodes setValue:@"Caro-Kann Defense" forKey:@"B19"];
	[mEcoCodes setValue:@"Sicilian Defense" forKey:@"B20"];
	[mEcoCodes setValue:@"Sicilian Defense. Morra Gambit; Grand Prix Attack" forKey:@"B21"];
	[mEcoCodes setValue:@"Sicilian Defense. Alapin Variation" forKey:@"B22"];
	[mEcoCodes setValue:@"Sicilian Defense. Closed Variation" forKey:@"B23"];
	[mEcoCodes setValue:@"Sicilian Defense. Closed Variation" forKey:@"B24"];
	[mEcoCodes setValue:@"Sicilian Defense. Closed Variation" forKey:@"B25"];
	[mEcoCodes setValue:@"Sicilian Defense. Closed Variation" forKey:@"B26"];
	[mEcoCodes setValue:@"Sicilian Defense" forKey:@"B27"];
	[mEcoCodes setValue:@"Sicilian Defense" forKey:@"B28"];
	[mEcoCodes setValue:@"Sicilian Defense. Rubinstein Variation" forKey:@"B29"];
	[mEcoCodes setValue:@"Sicilian Defense. Rossolimo Variation" forKey:@"B30"];
	[mEcoCodes setValue:@"Sicilian Defense. Rossolimo Variation" forKey:@"B31"];
	[mEcoCodes setValue:@"Sicilian Defense. Lowenthal Hunting Variation" forKey:@"B32"];
	[mEcoCodes setValue:@"Sicilian Defense. Sveshnikov Variation" forKey:@"B33"];
	[mEcoCodes setValue:@"Sicilian Defense. Accelerated Dragon Variation" forKey:@"B34"];
	[mEcoCodes setValue:@"Sicilian Defense. Accelerated Dragon Variation" forKey:@"B35"];
	[mEcoCodes setValue:@"Sicilian Defense. Accelerated Dragon Variation" forKey:@"B36"];
	[mEcoCodes setValue:@"Sicilian Defense. Accelerated Dragon Variation. Maroczy Bind" forKey:@"B37"];
	[mEcoCodes setValue:@"Sicilian Defense. Accelerated Dragon Variation. Maroczy Bind" forKey:@"B38"];
	[mEcoCodes setValue:@"Sicilian Defense. Accelerated Dragon Variation" forKey:@"B39"];
	[mEcoCodes setValue:@"Sicilian Defense. Counter Attack Variation" forKey:@"B40"];
	[mEcoCodes setValue:@"Sicilian Defense. Paulsen Variation. Kan System" forKey:@"B41"];
	[mEcoCodes setValue:@"Sicilian Defense. Paulsen Variation. Kan System" forKey:@"B42"];
	[mEcoCodes setValue:@"Sicilian Defense. Paulsen Variation. Kan System" forKey:@"B43"];
	[mEcoCodes setValue:@"Sicilian Defense. Paulsen Variation. Taimanov System" forKey:@"B44"];
	[mEcoCodes setValue:@"Sicilian Defense. Paulsen Variation. Classical System" forKey:@"B45"];
	[mEcoCodes setValue:@"Sicilian Defense. Paulsen Variation. Taimanov System" forKey:@"B46"];
	[mEcoCodes setValue:@"Sicilian Defense. Paulsen Variation. Taimanov System" forKey:@"B47"];
	[mEcoCodes setValue:@"Sicilian Defense. Paulsen Variation" forKey:@"B48"];
	[mEcoCodes setValue:@"Sicilian Defense. Paulsen Variation" forKey:@"B49"];
	[mEcoCodes setValue:@"Sicilian Defense. Kopec Variation" forKey:@"B50"];
	[mEcoCodes setValue:@"Sicilian Defense. Rossolimo Variation" forKey:@"B51"];
	[mEcoCodes setValue:@"Sicilian Defense. Rossolimo Variation" forKey:@"B52"];
	[mEcoCodes setValue:@"Sicilian Defense. Hungarian Variation" forKey:@"B53"];
	[mEcoCodes setValue:@"Sicilian Defense" forKey:@"B54"];
	[mEcoCodes setValue:@"Sicilian Defense. Anti-Dragon Variation" forKey:@"B55"];
	[mEcoCodes setValue:@"Sicilian Defense" forKey:@"B56"];
	[mEcoCodes setValue:@"Sicilian Defense. Sozin-Benko Variation" forKey:@"B57"];
	[mEcoCodes setValue:@"Sicilian Defense. Boleslavsky Variation" forKey:@"B58"];
	[mEcoCodes setValue:@"Sicilian Defense" forKey:@"B59"];
	[mEcoCodes setValue:@"Sicilian Defense. Richter Rauzer Attack" forKey:@"B60"];
	[mEcoCodes setValue:@"Sicilian Defense. Richter Rauzer Attack" forKey:@"B61"];
	[mEcoCodes setValue:@"Sicilian Defense. Richter Rauzer Attack" forKey:@"B62"];
	[mEcoCodes setValue:@"Sicilian Defense. Richter Rauzer Attack" forKey:@"B63"];
	[mEcoCodes setValue:@"Sicilian Defense. Richter Rauzer Attack" forKey:@"B64"];
	[mEcoCodes setValue:@"Sicilian Defense. Richter Rauzer Attack" forKey:@"B65"];
	[mEcoCodes setValue:@"Sicilian Defense. Richter Rauzer Attack" forKey:@"B66"];
	[mEcoCodes setValue:@"Sicilian Defense. Richter Rauzer Attack" forKey:@"B67"];
	[mEcoCodes setValue:@"Sicilian Defense. Richter Rauzer Attack" forKey:@"B68"];
	[mEcoCodes setValue:@"Sicilian Defense. Richter Rauzer Attack" forKey:@"B69"];
	[mEcoCodes setValue:@"Sicilian Defense. Dragon Variation" forKey:@"B70"];
	[mEcoCodes setValue:@"Sicilian Defense. Dragon Variation" forKey:@"B71"];
	[mEcoCodes setValue:@"Sicilian Defense. Dragon Variation. Classical System" forKey:@"B72"];
	[mEcoCodes setValue:@"Sicilian Defense. Dragon Variation" forKey:@"B73"];
	[mEcoCodes setValue:@"Sicilian Defense. Dragon Variation" forKey:@"B74"];
	[mEcoCodes setValue:@"Sicilian Defense. Dragon Variation" forKey:@"B75"];
	[mEcoCodes setValue:@"Sicilian Defense. Dragon Variation. Yugoslav Attack" forKey:@"B76"];
	[mEcoCodes setValue:@"Sicilian Defense. Dragon Variation. Yugoslav Attack" forKey:@"B77"];
	[mEcoCodes setValue:@"Sicilian Defense. Dragon Variation. Yugoslav Attack" forKey:@"B78"];
	[mEcoCodes setValue:@"Sicilian Defense. Dragon Variation" forKey:@"B79"];
	[mEcoCodes setValue:@"Sicilian Defense. Scheveningen Variation" forKey:@"B80"];
	[mEcoCodes setValue:@"Sicilian Defense. Scheveningen Variation. Keres System" forKey:@"B81"];
	[mEcoCodes setValue:@"Sicilian Defense. Scheveningen Variation" forKey:@"B82"];
	[mEcoCodes setValue:@"Sicilian Defense. Scheveningen Variation" forKey:@"B83"];
	[mEcoCodes setValue:@"Sicilian Defense. Scheveningen Variation" forKey:@"B84"];
	[mEcoCodes setValue:@"Sicilian Defense. Scheveningen Variation" forKey:@"B85"];
	[mEcoCodes setValue:@"Sicilian Defense. Scheveningen Variation. Fischer/Sozin System" forKey:@"B86"];
	[mEcoCodes setValue:@"Sicilian Defense. Scheveningen Variation. Fischer/Sozin System" forKey:@"B87"];
	[mEcoCodes setValue:@"Sicilian Defense. Scheveningen Variation" forKey:@"B88"];
	[mEcoCodes setValue:@"Sicilian Defense. Scheveningen Variation" forKey:@"B89"];
	[mEcoCodes setValue:@"Sicilian Defense. Najdorf Variation" forKey:@"B90"];
	[mEcoCodes setValue:@"Sicilian Defense. Najdorf Variation" forKey:@"B91"];
	[mEcoCodes setValue:@"Sicilian Defense. Najdorf Variation" forKey:@"B92"];
	[mEcoCodes setValue:@"Sicilian Defense. Najdorf Variation" forKey:@"B93"];
	[mEcoCodes setValue:@"Sicilian Defense. Najdorf Variation" forKey:@"B94"];
	[mEcoCodes setValue:@"Sicilian Defense. Najdorf Variation" forKey:@"B95"];
	[mEcoCodes setValue:@"Sicilian Defense. Najdorf Variation. Goteborg System" forKey:@"B96"];
	[mEcoCodes setValue:@"Sicilian Defense. Najdorf Variation. Poisoned Pawn System" forKey:@"B97"];
	[mEcoCodes setValue:@"Sicilian Defense. Najdorf Variation" forKey:@"B98"];
	[mEcoCodes setValue:@"Sicilian Defense. Najdorf Variation" forKey:@"B99"];
	[mEcoCodes setValue:@"French Defense" forKey:@"C00"];
	[mEcoCodes setValue:@"French Defense. Exchange Variation" forKey:@"C01"];
	[mEcoCodes setValue:@"French Defense. Advance Variation" forKey:@"C02"];
	[mEcoCodes setValue:@"French Defense. Tarrasch Variation. 3.... a6 System" forKey:@"C03"];
	[mEcoCodes setValue:@"French Defense. Tarrasch Variation. 3.... Bc6 System" forKey:@"C04"];
	[mEcoCodes setValue:@"French Defense. Tarrasch Variation. 3.... Nf6 System" forKey:@"C05"];
	[mEcoCodes setValue:@"French Defense. Tarrasch Variation. 3.... Nf6 System" forKey:@"C06"];
	[mEcoCodes setValue:@"French Defense. Tarrasch Variation. 3.... c5 System" forKey:@"C07"];
	[mEcoCodes setValue:@"French Defense. Tarrasch Variation. 3.... c5 System" forKey:@"C08"];
	[mEcoCodes setValue:@"French Defense. Tarrasch Variation. 3.... c5 System" forKey:@"C09"];
	[mEcoCodes setValue:@"French Defense. Rubinstein Variation" forKey:@"C10"];
	[mEcoCodes setValue:@"French Defense. Steinitz Variation" forKey:@"C11"];
	[mEcoCodes setValue:@"French Defense. MacCutcheon Variation" forKey:@"C12"];
	[mEcoCodes setValue:@"French Defense" forKey:@"C13"];
	[mEcoCodes setValue:@"French Defense" forKey:@"C14"];
	[mEcoCodes setValue:@"French Defense. Winawer Variation. Lapus Manus System" forKey:@"C15"];
	[mEcoCodes setValue:@"French Defense. Winawer Variation" forKey:@"C16"];
	[mEcoCodes setValue:@"French Defense. Winawer Variation. Swiss System" forKey:@"C17"];
	[mEcoCodes setValue:@"French Defense. Winawer Variation. Main Line" forKey:@"C18"];
	[mEcoCodes setValue:@"French Defense. Winawer Variation. Advance, 6. ... Ne7" forKey:@"C19"];
	[mEcoCodes setValue:@"French Defense. Winawer Variation. Exchange System" forKey:@"C20"];
	[mEcoCodes setValue:@"Nordic Gambit" forKey:@"C21"];
	[mEcoCodes setValue:@"Center Game" forKey:@"C22"];
	[mEcoCodes setValue:@"Bishop's Opening" forKey:@"C23"];
	[mEcoCodes setValue:@"Bishop's Opening" forKey:@"C24"];
	[mEcoCodes setValue:@"Vienna Game" forKey:@"C25"];
	[mEcoCodes setValue:@"Vienna Game" forKey:@"C26"];
	[mEcoCodes setValue:@"Vienna Game" forKey:@"C27"];
	[mEcoCodes setValue:@"Vienna Game" forKey:@"C28"];
	[mEcoCodes setValue:@"Vienna Game" forKey:@"C29"];
	[mEcoCodes setValue:@"King's Gambit" forKey:@"C30"];
	[mEcoCodes setValue:@"King's Gambit. Falkbeer Counter Gambit" forKey:@"C31"];
	[mEcoCodes setValue:@"King's Gambit. Falkbeer Counter Gambit" forKey:@"C32"];
	[mEcoCodes setValue:@"King's Gambit. Keres Variation" forKey:@"C33"];
	[mEcoCodes setValue:@"King's Gambit" forKey:@"C34"];
	[mEcoCodes setValue:@"King's Gambit. Cunningham Variation" forKey:@"C35"];
	[mEcoCodes setValue:@"King's Gambit. Modern Variation" forKey:@"C36"];
	[mEcoCodes setValue:@"King's Gambit. Muzio Gambit" forKey:@"C37"];
	[mEcoCodes setValue:@"King's Gambit. Greco & Philidor Gambits" forKey:@"C38"];
	[mEcoCodes setValue:@"King's Gambit. Allagier & Kiesertisky Gambits" forKey:@"C39"];
	[mEcoCodes setValue:@"Latvian Gambit" forKey:@"C40"];
	[mEcoCodes setValue:@"Philidor's Defense" forKey:@"C41"];
	[mEcoCodes setValue:@"Russian (Petroff's) Defense" forKey:@"C42"];
	[mEcoCodes setValue:@"Russian (Petroff's) Defense" forKey:@"C43"];
	[mEcoCodes setValue:@"Ponziani Opening" forKey:@"C44"];
	[mEcoCodes setValue:@"Scotch Game" forKey:@"C45"];
	[mEcoCodes setValue:@"Three Knights' Opening" forKey:@"C46"];
	[mEcoCodes setValue:@"Four Knights' Opening" forKey:@"C47"];
	[mEcoCodes setValue:@"Four Knights' Opening" forKey:@"C48"];
	[mEcoCodes setValue:@"Four Knights' Opening" forKey:@"C49"];
	[mEcoCodes setValue:@"Italian Game (Giuoco Piano). Hungarian Defense" forKey:@"C50"];
	[mEcoCodes setValue:@"Italian Game (Giuoco Piano). Evans Gambit" forKey:@"C51"];
	[mEcoCodes setValue:@"Italian Game (Giuoco Piano). Evans Gambit" forKey:@"C52"];
	[mEcoCodes setValue:@"Italian Game (Giuoco Piano)" forKey:@"C53"];
	[mEcoCodes setValue:@"Italian Game (Giuoco Piano)" forKey:@"C54"];
	[mEcoCodes setValue:@"Italian Game (Giuoco Piano). Two Knights' Defense" forKey:@"C55"];
	[mEcoCodes setValue:@"Italian Game (Giuoco Piano). Max Lange Attack" forKey:@"C56"];
	[mEcoCodes setValue:@"Italian Game (Giuoco Piano). Two Knights' Defense" forKey:@"C57"];
	[mEcoCodes setValue:@"Italian Game (Giuoco Piano). Two Knights' Defense" forKey:@"C58"];
	[mEcoCodes setValue:@"Italian Game (Giuoco Piano). Two Knights' Defense" forKey:@"C59"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez)" forKey:@"C60"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Bird's Defense" forKey:@"C61"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Old Steinitz Defense" forKey:@"C62"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Schliemann Gambit" forKey:@"C63"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Cordel Defense" forKey:@"C64"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Berlin Defense" forKey:@"C65"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Modern Steinitz Defense" forKey:@"C66"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Rio de Janerio Defense" forKey:@"C67"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Exchange Variation" forKey:@"C68"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Exchange Variation" forKey:@"C69"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez)" forKey:@"C70"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Modern Steinitz Defens" forKey:@"C71"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Modern Steinitz Defens" forKey:@"C72"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Modern Steinitz Defens" forKey:@"C73"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Modern Steinitz Defens" forKey:@"C74"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Modern Steinitz Defens" forKey:@"C75"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Modern Steinitz Defens" forKey:@"C76"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Anderssen Variation" forKey:@"C77"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Archangel Variation; Moeller Attack" forKey:@"C78"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Russian Variation" forKey:@"C79"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Open Variation. Bernstein System" forKey:@"C80"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Open Variation. Keres System" forKey:@"C81"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Open Variation" forKey:@"C82"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Open Variation. Main Line" forKey:@"C83"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Center Attack" forKey:@"C84"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Delayed Defered Exchange Variation" forKey:@"C85"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Worral Attack" forKey:@"C86"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez)" forKey:@"C87"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Marshall Gambit" forKey:@"C88"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez)" forKey:@"C89"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez)" forKey:@"C90"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez)" forKey:@"C91"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Zaitsev Variation" forKey:@"C92"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Smyslov Variation" forKey:@"C93"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Breyer Variation" forKey:@"C94"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Breyer Variation" forKey:@"C95"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Tchigorin" forKey:@"C96"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Tchigorin" forKey:@"C97"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Tchigorin" forKey:@"C98"];
	[mEcoCodes setValue:@"Spanish Opening (Ruy Lopez). Tchigorin" forKey:@"C99"];
	[mEcoCodes setValue:@"Queen's Pawn Opening" forKey:@"D00"];
	[mEcoCodes setValue:@"Veresov Opening" forKey:@"D01"];
	[mEcoCodes setValue:@"Gruenfeld Reversed Opening" forKey:@"D02"];
	[mEcoCodes setValue:@"Torre attack (Tartakower variation)" forKey:@"D03"];
	[mEcoCodes setValue:@"Queen's pawn game" forKey:@"D04"];
	[mEcoCodes setValue:@"Colle System" forKey:@"D05"];
	[mEcoCodes setValue:@"Queen's Gambit" forKey:@"D06"];
	[mEcoCodes setValue:@"Queen's Gambit. Tchigorin Variation" forKey:@"D07"];
	[mEcoCodes setValue:@"Queen's Gambit. Albin Counter Gambit" forKey:@"D08"];
	[mEcoCodes setValue:@"Queen's Gambit. Albin Counter Gambit" forKey:@"D09"];
	[mEcoCodes setValue:@"Queen's Gambit. Slav Defense" forKey:@"D10"];
	[mEcoCodes setValue:@"Queen's Gambit. Slav Defense" forKey:@"D11"];
	[mEcoCodes setValue:@"Queen's Gambit. Slav Defense" forKey:@"D12"];
	[mEcoCodes setValue:@"Queen's Gambit. Slav Defense" forKey:@"D13"];
	[mEcoCodes setValue:@"Queen's Gambit. Slav Defense. Exchange System" forKey:@"D14"];
	[mEcoCodes setValue:@"Queen's Gambit. Slav Defense. Geller Gambit" forKey:@"D15"];
	[mEcoCodes setValue:@"Queen's Gambit. Slav Defense" forKey:@"D16"];
	[mEcoCodes setValue:@"Queen's Gambit. Slav Defense. Czech System" forKey:@"D17"];
	[mEcoCodes setValue:@"Queen's Gambit. Slav Defense. Main Line" forKey:@"D18"];
	[mEcoCodes setValue:@"Queen's Gambit. Slav Defense. Euwe System" forKey:@"D19"];
	[mEcoCodes setValue:@"Queen's Gambit. Accepted" forKey:@"D20"];
	[mEcoCodes setValue:@"Queen's Gambit. Accepted. Borsenko-Furman System" forKey:@"D21"];
	[mEcoCodes setValue:@"Queen's Gambit. Accepted" forKey:@"D22"];
	[mEcoCodes setValue:@"Queen's Gambit. Accepted" forKey:@"D23"];
	[mEcoCodes setValue:@"Queen's Gambit. Accepted" forKey:@"D24"];
	[mEcoCodes setValue:@"Queen's Gambit. Accepted" forKey:@"D25"];
	[mEcoCodes setValue:@"Queen's Gambit. Accepted" forKey:@"D26"];
	[mEcoCodes setValue:@"Queen's Gambit. Accepted" forKey:@"D27"];
	[mEcoCodes setValue:@"Queen's Gambit. Accepted" forKey:@"D28"];
	[mEcoCodes setValue:@"Queen's Gambit. Accepted" forKey:@"D29"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined" forKey:@"D30"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Alatortsev System" forKey:@"D31"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Tarrasch System" forKey:@"D32"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Tarrasch System" forKey:@"D33"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Rubinstein System" forKey:@"D34"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Exchange System" forKey:@"D35"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Exchange System" forKey:@"D36"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. 5.Bf4 System" forKey:@"D37"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Ragozin Defense" forKey:@"D38"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Ragozin Defense" forKey:@"D39"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Semi-Tarrasch Defense" forKey:@"D40"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Semi-Tarrasch Defense" forKey:@"D41"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Semi-Tarrasch Defense" forKey:@"D42"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Semi-Slav Defense" forKey:@"D43"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Anti-Meran Defense" forKey:@"D44"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Anti-Meran Defense" forKey:@"D45"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Semi-Slav Defense" forKey:@"D46"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Meran Defense" forKey:@"D47"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Meran Defense" forKey:@"D48"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Meran Defense" forKey:@"D49"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined" forKey:@"D50"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Cambridge Springs Defense" forKey:@"D51"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Cambridge Springs Defense" forKey:@"D52"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Orthodox Defense" forKey:@"D53"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Orthodox Defense" forKey:@"D54"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Anti-Tartakower Syste" forKey:@"D55"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Lasker System" forKey:@"D56"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Modern System" forKey:@"D57"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Tartakower System" forKey:@"D58"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Tartakower System" forKey:@"D59"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Orthodox Defense" forKey:@"D60"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Orthodox Defense" forKey:@"D61"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Orthodox Defense" forKey:@"D62"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Blackburne System" forKey:@"D63"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Blackburne System" forKey:@"D64"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Blackburne System" forKey:@"D65"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Blackburne System" forKey:@"D66"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Capablanca System" forKey:@"D67"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined. Blackburne System" forKey:@"D68"];
	[mEcoCodes setValue:@"Queen's Gambit. Declined" forKey:@"D69"];
	[mEcoCodes setValue:@"Grunfeld Defense" forKey:@"D70"];
	[mEcoCodes setValue:@"Grunfeld Defense. Neo-Grunfeld Variatio" forKey:@"D71"];
	[mEcoCodes setValue:@"Grunfeld Defense" forKey:@"D72"];
	[mEcoCodes setValue:@"Grunfeld Defense" forKey:@"D73"];
	[mEcoCodes setValue:@"Grunfeld Defense" forKey:@"D74"];
	[mEcoCodes setValue:@"Grunfeld Defense" forKey:@"D75"];
	[mEcoCodes setValue:@"Grunfeld Defense. Orthodox Fianchetto Variation" forKey:@"D76"];
	[mEcoCodes setValue:@"Grunfeld Defense" forKey:@"D77"];
	[mEcoCodes setValue:@"Grunfeld Defense" forKey:@"D78"];
	[mEcoCodes setValue:@"Grunfeld Defense. Slav Variation" forKey:@"D79"];
	[mEcoCodes setValue:@"Grunfeld Defense" forKey:@"D80"];
	[mEcoCodes setValue:@"Grunfeld Defense" forKey:@"D81"];
	[mEcoCodes setValue:@"Grunfeld Defense. Bf4 System" forKey:@"D82"];
	[mEcoCodes setValue:@"Grunfeld Defense. Bf4 System" forKey:@"D83"];
	[mEcoCodes setValue:@"Grunfeld Defense. Bf4 System" forKey:@"D84"];
	[mEcoCodes setValue:@"Grunfeld Defense. Modern Exchange Variation" forKey:@"D85"];
	[mEcoCodes setValue:@"Grunfeld Defense" forKey:@"D86"];
	[mEcoCodes setValue:@"Grunfeld Defense. Botvinnik Exchange Variation" forKey:@"D87"];
	[mEcoCodes setValue:@"Grunfeld Defense" forKey:@"D88"];
	[mEcoCodes setValue:@"Grunfeld Defense. Exchange Variation" forKey:@"D89"];
	[mEcoCodes setValue:@"Grunfeld Defense" forKey:@"D90"];
	[mEcoCodes setValue:@"Grunfeld Defense" forKey:@"D91"];
	[mEcoCodes setValue:@"Grunfeld Defense" forKey:@"D92"];
	[mEcoCodes setValue:@"Grunfeld Defense. Bg3 System" forKey:@"D93"];
	[mEcoCodes setValue:@"Grunfeld Defense. Closed Variation" forKey:@"D94"];
	[mEcoCodes setValue:@"Grunfeld Defense. Closed Variation" forKey:@"D95"];
	[mEcoCodes setValue:@"Grunfeld Defense. Russian Variation" forKey:@"D96"];
	[mEcoCodes setValue:@"Grunfeld Defense. Ragozin Variation (Classical)" forKey:@"D97"];
	[mEcoCodes setValue:@"Grunfeld Defense" forKey:@"D98"];
	[mEcoCodes setValue:@"Grunfeld Defense. Ragozin Variation (Smyslov)" forKey:@"D99"];
	[mEcoCodes setValue:@"Catalan Opening" forKey:@"E00"];
	[mEcoCodes setValue:@"Catalan Opening" forKey:@"E01"];
	[mEcoCodes setValue:@"Catalan Opening" forKey:@"E02"];
	[mEcoCodes setValue:@"Catalan Opening" forKey:@"E03"];
	[mEcoCodes setValue:@"Catalan Opening. Open Variation" forKey:@"E04"];
	[mEcoCodes setValue:@"Catalan Opening. Open Variation" forKey:@"E05"];
	[mEcoCodes setValue:@"Catalan Opening. Closed Variation" forKey:@"E06"];
	[mEcoCodes setValue:@"Catalan Opening. Closed Variation" forKey:@"E07"];
	[mEcoCodes setValue:@"Catalan Opening. Closed Variation" forKey:@"E08"];
	[mEcoCodes setValue:@"Catalan Opening. Closed Variation" forKey:@"E09"];
	[mEcoCodes setValue:@"Blumenfeld Gambit" forKey:@"E10"];
	[mEcoCodes setValue:@"Bogo-Indian Defense" forKey:@"E11"];
	[mEcoCodes setValue:@"Queen's Indian Defense" forKey:@"E12"];
	[mEcoCodes setValue:@"Queen's Indian Defense" forKey:@"E13"];
	[mEcoCodes setValue:@"Queen's Indian Defense" forKey:@"E14"];
	[mEcoCodes setValue:@"Queen's Indian Defense. Accelerated Fianchetto Variation" forKey:@"E15"];
	[mEcoCodes setValue:@"Queen's Indian Defense. Bogo Variation" forKey:@"E16"];
	[mEcoCodes setValue:@"Queen's Indian Defense" forKey:@"E17"];
	[mEcoCodes setValue:@"Queen's Indian Defense" forKey:@"E18"];
	[mEcoCodes setValue:@"Queen's Indian Defense" forKey:@"E19"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense" forKey:@"E20"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense" forKey:@"E21"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense" forKey:@"E22"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense" forKey:@"E23"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Saemisch Variation" forKey:@"E24"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Saemisch Variation" forKey:@"E25"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Saemisch Variation" forKey:@"E26"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Saemisch Variation" forKey:@"E27"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Saemisch Variation" forKey:@"E28"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Saemisch Variation" forKey:@"E29"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Leningrad Variation" forKey:@"E30"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Leningrad Variation" forKey:@"E31"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Classical Variation" forKey:@"E32"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Classical Variation" forKey:@"E33"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Classical Variation" forKey:@"E34"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Classical Variation" forKey:@"E35"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Classical Variation" forKey:@"E36"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Classical Variation" forKey:@"E37"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Classical Variation" forKey:@"E38"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Classical Variation" forKey:@"E39"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense" forKey:@"E40"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Huebner Variation" forKey:@"E41"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Huebner Variation" forKey:@"E42"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Nimzowitsch Variation" forKey:@"E43"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Nimzowitsch Variation" forKey:@"E44"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Nimzowitsch Variation" forKey:@"E45"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Nimzowitsch Variation" forKey:@"E46"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Rubinstein Variation" forKey:@"E47"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Rubinstein Variation" forKey:@"E48"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Rubinstein Variation" forKey:@"E49"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Modern Variation" forKey:@"E50"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Modern Variation" forKey:@"E51"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Modern Variation" forKey:@"E52"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Modern Variation" forKey:@"E53"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Modern Variation" forKey:@"E54"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Modern Variation" forKey:@"E55"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Modern Variation" forKey:@"E56"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Modern Variation" forKey:@"E57"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Modern Variation" forKey:@"E58"];
	[mEcoCodes setValue:@"Nimzo-Indian Defense. Modern Variation" forKey:@"E59"];
	[mEcoCodes setValue:@"King's Indian Defense" forKey:@"E60"];
	[mEcoCodes setValue:@"King's Indian Defense" forKey:@"E61"];
	[mEcoCodes setValue:@"King's Indian Defense. Fianchetto Variation. Panno System" forKey:@"E62"];
	[mEcoCodes setValue:@"King's Indian Defense. Fianchetto Variation. Panno System" forKey:@"E63"];
	[mEcoCodes setValue:@"King's Indian Defense. Fianchetto Variation" forKey:@"E64"];
	[mEcoCodes setValue:@"King's Indian Defense. Fianchetto Variation. Yugoslav System" forKey:@"E65"];
	[mEcoCodes setValue:@"King's Indian Defense. Fianchetto Variation. Yugoslav System" forKey:@"E66"];
	[mEcoCodes setValue:@"King's Indian Defense. Fianchetto Variation" forKey:@"E67"];
	[mEcoCodes setValue:@"King's Indian Defense. Fianchetto Variation" forKey:@"E68"];
	[mEcoCodes setValue:@"King's Indian Defense. Fianchetto Variation" forKey:@"E69"];
	[mEcoCodes setValue:@"King's Indian Defense. Fianchetto Variation" forKey:@"E70"];
	[mEcoCodes setValue:@"King's Indian Defense" forKey:@"E71"];
	[mEcoCodes setValue:@"King's Indian Defense" forKey:@"E72"];
	[mEcoCodes setValue:@"King's Indian Defense. Averbach Variation" forKey:@"E73"];
	[mEcoCodes setValue:@"King's Indian Defense. Averbach Variation" forKey:@"E74"];
	[mEcoCodes setValue:@"King's Indian Defense" forKey:@"E75"];
	[mEcoCodes setValue:@"King's Indian Defense. Four Pawns' Variation" forKey:@"E76"];
	[mEcoCodes setValue:@"King's Indian Defense. Four Pawns' Variation" forKey:@"E77"];
	[mEcoCodes setValue:@"King's Indian Defense. Four Pawns' Variation" forKey:@"E78"];
	[mEcoCodes setValue:@"King's Indian Defense. Four Pawns' Variation" forKey:@"E79"];
	[mEcoCodes setValue:@"King's Indian Defense. Classical Variation" forKey:@"E80"];
	[mEcoCodes setValue:@"King's Indian Defense. Classical Variation. Saemisch (Byrne) System" forKey:@"E81"];
	[mEcoCodes setValue:@"King's Indian Defense. Classical Variation" forKey:@"E82"];
	[mEcoCodes setValue:@"King's Indian Defense. Classical Variation. Panov System" forKey:@"E83"];
	[mEcoCodes setValue:@"King's Indian Defense. Classical Variation" forKey:@"E84"];
	[mEcoCodes setValue:@"King's Indian Defense. Classical Variation" forKey:@"E85"];
	[mEcoCodes setValue:@"King's Indian Defense. Classical Variation" forKey:@"E86"];
	[mEcoCodes setValue:@"King's Indian Defense. Classical Variation" forKey:@"E87"];
	[mEcoCodes setValue:@"King's Indian Defense. Classical Variation" forKey:@"E88"];
	[mEcoCodes setValue:@"King's Indian Defense. Classical Variation" forKey:@"E89"];
	[mEcoCodes setValue:@"King's Indian Defense" forKey:@"E90"];
	[mEcoCodes setValue:@"King's Indian Defense" forKey:@"E91"];
	[mEcoCodes setValue:@"King's Indian Defense. Exchange Variation" forKey:@"E92"];
	[mEcoCodes setValue:@"King's Indian Defense. Petrosian Variation" forKey:@"E93"];
	[mEcoCodes setValue:@"King's Indian Defense" forKey:@"E94"];
	[mEcoCodes setValue:@"King's Indian Defense" forKey:@"E95"];
	[mEcoCodes setValue:@"King's Indian Defense" forKey:@"E96"];
	[mEcoCodes setValue:@"King's Indian Defense" forKey:@"E97"];
	[mEcoCodes setValue:@"King's Indian Defense" forKey:@"E98"];
	[mEcoCodes setValue:@"King's Indian Defense" forKey:@"E99"];
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return [mGames count];
}

- (void)configureCell:(UITableViewCell*)cell forIndex:(int)index {
	
	NSDictionary *game = [mGames objectAtIndex:index];		
	UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 2, 220, 20)];
	label.text = [game valueForKey:@"White"];
	label.textAlignment = UITextAlignmentCenter;
	label.adjustsFontSizeToFitWidth = true;
	[cell.contentView addSubview:label];
	
	label = [[UILabel alloc] initWithFrame:CGRectMake(5, 21, 220, 20)];
	label.text = [game valueForKey:@"Black"];
	label.textAlignment = UITextAlignmentCenter;
	label.adjustsFontSizeToFitWidth = true;
	[cell.contentView addSubview:label];
	
	label = [[UILabel alloc] initWithFrame:CGRectMake(220, 2, 40, 40)];
	label.font = [UIFont boldSystemFontOfSize:16];
	label.text = [game valueForKey:@"Result"];
	label.textAlignment = UITextAlignmentCenter;
	label.adjustsFontSizeToFitWidth = true;
	[cell.contentView addSubview:label];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
	UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:nil];
	cell.selectionStyle = UITableViewCellSelectionStyleBlue;
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	[self configureCell:cell forIndex:[indexPath indexAtPosition:1]];
	return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	ChessGame *game = [mGames objectAtIndex:[indexPath indexAtPosition:1]];
	[[NSNotificationCenter defaultCenter] postNotificationName:LoadGameNotification object:game];
}

@end
