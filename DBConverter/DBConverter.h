//
//  DBConverter.h
//  DBConverter
//
//  Created by Sergey Seitov on 7/1/10.
//  Copyright 2010 Progorod Ltd. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface DBConverter : NSObject {

	IBOutlet NSButton *button;
	IBOutlet NSProgressIndicator *progress;
}

- (IBAction)openPGN:(id)sender;

@end
