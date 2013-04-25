//
//  Audit_ReaderAppDelegate.h
//  Audit Reader
//
//  Created by Timothy Perfitt on 10/24/09.
//  Copyright 2013 Twocanoes Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface Audit_ReaderAppDelegate : NSObject <NSApplicationDelegate> {
    NSWindow *window;
}

@property (assign) IBOutlet NSWindow *window;

@end
