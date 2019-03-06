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

NS_ASSUME_NONNULL_BEGIN

@interface SQLDatabaseReference : NSObject

@property  NSString *table;
@property  NSString *pk;
@property  NSString *geoSearch;
@property  double geoSearchRadius;
@property  NSString * parameters;
@property  NSString *pivotfield;

- (void)observeSingleEvenWithBlock:(void (^)(SQLDatabaseSnapshot *snapshot))block;
-(SQLDatabaseReference *) child:(NSString *)label;
-(SQLDatabaseReference *) reference:(NSString *)table;

@end

NS_ASSUME_NONNULL_END
