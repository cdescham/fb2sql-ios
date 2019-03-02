//
//  SQLDatabase.h
//  fb2sql
//
//  Created by Tof on 01/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLDatabaseEndPoint.h"
#import "SQLDatabaseSnapshot.h"


#define TAG @"[SQLDATABASE]"
#define Debug 0
#define Info 1
#define Warn 2
#define Error 3

#define LOGV(level, ...) [SQLDatabase log:level format:__VA_ARGS__]
#define LOGD(...) LOGV(Debug, __VA_ARGS__)
#define LOGI(...) LOGV(Info, __VA_ARGS__)
#define LOGW(...) LOGV(Warn, __VA_ARGS__)
#define LOGE(...) LOGV(Error, __VA_ARGS__)

NS_ASSUME_NONNULL_BEGIN

@interface SQLDatabase : NSObject
@property SQLDatabaseEndPoint *endPoint;
@property int logVerbosity;

+ (void)log:(int)severity format:(NSString *)format, ...;

// - (void)observeSingleEventOfType:(FIRDataEventType)eventType withBlock:(void (^)(FIRDataSnapshot *snapshot))block;
// - (void)observeSingleEventOfType:(FIRDataEventType)eventType withBlock:(void (^)(FIRDataSnapshot *snapshot))block;

+ (SQLDatabase *) database;

@end

NS_ASSUME_NONNULL_END
