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
#import <CoreLocation/CoreLocation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SQLDatabaseReference : NSObject

@property  NSString *table;
@property  NSString *pk;
@property  NSString *geoSearch;
@property  double geoSearchRadius;
@property  NSString * parameters;
@property  NSString *pivotfield;

- (void)observeSingleEvent:(SQLDatabaseEventType)type withBlock:(void (^)(SQLDatabaseSnapshot *snapshot))block;
- (void)observeSingleEventOfType:(SQLDatabaseEventType)eventType withBlock:(void (^)(SQLDatabaseSnapshot *snapshot))block withCancelBlock:(nullable void (^)(NSError* error))cancelBlock;
-(SQLDatabaseReference *) queryAtLocation:(CLLocation *)location withRadius:(double)radius  andDistanceunit:(NSString *)unit;
-(void) addGeoQueryEventObserverBlock:(nullable void (^)(SQLDatabaseSnapshot* snap))observe withCompletionBlock:(nullable void (^)(void))completion withErrorBlock:(nullable void (^)(NSError* error))erroBlock;
- (void) updateChildValues:(NSDictionary *)values withDenormalizers:(NSArray<SQLJSONTransformer *> *)denorm withCompletionBlock:(void (^)(NSError *__nullable error))block;
- (void) updateChildValues:(NSDictionary *)values withCompletionBlock:(void (^)(NSError *__nullable error))block;
- (void) setValue:(NSDictionary *)value withDenormalizers:(NSArray<SQLJSONTransformer *> *)denorm withCompletionBlock:(void (^)(NSError *__nullable error))block;
-(SQLDatabaseReference *) child:(NSString *)label;
-(SQLDatabaseReference *) reference:(NSString *)table;
-(SQLDatabaseReference *) orderByChildAsc:(NSString *)field;
-(SQLDatabaseReference *) limitToFirst:(int)limit;
-(SQLDatabaseReference *) equalTo:(NSString *)value;
-(void) removeValue;

@end

NS_ASSUME_NONNULL_END
