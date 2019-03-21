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


-(NSMutableDictionary *)replaceIdByKeyRecursively:(NSMutableDictionary *) input {
    if ([input isKindOfClass:NSMutableDictionary.class]  && [(NSMutableDictionary *)input objectForKey:@"@id"]) {
        [input setObject:[SQLDatabase getIdFromIri:[input objectForKey:@"@id"]] forKey:@"key"];
        return input;
    } else if ([input isKindOfClass:NSMutableDictionary.class])  {
        for(NSString *key in input.allKeys) {
            [input setObject:[self replaceIdByKeyRecursively:[input objectForKey:key]] forKey:key];
        }
    } else {
        return input;
    }
}

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
        /*
        if ([val isKindOfClass:NSMutableDictionary.class] ) {
            NSMutableDictionary *md =[(NSDictionary *)val mutableCopy];
            [md setObject:[self replaceIdByKeyRecursively:md] forKey:key];
            [output setObject:md forKey:key];
        }
        if ([val isKindOfClass:NSArray.class] && ((NSArray *)val).count > 0 && [[(NSArray *)val objectAtIndex:0] isKindOfClass:NSDictionary.class]) {
            NSMutableArray *newList = [[NSMutableArray alloc]init];
            for (NSMutableDictionary *d in (NSArray *)val) {
                [newList addObject:[self replaceIdByKeyRecursively:d]];
            }
            [output setObject:newList forKey:key];
        }
      */
	}
	return output;
}



@end
