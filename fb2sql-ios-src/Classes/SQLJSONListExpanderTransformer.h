//
//  SQLJSONListExpanderTransformer.h
//  fb2sql
//
//  Created by Tof on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLJSONTransformer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SQLJSONListExpanderTransformer : SQLJSONTransformer
@property NSString *property;
@property NSString *subKeyName;
@property NSString *subPropertyName;


- (id)initWithProperty:(NSString *)property subKeyName:(NSString *)subKeyName  subPropertyName:(NSString *)subPropertyName;
@end

NS_ASSUME_NONNULL_END
