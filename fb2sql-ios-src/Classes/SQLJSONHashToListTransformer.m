//
//  SQLJSONHashToListTransformer.m
//  fb2sql
//
//  Created by Christophe Deschamps on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLJSONHashToListTransformer.h"

@implementation SQLJSONHashToListTransformer


- (id)initWithProperty:(NSString *)property andKey:(NSString *)key {
	self = [super init];
	self.property = property;
	self.key = key;
	return self;
}

-(NSMutableDictionary *) transform:(NSMutableDictionary *) input {
	NSMutableDictionary * output = [input mutableCopy];
	NSMutableArray *result = [[NSMutableArray alloc]init];
	NSDictionary  *elems =[input objectForKey:self.property];
	for (NSString *k in [elems allKeys]) {
		NSMutableDictionary * theObj = [[elems objectForKey:k] mutableCopy];
		[theObj setObject:k forKey:self.key];
		[result addObject:theObj];
	}
	[output setObject:result forKey:self.property];
	return output;

}

@end
