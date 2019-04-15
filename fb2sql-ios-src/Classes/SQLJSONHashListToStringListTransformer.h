//
//  SQLJSONHashListToStringListTransformer.h
//  fb2sql
//
//  Created by Christophe Deschamps on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLJSONTransformer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SQLJSONHashListToStringListTransformer : SQLJSONTransformer

@property NSString *property;
@property NSString *key;
@property NSString *filterProperty;
@property int filterValue;

- (id)initWithProperty:(NSString *)property andKey:(NSString *)key;
- (id)initWithProperty:(NSString *)property andKey:(NSString *)key filterOn:(NSString *)filterProperty filterValue:(int)filterValue;


@end

NS_ASSUME_NONNULL_END
