//
//  TurnCell.mm
//  vChess
//
//  Created by Sergey Seitov on 12/12/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import "TurnCell.h"


@implementation TurnCell

- (id)initCell:(NSString*)pgn withFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		text = [[NSString alloc] initWithString:pgn];
		self.selected = NO;
		self.backgroundColor = [UIColor clearColor];
		self.opaque = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	
	UIBezierPath *back = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:10.0];
	if (selected) {
		[[UIColor darkGrayColor] setFill];
	} else {
		[[UIColor clearColor] setFill];
	}
	[back fill];
	if (selected) {
		[[UIColor whiteColor] setFill];
	} else {
		[[UIColor blackColor] setFill];
	}
	rect.origin.y += 5;
	[text drawInRect:rect withFont:[UIFont fontWithName:@"Verdana-Bold" size:16]
	   lineBreakMode:UILineBreakModeClip alignment:UITextAlignmentCenter];
}

- (void)setSelected:(BOOL)bSelected {
	
	selected = bSelected;
	[self setNeedsDisplay];
}

@end
