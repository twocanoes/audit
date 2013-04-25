//
//  AuditInfoDataSource.m
//  Audit Reader
//
//  Created by Tim Perfitt on 3/11/10.
//  Copyright 2013 Twocanoes Software, Inc. All rights reserved.
//

#import "AuditInfoDataSource.h"


@implementation AuditInfoDataSource
-(void)awakeFromNib{
    [self setFilteredTree:nil];;
    tree=[NSMutableDictionary dictionary];
    [tree retain];
    [tree setObject:[NSMutableArray array] forKey:@"children"];
}
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item{
    NSDictionary *currDict=(filteredTree==nil)?tree:filteredTree;

    if (item==nil) return [[currDict objectForKey:@"children"] objectAtIndex:index];

    return [[item objectForKey:@"children"] objectAtIndex:index];
}
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item{
    if ([item objectForKey:@"children"] && [[item objectForKey:@"children"] count]>0) return YES;
    return NO;
}
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item{
    NSDictionary *currDict=(filteredTree==nil)?tree:filteredTree;

    if (item==nil) return [[currDict objectForKey:@"children"] count];
    if ([item objectForKey:@"children"]) return [[item objectForKey:@"children"] count];
    return NO;
}
- (NSInteger)numberOfRowsInTableView:(NSTableView *)aTableView{
    NSDictionary *currDict=(filteredTree==nil)?tree:filteredTree;

    return [[currDict objectForKey:@"children"] count];
    
    
}

- (id)tableView:(NSTableView *)aTableView objectValueForTableColumn:(NSTableColumn *)aTableColumn row:(NSInteger)rowIndex{
    //NSLog(@"id is %@",[aTableColumn identifier]);

    NSDictionary *currDict=(filteredTree==nil)?tree:filteredTree;
  //  NSLog(@"%@",[[[currDict objectForKey:@"children"] objectAtIndex:rowIndex]valueForKey:[aTableColumn identifier]]);
    return [[[currDict objectForKey:@"children"] objectAtIndex:rowIndex]valueForKey:[aTableColumn identifier]];
    
}
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item{
    NSDictionary *currDict=(filteredTree==nil)?tree:filteredTree;

    if (item==nil) {
        return [currDict valueForKey:[tableColumn identifier]];
        
    }
    return [item valueForKey:[tableColumn identifier]];
}

-(void)addObjectAtRoot:(id)object{
    NSMutableArray *children=[tree objectForKey:@"children"];
    [children addObject:object];
    
    
}
-(void)deleteAll{
    [tree removeAllObjects];
    [tree setObject:[NSMutableArray array] forKey:@"children"];

}
- (void)tableView:(NSTableView *)aTableView sortDescriptorsDidChange:(NSArray *)oldDescriptors{
    NSLog(@"  tableView"); 
    
}
- (void)outlineView:(NSOutlineView *)outlineView sortDescriptorsDidChange:(NSArray *)oldDescriptors{
    NSSortDescriptor *sortDescriptor;
    NSString *key=[[[outlineView sortDescriptors] objectAtIndex:0] key];
    BOOL isAscending=[[[outlineView sortDescriptors] objectAtIndex:0] ascending];
    sortDescriptor = [[[NSSortDescriptor alloc] initWithKey:key
        
                                                  ascending:isAscending] autorelease];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray;
    NSMutableArray *currChildren=[tree objectForKey:@"children"];
    sortedArray = [currChildren sortedArrayUsingDescriptors:sortDescriptors];
    [tree setObject:sortedArray forKey:@"children"];
    [outlineView reloadData];
}

-(IBAction)filterWithString:(id)sender{

    NSLog(@"filter");
    NSString *inFilter=[sender stringValue];
    if ([inFilter isEqualToString:@""]) {
        [self setFilteredTree:nil];
        [dataOutlineView reloadData];
        return;
    }
    else {
        [self setFilteredTree:[NSMutableDictionary dictionary]];
        
    }
    NSArray *children=[tree objectForKey:@"children"];
    NSMutableArray *filteredChildren=[NSMutableArray array];
    for (NSDictionary *curEntry in children) {
        NSString *curSearchBlob=[curEntry objectForKey:@"searchString"];
        if ([curSearchBlob rangeOfString:[inFilter lowercaseString]].length!=0) { // found
            [filteredChildren addObject:curEntry];
        }
        
    }
    [filteredTree setObject:filteredChildren forKey:@"children"];
    [dataOutlineView reloadData];
    
    
}
-(void)setFilteredTree:(NSMutableDictionary *)inDict{
    
    [inDict retain];
    [filteredTree release];
    filteredTree=inDict;
    
    
}
-(void)dealloc{
    [tree release];
    [super dealloc];
}
-(void)compare:(id)sender{
    
    
    NSLog(@"compare");
}

@end
