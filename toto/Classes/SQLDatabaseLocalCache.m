//
//  SQLDatabaseLocalCache.m
//  fb2sql
//
//  Created by Tof on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLDatabaseLocalCache.h"


@interface CacheObject : NSObject
	@property NSDate *storedDate;
	@property NSDictionary *jsonDict;
@end

@implementation CacheObject : NSObject
@end
	
@implementation SQLDatabaseLocalCache

-(NSDictionary *) get:(NSString *)key ttl:(int)ttl{
	@synchronized (self.cache) {
		CacheObject *o = [self.cache objectForKey:key];
		if (!o || o.storedDate.timeIntervalSinceNow > ttl) return nil;
		else return o.jsonDict;
	}
}

-(void) put:(NSString *)key value:(NSDictionary *)jsonDict {
	@synchronized (self.cache) {
		CacheObject *o = [[CacheObject alloc] init];
		o.storedDate = [NSDate date];
		o.jsonDict = jsonDict;
	}
}

+ (SQLDatabaseLocalCache *) instance{
	static dispatch_once_t pred;
	static SQLDatabaseLocalCache *shared = nil;
	dispatch_once(&pred, ^{
		shared = [[SQLDatabaseLocalCache alloc] init];
		shared.cache = [[NSMutableDictionary alloc] init];
	});
	return shared;
}

-(void)clear {
	@synchronized (self.cache) {
		[self.cache removeAllObjects];
	}
}


@end
