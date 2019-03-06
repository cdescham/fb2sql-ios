//
//  SQLJSONListExpanderTransformer.m
//  fb2sql
//
//  Created by Tof on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//


/*
 
 "property": [
 {
 "subKeyName": "123",
 "subPropertyName": "blue"
 },
 {
 "subKeyName": "456",
 "subPropertyName": "red"
 }
 ...
 ]
 
 to
 "property": {
 "blue":[123,...]
 "received": [456,...]
 }
 */


#import "SQLJSONListExpanderTransformer.h"

@implementation SQLJSONListExpanderTransformer


- (id)initWithProperty:(NSString *)property subKeyName:(NSString *)subKeyName  subPropertyName:(NSString *)subPropertyName {
	self = [super init];
	self.property = property;
	self.subKeyName = subKeyName;
	self.subPropertyName = subPropertyName;

	return self;
}

-(NSMutableDictionary *) transform:(NSMutableDictionary *) input {
	NSMutableDictionary * output = [input mutableCopy];
	NSMutableDictionary * hash = [[NSMutableDictionary alloc] init];
	NSArray *list = [input objectForKey:self.property];
	for (NSDictionary *e in list ) {
		if (![hash objectForKey:[e objectForKey:self.subPropertyName]]) {
			[hash setObject:[[NSMutableArray alloc]init] forKey:[e objectForKey:self.subPropertyName]];
		}
		NSMutableArray *current = [hash objectForKey:[e objectForKey:self.subPropertyName]];
		[current addObject:[e objectForKey:self.subKeyName]];
	}
	[output setObject:hash forKey:self.property];
	return output;
}




@end
