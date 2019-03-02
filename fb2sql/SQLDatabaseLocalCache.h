//
//  SQLDatabaseLocalCache.h
//  fb2sql
//
//  Created by Tof on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SQLDatabaseLocalCache : NSObject
@property NSMutableDictionary *cache;
+ (SQLDatabaseLocalCache *) instance;
-(NSDictionary *) get:(NSString *)key ttl:(int)ttl;
-(void) put:(NSString *)key value:(NSDictionary *)jsonDict;
-(void)clear;

@end

NS_ASSUME_NONNULL_END
