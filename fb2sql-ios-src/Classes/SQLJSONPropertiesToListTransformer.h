//
//  SQLJSONPropertiesToListTransformer.h
//  fb2sql
//
//  Created by Christophe Deschamps on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLJSONTransformer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SQLJSONPropertiesToListTransformer : SQLJSONTransformer
@property NSArray *propertyNames;
@property NSString *key;
- (id)initWithProperty:(NSArray *)propertyNames andKey:(NSString *)key;
@end

NS_ASSUME_NONNULL_END
