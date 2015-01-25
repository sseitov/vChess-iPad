//
//  TurnCell.h
//  vChess
//
//  Created by Sergey Seitov on 12/12/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TurnCell : UIView {
	
	NSString *text;
	BOOL selected;
}

- (id)initCell:(NSString*)pgn withFrame:(CGRect)frame;
- (void)setSelected:(BOOL)bSelected;

@end
