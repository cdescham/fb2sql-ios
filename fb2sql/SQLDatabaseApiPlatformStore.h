//
//  SQLDatabaseApiPlatformStore.h
//  fb2sql
//
//  Created by Tof on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFHTTPSessionManager.h"


#define MEDIA_TYPE @"application/ld+json"
#define ENCODING @"utf-8"

NS_ASSUME_NONNULL_BEGIN

@interface SQLDatabaseApiPlatformStore : NSObject

@property NSNumber *seqNum;
@property AFHTTPSessionManager *manager ;
@property NSString *digestUser;
@property NSString *digestPass;
@property NSString *basicUser;
@property NSString *basicPass;
@property NSMutableDictionary *blocksQueueForOngoingRequests;

@end

NS_ASSUME_NONNULL_END
