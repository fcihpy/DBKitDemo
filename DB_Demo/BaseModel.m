//
//  BaseModel.m
//  DB_Demo
//
//  Created by 支舍社 on 2017/4/24.
//  Copyright © 2017年 支舍社. All rights reserved.
//

#import "BaseModel.h"
#import "NSObject+Property.h"
#import "MJExtension.h"

@interface BaseModel ()


@end

@implementation BaseModel

//! 将字典转为model
+ (instancetype)modelWithDict:(nullable NSDictionary *)dict {
    return [self mj_objectWithKeyValues:dict];
}

//! 将model转为字典
- (NSDictionary *)dictValue {
    return [self mj_keyValues];
}
@end

@implementation BaseModel (DB)

//! 查
+ (nullable NSArray <__kindof BaseModel *> *)queryModelWithDBOpertaionContext:(nonnull DB_DBOperationContext *)DBContext {
    if (!DBContext) {
        return nil;
    }
    NSArray *dataArray = [[self databaseHelper] queryDataWithDBOperationContext:DBContext];
    NSMutableArray *modelArray = [NSMutableArray array];
    for (NSDictionary *dict in dataArray) {
        id model =  [self modelWithDict:dict];
        [modelArray addObject:model];
    }
    
    return modelArray;
}

+ (NSArray<NSDictionary *> *)queryDataWithDBOpertaionContext:(DB_DBOperationContext *)DBContext {
    NSMutableArray *dataArray = [NSMutableArray array];
    
    return dataArray;
}

//! 存
+ (BOOL)saveWithTable:(NSString *)tableName
      filterfeildName:(NSString *)filterfeildName
           ModelArray:(NSArray<__kindof BaseModel *> *)modelArray {
    __block BOOL result = NO;
    DB_DBOperationContext *context = [DB_DBOperationContext new];
    context.tableName = tableName;
    context.opertionType = TableOpertaionTypeSave;
    for (__kindof BaseModel *model in modelArray) {
        context.updateDict = [model dictValue];
        context.filterDict = @{USERNAME : [model valueForKey:filterfeildName]};
        [[self databaseHelper] handleDataWithDBOperationContext:context
                                                    resultBlock:^(BOOL isSuccess, NSString * _Nullable resultMsg) {
                                                        result = isSuccess;
                                                        if (!isSuccess) {
                                                            return;
                                                        }
                                                    }];
    }
    
    return result;
}


//! 删
+ (BOOL)deleteModelArray:(nullable NSArray <__kindof BaseModel *> *)modelArray {
    BOOL result = NO;
    
    return result;
}

+ (DB_DatabaseHelper *)databaseHelper {
    return [DB_DatabaseHelper sharedHelper];
}
@end
