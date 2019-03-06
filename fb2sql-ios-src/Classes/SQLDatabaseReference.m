//
//  SQLDatabaseReference.m
//  fb2sql
//
//  Created by Tof on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLDatabaseReference.h"

@implementation SQLDatabaseReference


-(SQLDatabaseReference *) reference:(NSString *)table {
    self.table = table;
    return self;
}

-(SQLDatabaseReference *) child:(NSString *)label {
	if (!self.table)
		self.table = label;
	else if (!self.pk)
		self.pk = label;
	else
		LOGA(@"Child call too many times. Maximum time is 2, child(<table>).child(<primary key>)");
	return self;
}

-(void) addParameter:(NSString *)key value:(NSObject *)value {
	self.parameters =self.parameters?  [NSString stringWithFormat:@"%@&%@=%@",self.parameters,key,value] : [NSString stringWithFormat:@"%@=%@",key,value];
}

-(SQLDatabaseReference *) limitToFirst:(int)limit {
	[self addParameter:@"itemsPerPage" value:[NSNumber numberWithInt:limit]];
	return self;
}

-(SQLDatabaseReference *) orderByChildAsc:(NSString *)field {
	[self addParameter:[NSString stringWithFormat:@"order%%5B%@%%5D",field] value:@"asc"];
	return self;
}

-(SQLDatabaseReference *) orderByChildDesc:(NSString *)field {
	[self addParameter:[NSString stringWithFormat:@"order%%5B%@%%5D",field] value:@"desc"];
	return self;
}

-(SQLDatabaseReference *) timestampStartAt:(NSDate *)date {
	if (!self.pivotfield)
		LOGA(@"timestampStartAt called but no column defined by orderByChildDesc prior to this call");
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat: @"yyyy-MM-dd%%20HH:mm:ss"];
	[self addParameter:[NSString stringWithFormat:@"%@%%5Bafter%%5D",self.pivotfield] value:[formatter stringFromDate:date]];
	return self;
}

-(SQLDatabaseReference *) timestampEndtAt:(NSDate *)date {
	if (!self.pivotfield)
		LOGA(@"timestampStartAt called but no column defined by orderByChildDesc prior to this call");
	NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
	[formatter setDateFormat: @"yyyy-MM-dd%%20HH:mm:ss"];
	[self addParameter:[NSString stringWithFormat:@"%@%%5Bbeforer%%5D",self.pivotfield] value:[formatter stringFromDate:date]];
	return self;
}

-(SQLDatabaseReference *) equalTo:(NSString *)value {
	if (!self.pivotfield)
		LOGA(@"timestampStartAt called but no column defined by orderByChildDesc prior to this call");
	[self addParameter:self.pivotfield  value:value];
	return self;
}

-(SQLDatabaseReference *) whereEquals:(NSString *)property value:(NSString *)value {
	if (!self.pivotfield)
		LOGA(@"timestampStartAt called but no column defined by orderByChildDesc prior to this call");
	[self addParameter:property value:value];
	return self;
}


- (void)observeSingleEvenWithBlock:(void (^)(SQLDatabaseSnapshot *snapshot))block {
	[SQLDatabaseApiPlatformStore.sharedManager get:self.table pk:self.pk geoSearch:self.geoSearch parameters:self.parameters okBlock:block koBlock:nil];
}


@end
