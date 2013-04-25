//
//  BSMPref.m
//  BSM
//
//  Created by Timothy Perfitt.
//  Copyright (c)  Twocanoes Software. All rights reserved.
//

#import "Audit.h"



@implementation Audit

@synthesize hasUnchangedSettings;



- (void)authorizationViewDidAuthorize:(SFAuthorizationView *)view{


    [eventsModel setAuthorizationRef:[[lockView authorization] authorizationRef]];
    [self updateViewsToAuthorize:YES];




}
-(void)updateViewsToAuthorize:(BOOL)shouldAuthorize{
    float authorizedViewHeight=[authorizedView frame].size.height;
    float unauthorizedViewHeight=[unauthorizedView frame].size.height;
    

    NSView *mainView=[self mainView];
    NSRect mainWindowRect=[[mainView window] frame];
    NSRect contentViewRect=[[[mainView window] contentView] frame];

    float titleBarHeight=mainWindowRect.size.height-contentViewRect.size.height;

    
    if (shouldAuthorize==YES) {
        [unauthorizedView retain];
        [unauthorizedView removeFromSuperview];
        [[mainView window] setFrame:NSMakeRect(mainWindowRect.origin.x, mainWindowRect.origin.y-(authorizedViewHeight-mainWindowRect.size.height+titleBarHeight), 
                                               mainWindowRect.size.width,
                                               authorizedViewHeight+titleBarHeight) display:YES animate:YES];
   
        [customMainView addSubview:authorizedView];

    }
    else {
        [authorizedView retain];
        [authorizedView removeFromSuperview];
        float titleBarHeight=mainWindowRect.size.height-contentViewRect.size.height;
        
        [[mainView window] setFrame:NSMakeRect(mainWindowRect.origin.x, mainWindowRect.origin.y+(authorizedViewHeight-unauthorizedViewHeight), 
                                               mainWindowRect.size.width,
                                               unauthorizedViewHeight+titleBarHeight) display:YES animate:YES];
        [mainView addSubview:unauthorizedView];
    }
    
    
}

- (void)authorizationViewDidDeauthorize:(SFAuthorizationView *)view{

    [self updateViewsToAuthorize:NO];
    

}

    
- (void) mainViewDidLoad{
    NSView *mainView=[self mainView];
    [mainView setAutoresizingMask:255];
    
    [lockView setDelegate:self];
    [lockView setString:"sys.openfile."];
    [lockView setAutoupdate:YES];
    [lockView updateStatus:self];

    
//    [eventsModel setAuthorizationRef:[[lockView authorization] authorizationRef]];


    
    [self setHasUnchangedSettings:NO];
}





-(void)addEvent:(id)sender{

    
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithObjectsAndKeys:
                               @"All Users",@"user",
                               [NSNumber numberWithBool:YES],@"recordSuccessfulEvent",
                              [NSNumber numberWithBool:YES],@"recordFailedEvent",
                               nil];
    [eventsController addObject:dict];
    [self setHasUnchangedSettings:YES];
    
}
-(void)deleteEvents:(id)sender{
    
    [eventsController removeObjects:[eventsController selectedObjects]];
    [self setHasUnchangedSettings:YES];
    

}


-(IBAction)showLoggingView:(id)sender{
    [NSApp beginSheet:loggingOptionsWindow modalForWindow:[[self mainView] window] modalDelegate:nil didEndSelector:nil
          contextInfo:nil];

}
-(IBAction)dismissLoggingSheet:(id)sender{
    [loggingOptionsWindow orderOut:self];
    [NSApp endSheet:loggingOptionsWindow];
   // [self setMainView:[unautheniticatedView contentView]];
//    [self assignMainView];

    
    
}


-(IBAction)applySettings:(id)sender{
    [eventsModel save];
    [self setHasUnchangedSettings:NO];
}
-(IBAction)revertSettings:(id)sender{

   // [self setSettings:[NSMutableDictionary dictionaryWithCapacity:10]];
    [eventsModel revert];
//    [self readSettingsFromFile];
    [self setHasUnchangedSettings:NO];
}
-(IBAction)popupChanged:(id)sender{
        [self setHasUnchangedSettings:YES];
}
-(IBAction)dismissExecSheet:(id)sender{
    [execOptionsWindow orderOut:self];
    [NSApp endSheet:execOptionsWindow];

    
}
-(IBAction)showExecView:(id)sender{
    [NSApp beginSheet:execOptionsWindow modalForWindow:[[self mainView] window] modalDelegate:nil didEndSelector:nil
          contextInfo:nil];
}
- (NSPreferencePaneUnselectReply)shouldUnselect{
    if (hasUnchangedSettings==YES) {
        int ret=NSRunAlertPanel(@"Exit without changes?", @"You have unsaved changes.  Do you want to commit or revert these changes?", @"Commit",  @"Cancel",@"Lose Changes");
        if (ret==NSOKButton) {
            [eventsModel save];
            [self setHasUnchangedSettings:NO];
        }
        else if (ret==NSAlertAlternateReturn) {

            return NSUnselectCancel;
        }
        else{
            [self revertSettings:self];
            [self setHasUnchangedSettings:NO];
            return NSUnselectNow;
        }
    }
    return NSUnselectNow;
}
-(IBAction)popupPresets:(id)sender{
    [[presetPopup cell] performClickWithFrame:[sender frame] inView:[sender superview]];     
}
-(void)dealloc{


    [super dealloc];
}
@end
