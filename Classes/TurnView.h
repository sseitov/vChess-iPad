//
//  TurnView.h
//  vChess
//
//  Created by Sergey Seitov on 12/11/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PanelView.h"

#define TURNVIEW_HEIGHT 40

@class TurnCell;

@interface TurnView : PanelView {

	UILabel		*Number;
	TurnCell	*whiteButton;
	TurnCell	*blackButton;
}

@property (readonly) UILabel	*Number;
@property (readonly) TurnCell	*whiteButton;
@property (readonly) TurnCell	*blackButton;

- (id)initWithFrame:(CGRect)frame number:(int)number;
- (void)addWhite:(NSString*)turn interactive:(BOOL)interactive;
- (void)addBlack:(NSString*)turn interactive:(BOOL)interactive;

@end
