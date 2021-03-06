//
//  SQLJSONListToHashTransformer.m
//  fb2sql
//
//  Created by Christophe Deschamps on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLJSONListToHashTransformer.h"

@implementation SQLJSONListToHashTransformer



- (id)initWithProperty:(NSString *)property andKey:(NSString *)key {
	self = [super init];
	self.property = property;
	self.key = key;
	return self;
}

-(NSMutableDictionary *) transform:(NSMutableDictionary *) input {
	NSMutableDictionary * output = [input mutableCopy];
	NSMutableDictionary * hash = [[NSMutableDictionary alloc] init];
	NSArray *list = [input objectForKey:self.property];
	if (!list) return input;
	for (NSMutableDictionary *e in list) {
		[hash setObject:e forKey:[e objectForKey:self.key]];
	}
	[output setObject:hash forKey:self.property];
	return output;
}


@end
