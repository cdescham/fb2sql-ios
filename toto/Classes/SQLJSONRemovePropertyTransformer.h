//
//  SQLJSONRemovePropertyTransformer.h
//  fb2sql
//
//  Created by Tof on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLJSONTransformer.h"

NS_ASSUME_NONNULL_BEGIN

@interface SQLJSONRemovePropertyTransformer : SQLJSONTransformer

@property NSString *property;
- (id)initWithProperty:(NSString *)property;
@end

NS_ASSUME_NONNULL_END
