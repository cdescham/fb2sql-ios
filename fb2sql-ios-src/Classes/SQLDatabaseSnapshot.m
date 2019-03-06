//
//  SQLDatabaseSnapshot.m
//  fb2sql
//
//  Created by Tof on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLDatabaseSnapshot.h"
#import "SQLDatabaseEntity.h"
#import "SQLJSONTransformer.h"

@implementation SQLDatabaseSnapshot

- (id)initWithDictionary:(NSMutableDictionary *)dict andTable:(NSString *)table {
	self = [super init];
	self.dict = dict;
    self.table = table;
	return self;
}


-(NSEnumerator<SQLDatabaseSnapshot *>*) children {
    NSMutableArray *children = [[NSMutableArray alloc] init];
    for (NSDictionary *child in [self.dict objectForKey:@"hydra:member"]) {
        [children addObject:[[SQLDatabaseSnapshot alloc] initWithDictionary:child andTable:self.table]];
    }
    return [children objectEnumerator];
}


-(BOOL) exists {
    return self.dict != nil;
}

/**
 * Returns the contents of this data snapshot as native types.
 *
 * Data types returned:
 * + NSDictionary
 * + NSArray
 * + NSNumber (also includes booleans)
 * + NSString
 *
 * @return The data as a native object.
 */

-(id) value:(NSString *)className {
    if (className) {
        Class c =NSClassFromString(className);
        if (![c isKindOfClass:SQLDatabaseEntity.class])
        	return self.dict;
        NSArray *normalizers = [c getNormalizers];
        for (SQLJSONTransformer *t in normalizers) {
            self.dict = [t transform:self.dict];
        }
    }
    self.key = [self.dict objectForKey:[[self.table substringToIndex:self.table.length-1] stringByAppendingString:@"Id"]];
	return self.dict;
}

@end
