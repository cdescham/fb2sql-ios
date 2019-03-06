//
//  SQLDatabaseReference.h
//  fb2sql
//
//  Created by Tof on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLDatabaseApiPlatformStore.h"
#import "SQLDatabaseSnapshot.h"
#import "SQLDatabaseEventType.h"

NS_ASSUME_NONNULL_BEGIN

@interface SQLDatabaseReference : NSObject

@property  NSString *table;
@property  NSString *pk;
@property  NSString *geoSearch;
@property  double geoSearchRadius;
@property  NSString * parameters;
@property  NSString *pivotfield;

- (void)observeSingleEvent:(SQLDatabaseEventType)type withBlock:(void (^)(SQLDatabaseSnapshot *snapshot))block;
- (void) updateChildValues:(NSDictionary *)values withCompletionBlock:(void (^)(NSError *__nullable error, SQLDatabaseReference * ref))block;
- (void) setValue:(nullable id)value withCompletionBlock:(void (^)(NSError *__nullable error, SQLDatabaseReference * ref))block;
-(SQLDatabaseReference *) child:(NSString *)label;
-(SQLDatabaseReference *) reference:(NSString *)table;
-(SQLDatabaseReference *) orderByChildAsc:(NSString *)field;
-(SQLDatabaseReference *) limitToFirst:(int)limit;
-(SQLDatabaseReference *) equalTo:(NSString *)value;

@end

NS_ASSUME_NONNULL_END
