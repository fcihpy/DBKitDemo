//
//  BaseModel.h
//  DB_Demo
//
//  Created by 支舍社 on 2017/4/24.
//  Copyright © 2017年 支舍社. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DB_DatabaseHelper.h"

@interface BaseModel : NSObject
//! 将字典转为model
+ (instancetype)modelWithDict:(nullable NSDictionary *)dict;

@end

@interface BaseModel (DB)
//! 查
+ (nullable NSArray <__kindof BaseModel *> *)queryModelWithDBOpertaionContext:(nonnull DB_DBOperationContext *)DBContext;
+ (nullable NSArray <NSDictionary *> *)queryDataWithDBOpertaionContext:(nonnull DB_DBOperationContext *)DBContext;
//! 存
+ (BOOL)saveWithTable:(nonnull NSString *)tableName
      filterfeildName:(nullable NSString *)filterfeildName
           ModelArray:(nullable NSArray <__kindof BaseModel *> *)modelArray;
//! 删
+ (BOOL)deleteModelArray:(nullable NSArray <__kindof BaseModel *> *)modelArray;

@end
