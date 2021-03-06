//
//  SQLDatabaseLocalCache.m
//  fb2sql
//
//  Created by Christophe Deschamps on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLDatabaseLocalCache.h"
#import "SQLDatabase.h"


@interface CacheObject : NSObject
	@property NSDate *storedDate;
	@property SQLDatabaseSnapshot *snap;
@end

@implementation CacheObject : NSObject
@end
	
@implementation SQLDatabaseLocalCache

-(SQLDatabaseSnapshot *) get:(NSString *)key ttl:(int)ttl{
	@synchronized (self.cache) {
		CacheObject *o = [self.cache objectForKey:key];
		if (!o) {
			LOGD(@"[SQLDatabaseLocalCache] no cache entry for %@",key);
			return nil;
		}
		if ( o.storedDate.timeIntervalSinceNow > ttl) {
			LOGD(@"[SQLDatabaseLocalCache] entry expired %@",key);
			return nil;
		}
		return o.snap;
	}
}

-(void) put:(NSString *)key value:(SQLDatabaseSnapshot *)snap {
	@synchronized (self.cache) {
		CacheObject *o = [[CacheObject alloc] init];
		o.storedDate = [NSDate date];
		o.snap = snap;
    	[self.cache setObject:o forKey:key];
		LOGD(@"[SQLDatabaseLocalCache] inserting cache key : %@",key);
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
		LOGD(@"[SQLDatabaseLocalCache] cache cleared");
	}
}


@end
