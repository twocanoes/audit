//
//  EventsModel.h
//  BSM
//
//  Created by Timothy Perfitt.
//  Copyright  Twocanoes Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "EventTypesModel.h"

@interface EventsModel : NSObject {
    NSMutableDictionary *settings;
    NSMutableArray *policies;
    IBOutlet EventTypesModel *eventTypesModel;
    AuthorizationRef authorization;
   
    
}
@property (retain)     NSMutableArray *policies;
@property (retain) NSMutableDictionary *settings;
-(void)setAuthorizationRef:(AuthorizationRef)ref;
-(void)revert;
-(void)readSettingsFromFile;
-(NSString *)auditControlFileContents;
-(NSMutableDictionary *)entryForFlags:(NSString *)flags;
-(void)save;
-(NSString *)outputString;
@end
