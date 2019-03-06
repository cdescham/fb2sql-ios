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

- (id)initWithDictionary:(NSMutableDictionary *)dict {
	self = [super init];
	self.dict = dict;
	return self;
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
	return self.dict;
}

@end
