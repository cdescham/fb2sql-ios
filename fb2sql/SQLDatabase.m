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

- (SQLDatabase *) setUri:(NSString *)uri{
	endPoint.uriString = uri;
	return [SQLDatabase database];
}


- (SQLDatabase *) setAuthToken:(NSString *)token{
	endPoint.authToken = token;
	return [SQLDatabase database];
}

+ (void)log:(int)severity format:(NSString *)format, ... {
	if (severity < SQLDatabase.database.logVerbosity)
		return;
	va_list args;
	va_start(args, format);
	NSString *str = [[NSString alloc] initWithFormat:format arguments:args];
	NSLog(@"%@ %@",TAG,str);
	va_end(args);
}


// Configuration

/*
@PublicApi
public SQLDatabase setUri(String uriString) {
	if (endPoint == null)
		endPoint = new SQLDatabaseEndpoint();
	endPoint.uriString = uriString;
	return this;
}

@PublicApi
public SQLDatabase setAuthUser(String authUser) {
	if (endPoint == null)
		endPoint = new SQLDatabaseEndpoint();
	endPoint.authUser = authUser;
	return this;
}

@PublicApi
public SQLDatabase setAuthPass(String authPass) {
	if (endPoint == null)
		endPoint = new SQLDatabaseEndpoint();
	endPoint.authPass = authPass;
	return this;
}

@PublicApi
public SQLDatabase setAuthToken(String authToken) {
	if (endPoint == null)
		endPoint = new SQLDatabaseEndpoint();
	endPoint.authToken = authToken;
	return this;
}

@PublicApi
public SQLDatabase setConnectionTimeout(int connectionTimeoutSeconds) {
	if (endPoint == null)
		endPoint = new SQLDatabaseEndpoint();
	endPoint.connectionTimeout = connectionTimeoutSeconds;
	return this;
}

@PublicApi
public SQLDatabase setReadTimeout(int readTimeoutSeconds) {
	if (endPoint == null)
		endPoint = new SQLDatabaseEndpoint();
	endPoint.readTimeout = readTimeoutSeconds;
	return this;
}

@PublicApi
public SQLDatabase setWriteTimeout(int writeTimeoutSeconds) {
	if (endPoint == null)
		endPoint = new SQLDatabaseEndpoint();
	endPoint.writeTimeout = writeTimeoutSeconds;
	return this;
}

@PublicApi
public SQLDatabase setConnectionPoolMaxIdleConnections(int maxIdleConnections) {
	if (endPoint == null)
		endPoint = new SQLDatabaseEndpoint();
	endPoint.connectionPoolMaxIdleConnections = maxIdleConnections;
	return this;
}

@PublicApi
public SQLDatabase setConnectionPoolKeepAliveDuration(int keepAliveDurationInSeconds) {
	if (endPoint == null)
		endPoint = new SQLDatabaseEndpoint();
	endPoint.connectionPoolKeepAliveDuration = keepAliveDurationInSeconds;
	return this;
}

@PublicApi
public SQLDatabase enableOkhttpCache(int sizeMb) {
	if (endPoint == null)
		endPoint = new SQLDatabaseEndpoint();
	endPoint.okHttpCacheEnabled = true;
	endPoint.okHttpCacheSizeMb = sizeMb;
	return this;
}


@PublicApi
public SQLDatabase enableLocalCache(int timeToLiveInSecondes) {
	if (endPoint == null)
		endPoint = new SQLDatabaseEndpoint();
	endPoint.localCacheEnabled = true;
	endPoint.localcacheTTL = timeToLiveInSecondes;
	return this;
}

@PublicApi
public SQLDatabase setRetryTimeout(int retryyTimeoutSeconds) {
	if (endPoint == null)
		endPoint = new SQLDatabaseEndpoint();
	endPoint.retryTimeOut = retryyTimeoutSeconds;
	return this;
}

@PublicApi
public SQLDatabase setLogVerbosity(int verbosity) {
	SQLDatabaseLogger.verbosity = verbosity;
	return this;
}


@PublicApi
public SQLDatabase setContext(Context context) {
	this.context = context;
	return this;
}

@PublicApi
public void clearCache() {
	if (endPoint != null && endPoint.localCacheEnabled)
		SQLDatabaseLocalCache.getInstance().clear();
}
*/

@end



