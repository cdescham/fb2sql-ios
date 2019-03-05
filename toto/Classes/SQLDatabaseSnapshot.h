//
//  SQLDatabaseSnapshot.h
//  fb2sql
//
//  Created by Tof on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SQLDatabaseSnapshot : NSObject

@property NSDictionary *dict;

- (id)initWithDictionary:(NSDictionary *)dict;


@end

NS_ASSUME_NONNULL_END
