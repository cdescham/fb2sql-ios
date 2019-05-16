//
//  SQLDatabaseApiPlatformStore.h
//  fb2sql
//
//  Created by Christophe Deschamps on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking/AFHTTPSessionManager.h>
#import "SQLDatabase.h"
#import "SQLDatabaseSnapshot.h"
#import "BlockVector.h"
#import "SQLDatabaseLocalCache.h"

#define MEDIA_TYPE @"application/ld+json"
#define ENCODING @"utf-8"

NS_ASSUME_NONNULL_BEGIN

@interface SQLDatabaseApiPlatformStore : NSObject

@property NSNumber *seqNum;
@property AFHTTPSessionManager *manager ;
@property NSMutableDictionary *blocksQueueForOngoingRequests;

+(SQLDatabaseApiPlatformStore *)sharedManager;
-(void) get:(NSString *)table pk:(NSString *)pk geoSearch:(NSString *)geoSearch parameters:(NSString *)parameters block:(void (^)(SQLDatabaseSnapshot *))block cancelBlock:(nullable void (^)(NSError *))cancelBlock;
-(void) remove:(NSString *)table pk:(NSString *)pk block:(nullable void (^)(NSError *))block  keepCache:(BOOL)keepCache;
-(void) insert:(NSString *)table json:(NSDictionary *)jsonDict block:(void (^)(NSError *))block keepCache:(BOOL)keepCache;
-(void) update:(NSString *)table pk:(NSString *)pk json:(NSDictionary *)jsonDict block:(void (^)(NSError *))block insertOn404:(BOOL)insertOn404 keepCache:(BOOL)keepCache;

@end

NS_ASSUME_NONNULL_END
