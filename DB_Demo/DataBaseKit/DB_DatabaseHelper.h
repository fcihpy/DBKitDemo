//
//  DB_DatabaseHelper.h
//  DB_MyBaby
//
//  Created by 支舍社 on 2017/3/7.
//  Copyright © 2017年 Bohuai Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDB.h>
#import "DB_DatabaseConstants.h"
#import "DB_DBOperationContext.h"

@interface DB_DatabaseHelper : NSObject

+ (nullable instancetype)sharedHelper;

@end

@interface DB_DatabaseHelper (Table)
- (NSInteger)countOfTableName:(nonnull NSString *)tableName whereSQL:(nonnull NSString *)whereSQL;

- (nullable NSArray<NSString *> *)getColumnFromTableName:(nonnull NSString *)tableName;

- (nullable NSArray<NSDictionary *> *)queryDataWithDBOperationContext:(nonnull DB_DBOperationContext *)DBContext;

- (void)handleDataWithDBOperationContext:(nonnull DB_DBOperationContext *)DBContext
                             resultBlock:(void (^ _Nullable) (BOOL isSuccess,
                                                    NSString * _Nullable resultMsg))resultBlock;

@end


