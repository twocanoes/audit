//
//  Controller.m
//  Audit Reader
//
//  Created by Timothy Perfitt on 10/24/09.
//  Copyright 2013 Twocanoes Software. All rights reserved.
//

#import "Controller.h"
 

@implementation Controller

-(void)awakeFromNib{
    
    isRunning=NO;
    partial=[NSMutableString string];
    [partial retain];
    [predicateEditor addRow:self];
            
   // [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(rulesUpdated:) name:NSRuleEditorRowsDidChangeNotification object:nil];

    tokens=[NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"AuditTokens" ofType:@"plist"]];
    [tokens retain];
    
    
	//[resultsOutlineView setSortDescriptors:[NSArray arrayWithObjects:[[[NSSortDescriptor alloc] initWithKey:@"event" ascending:YES] autorelease],
       //                            [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES] autorelease],
         //                          nil]];
    

    //[self startTaskWithFilter:[predicateEditor predicate]];
    [lockView setDelegate:self];
    [lockView setString:"system.privilege.admin"];
    [lockView setAutoupdate:YES];
    [lockView updateStatus:self];
    

    
}
    

-(void)rulesUpdated:(id)sender{
    
    
    if (predicateEditor) [self startTask];
}
-(void)startTask{
    
    NSString *startDateString=nil;
    NSString *endDateString=nil;
    NSString *eventString=nil;
    NSString *dateEventOccurred=nil;
    NSString *effectiveUserIdString=nil;
    NSString *effectiveGroupIdString=nil;
    
    NSMutableString *argString=[NSMutableString string];
    NSArray *predicates=[(NSCompoundPredicate *)([predicateEditor predicate]) subpredicates];
    
    NSString *modifier;
    if ([showSuccess state]==YES && [showFailed state]==YES) modifier=@"";
    else if ([showSuccess state]==YES) modifier=@"+";
    else modifier=@"-";
    for (NSComparisonPredicate *curPred in predicates) {
        
        NSString *leftSide=[[curPred leftExpression] keyPath];

        NSString *rightSide=[[curPred rightExpression] constantValue];
        if (!leftSide) continue;
        if ([leftSide isEqualToString:@"Start Date"]) {
            NSDate *startDate=(NSDate *)rightSide;
            startDateString=[startDate descriptionWithCalendarFormat:@"%Y%m%d" timeZone:nil locale:nil];
            [argString appendString:[NSString stringWithFormat:@"-a %@ ",startDateString]];
            
        }
        else if ([leftSide isEqualToString:@"End Date"]) {
            NSDate *endDate=(NSDate *)rightSide;
            endDateString=[endDate descriptionWithCalendarFormat:@"%Y%m%d" timeZone:nil locale:nil];
            [argString appendString:[NSString stringWithFormat:@"-b %@ ",endDateString]];

        }
        else if ([leftSide isEqualToString:@"Event"]) {
            
            eventString=rightSide;
            [argString appendString:[NSString stringWithFormat:@"-c %@\"%@\" ",modifier,eventString]];

        }
        else if ([leftSide isEqualToString:@"Date Event Occurred"]) {
            NSDate *onDate=(NSDate *)rightSide;
            dateEventOccurred=[onDate descriptionWithCalendarFormat:@"%Y%m%d" timeZone:nil locale:nil];
            [argString appendString:[NSString stringWithFormat:@"-d %@ ",dateEventOccurred]];

            
        }
        else if ([leftSide isEqualToString:@"Effective user ID or name"]) {
            effectiveUserIdString=rightSide; 
            [argString appendString:[NSString stringWithFormat:@"-e \"%@\" ",effectiveUserIdString]];

        }
        else if ([leftSide isEqualToString:@"Effective Group ID or name"]) {
            effectiveGroupIdString=rightSide;
            [argString appendString:[NSString stringWithFormat:@"-f \"%@\" ",effectiveGroupIdString]];

        }
        
    }
    
  /*  if (task) {
        [task terminate];
        [task release];
    }
    
    NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(fileDataReceived:) name:NSFileHandleDataAvailableNotification object:nil];

    NSPipe *pipe=[NSPipe pipe];
    NSFileHandle *fh=[pipe fileHandleForReading];
    [fh waitForDataInBackgroundAndNotify];
    task=[[NSTask alloc] init];
    NSString *args=[NSString stringWithFormat:@"/usr/sbin/auditreduce %@ /var/audit/*|/usr/sbin/praudit -d \"|\"",argString];    

    [task setArguments:[NSArray arrayWithObjects:@"-c",args,nil]];
    [task setLaunchPath:@"/bin/sh"];
    [task setStandardOutput:pipe];
    [task launch];
   */
    NSNotificationCenter *nc=[NSNotificationCenter defaultCenter];
    [nc addObserver:self selector:@selector(fileDataReceived:) name:NSFileHandleDataAvailableNotification object:nil];


    NSString *args=[NSString stringWithFormat:@"echo pid $$ end && /usr/sbin/auditreduce %@ /var/audit/*|/usr/sbin/praudit -d \"|\"",argString];
    const char *argsCstring=[args UTF8String];
    const char *pathToTool="/bin/sh";
    AuthorizationFlags flags = kAuthorizationFlagDefaults |
    kAuthorizationFlagInteractionAllowed |
    kAuthorizationFlagPreAuthorize |
    kAuthorizationFlagExtendRights;
    FILE *communicationsPipe=NULL;
    
    char *arguments[3]={"-c",(char *)argsCstring};
    authorization=[[lockView authorization] authorizationRef];
    AuthorizationItem right = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights rights = {1, &right};
    
    OSStatus status;
    // Call AuthorizationCopyRights to determine or extend the allowable rights.
    status = AuthorizationCopyRights(authorization, &rights, NULL, flags, NULL);
    if (status != errAuthorizationSuccess) {
        NSLog(@"Copy Rights Unsuccessful: %d", status);
        return;
    }
    
    isRunning=YES;
    AuthorizationExecuteWithPrivileges (
                                        authorization,
                                        pathToTool,
                                        kAuthorizationFlagDefaults,
                                        arguments,
                                        &communicationsPipe);
    

    
    NSFileHandle *fh=[[NSFileHandle alloc] initWithFileDescriptor:fileno(communicationsPipe) closeOnDealloc:YES];
    
    [fh waitForDataInBackgroundAndNotify];
    
    
    NSMutableString *processListing=[NSMutableString string];
    FILE *pidFileRef=popen("/bin/ps axwwopid,command", "r");
    char data[255];
    
    while (fgets(data, 255, pidFileRef)) {
        
        [processListing appendString:[NSString stringWithUTF8String:data]];

    }
    
    NSArray *lines=[processListing componentsSeparatedByString:@"\n"];
    
    for (NSString *curLine in lines) {
        NSArray *commands=[curLine componentsSeparatedByString:@" "];
        
        if (([commands count]>1) && [[commands objectAtIndex:1] hasPrefix:@"/usr/sbin/auditreduce"]) 
            pid=[[commands objectAtIndex:0] intValue];
    }                        

    NSLog(@"pid is %i",pid);
}
-(void)fileDataReceived:(NSNotification *)notification{
    


    NSMutableDictionary *newEntry=nil;
    BOOL completed=NO;

    NSFileHandle *fh=[notification object];
    NSData *data=[fh availableData];
    if ([data length]==0) {
        [startStopButton setTitle:@"Search"];
        isRunning=NO;
        [[NSNotificationCenter defaultCenter] removeObserver:self name:NSFileHandleDataAvailableNotification object:nil];
    }
    NSArray *currToken;
    NSMutableArray *currentRecordTokens=[NSMutableArray arrayWithCapacity:10];
    NSString *output=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSMutableArray *objectsToInsert=[NSMutableArray array];
    [output autorelease];
    if (![partial isEqualToString:@""]) 
        output=[partial stringByAppendingString:output];
    [partial setString:@""];
    NSArray *record=[output componentsSeparatedByString:@"\n"];


    for (NSString *currString in record) {
      // if (![partial isEqualToString:@""]) [partial appendString:@"\n"];
        [partial appendString:currString];
        NSArray *recordArray=[currString componentsSeparatedByString:@"|"];
        NSString *command=[[recordArray objectAtIndex:0] stringByReplacingOccurrencesOfString:@" " withString:@""];
        if ([command isEqualToString:@""]) continue;
        if ([command isEqualToString:@"header"]) {
            
            if (newEntry && currentRecordTokens) {

                [newEntry setObject:currentRecordTokens forKey:@"children"];
                [objectsToInsert addObject:newEntry];

                currentRecordTokens=[NSMutableArray arrayWithCapacity:10];
            }

            if ([recordArray count]>5) {
                newEntry=[NSMutableDictionary dictionaryWithObjectsAndKeys:[recordArray objectAtIndex:3],@"record",
                                    [recordArray objectAtIndex:5],@"time",nil];
                completed=NO;
            }
            else newEntry=nil;

            
        } else if (currToken=[tokens objectForKey:command]) {
            int i;

            NSMutableArray *attributeArray=[NSMutableArray arrayWithCapacity:[recordArray count]];
            NSDictionary *attributeHeader;

            for (i=1;i<[recordArray count];i++) {
                if (([currToken count]>i) && ([recordArray count]>i)) {
                    NSDictionary *currAttributeDict=[NSDictionary dictionaryWithObjectsAndKeys:[currToken objectAtIndex:i],@"record",
                                                     [recordArray objectAtIndex:i],@"time",nil];
                    [attributeArray addObject:currAttributeDict];
                }

                
            }
            attributeHeader=[NSDictionary dictionaryWithObjectsAndKeys:command,@"record",[currToken objectAtIndex:0],@"time",
                             attributeArray,@"children",nil];
            
            [currentRecordTokens addObject:attributeHeader];
            if ([command isEqualToString:@"return"] && [attributeArray count]>0) {
                [newEntry setObject:[[attributeArray objectAtIndex:0] valueForKey:@"time"] forKey:@"status"];
                
            }
            else if ([command isEqualToString:@"trailer"] && [attributeArray count]>0) {
                [newEntry setObject:[partial lowercaseString] forKey:@"searchString"];
                [partial setString:@""];
                completed=YES;
            }
        }

            
    }

    if (newEntry && completed==YES) {
        [newEntry setObject:currentRecordTokens forKey:@"children"];
        [datasource addObjectAtRoot:newEntry];
    }
    if (objectsToInsert) {
       // int insertHere=[[[treeController arrangedObjects] childNodes] count];
        for (id curObject in objectsToInsert) 
            [datasource addObjectAtRoot:curObject];

        [resultsOutlineView reloadData];

    }

    [fh waitForDataInBackgroundAndNotify];
}
-(IBAction)searchButtonPressed:(id)sender{
    
    if (isRunning==YES) {
        isRunning=NO;
        [self killChildren];
        [startStopButton setTitle:@"Search"];
        return;
    }
    
    [datasource deleteAll];
    [resultsOutlineView reloadData];
    [startStopButton setTitle:@"Stop"];

    if (predicateEditor) [self startTask];
}

-(void)killChildren{
    const char *args=[[NSString stringWithFormat:@"%i",pid] UTF8String];
    const char *pathToTool="/bin/kill";
    AuthorizationFlags flags = kAuthorizationFlagDefaults |
    kAuthorizationFlagInteractionAllowed |
    kAuthorizationFlagPreAuthorize |
    kAuthorizationFlagExtendRights;
    
    char *arguments[2]={(char *)args};
    authorization=[[lockView authorization] authorizationRef];

    AuthorizationItem right = {kAuthorizationRightExecute, 0, NULL, 0};
    AuthorizationRights rights = {1, &right};
    
    OSStatus status;
    // Call AuthorizationCopyRights to determine or extend the allowable rights.
    status = AuthorizationCopyRights(authorization, &rights, NULL, flags, NULL);
    if (status != errAuthorizationSuccess) {
        NSLog(@"Copy Rights Unsuccessful: %d", status);
        return;
    }
    
    isRunning=NO;
    
    NSLog(@"killing children");
    AuthorizationExecuteWithPrivileges (
                                        authorization,
                                        pathToTool,
                                        kAuthorizationFlagDefaults,
                                        arguments,
                                        NULL);
    isRunning=NO;
    NSLog(@"done");
    
    
}
- (void)outlineView:(NSOutlineView *)outlineView sortDescriptorsDidChange:(NSArray *)oldDescriptors{
    NSLog(@"  outlineView"); 
}

-(void)setAuthorizationRef:(AuthorizationRef)ref{
    
    authorization=ref;
    

    
}
- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors{
    NSLog(@"  tableView"); 

}

- (void)authorizationViewDidAuthorize:(SFAuthorizationView *)view{
    
    
    [self setAuthorizationRef:[[lockView authorization] authorizationRef]];

    
    
    
    
}

-(void)dealloc{

    
    [super dealloc];
}
@end
