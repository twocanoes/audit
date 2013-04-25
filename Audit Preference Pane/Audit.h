//
//  BSMPref.h
//  BSM
//
//  Created by Timothy Perfitt.
//  Copyright (c)  Twocanoes Software. All rights reserved.
//
#import <AppKit/AppKit.h>

#import <PreferencePanes/PreferencePanes.h>
#import <SecurityInterface/SFAuthorizationView.h>
#import "UserTypesModel.h"
#import "EventTypesModel.h"
#import "EventsModel.h"
@interface Audit : NSPreferencePane 
{
    
    IBOutlet NSView *customMainView;
    IBOutlet NSArrayController * eventsController;
    IBOutlet NSController * settingsController;
    IBOutlet NSWindow * loggingOptionsWindow;
    IBOutlet NSWindow * execOptionsWindow;
    IBOutlet NSWindow * unautheniticatedView;
    IBOutlet NSPopUpButton *presetPopup;
    IBOutlet NSTableView *policyTableView;


    NSMutableDictionary *eventHashLookup;
    IBOutlet SFAuthorizationView *lockView;
    BOOL hasUnchangedSettings;

    IBOutlet NSWindow *mainWindow;
    IBOutlet NSView *authorizedView;
    IBOutlet NSView *unauthorizedView;


    IBOutlet EventTypesModel *eventTypesModel;
    IBOutlet EventsModel *eventsModel;

}

@property (assign) BOOL hasUnchangedSettings;

-(IBAction)applySettings:(id)sender;
-(IBAction)popupChanged:(id)sender;
-(IBAction)revertSettings:(id)sender;

- (void) mainViewDidLoad;
-(IBAction)addEvent:(id)sender;
-(IBAction)popupPresets:(id)sender;
-(void)deleteEvents:(id)sender;
-(IBAction)showLoggingView:(id)sender;
-(IBAction)showExecView:(id)sender;
-(IBAction)dismissLoggingSheet:(id)sender;
-(IBAction)dismissExecSheet:(id)sender;





-(void)updateViewsToAuthorize:(BOOL)shouldAuthorize;
@end
