//
//  SQLDatabaseSnapshot.h
//  fb2sql
//
//  Created by Christophe Deschamps on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLJSONTransformer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SQLDatabaseSnapshot : NSObject

@property NSMutableDictionary *dict;
@property NSString *table;
@property NSString *key;
@property bool normalized;

- (id)initWithDictionary:(NSMutableDictionary *)inputDict andTable:(NSString *)table;
-(id) value:(nullable NSArray<SQLJSONTransformer *> *)normalizers;
-(id) value;

-(NSEnumerator<SQLDatabaseSnapshot *>*) children;
-(NSEnumerator<SQLDatabaseSnapshot *>*) reversedChildren;

-(BOOL) exists;

@end

NS_ASSUME_NONNULL_END
