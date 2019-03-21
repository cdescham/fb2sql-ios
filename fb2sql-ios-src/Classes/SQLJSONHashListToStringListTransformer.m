//
//  SQLJSONHashListToStringListTransformer.m
//  fb2sql
//
//  Created by Christophe Deschamps on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLJSONHashListToStringListTransformer.h"
#import "SQLDatabase.h"

@implementation SQLJSONHashListToStringListTransformer


- (id)initWithProperty:(NSString *)property andKey:(NSString *)key {
	self = [super init];
	self.property = property;
	self.key = key;
	return self;
}


-(NSMutableDictionary *) transform:(NSMutableDictionary *) input {
	NSMutableDictionary * output = [input mutableCopy];
	NSArray *list = [output objectForKey:self.property];
	if (!list) return output;
	
	NSMutableArray *listOfKeys = [[NSMutableArray alloc] init];
	for (NSDictionary *sublist in list) {
		[listOfKeys addObject:[SQLDatabase getIdFromIri:[sublist objectForKey:self.key]]];
	}
	[output setObject:listOfKeys forKey:self.property];
	return output;
}

@end
