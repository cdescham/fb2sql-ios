//
//  SQLJSONCommonNormalizer.m
//  fb2sql
//
//  Created by Christophe Deschamps on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLJSONCommonNormalizer.h"
#import "SQLDatabase.h"

@implementation SQLJSONCommonNormalizer


-(NSMutableDictionary *) transform:(NSMutableDictionary *) input {
	NSMutableDictionary * output = [input mutableCopy];
	if ([output objectForKey:@"@id"]) {
		[output setObject:[output objectForKey:@"@id"] forKey:@"key"];
		[output removeObjectForKey:@"@id"];
	}
	[output removeObjectForKey:@"@type"];
	[output removeObjectForKey:@"@Context"];
	
	for(NSString *key in output.allKeys) {
		NSObject *val = [output objectForKey:key];
		if ([val isKindOfClass:NSString.class] &&  [(NSString *)val hasPrefix:@"/api"]) {
			[output setObject:[SQLDatabase getIdFromIri:(NSString *)val] forKey:key];
		}
		if ([val isKindOfClass:NSArray.class] && ((NSArray *)val).count > 0 && [[(NSArray *)val objectAtIndex:0] isKindOfClass:NSString.class] &&  [[(NSArray *)val objectAtIndex:0] hasPrefix:@"/api"]) {
			NSMutableArray *newList = [[NSMutableArray alloc]init];
			for (NSString *s in (NSArray *)val) {
				[newList addObject:[SQLDatabase getIdFromIri:s]];
			}
			[output setObject:newList forKey:key];
		}
	}
	return output;
}



@end
