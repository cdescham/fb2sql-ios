//
//  BlockVector.h
//  fb2sql
//
//  Created by Christophe Deschamps on 02/03/2019.
//  Copyright © 2019 Inventivelink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SQLDatabaseSnapshot.h"

NS_ASSUME_NONNULL_BEGIN

@interface BlockVector : NSObject

@property (nonatomic) void (^okBlock) (SQLDatabaseSnapshot*);
@property (nonatomic) void (^cancelBlock) (NSError *);


@end

NS_ASSUME_NONNULL_END
