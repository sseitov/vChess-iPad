//
//  PanelView.mm
//  vChess
//
//  Created by Sergey Seitov on 01.12.10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import "PanelView.h"


@implementation PanelView

@synthesize bHorizontal;

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
		self.backgroundColor = [UIColor clearColor];
		self.bHorizontal = NO;
		self.bInvert = NO;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	
    CGContextRef context = UIGraphicsGetCurrentContext();
	
	// create bubble clip path
	CGFloat radius = 10.0;
	CGFloat minx = CGRectGetMinX(rect), midx = CGRectGetMidX(rect), maxx = CGRectGetMaxX(rect);
	CGFloat miny = CGRectGetMinY(rect), midy = CGRectGetMidY(rect), maxy = CGRectGetMaxY(rect);
	CGContextMoveToPoint(context, minx, midy);
	CGContextAddArcToPoint(context, minx, miny, midx, miny, radius);
	CGContextAddArcToPoint(context, maxx, miny, maxx, midy, radius);
	CGContextAddArcToPoint(context, maxx, maxy, midx, maxy, radius);
	CGContextAddArcToPoint(context, minx, maxy, minx, midy, radius);
	CGContextClosePath(context);
	
	// draw bubble with gradient
	CGContextSaveGState(context);
	CGContextClip(context);
	
	CGColorSpaceRef rgb = CGColorSpaceCreateDeviceRGB();
	CGGradientRef	gradient;
	if (self.bInvert) {
		CGFloat colors[] =
		{
			128.0 / 255.0, 128.0 / 255.0, 128.0 / 255.0, 1.00,
			164.0 / 255.0, 164.0 / 255.0, 164.0 / 255.0, 1.00,
			206.0 / 255.0, 206.0 / 255.0, 206.0 / 255.0, 1.00,
		};
		gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
	} else {
		CGFloat colors[] =
		{
			206.0 / 255.0, 206.0 / 255.0, 206.0 / 255.0, 1.00,
			164.0 / 255.0, 164.0 / 255.0, 164.0 / 255.0, 1.00,
			128.0 / 255.0, 128.0 / 255.0, 128.0 / 255.0, 1.00,
		};
		gradient = CGGradientCreateWithColorComponents(rgb, colors, NULL, sizeof(colors)/(sizeof(colors[0])*4));
	}
	if (bHorizontal) {
		CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(0, rect.size.height), 0);
	} else {
		CGContextDrawLinearGradient(context, gradient, CGPointMake(0, 0), CGPointMake(rect.size.width, 0), 0);
	}
	CGGradientRelease(gradient);
	CGColorSpaceRelease(rgb);
	
	CGContextRestoreGState(context);
}

@end
