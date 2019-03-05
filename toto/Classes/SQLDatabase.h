//
//  SQLDatabase.h
//  fb2sql
//
//  Created by Tof on 01/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLDatabaseReference.h"
#import "SQLDatabaseEndPoint.h"
#import "SQLDatabaseSnapshot.h"
@class SQLDatabaseReference;


#define TAG @"[SQLDATABASE]"
#define Debug 0
#define Info 1
#define Warn 2
#define Error 3
#define Abort 4


#define LOGV(level, ...) [SQLDatabase log:level format:__VA_ARGS__]
#define LOGD(...) LOGV(Debug, __VA_ARGS__)
#define LOGI(...) LOGV(Info, __VA_ARGS__)
#define LOGW(...) LOGV(Warn, __VA_ARGS__)
#define LOGE(...) LOGV(Error, __VA_ARGS__)
#define LOGA(...) LOGV(Abort, __VA_ARGS__)

NS_ASSUME_NONNULL_BEGIN

@interface SQLDatabase : NSObject
@property SQLDatabaseEndPoint *endPoint;
@property int logVerbosity;

+(void)log:(int)severity format:(NSString *)format, ...;
+(SQLDatabase *) database;
-(void) clearCache;
-(SQLDatabase *) seVerbosityForLog:(int)verbosity;
-(SQLDatabase *) setRetryTimeout:(int)retryto;
-(SQLDatabase *) enableLocalCache:(BOOL)value;
-(SQLDatabase *) setAuthPass:(NSString *)value;
-(SQLDatabase *) setAuthUsername:(NSString *)value;
-(SQLDatabase *) setAuthToken:(NSString *)token;
-(SQLDatabase *) setUri:(NSString *)uri;
-(SQLDatabaseReference *) reference;
+(NSString *) getIdFromIri:(NSString *)IRI;
+(NSString *) buildUriForProperty:(NSString *)property withCalue:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
