//
//  EventTypesModel.h
//  BSM
//
//  Created by Timothy Perfitt.
//  Copyright  Twocanoes Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@interface EventTypesModel : NSObject {
    NSMutableArray *eventClasses;
    NSMutableDictionary *eventHashLookup;
}
@property (retain) NSMutableDictionary *eventHashLookup;
@end
