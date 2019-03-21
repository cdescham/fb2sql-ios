//
//  SQLDatabase.m
//  fb2sql
//
//  Created by Christophe Deschamps on 01/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import "SQLDatabase.h"

static NSString *const PUSH_CHARS = @"-0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz";

@implementation SQLDatabase
@synthesize endPoint;


- (id)init {
    if (self = [super init]) {
        self.endPoint = [[SQLDatabaseEndPoint alloc] init];
        self.lVerbosity = Warn;
    }
    return self;
}

+ (SQLDatabase *) database{
    static dispatch_once_t pred;
    static SQLDatabase *shared = nil;
    dispatch_once(&pred, ^{
        shared = [[SQLDatabase alloc] init];
    });
    return shared;
}

+ (NSString *) irize:(NSString *)prop  value:(NSString *)value{
    return [NSString stringWithFormat:@"/api/%@s/%@",prop,value];
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


-(SQLDatabase *) enableLocalCacheWithTTL:(int)ttl {
	endPoint.localCacheEnabled = YES;
    endPoint.localcacheTTL = ttl;
	return [SQLDatabase database];
}

- (SQLDatabase *) setRetryTimeout:(int)retryto{
	endPoint.retryTimeOut = retryto;
	return [SQLDatabase database];
}

- (SQLDatabase *) setLogVerbosity:(int)verbosity{
	self.lVerbosity = verbosity;
	return [SQLDatabase database];
}

- (void) clearCache {
	[SQLDatabaseLocalCache.instance clear];
}


+ (void)log:(int)severity format:(NSString *)format, ... {
	if (severity < SQLDatabase.database.lVerbosity)
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
    if (!IRI || ![IRI hasPrefix:@"/api"])
        return nil;
	NSArray *components = [IRI componentsSeparatedByString:@"/"];
    return components[components.count-1];
}

+(NSString *) buildUriForProperty:(NSString *)property withValue:(NSString *)value {
	return [NSString stringWithFormat:@"/api/%@s/%@",property,value];
}

+(NSString *) generateID  {
        static long long lastPushTime = 0;
        static int lastRandChars[12];
    	NSTimeInterval currentTime = [NSDate timeIntervalSinceReferenceDate];
        long long now = (long long)(currentTime * 1000);
        
        BOOL duplicateTime = now == lastPushTime;
        lastPushTime = now;
        
        unichar timeStampChars[8];
        for(int i = 7; i >= 0; i--) {
            timeStampChars[i] = [PUSH_CHARS characterAtIndex:(now % 64)];
            now = (long long)floor(now / 64);
        }
        
        NSMutableString* id = [[NSMutableString alloc] init];
        [id appendString:[NSString stringWithCharacters:timeStampChars length:8]];
        
        
        if(!duplicateTime) {
            for(int i = 0; i < 12; i++) {
                lastRandChars[i] = (int)floor(arc4random() % 64);
            }
        }
        else {
            int i = 0;
            for(i = 11; i >= 0 && lastRandChars[i] == 63; i--) {
                lastRandChars[i] = 0;
            }
            lastRandChars[i]++;
        }
        
        for(int i = 0; i < 12; i++) {
            [id appendFormat:@"%C", [PUSH_CHARS characterAtIndex:lastRandChars[i]]];
        }
        
        return [NSString stringWithString:id];
}


@end



