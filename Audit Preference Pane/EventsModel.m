//
//  EventsModel.m
//  BSM
//
//  Created by Timothy Perfitt.
//  Copyright  Twocanoes Software. All rights reserved.
//

#import "EventsModel.h"


@implementation EventsModel
@synthesize settings;
@synthesize policies;


-(id)init{
    if (self=[super init]) {
        
        policies=[[NSMutableArray alloc] init];
        settings=[NSMutableDictionary dictionaryWithCapacity:10];
        [self readSettingsFromFile];
        authorization=nil;
    }
    return self;
}

-(void)setAuthorizationRef:(AuthorizationRef)ref{
    
    authorization=ref;

    [self readSettingsFromFile];

}


-(NSString *)auditControlFileContents{

   // AuthorizationRef authorization=[[lockView authorization] authorizationRef];
    if (authorization==nil)  {
        return @"";
    }

    const char *pathToTool="/bin/cat";
    AuthorizationFlags flags = kAuthorizationFlagDefaults |
    kAuthorizationFlagInteractionAllowed |
    kAuthorizationFlagPreAuthorize |
    kAuthorizationFlagExtendRights;
    FILE *communicationsPipe=NULL;
    
    char *arguments[1]={"/etc/security/audit_control"};
    AuthorizationItem right = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights rights = {1, &right};
    
    OSStatus status;
    // Call AuthorizationCopyRights to determine or extend the allowable rights.
    status = AuthorizationCopyRights(authorization, &rights, NULL, flags, NULL);
    if (status != errAuthorizationSuccess)
        NSLog(@"Copy Rights Unsuccessful: %ld", status);
    
    
    AuthorizationExecuteWithPrivileges (
                                        authorization,
                                        pathToTool,
                                        kAuthorizationFlagDefaults,
                                        arguments,
                                        &communicationsPipe);
    
    
    NSFileHandle *fh=[[NSFileHandle alloc] initWithFileDescriptor:fileno(communicationsPipe) closeOnDealloc:YES];
    
    [fh autorelease];
    NSData *data=[fh readDataToEndOfFile];
    NSString *string=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    [string autorelease];
    return string;
    
    
    
}

-(void)revert{
    
    [self setSettings:[NSMutableDictionary dictionaryWithCapacity:10]];
    [self readSettingsFromFile];
}


-(void)readSettingsFromFile{

    
    [[self mutableArrayValueForKey:@"policies"] removeAllObjects];
    
    
    NSString *fileContents=[self auditControlFileContents];
    
    NSArray *lines=[fileContents componentsSeparatedByString:@"\n"];
    
    for (NSString *currentLine in lines) {
        if (([currentLine length]==0) || [currentLine hasPrefix:@"#"]) continue; //skip comments and blank lines.
        NSArray *linePieces=[currentLine componentsSeparatedByString:@":"];
        if ([linePieces count]<2) continue;  // not valid line
        
        NSString *key=[linePieces objectAtIndex:0];
        NSString *value=[linePieces objectAtIndex:1];
        
        if ([key isEqualToString:@"dir"]) {
            
            [settings setValue:value forKey:@"logFilePath"];
        }
        else if ([key isEqualToString:@"host"]) [settings setValue:value forKey:@"host"];
        else if ([key isEqualToString:@"filesz"]) {
            if ([value intValue]==0) [settings setValue:@"Do not rotate" forKey:@"rotateLogsLevel"];   
            else [settings setValue:value forKey:@"rotateLogsLevel"];   
        }
        else if ([key isEqualToString:@"expire-after"]) [settings setValue:value forKey:@"expireAfter"];
        else if ([key isEqualToString:@"minfree"]) [settings setValue:value forKey:@"diskSizeWarningLevel"];
        else if ([key isEqualToString:@"policy"]){
            NSArray *policyArray=[value componentsSeparatedByString:@","];
            for (NSString *curPolicy in policyArray) {
                
                NSString *cleanupPolicy=[curPolicy stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
                
                if ([cleanupPolicy isEqualToString:@"argv"]) 
                    [settings setValue:[NSNumber numberWithBool:YES] forKey:@"auditExecCLI"];
                else if ([cleanupPolicy isEqualToString:@"arge"]) 
                    [settings setValue:[NSNumber numberWithBool:YES] forKey:@"auditExecEnvArgs"];
                else if ([[curPolicy stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@"cnt"]) 
                    [settings setValue:[NSNumber numberWithBool:NO] forKey:@"haltIfCannotAudit"];
                else if ([[curPolicy stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] isEqualToString:@"ahlt"]) 
                    [settings setValue:[NSNumber numberWithBool:YES] forKey:@"haltIfCannotAudit"];
                
            }
            
        }
        else if ([key isEqualToString:@"flags"]){
            
            NSArray *flags=[value componentsSeparatedByString:@","];
            for (NSMutableString *curFlag in flags) {
                NSMutableDictionary *newEntry=[self entryForFlags:curFlag];
                [newEntry setValue:@"All Users" forKey:@"user"];
                [[self mutableArrayValueForKey:@"policies"] addObject:newEntry];

            }
            
        }
        else if ([key isEqualToString:@"naflags"]){
            NSArray *flags=[value componentsSeparatedByString:@","];
            for (NSMutableString *curFlag in flags) {
                NSMutableDictionary *newEntry=[self entryForFlags:curFlag];
                [newEntry setValue:@"Not Attributed to Specific User" forKey:@"user"];
                [[self mutableArrayValueForKey:@"policies"] addObject:newEntry];
            }
            
        }
        
        
        
    }

}
-(void)save{
    
   
    const char *pathToTool="/usr/bin/tee";
    AuthorizationFlags flags = kAuthorizationFlagDefaults |
    kAuthorizationFlagInteractionAllowed |
    kAuthorizationFlagPreAuthorize |
    kAuthorizationFlagExtendRights;
    FILE *communicationsPipe=NULL;
    
    char *arguments[2]={"/etc/security/audit_control"};
    AuthorizationItem right = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights rights = {1, &right};
    
    OSStatus status;
    // Call AuthorizationCopyRights to determine or extend the allowable rights.
    status = AuthorizationCopyRights(authorization, &rights, NULL, flags, NULL);
    if (status != errAuthorizationSuccess)
        NSLog(@"Copy Rights Unsuccessful: %d", status);
    
    
    AuthorizationExecuteWithPrivileges (
                                        authorization,
                                        pathToTool,
                                        kAuthorizationFlagDefaults,
                                        arguments,
                                        &communicationsPipe);
    
    
    NSFileHandle *fh=[[NSFileHandle alloc] initWithFileDescriptor:fileno(communicationsPipe) closeOnDealloc:YES];
    
    [fh autorelease];
    [fh writeData:[[self outputString] dataUsingEncoding:NSUTF8StringEncoding]];
    
    NSRunInformationalAlertPanel(@"Restart May Be Required", 
                                 @"Any changes to audit rules may require a restart to take affect.", 
                                 @"OK",  nil,nil);
    
}
-(NSString *)outputString{
    
    NSMutableString *outputString=[NSMutableString stringWithString:@"####Created with BSM System Preference Pane####\n\n"];
    
    NSMutableArray *flags=[NSMutableArray arrayWithCapacity:2];
    NSMutableArray *naflags=[NSMutableArray arrayWithCapacity:2];
    NSMutableArray *policy=[NSMutableArray arrayWithCapacity:2];
    
    
    
   
    NSString *currString;
    if (currString=[settings valueForKey:@"logFilePath"]) {
        [outputString appendString:[NSString stringWithFormat:@"dir:%@\n",currString]];
    }
    
    if (currString=[settings valueForKey:@"host"]) {
        [outputString appendString:[NSString stringWithFormat:@"host:%@\n",currString]];
    }
    else [outputString appendString:@"host:localhost"];
    
    if (currString=[settings valueForKey:@"diskSizeWarningLevel"]) {
        [outputString appendString:[NSString stringWithFormat:@"minfree:%@\n",currString]];
    }
    
    if (currString=[settings valueForKey:@"expireAfter"]) {
        [outputString appendString:[NSString stringWithFormat:@"expire-after:%@\n",currString]];
    }
    
    if (currString=[settings valueForKey:@"rotateLogsLevel"]) {
        if ([currString isEqualToString:@"Do not rotate"])
            [outputString appendString:@"filesz:0\n"];
        else
            [outputString appendString:[NSString stringWithFormat:@"filesz:%@\n",currString]];
    }
    
    if ([[settings valueForKey:@"auditExecEnvArgs"] boolValue]==YES){
        [policy addObject:[NSString stringWithFormat:@"argv",currString]];
    }    
    if ([[settings valueForKey:@"auditExecEnvArgs"] boolValue]==YES) {
        [policy addObject:@"arge"];
    }  
    
    if ([[settings valueForKey:@"haltIfCannotAudit"] boolValue]==NO) {
        [policy addObject:@"cnt"];
    } 
    else {
        [policy addObject:@"ahlt"];
    }
    
    for (NSArray *currArray in policies) {
        if (![currArray valueForKey:@"event"] ) continue;
        if ([[currArray valueForKey:@"user"] isEqualToString:@"All Users"]) {
            
            
            NSString *mod=@"";
            if ([[currArray valueForKey:@"recordSuccessfulEvent"] boolValue]==YES && 
                [[currArray valueForKey:@"recordFailedEvent"] boolValue]==NO)
                mod=@"+";
            else  if ([[currArray valueForKey:@"recordSuccessfulEvent"] boolValue]==NO && 
                      [[currArray valueForKey:@"recordFailedEvent"] boolValue]==YES)
                mod=@"-";
            [flags addObject:[NSString stringWithFormat:@"%@%@",mod,[[currArray valueForKey:@"event"] valueForKey:@"code"]]];
        }
        else {
            
            
            NSString *mod=@"";
            if ([[currArray valueForKey:@"recordSuccessfulEvent"] boolValue]==YES && 
                [[currArray valueForKey:@"recordFailedEvent"] boolValue]==NO)
                mod=@"+";
            else  if ([[currArray valueForKey:@"recordSuccessfulEvent"] boolValue]==NO && 
                      [[currArray valueForKey:@"recordFailedEvent"] boolValue]==YES)
                mod=@"-";
            else  if ([[currArray valueForKey:@"recordSuccessfulEvent"] boolValue]==NO && 
                      [[currArray valueForKey:@"recordFailedEvent"] boolValue]==NO)
                mod=@"^";
            [naflags addObject:[NSString stringWithFormat:@"%@%@",mod,[[currArray valueForKey:@"event"] valueForKey:@"code"]]];
        }
    }
    
    
    [outputString appendString:[NSString stringWithFormat:@"policy:%@\n",[policy componentsJoinedByString:@","]]];
    if ([flags count]>0) {
        [outputString appendString:[NSString stringWithFormat:@"flags:%@\n",[flags componentsJoinedByString:@","]]];     
        
    }
    else [outputString appendString:@"flags:\n"];
    if ([naflags count]>0) {
        [outputString appendString:[NSString stringWithFormat:@"naflags:%@\n",[naflags componentsJoinedByString:@","]]];     
    }
    else [outputString appendString:@"naflags:\n"];
    
    return outputString;
}



-(NSMutableDictionary *)entryForFlags:(NSString *)flags{
    
    NSMutableString *cleanedupFlag=[NSMutableString stringWithString:[flags stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
    NSMutableDictionary *newEntry=[NSMutableDictionary dictionaryWithCapacity:4];
    
    if ([cleanedupFlag hasPrefix:@"+"]) [newEntry setValue:[NSNumber numberWithBool:YES] forKey:@"recordSuccessfulEvent"];
    else if ([cleanedupFlag hasPrefix:@"-"]) [newEntry setValue:[NSNumber numberWithBool:YES] forKey:@"recordFailedEvent"];
    
    if (([cleanedupFlag hasPrefix:@"^+"])||
        ([cleanedupFlag hasPrefix:@"^-"]) )  {
        [cleanedupFlag deleteCharactersInRange:NSMakeRange(0, 2)];
    }
    
    else if (([cleanedupFlag hasPrefix:@"+"])||
             ([cleanedupFlag hasPrefix:@"-"]) ||
             ([cleanedupFlag hasPrefix:@"^"]) ) {
        [cleanedupFlag deleteCharactersInRange:NSMakeRange(0, 1)];
    }
    else {
        [newEntry setValue:[NSNumber numberWithBool:YES] forKey:@"recordSuccessfulEvent"];
        [newEntry setValue:[NSNumber numberWithBool:YES] forKey:@"recordFailedEvent"];
    }
    [newEntry setValue:cleanedupFlag forKey:@"code"];
    [newEntry setValue:cleanedupFlag forKey:@"eventName"];
    
    [newEntry setValue:[[eventTypesModel eventHashLookup] valueForKey:cleanedupFlag] forKey:@"event"];
    
    
    return newEntry;
    
}

-(void)dealloc{
    [policies release];
    [super dealloc];
}
@end
