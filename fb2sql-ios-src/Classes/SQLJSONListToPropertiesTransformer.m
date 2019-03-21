//
//  SQLJSONListToPropertiesTransformer.m
//  fb2sql
//
//  Created by Christophe Deschamps on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLJSONListToPropertiesTransformer.h"

@implementation SQLJSONListToPropertiesTransformer


- (id)initWithProperty:(NSArray *)propertyNames andKey:(NSString *)key {
	self = [super init];
	self.propertyNames = propertyNames;
	self.key = key;
	return self;
}

-(NSMutableDictionary *) transform:(NSMutableDictionary *) input {
	NSMutableDictionary * output = [input mutableCopy];
	NSArray * list = [input objectForKey:self.key];
	int i=0;
	for (NSString *property in self.propertyNames) {
		[output setObject:[list objectAtIndex:i++] forKey:property];
	}
	[output removeObjectForKey:self.key];
	return output;
}

@end
