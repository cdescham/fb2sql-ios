//
//  SQLJSONTransformer.h
//  fb2sql
//
//  Created by Christophe Deschamps on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SQLJSONTransformer : NSObject


-(NSMutableDictionary *) transform:(NSMutableDictionary *) input;



@end

NS_ASSUME_NONNULL_END
