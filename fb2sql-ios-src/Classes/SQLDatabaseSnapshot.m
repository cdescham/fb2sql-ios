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
#import "SQLDatabase.h"

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

-(id) value:(NSArray<SQLJSONTransformer *> *)normalizers {
    self.key = [self.dict objectForKey:[[self.table substringToIndex:self.table.length-1] stringByAppendingString:@"Id"]];
    LOGD(@"Processing %d normalizer(s) initial dict= %@",normalizers.count,self.dict );
    if (normalizers) {
        for (SQLJSONTransformer *t in normalizers) {
            self.dict = [t transform:self.dict];
            LOGD(@"Processing normalizer %@ dict = %@",t.class,self.dict);
        }
    }
    LOGD(@"Processed %d normalizer(s) result is %@",normalizers.count,self.dict);

    return self.dict;
}

@end
