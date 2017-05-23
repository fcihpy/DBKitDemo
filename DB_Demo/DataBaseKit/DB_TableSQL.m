//
//  DB_TableSQL.m
//  DB_MyBaby
//
//  Created by 支舍社 on 2017/3/24.
//  Copyright © 2017年 Bohuai Chen. All rights reserved.
//

#import "DB_TableSQL.h"
#import "DB_DatabaseConstants.h"

@implementation DB_TableSQL

+ (NSString *)userInfoTableSQL {
    return [NSString stringWithFormat:
            @"CREATE TABLE IF NOT EXISTS %@ (ID integer PRIMARY KEY NOT NULL, %@ %@,%@ %@,%@ %@)",
            TABLE_DB_USER_INFO,
            USERNAME,TEXT,
            PASSWD,TEXT,
            AGE,INTEGER];
}

@end
