//
//  Controller.h
//  Audit Reader
//
//  Created by Timothy Perfitt on 10/24/09.
//  Copyright 2013 Twocanoes Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <Security/Security.h>
#import "AuditInfoDataSource.h"
#import <SecurityInterface/SFAuthorizationView.h>

@interface Controller : NSObject {

    IBOutlet id resultsOutlineView;

    NSDictionary *tokens;
    IBOutlet NSPredicateEditor *predicateEditor;
    NSTask *task;
    IBOutlet NSButton *showSuccess, *showFailed;
    NSMutableString *partial;
    IBOutlet AuditInfoDataSource *datasource;
    IBOutlet NSSearchField *searchField;
    AuthorizationRef authorization;
    IBOutlet SFAuthorizationView *lockView;

    IBOutlet NSButton *startStopButton;
    IBOutlet NSWindow *mainWindow;
    int pid;
    BOOL isRunning;
}

-(void)startTask;
-(void)killChildren;
-(IBAction)searchButtonPressed:(id)sender;
- (IBAction)updateFilter:sender;
@end
