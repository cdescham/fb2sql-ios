//
//  SQLDatabaseSnapshot.m
//  fb2sql
//
//  Created by Tof on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLDatabaseSnapshot.h"

@implementation SQLDatabaseSnapshot

- (id)initWithDictionary:(NSDictionary *)dict {
	self = [super init];
	self.dict = dict;
	return self;
}

@end
