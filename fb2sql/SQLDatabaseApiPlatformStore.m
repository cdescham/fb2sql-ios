//
//  SQLDatabaseApiPlatformStore.m
//  fb2sql
//
//  Created by Tof on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLDatabaseApiPlatformStore.h"
#import "SQLDatabase.h"
#import "SQLDatabaseSnapshot.h"
#import "BlockVector.h"
#import "SQLDatabaseLocalCache.h"


@implementation SQLDatabaseApiPlatformStore
@synthesize seqNum,blocksQueueForOngoingRequests;

-(NSNumber *) getSeqNum {
	@synchronized (seqNum) {
		seqNum = [NSNumber numberWithLongLong:[seqNum longLongValue] + 1];
		return seqNum;
	}
}

-(void) get:(NSString *)table pk:(NSString *)pk geoSearch:(NSString *)geoSearch parameters:(NSString *)parameters okBlock:(void (^)(SQLDatabaseSnapshot *))okBlock koBlock:(void (^)(NSError *))koBlock {
	SQLDatabaseEndPoint *endPoint = [SQLDatabase database].endPoint;
	NSNumber *seq = self.getSeqNum;
	NSString *point = nil;
	if (pk)
		point =[NSString stringWithFormat:@"%@/%@/%@?%@",endPoint.uriString,table,pk,parameters] ;
	else if (geoSearch)
		point =[NSString stringWithFormat:@"%@/%@/%@?%@",endPoint.uriString,table,geoSearch,parameters] ;
	else
		point =[NSString stringWithFormat:@"%@/%@?%@",endPoint.uriString,table,parameters];
	LOGD(@"[%@][read request] %@",seq,point);
	if (endPoint.localCacheEnabled) {
		NSDictionary *json = [SQLDatabaseLocalCache.instance get:point ttl:endPoint.localcacheTTL];
		if (json) {
			okBlock([[SQLDatabaseSnapshot alloc] initWithDictionary:json]);
			return;
		}
	}
	@synchronized (blocksQueueForOngoingRequests) {
		BlockVector *bv = [[BlockVector alloc] init];
		bv.okBlock = okBlock;
		bv.koBlock = koBlock;
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

-(void) dispatchResults:(BOOL)success point:(NSString *)point andResult:(NSDictionary *)result  error:(NSError *)error{
	@synchronized (blocksQueueForOngoingRequests) {
		for (BlockVector *bv in [blocksQueueForOngoingRequests objectForKey:point]) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (success)
					bv.okBlock([[SQLDatabaseSnapshot alloc] initWithDictionary:result]);
				else
					bv.koBlock(error);
			});
		}
		[blocksQueueForOngoingRequests removeObjectForKey:point];
	}
}

-(NSError *) errorForReason:(NSString *)description code:(long)code{
	NSMutableDictionary * userInfo = [[NSMutableDictionary alloc] init];
	[userInfo setObject:description forKey:@"description"];
	[userInfo setObject:[NSNumber numberWithLong:code] forKey:@"code"];
	NSError *e = [[NSError alloc] initWithDomain:@"FB2SQL" code:code userInfo:userInfo];
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
		if (error) {
			dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(SQLDatabase.database.endPoint.retryTimeOut * NSEC_PER_SEC)), dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
				LOGD(@"[%@][read request retrying] %@",seq,point);
				[self enqueueReadRequestForEndpointAndExpectedReturnCode:point expectedRC:expectedRC pk:pk table:table seq:seq];
			});
		} else {
			NSError *jsonerror = nil;
			NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *) response;
			if ([httpResponse statusCode] == expectedRC) {
				NSDictionary *result = [NSJSONSerialization JSONObjectWithData:responseObject options:NSJSONReadingMutableContainers error:&jsonerror];
				if (jsonerror == nil) {
					if (SQLDatabase.database.endPoint.localCacheEnabled) {
						[SQLDatabaseLocalCache.instance put:point value:result];
					}
					LOGD(@"[%@][read response] %@",seq,point,result);
					[self dispatchResults:true point:point andResult:result error:nil];
				} else {
					LOGD(@"[%@][read error - json] %@",seq,point,jsonerror);
					[self dispatchResults:false point:point andResult:nil error:jsonerror];
				}
			} else {
				NSError *e = [self errorForReason:@"wrong return code." code:[httpResponse statusCode]];
				LOGD(@"[%@][read error - wrong status code] %@",seq,point,e);
				[self dispatchResults:false point:point andResult:nil error:e];
			}
		}
	}] resume];
}


-(void) insert:(NSString *)table json:(NSDictionary *)jsonDict okBlock:(void (^)(void))okBlock koBlock:(void (^)(NSError *))koBlock {
	SQLDatabaseEndPoint *endPoint = [SQLDatabase database].endPoint;
	NSString *point = [NSString stringWithFormat:@"%@/%@",endPoint.uriString,table];
	[self enqueueWriteRequestForEndpointAndExpectedReturnCode:point jsonDict:jsonDict method:@"POST" expectedRC:201 table:table okBlock:okBlock koBlock:koBlock];
}

-(void) delete:(NSString *)table pk:(NSString *)pk okBlock:(void (^)(void))okBlock koBlock:(void (^)(NSError *))koBlock {
	SQLDatabaseEndPoint *endPoint = [SQLDatabase database].endPoint;
	NSString *point = [NSString stringWithFormat:@"%@/%@/%@",endPoint.uriString,table,pk];
	[self enqueueWriteRequestForEndpointAndExpectedReturnCode:point jsonDict:nil method:@"DELETE" expectedRC:304 table:table okBlock:okBlock koBlock:koBlock];
}



-(void) update:(NSString *)table pk:(NSString *)pk json:(NSDictionary *)jsonDict okBlock:(void (^)(void))okBlock koBlock:(void (^)(NSError *))koBlock insertOn404:(BOOL)insertOn404{
	SQLDatabaseEndPoint *endPoint = [SQLDatabase database].endPoint;
	NSString *point = [NSString stringWithFormat:@"%@/%@/%@",endPoint.uriString,table,pk];
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
		if (!error && [httpResponse statusCode] == 404 && insertOn404) {
			[self insert:table json:jsonDict okBlock:okBlock koBlock:koBlock];
		} else if (!error && [httpResponse statusCode] == 200) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (okBlock)
					okBlock();
			});
		} else {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (koBlock)
					koBlock(error);
			});
		}
	}] resume];
}

-(void) enqueueWriteRequestForEndpointAndExpectedReturnCode :(NSString *)point jsonDict:(NSDictionary *)jsonDict method:(NSString *)method expectedRC:(int)expectedRC  table:(NSString *)table okBlock:(void (^)(void))okBlock koBlock:(void (^)(NSError *))koBlock{
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
		if (!error && [httpResponse statusCode] == expectedRC) {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (okBlock)
					okBlock();
			});
		} else {
			dispatch_async(dispatch_get_main_queue(), ^{
				if (koBlock)
					koBlock(error);
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
				if (!shared.digestUser) {
					return NSURLSessionAuthChallengeCancelAuthenticationChallenge;
				}
				*credential = [NSURLCredential credentialWithUser:shared.digestUser password:shared.digestPass persistence:NSURLCredentialPersistenceForSession];
				return NSURLSessionAuthChallengeUseCredential;
			}
			if ([authenicationMethod isEqualToString:NSURLAuthenticationMethodHTTPBasic]) {
				*credential = [NSURLCredential credentialWithUser:shared.basicUser password:shared.basicPass persistence:NSURLCredentialPersistencePermanent];
				return NSURLSessionAuthChallengeUseCredential;
			}
			return NSURLSessionAuthChallengeCancelAuthenticationChallenge;
		}];
	});
	return shared;
}

@end
