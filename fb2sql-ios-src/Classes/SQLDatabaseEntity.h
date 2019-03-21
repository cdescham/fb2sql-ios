//
//  SQLEntity.h
//  SQLDatabase
//
//  Created by Christophe Deschamps on 06/03/2019.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface SQLDatabaseEntity : NSObject


+(NSArray *)getNormalizers;
+(NSArray *)getDeNormalizers;


@end

NS_ASSUME_NONNULL_END
