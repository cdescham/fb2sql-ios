//
//  SQLJSONTransformer.m
//  fb2sql
//
//  Created by Tof on 04/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLJSONTransformer.h"

@implementation SQLJSONTransformer

-(NSDictionary *) transform:(NSDictionary *) input {
	// stub
	return nil;
}

-(NSString *)idFromIRI:(NSString *)iri {
	if (iri || ![iri hasPrefix:@"/api"])
		return nil;
	else
		return [[iri componentsSeparatedByString:@"/"] objectAtIndex:2];
	
}



@end
