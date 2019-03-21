//
//  SQLDatabaseSnapshot.m
//  fb2sql
//
//  Created by Christophe Deschamps on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLDatabaseSnapshot.h"
#import "SQLDatabaseEntity.h"
#import "SQLJSONTransformer.h"
#import "SQLDatabase.h"
#import "SQLJSONCommonNormalizer.h"

@implementation SQLDatabaseSnapshot

- (id)initWithDictionary:(NSMutableDictionary *)dict andTable:(NSString *)table {
    self = [super init];
    self.dict = dict;
    self.table = table;
    self.normalized = NO;
    self.key = self.dict ? [SQLDatabase getIdFromIri:[self.dict objectForKey:@"@id"]] : nil;
    return self;
}


-(NSEnumerator<SQLDatabaseSnapshot *>*) children:(BOOL) reverseOrder {
    NSMutableArray *children = [[NSMutableArray alloc] init];
    for (NSDictionary *child in [self.dict objectForKey:@"hydra:member"]) {
        [children addObject:[[SQLDatabaseSnapshot alloc] initWithDictionary:child andTable:self.table]];
    }
    return reverseOrder ? [children reverseObjectEnumerator] : [children objectEnumerator];
}


-(NSEnumerator<SQLDatabaseSnapshot *>*) children {
    return [self children:false];
}

-(NSEnumerator<SQLDatabaseSnapshot *>*) reversedChildren {
    return [self children:true];
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
    @synchronized (self.dict) {
        if (self.normalized)
            return self.dict;
        
        SQLJSONCommonNormalizer *common = [[SQLJSONCommonNormalizer alloc] init];
        self.dict = [common transform:self.dict];
        if (normalizers) {
            for (SQLJSONTransformer *t in normalizers) {
                self.dict = [t transform:self.dict];
            }
        }
        self.normalized = true;
        return self.dict;
    }
    
}

-(id) value {
    return [self value:nil];
}

@end
