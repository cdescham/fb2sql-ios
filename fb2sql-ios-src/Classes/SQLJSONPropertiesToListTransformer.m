//
//  SQLJSONPropertiesToListTransformer.m
//  fb2sql
//
//  Created by Christophe Deschamps on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLJSONPropertiesToListTransformer.h"

@implementation SQLJSONPropertiesToListTransformer


- (id)initWithProperty:(NSArray *)propertyNames andKey:(NSString *)key {
	self = [super init];
	self.propertyNames = propertyNames;
	self.key = key;
	return self;
}

-(NSMutableDictionary *) transform:(NSMutableDictionary *) input {
	NSMutableDictionary * output = [input mutableCopy];
	NSMutableArray * grouped = [[NSMutableArray alloc] init];
	for (NSString *property in self.propertyNames) {
		[grouped addObject:[input objectForKey:property]];
		[output removeObjectForKey:property];
	}
	[output setObject:grouped forKey:self.key];
	return output;
}

@end
