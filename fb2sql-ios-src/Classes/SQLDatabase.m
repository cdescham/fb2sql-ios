//
//  SQLDatabase.m
//  fb2sql
//
//  Created by Tof on 01/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLDatabase.h"


@implementation SQLDatabase
@synthesize endPoint;

+ (SQLDatabase *) database{
	static dispatch_once_t pred;
	static SQLDatabase *shared = nil;
	dispatch_once(&pred, ^{
		shared = [[SQLDatabase alloc] init];
		shared.endPoint = [[SQLDatabaseEndPoint alloc] init];
		shared.logVerbosity = Warn;
	});
	return shared;
}

- (SQLDatabaseReference *) reference {
	return [[SQLDatabaseReference alloc] init];
}

- (SQLDatabase *) setUri:(NSString *)uri{
	endPoint.uriString = uri;
	return [SQLDatabase database];
}

- (SQLDatabase *) setAuthToken:(NSString *)token{
	endPoint.authToken = token;
	return [SQLDatabase database];
}

- (SQLDatabase *) setAuthUsername:(NSString *)value{
	endPoint.authUser = value;
	return [SQLDatabase database];
}

- (SQLDatabase *) setAuthPass:(NSString *)value{
	endPoint.authPass = value;
	return [SQLDatabase database];
}

- (SQLDatabase *) enableLocalCache:(BOOL)value{
	endPoint.localCacheEnabled = value;
	return [SQLDatabase database];
}

- (SQLDatabase *) setRetryTimeout:(int)retryto{
	endPoint.retryTimeOut = retryto;
	return [SQLDatabase database];
}

- (SQLDatabase *) seVerbosityForLog:(int)verbosity{
	self.logVerbosity = verbosity;
	return [SQLDatabase database];
}

- (void) clearCache {
	[SQLDatabaseLocalCache.instance clear];
}


+ (void)log:(int)severity format:(NSString *)format, ... {
	if (severity < SQLDatabase.database.logVerbosity)
		return;
	va_list args;
	va_start(args, format);
	NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
	NSLog(@"%@ %@",TAG,str);
	va_end(args);
	if (severity == Abort)
		abort();
}


+(NSString *) getIdFromIri:(NSString *)IRI {
	NSArray *components = [IRI componentsSeparatedByString:@"/"];
	if (components.count == 3)
		return components[2];
	else
		return nil;
}

+(NSString *) buildUriForProperty:(NSString *)property withCalue:(NSString *)value {
	return [NSString stringWithFormat:@"/api/%@/%@",property,value];
}

@end



