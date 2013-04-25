//
//  AuditInfoDataSource.h
//  Audit Reader
//
//  Created by Tim Perfitt on 3/11/10.
//  Copyright 2013 Twocanoes Software, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface AuditInfoDataSource : NSObject <NSTableViewDataSource> {

    NSMutableDictionary *tree;
    NSMutableDictionary *filteredTree;
    IBOutlet id dataOutlineView;

}
- (id)outlineView:(NSOutlineView *)outlineView child:(NSInteger)index ofItem:(id)item;
- (BOOL)outlineView:(NSOutlineView *)outlineView isItemExpandable:(id)item;
- (NSInteger)outlineView:(NSOutlineView *)outlineView numberOfChildrenOfItem:(id)item;
- (id)outlineView:(NSOutlineView *)outlineView objectValueForTableColumn:(NSTableColumn *)tableColumn byItem:(id)item;

-(void)addObjectAtRoot:(id)object;
-(void)setFilteredTree:(NSMutableDictionary *)inDict;
-(IBAction)filterWithString:(id)sender;
@end
