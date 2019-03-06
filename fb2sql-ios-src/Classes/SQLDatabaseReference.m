//
//  SQLDatabaseReference.m
//  fb2sql
//
//  Created by Tof on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLDatabaseReference.h"
#import "SQLDatabaseEventType.h"
#import "SQLDatabaseEntity.h"
#import "SQLJSONTransformer.h"

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


- (void)observeSingleEvent:(SQLDatabaseEventType)type withBlock:(void (^)(SQLDatabaseSnapshot *snapshot))block {
    [SQLDatabaseApiPlatformStore.sharedManager get:self.table pk:self.pk geoSearch:self.geoSearch parameters:self.parameters block:block];
}

- (void) updateChildValues:(NSDictionary *)values withCompletionBlock:(void (^)(NSError *__nullable error))block {
    
}

/*
 - NSString -- @"Hello World"
 - NSNumber (also includes boolean) -- @YES, @43, @4.333
 - NSDictionary -- @{@"key": @"value", @"nested": @{@"another": @"value"} }
 - NSArray
 */

- (void) setValue:(NSDictionary *)value forRootEntity:(NSString *)className withCompletionBlock:(void (^)(NSError *__nullable error))block {
    if (value) {
        NSDictionary *input;
        if (className) {
            NSMutableDictionary *d = [value mutableCopy];
            Class c =NSClassFromString(className);
            if ([c isKindOfClass:SQLDatabaseEntity.class]) {
                NSArray *denormalizers = [c getDeNormalizers];
                for (SQLJSONTransformer *t in denormalizers) {
                    d = [t transform:d];
                }
            }
            input = d;
        } else
        input = value;
        if (self.pk)
        	[SQLDatabaseApiPlatformStore.sharedManager update:self.table pk:self.pk json:input block:block insertOn404:true];
        else
        	[SQLDatabaseApiPlatformStore.sharedManager insert:self.table json:input block:block];
    }
    else {
        [SQLDatabaseApiPlatformStore.sharedManager remove:self.table pk:self.pk block:block];
    }
}

/*
 @PublicApi
 public Task<Void> setValue(@Nullable Object object) throws Exception {
 final TaskCompletionSource<Void> source = new TaskCompletionSource<>();
 if (object != null) {
 List<SQLJSONTransformer> deNormalizers = getDenormalizerForClass(object.getClass());
 String json = new Gson().toJson(object);
 Map<String, Object> bouncedUpdate = CustomClassMapper.convertToPlainJavaTypes(JsonMapper.parseJson(json));
 String pkName = table.substring(0, table.length() - 1)+"Id";
 if (bouncedUpdate.get(pkName) == null)
 bouncedUpdate.put(pkName,id);
 if (deNormalizers != null) {
 bouncedUpdate = deNormalize(bouncedUpdate, deNormalizers);
 json = new Gson().toJson(bouncedUpdate);
 }
 if (id == null)
 SQLApiPlatformStore.insert(table, json, source);
 else
 SQLApiPlatformStore.update(table, id, json, source, true);
 } else {
 SQLApiPlatformStore.delete(table, id, source);
 }
 return source.getTask();
 }
 */


@end
