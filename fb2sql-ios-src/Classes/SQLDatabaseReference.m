//
//  SQLDatabaseReference.m
//  fb2sql
//
//  Created by Christophe Deschamps on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLDatabaseReference.h"
#import "SQLDatabaseEventType.h"
#import "SQLDatabaseEntity.h"
#import "SQLJSONTransformer.h"
#import "SQLDatabaseSnapshot.h"

@implementation SQLDatabaseReference

- (id)init {
	if (self = [super init]) {
		self.keep = NO;
	}
	return self;
}

-(SQLDatabaseReference *) reference:(NSString *)table {
    self.table = table;
    return self;
}

-(SQLDatabaseReference *) keepCache:(BOOL)keep {
    self.keep = keep;
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

-(SQLDatabaseReference *) children:(NSArray *)labels {
	for (NSString *k in labels) {
		[self addParameter:[NSString stringWithFormat:@"%@Id%%5B%%5D",[self.table hasSuffix:@"s"] ? [self.table substringToIndex:self.table.length-1] : self.table] value:k];
	}
	return self;
}


-(SQLDatabaseReference *) setGroups:(NSString *)groups {
	[self addParameter:@"groups%5B%5D" value:groups];
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
    self.pivotfield = field;
    [self addParameter:[NSString stringWithFormat:@"order%%5B%@%%5D",field] value:@"asc"];
    return self;
}

-(SQLDatabaseReference *) orderByChildDesc:(NSString *)field {
    self.pivotfield = field;
    [self addParameter:[NSString stringWithFormat:@"order%%5B%@%%5D",field] value:@"desc"];
    return self;
}

-(SQLDatabaseReference *) timestampStartAt:(NSDate *)date {
    if (!self.pivotfield)
        LOGA(@"timestampStartAt called but no column defined by orderByChildDesc prior to this call");
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd%20HH:mm:ss"];
    [self addParameter:[NSString stringWithFormat:@"%@%%5Bafter%%5D",self.pivotfield] value:[formatter stringFromDate:date]];
    return self;
}

-(SQLDatabaseReference *) timestampEndtAt:(NSDate *)date {
    if (!self.pivotfield)
        LOGA(@"timestampStartAt called but no column defined by orderByChildDesc prior to this call");
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat: @"yyyy-MM-dd%20HH:mm:ss"];
    [self addParameter:[NSString stringWithFormat:@"%@%%5Bbefore%%5D",self.pivotfield] value:[formatter stringFromDate:date]];
    return self;
}

-(SQLDatabaseReference *) equalTo:(NSString *)value {
    if (!self.pivotfield)
        LOGA(@"timestampStartAt called but no column defined by orderByChildDesc prior to this call");
    [self addParameter:self.pivotfield  value:value];
    return self;
}

-(SQLDatabaseReference *) whereEquals:(NSString *)property value:(NSString *)value {
    [self addParameter:property value:value];
    return self;
}


- (void)observeSingleEvent:(SQLDatabaseEventType)type withBlock:(void (^)(SQLDatabaseSnapshot *snapshot))block {
    [SQLDatabaseApiPlatformStore.sharedManager get:self.table pk:self.pk geoSearch:self.geoSearch parameters:self.parameters block:block cancelBlock:nil];
}

- (void)observeSingleEventOfType:(SQLDatabaseEventType)eventType withBlock:(void (^)(SQLDatabaseSnapshot *snapshot))block withCancelBlock:(nullable void (^)(NSError* error))cancelBlock {
    [SQLDatabaseApiPlatformStore.sharedManager get:self.table pk:self.pk geoSearch:self.geoSearch parameters:self.parameters block:block cancelBlock:cancelBlock];
}

-(SQLDatabaseReference *) queryAtLocation:(CLLocation *)location withRadius:(double)radius  andDistanceunit:(NSString *)unit {
    self.geoSearch = [NSString stringWithFormat:@"geo_search/%lf/%lf/%lf%@",location.coordinate.latitude,location.coordinate.longitude,radius,unit];
    return self;
}

-(void) addGeoQueryEventObserverBlock:(nullable void (^)(SQLDatabaseSnapshot* snap))observe withCompletionBlock:(nullable void (^)(void))completion withErrorBlock:(nullable void (^)(NSError* error))erroBlock {
    [SQLDatabaseApiPlatformStore.sharedManager get:self.table pk:self.pk geoSearch:self.geoSearch parameters:self.parameters block:^(SQLDatabaseSnapshot* snap) {
        for (SQLDatabaseSnapshot *s in [snap children]) {
            observe(s);
        }
        completion();
    } cancelBlock:erroBlock];
}

- (void) updateChildValues:(NSDictionary *)values withDenormalizers:(NSArray<SQLJSONTransformer *> *)denorm withCompletionBlock:(void (^)(NSError *__nullable error))block {
    [self setValue:values withDenormalizers:denorm withCompletionBlock:block];
}

- (void) updateChildValues:(NSDictionary *)values withCompletionBlock:(void (^)(NSError *__nullable error))block {
    [self setValue:values withDenormalizers:nil withCompletionBlock:block];
}

- (void) updateChildValues:(NSDictionary *)values{
    [self setValue:values withDenormalizers:nil withCompletionBlock:nil];
}


- (void) setValue:(nullable NSDictionary *)values withCompletionBlock:(void (^)(NSError *__nullable error))block  {
    [self setValue:values withDenormalizers:nil withCompletionBlock:block];
}


/*
 - NSString -- @"Hello World"
 - NSNumber (also includes boolean) -- @YES, @43, @4.333
 - NSDictionary -- @{@"key": @"value", @"nested": @{@"another": @"value"} }
 - NSArray
 */

- (void) setValue:(NSDictionary *)value withDenormalizers:(nullable NSArray<SQLJSONTransformer *> *)denorm withCompletionBlock:(nullable void (^)(NSError *__nullable error))block {
    if (value) {
        NSMutableDictionary *d = [value mutableCopy];
        if (denorm) {
            for (SQLJSONTransformer *t in denorm) {
                d = [t transform:d];
            }
        }
        if (self.pk) {
            [d setObject:self.pk forKey:[NSString stringWithFormat:@"%@Id",[self.table substringToIndex:self.table.length-1]]];
        }
        if (self.pk)
            [SQLDatabaseApiPlatformStore.sharedManager update:self.table pk:self.pk json:d block:block insertOn404:true keepCache:self.keep];
        else
            [SQLDatabaseApiPlatformStore.sharedManager insert:self.table json:d block:block];
    }
    else {
        [SQLDatabaseApiPlatformStore.sharedManager remove:self.table pk:self.pk block:block];
    }
}

-(void) removeValue {
    [SQLDatabaseApiPlatformStore.sharedManager remove:self.table pk:self.pk block:nil];
}


@end
