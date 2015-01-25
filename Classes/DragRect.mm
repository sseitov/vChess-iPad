//
//  DragRect.mm
//  vChess
//
//  Created by Sergey Seitov on 18.02.11.
//  Copyright 2011 V-Channel. All rights reserved.
//

#import "DragRect.h"


@implementation DragRect


- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0 green:200.0/255.0 blue:0 alpha:1.0].CGColor);
	CGContextStrokeRectWithWidth(context, rect, 10);
}


@end
