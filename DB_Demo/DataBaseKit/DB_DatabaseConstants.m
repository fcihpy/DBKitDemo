//
//  DB_DatabaseConstants.m
//  DB_MyBaby
//
//  Created by 支舍社 on 2017/3/16.
//  Copyright © 2017年 Bohuai Chen. All rights reserved.
//

#import "DB_DatabaseConstants.h"
#define DB_force_inline __inline__ __attribute__((always_inline))

//MESSAGE_TABLE_FEILD
NSString *USERNAME = @"name";
NSString *PASSWD = @"passwd";
NSString *AGE = @"age";

//TABLE_FIELD_TYPE
NSString *TEXT = @"TEXT";
NSString *INTEGER = @"INTEGER";
NSString *BLOB = @"BLOB";

//TABLE_NAME
const NSString *TABLE_DB_USER_INFO = @"t_DB_USER";

extern DB_force_inline void DB_dispatch_main_async_safe(dispatch_block_t block) {
    if ([NSThread isMainThread]) {
        block();
    } else {
        dispatch_async(dispatch_get_main_queue(), block);
    }
}


