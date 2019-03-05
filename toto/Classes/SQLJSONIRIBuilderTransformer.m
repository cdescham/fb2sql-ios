//
//  SQLJSONIRIBuilderTransformer.m
//  fb2sql
//
//  Created by Tof on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLJSONIRIBuilderTransformer.h"

@implementation SQLJSONIRIBuilderTransformer


- (id)initWithProperty:(NSString *)property andKey:(NSString *)key {
	self = [super init];
	self.property = property;
	self.key = key;
	return self;
}

-(NSDictionary *) transform:(NSDictionary *) input {
	NSMutableDictionary * output = [input mutableCopy];
	[output setObject:[NSString stringWithFormat:@"/api/%@s/%@",self.property,self.key] forKey:self.property];
	return output;
}

@end
