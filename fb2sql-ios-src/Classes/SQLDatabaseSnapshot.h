//
//  SQLDatabaseSnapshot.h
//  fb2sql
//
//  Created by Tof on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLJSONTransformer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SQLDatabaseSnapshot : NSObject

@property NSMutableDictionary *dict;
@property NSString *table;
@property NSString *key;

- (id)initWithDictionary:(NSMutableDictionary *)dict andTable:(NSString *)table;
-(id) value:(NSArray<SQLJSONTransformer *> *)normalizers;
-(NSEnumerator<SQLDatabaseSnapshot *>*) children;
-(BOOL) exists;

@end

NS_ASSUME_NONNULL_END
