//
//  UserTypes Model.m
//  BSM
//
//  Created by Timothy Perfitt.
//  Copyright  Twocanoes Software. All rights reserved.
//

#import "UserTypesModel.h"


@implementation UserTypesModel
@synthesize userTypes;
- (id) init{

    if (self=[super init]) {
        [self setUserTypes:[NSArray arrayWithObjects:[NSDictionary dictionaryWithObject:@"All Users" forKey:@"userType"]
                        ,[NSDictionary dictionaryWithObject:@"Not Attributed to Specific User" forKey:@"userType"],
                        nil]];
    
    }
    return self;
}    
@end
