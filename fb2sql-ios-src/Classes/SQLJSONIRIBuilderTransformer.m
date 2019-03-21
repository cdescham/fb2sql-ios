//
//  SQLJSONIRIBuilderTransformer.m
//  fb2sql
//
//  Created by Christophe Deschamps on 04/03/2019.
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

-(NSMutableDictionary *) transform:(NSMutableDictionary *) input {
	NSMutableDictionary * output = [input mutableCopy];
    if (![output objectForKey:self.key])
        return output;
	[output setObject:[NSString stringWithFormat:@"/api/%@s/%@",self.property,[output objectForKey:self.key]] forKey:self.property];
	return output;
}

@end
