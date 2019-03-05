//
//  SQLJSONNameMapperTransformer.m
//  fb2sql
//
//  Created by Tof on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLJSONNameMapperTransformer.h"

@implementation SQLJSONNameMapperTransformer

- (id)initWithProperty:(NSString *)property andKey:(NSString *)key {
	self = [super init];
	self.property = property;
	self.key = key;
	return self;
}

-(NSDictionary *) transform:(NSDictionary *) input {
	NSMutableDictionary * output = [input mutableCopy];
	[output setObject:[input objectForKey:self.property] forKey:self.key];
	return output;
}


@end
