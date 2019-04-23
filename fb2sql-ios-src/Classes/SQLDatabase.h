//
//  SQLDatabase.h
//  fb2sql
//
//  Created by Christophe Deschamps on 01/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLDatabaseReference.h"
#import "SQLDatabaseEndPoint.h"
#import "SQLDatabaseSnapshot.h"
@class SQLDatabaseReference;


#define TAG @"[SQLDATABASE]"
#define SQLDATABASEDebug 0
#define SQLDATABASEInfo 1
#define SQLDATABASEWarn 2
#define SQLDATABASEError 3
#define SQLDATABASEAbort 4


#define LOGV(level, ...) [SQLDatabase log:level format:__VA_ARGS__]
#define LOGD(...) LOGV(SQLDATABASEDebug, __VA_ARGS__)
#define LOGI(...) LOGV(SQLDATABASEInfo, __VA_ARGS__)
#define LOGW(...) LOGV(SQLDATABASEWarn, __VA_ARGS__)
#define LOGE(...) LOGV(SQLDATABASEError, __VA_ARGS__)
#define LOGA(...) LOGV(SQLDATABASEAbort, __VA_ARGS__)

NS_ASSUME_NONNULL_BEGIN

@interface SQLDatabase : NSObject
@property SQLDatabaseEndPoint *endPoint;
@property int lVerbosity;

@property(nonatomic, class, strong, readonly) SQLDatabase *_Nonnull database;

+(void)log:(int)severity format:(NSString *)format, ...;
-(void) clearCache;
- (SQLDatabase *) setLogVerbosity:(int)verbosity;
-(SQLDatabase *) setRetryTimeout:(int)retryto;
-(SQLDatabase *) enableLocalCacheWithTTL:(int)ttl;
-(SQLDatabase *) setAuthPass:(NSString *)value;
-(SQLDatabase *) setAuthUsername:(NSString *)value;
-(SQLDatabase *) setAuthToken:(NSString *)token;
-(SQLDatabase *) setUri:(NSString *)uri;
-(SQLDatabaseReference *) reference;
+(NSString *) getIdFromIri:(NSString *)IRI;
+(NSString *) buildUriForProperty:(NSString *)property withValue:(NSString *)value;
+(NSString *) generateID;
+ (NSString *) irize:(NSString *)prop  value:(NSString *)value;
@end

NS_ASSUME_NONNULL_END
