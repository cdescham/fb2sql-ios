//
//  SQLJSONStringListToHashListTransformer.m
//  fb2sql
//
//  Created by Tof on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLJSONStringListToHashListTransformer.h"

@implementation SQLJSONStringListToHashListTransformer

- (id)initWithProperty:(NSString *)property andKey:(NSString *)key {
	self = [super init];
	self.property = property;
	self.key = key;
	return self;
}

-(NSDictionary *) transform:(NSDictionary *) input {
	NSMutableDictionary * output = [input mutableCopy];
	NSArray *listOfKeys = [input objectForKey:self.property];
	if (!listOfKeys)
		return input;
	NSMutableArray *list = [[NSMutableArray alloc] init];
	for (NSString *s in listOfKeys) {
		NSMutableDictionary *obj = [[NSMutableDictionary alloc] init];
		[obj setObject:[NSString stringWithFormat:@"/api/%@/%@",self.key,s] forKey:self.key];
		[list addObject:obj];
	}
	[output setObject:list forKey:self.property];
	return output;
}


@end
