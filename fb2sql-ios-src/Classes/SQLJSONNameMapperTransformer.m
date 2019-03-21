//
//  SQLJSONNameMapperTransformer.m
//  fb2sql
//
//  Created by Christophe Deschamps on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLJSONNameMapperTransformer.h"
#import "SQLDatabase.h"

@implementation SQLJSONNameMapperTransformer

- (id)initWithProperty:(NSString *)property andKey:(NSString *)key {
	self = [super init];
	self.property = property;
	self.key = key;
	return self;
}

-(NSMutableDictionary *) transform:(NSMutableDictionary *) input {
    if (![input objectForKey:self.property])
        return input;
	NSMutableDictionary * output = [input mutableCopy];
	[output setObject:[input objectForKey:self.property] forKey:self.key];
    [output removeObjectForKey:self.property];
	return output;
}


@end
