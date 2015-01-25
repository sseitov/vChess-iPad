//
//  Desk.h
//  vChess
//
//  Created by Sergey Seitov on 1/26/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "vchess/game.h"

@class DeskRule;
@class LostFigures;
@class Figure;
@class DragRect;

enum PLAY_MODE {
	NOPLAY,
	PLAY_FORWARD,
	PLAY_BACKWARD
};

@interface Desk : UIView {
	
	UIImageView	*deskImage;
	DeskRule	*horzRule;
	DeskRule	*vertRule;
	
	LostFigures		*whiteLost;
	LostFigures		*blackLost;
	NSMutableArray	*figures;
	vchess::Game	*currentGame;
	
	Figure		*dragFigure;
	DragRect	*dragRect;
	CGPoint		dragStart;
	int			playMode;
	BOOL		rotated;
}

@property (readwrite) int	playMode;

- (CGPoint)cellCenterX:(int)x Y:(int)y;
- (CGPoint)lostCenterForColor:(int)color;

- (void)rotate:(BOOL)bRotate;
- (void)setGame:(vchess::Game*)game;
- (BOOL)turnForwardAnimated:(BOOL)animated;
- (BOOL)turnBackAnimated:(BOOL)animated;
- (void)moveFigure:(Figure*)f to:(NSNumber*)position;
- (void)setFigures:(NSArray*)theFigures toPos:(NSArray*)positions;
- (void)moveFigures:(NSArray*)theFigures toPos:(NSArray*)positions;
- (void)animateFigure:(Figure*)figure to:(CGPoint)pt;
- (Figure*)figureAt:(NSNumber*)position;
- (Figure*)figureFor:(unsigned char)model fromArray:(NSMutableArray*)array;
- (void)aliveFigure:(Figure*)f;
- (BOOL)makeTurn:(Figure*)figure from:(int)from to:(int)to animated:(BOOL)animated;

@end
