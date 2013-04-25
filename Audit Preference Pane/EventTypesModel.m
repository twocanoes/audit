//
//  EventTypesModel.m
//  BSM
//
//  Created by Timothy Perfitt.
//  Copyright  Twocanoes Software. All rights reserved.
//

#import "EventTypesModel.h"


@implementation EventTypesModel
@synthesize eventHashLookup;
-(NSArray *)eventClasses{
    
    if (!eventClasses) {
        [self setEventHashLookup:[NSMutableDictionary dictionaryWithCapacity:10]];
        NSMutableArray *returnArray=[NSMutableArray arrayWithCapacity:10];
        NSString *eventBlob=[NSString stringWithContentsOfFile:@"/etc/security/audit_class" 
                                                      encoding:NSUTF8StringEncoding error:nil];
        NSArray *eventBlobLines=[eventBlob componentsSeparatedByString:@"\n"];
        
        for (NSString *currLine in eventBlobLines) {
            NSArray *lineComponents=[currLine componentsSeparatedByString:@":"];
            if ([lineComponents count]==3) {
                NSString *code=[lineComponents objectAtIndex:1];
                NSString *eventName=[lineComponents objectAtIndex:2];
                NSDictionary *eventDictionary=[NSDictionary dictionaryWithObjectsAndKeys:code,@"code",eventName,@"eventName",nil];
                [[self eventHashLookup] setValue:eventDictionary forKey:code];
                [returnArray addObject:eventDictionary];
            }
        }
        //        [returnArray sortUsingSelector:@selector(caseInsensitiveCompare:)];
        eventClasses=[NSArray arrayWithArray:returnArray];
        
    }
    return eventClasses;
}

-(void)dealloc{
    [eventClasses release];
    [super dealloc];
 
}
@end
