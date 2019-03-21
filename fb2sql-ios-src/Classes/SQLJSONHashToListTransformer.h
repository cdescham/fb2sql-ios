//
//  SQLJSONHashToListTransformer.h
//  fb2sql
//
//  Created by Christophe Deschamps on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLJSONTransformer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SQLJSONHashToListTransformer : SQLJSONTransformer
@property NSString *property;
@property NSString *key;

- (id)initWithProperty:(NSString *)property andKey:(NSString *)key;

@end

NS_ASSUME_NONNULL_END
