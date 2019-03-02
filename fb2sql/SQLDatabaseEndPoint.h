//
//  SQLDatabaseEndPoint.h
//  fb2sql
//
//  Created by Tof on 01/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
@interface SQLDatabaseEndPoint : NSObject

@property NSString * uriString;
@property NSString * authUser;
@property NSString * authPass;
@property NSString * authToken;
@property int connectionTimeout;
@property int readTimeout;
@property int writeTimeout;
@property int connectionPoolMaxIdleConnections;
@property int connectionPoolKeepAliveDuration;
@property BOOL httpCacheEnabled;
@property int httpCacheSizeMb;
@property int localcacheTTL;
@property BOOL localCacheEnabled;
@property int retryTimeOut; // Time between retries for reading.

@end

NS_ASSUME_NONNULL_END
