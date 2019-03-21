//
//  SQLJSONRemovePropertyTransformer.m
//  fb2sql
//
//  Created by Christophe Deschamps on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLJSONRemovePropertyTransformer.h"

@implementation SQLJSONRemovePropertyTransformer

- (id)initWithProperty:(NSString *)property {
	self = [super init];
	self.property = property;
	return self;
}

-(NSMutableDictionary *) transform:(NSMutableDictionary *) input {
	NSMutableDictionary * output = [input mutableCopy];
	[output removeObjectForKey:self.property];
	return output;
}


@end
