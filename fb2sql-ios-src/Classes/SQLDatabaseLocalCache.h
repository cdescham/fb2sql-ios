//
//  SQLDatabaseLocalCache.h
//  fb2sql
//
//  Created by Christophe Deschamps on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLDatabaseSnapshot.h"

NS_ASSUME_NONNULL_BEGIN

@interface SQLDatabaseLocalCache : NSObject
@property NSMutableDictionary *cache;
+ (SQLDatabaseLocalCache *) instance;
-(SQLDatabaseSnapshot *) get:(NSString *)key ttl:(int)ttl;
-(void) put:(NSString *)key value:(SQLDatabaseSnapshot *)snap;
-(void)clear;

@end

NS_ASSUME_NONNULL_END
