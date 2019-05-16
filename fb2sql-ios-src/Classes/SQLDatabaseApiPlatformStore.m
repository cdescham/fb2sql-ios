//
//  SQLDatabaseApiPlatformStore.m
//  fb2sql
//
//  Created by Christophe Deschamps on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLDatabaseApiPlatformStore.h"



@implementation SQLDatabaseApiPlatformStore
@synthesize seqNum,blocksQueueForOngoingRequests;

-(NSNumber *) getSeqNum {
	@synchronized (seqNum) {
		seqNum = [NSNumber numberWithLongLong:[seqNum longLongValue] + 1];
		return seqNum;
	}
}

-(void) get:(NSString *)table pk:(NSString *)pk geoSearch:(NSString *)geoSearch parameters:(NSString *)parameters block:(void (^)(SQLDatabaseSnapshot *))block cancelBlock:(nullable void (^)(NSError *))cancelBlock {
	SQLDatabaseEndPoint *endPoint = [SQLDatabase database].endPoint;
	NSNumber *seq = self.getSeqNum;
	NSString *point = nil;
	if (pk)
		point =[NSString stringWithFormat:@"%@/%@/%@?%@",endPoint.uriString,table,pk,parameters ? : @""] ;
	else if (geoSearch)
		point =[NSString stringWithFormat:@"%@/%@/%@?%@",endPoint.uriString,table,geoSearch,parameters ? : @""] ;
	else
		point =[NSString stringWithFormat:@"%@/%@?%@",endPoint.uriString,table,parameters? : @""];
	LOGD(@"[%@][read request] %@",seq,point);
	if (endPoint.localCacheEnabled) {
		SQLDatabaseSnapshot *snap = [SQLDatabaseLocalCache.instance get:point ttl:endPoint.localcacheTTL];
		if (snap) {
			LOGD(@"[%@][read response from cache] %@ %@",seq,point,snap.dict);
			block(snap);
			return;
		}
	}
	@synchronized (blocksQueueForOngoingRequests) {
		BlockVector *bv = [[BlockVector alloc] init];
		bv.okBlock = block;
		bv.cancelBlock = cancelBlock;
		NSMutableArray *waitingVectorsForRequest = [blocksQueueForOngoingRequests objectForKey:point];
		if (waitingVectorsForRequest) {
			[waitingVectorsForRequest addObject:bv];
			LOGD(@"[%@][read request - already in progress] %@",seq,point);
			return;
		}
		waitingVectorsForRequest =  [[NSMutableArray alloc] init];
		[waitingVectorsForRequest addObject:bv];
		[blocksQueueForOngoingRequests setObject:waitingVectorsForRequest forKey:point];
	}
	
	[self enqueueReadRequestForEndpointAndExpectedReturnCode:point expectedRC:200 pk:pk table:table seq:seq];
}

-(SQLDatabaseSnapshot *) dispatchResults:(BOOL)success point:(NSString *)point andResult:(NSMutableDictionary *)result  error:(NSError *)error table:(NSString *)table{
	SQLDatabaseSnapshot *snap = [[SQLDatabaseSnapshot alloc] initWithDictionary:success?result:nil andTable:table];
	@synchronized (blocksQueueForOngoingRequests) {
		for (BlockVector *bv in [blocksQueueForOngoingRequests objectForKey:point]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (success||bv.cancelBlock == nil)
					bv.okBlock(snap);
				else
					bv.cancelBlock(error);
			});
		}
		[blocksQueueForOngoingRequests removeObjectForKey:point];
		return snap;
	}
}

-(NSError *) errorForReason:(NSString *)description code:(long)code{
	NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:description forKey:@"description"];
	[userInfo setObject:[NSNumber numberWithLong:code] forKey:@"code"];
	NSError *e = [[NSError alloc] initWithDomain:@"[SQLDATABASE]" code:code userInfo:userInfo];
	return e;
}

-(void) enqueueReadRequestForEndpointAndExpectedReturnCode :(NSString *)point expectedRC:(int)expectedRC pk:(NSString *)pk table:(NSString *)table seq:(NSNumber *)seq{
	
	NSURL *url =[NSURL URLWithString:point];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	[urlRequest setHTTPMethod:@"GET"];
	[urlRequest setValue:MEDIA_TYPE forHTTPHeaderField:@"Accept"];
	[urlRequest setValue:MEDIA_TYPE forHTTPHeaderField:@"Content-Type"];
	[urlRequest setValue:[SQLDatabase database].endPoint.authToken forHTTPHeaderField:@"X-AUTH-TOKEN"];
	[urlRequest setValue:ENCODING forHTTPHeaderField:@"charset"];
	[urlRequest setValue:0 forHTTPHeaderField:@"Content-Length"];
	[[SQLDatabaseApiPlatformStore.sharedManager.manager dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
		NSString* errorResponse = error ? [[NSString alloc] initWithData:(NSData *)error.userInfo[AFNetworkingOperationFailingURLResponseDataErrorKey] encoding:NSUTF8StringEncoding] : nil;
		LOGD(@"[%@][read http response] %@ code = %d, error=%@",seq,point,[httpResponse statusCode],errorResponse);
		NSError *jsonerror = nil;
		if (!error && [httpResponse statusCode] == expectedRC) {
			NSMutableDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&jsonerror];
			if (jsonerror == nil) {
				SQLDatabaseSnapshot *snap =[self dispatchResults:true point:point andResult:result error:nil table:table];
				if (SQLDatabase.database.endPoint.localCacheEnabled) {
					[SQLDatabaseLocalCache.instance put:point value:snap];
				}
				LOGD(@"[%@][read response] %@ %@",seq,point,result);
			} else {
				LOGD(@"[%@][read error - json] %@ %@",seq,point,jsonerror);
				[self dispatchResults:false point:point andResult:nil error:jsonerror table:table];
			}
		} else {
			NSError *e = [self errorForReason:@"wrong return code." code:[httpResponse statusCode]];
			LOGE(@"[%@][read error - wrong status code] %@ %@",seq,point,e);
			SQLDatabaseSnapshot *snap = [self dispatchResults:false point:point andResult:nil error:e table:table];
			if (SQLDatabase.database.endPoint.localCacheEnabled) {
				[SQLDatabaseLocalCache.instance put:point value:snap];
			}
		}
	}] resume];
}



-(void) insert:(NSString *)table json:(NSDictionary *)jsonDict block:(void (^)(NSError *))block keepCache:(BOOL)keepCache{
	SQLDatabaseEndPoint *endPoint = [SQLDatabase database].endPoint;
	NSString *point = [NSString stringWithFormat:@"%@/%@",endPoint.uriString,table];
	NSNumber *seq = self.getSeqNum;
	LOGD(@"[%@][insert request] %@ %@",seq,point,jsonDict);
	[self enqueueWriteRequestForEndpointAndExpectedReturnCode:point jsonDict:jsonDict method:@"POST" expectedRC:201 table:table okBlock:block seq:seq keepCache:keepCache];
}


-(void) remove:(NSString *)table pk:(NSString *)pk block:(nullable void (^)(NSError *))block  keepCache:(BOOL)keepCache{
	SQLDatabaseEndPoint *endPoint = [SQLDatabase database].endPoint;
	NSString *point = [NSString stringWithFormat:@"%@/%@/%@",endPoint.uriString,table,pk];
	NSNumber *seq = self.getSeqNum;
	LOGD(@"[%@][remove request] %@",seq,point);
	[self enqueueWriteRequestForEndpointAndExpectedReturnCode:point jsonDict:nil method:@"DELETE" expectedRC:204 table:table okBlock:block seq:seq keepCache:keepCache];
}



-(void) update:(NSString *)table pk:(NSString *)pk json:(NSDictionary *)jsonDict block:(void (^)(NSError *))block insertOn404:(BOOL)insertOn404 keepCache:(BOOL)keepCache{
	SQLDatabaseEndPoint *endPoint = [SQLDatabase database].endPoint;
	NSString *point = [NSString stringWithFormat:@"%@/%@/%@",endPoint.uriString,table,pk];
	NSNumber *seq = self.getSeqNum;
	LOGD(@"[%@][update request] insertOn404=%d %@ %@",seq,insertOn404,point,jsonDict);
	NSURL *url =[NSURL URLWithString:point];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSData *requestData = [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil];
	[urlRequest setHTTPBody:requestData];
	[urlRequest setHTTPMethod:@"PUT"];
	[urlRequest setValue:MEDIA_TYPE forHTTPHeaderField:@"Accept"];
	[urlRequest setValue:MEDIA_TYPE forHTTPHeaderField:@"Content-Type"];
	[urlRequest setValue:[SQLDatabase database].endPoint.authToken forHTTPHeaderField:@"X-AUTH-TOKEN"];
	[urlRequest setValue:ENCODING forHTTPHeaderField:@"charset"];
	[urlRequest setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[requestData length]] forHTTPHeaderField:@"Content-Length"];
	[[SQLDatabaseApiPlatformStore.sharedManager.manager dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
		LOGD(@"[%@][update response] insertOn404=%d %@ %d",seq,insertOn404,point,[httpResponse statusCode]);
		if ([httpResponse statusCode] == 404 && insertOn404) {
			[self insert:table json:jsonDict block:block];
		} else if (!error && [httpResponse statusCode] == 200) {
			if (!keepCache)
				[SQLDatabaseLocalCache.instance clear];
			dispatch_async(dispatch_get_main_queue(), ^{
				if (block)
					block(nil);
			});
		} else {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (block)
					block(error);
			});
		}
	}] resume];
}

-(void) enqueueWriteRequestForEndpointAndExpectedReturnCode :(NSString *)point jsonDict:(NSDictionary *)jsonDict method:(NSString *)method expectedRC:(int)expectedRC  table:(NSString *)table okBlock:(void (^)(NSError *))okBlock seq:(NSNumber *)seq keepCache:(BOOL)keepCache{
	NSURL *url =[NSURL URLWithString:point];
	NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
	NSData *requestData = jsonDict ? [NSJSONSerialization dataWithJSONObject:jsonDict options:0 error:nil] : nil;
	[urlRequest setHTTPBody:requestData];
	[urlRequest setHTTPMethod:method];
	[urlRequest setValue:MEDIA_TYPE forHTTPHeaderField:@"Accept"];
	[urlRequest setValue:MEDIA_TYPE forHTTPHeaderField:@"Content-Type"];
	[urlRequest setValue:[SQLDatabase database].endPoint.authToken forHTTPHeaderField:@"X-AUTH-TOKEN"];
	[urlRequest setValue:ENCODING forHTTPHeaderField:@"charset"];
	[urlRequest setValue:[NSString stringWithFormat:@"%lu", jsonDict ? (unsigned long)[requestData length] : 0] forHTTPHeaderField:@"Content-Length"];
	[[SQLDatabaseApiPlatformStore.sharedManager.manager dataTaskWithRequest:urlRequest completionHandler:^(NSURLResponse * _Nonnull response, id  _Nullable responseObject, NSError * _Nullable error) {
		NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
		LOGD(@"[%@][%@ response] %@ %d %@",seq,[method isEqualToString:@"POST"] ? @"insert" : @"delete",point,[httpResponse statusCode],[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding]);
		if (!error && [httpResponse statusCode] == expectedRC) {
			if (!keepCache)
				[SQLDatabaseLocalCache.instance clear];
			dispatch_async(dispatch_get_main_queue(), ^{
				if (okBlock)
					okBlock(nil);
			});
		} else {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (okBlock)
					okBlock(error);
			});
		}
	}] resume];
}


+(SQLDatabaseApiPlatformStore *)sharedManager {
	static dispatch_once_t pred;
	static SQLDatabaseApiPlatformStore *shared = nil;
	dispatch_once(&pred, ^{
		shared = [[SQLDatabaseApiPlatformStore alloc]init];
		shared.blocksQueueForOngoingRequests = [[NSMutableDictionary alloc] init];
		NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
		shared.manager = [[AFHTTPSessionManager alloc] initWithSessionConfiguration:configuration];
		[shared.manager setResponseSerializer:[AFHTTPResponseSerializer serializer]];
		[shared.manager setRequestSerializer:[AFHTTPRequestSerializer serializer]];
		[shared.manager.requestSerializer setValue:MEDIA_TYPE forHTTPHeaderField:@"Content-Type"];
		[shared.manager setTaskDidReceiveAuthenticationChallengeBlock:^NSURLSessionAuthChallengeDisposition(NSURLSession * _Nonnull session, NSURLSessionTask * _Nonnull task, NSURLAuthenticationChallenge * _Nonnull challenge, NSURLCredential *__autoreleasing  _Nullable * _Nullable credential) {
			NSString *authenicationMethod = challenge.protectionSpace.authenticationMethod;
			if ([authenicationMethod isEqualToString:NSURLAuthenticationMethodHTTPDigest]) {
				if (!SQLDatabase.database.endPoint.authUser) {
					return NSURLSessionAuthChallengeCancelAuthenticationChallenge;
				}
				*credential = [NSURLCredential credentialWithUser:SQLDatabase.database.endPoint.authUser password:SQLDatabase.database.endPoint.authPass persistence:NSURLCredentialPersistenceForSession];
				return NSURLSessionAuthChallengeUseCredential;
			}
			if ([authenicationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]) {
				*credential = [NSURLCredential credentialWithUser:SQLDatabase.database.endPoint.authUser password:SQLDatabase.database.endPoint.authPass persistence:NSURLCredentialPersistencePermanent];
				return NSURLSessionAuthChallengeUseCredential;
			}
			return NSURLSessionAuthChallengeCancelAuthenticationChallenge;
		}];
	});
	return shared;
}

@end
