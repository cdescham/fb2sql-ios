//
//  SQLJSONTransformer.h
//  fb2sql
//
//  Created by Tof on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SQLJSONTransformer : NSObject


-(NSString *)idFromIRI:(NSString *)iri;

-(NSDictionary *) transform:(NSDictionary *) input;



@end

NS_ASSUME_NONNULL_END
