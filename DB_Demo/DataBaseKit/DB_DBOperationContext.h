//
//  DB_DBOperationContext.h
//  DB_MyBaby
//
//  Created by 支舍社 on 2017/3/21.
//  Copyright © 2017年 Bohuai Chen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DB_DatabaseConstants.h"

@interface DB_DBOperationContext : NSObject

@property (nonatomic, strong) NSString *tableName;
//! 进行数据表操作的类型，是个枚举
@property (nonatomic, assign) TableOpertaionType opertionType;
//! 进行数据表操作时的字典，一般用在插入、更新数据操作中
@property (nonatomic, strong) NSDictionary *updateDict;
//! 要查询的字段名
@property (nonatomic, strong) NSString *fieldName;
//! 要排序的字段名
@property (nonatomic, strong) NSString *sortKey;
//! 是否进行排序
@property (nonatomic, assign) BOOL isDesc;
//! 筛选的条目
@property (nonatomic, assign) DBQueryLimitRang queryLimit;
//! 自己定义筛选条件，
@property (nonatomic, strong) NSString *whereSQL;
//! 单个筛选条件，一般用在update，delete操作中
@property (nonatomic, strong) NSDictionary *filterDict;
//! AND 筛选条件 与下面条件二选一
@property (nonatomic, strong) NSDictionary *queryCondationAndFilterDict;
//! OR 筛选条件 与上面条件二选一
@property (nonatomic, strong) NSDictionary *queryCondationOrFilterDict;
//! 筛选后返回的Model名
@property (nonatomic, strong) Class modelClas;

#pragma mark - 查询全能语句
/**
 组装查全能查询语句
 @auth  zhisheshe
 @date  2017-03-15
 @param tableName 要执行操作的表名
 @param queryFieldName 要查询的字段名
 @param whereSQL where 相关的SQL语句
 @param sortKey 要排序的字段
 @param isDesc 是否降序
 @param queryLimit 要查询的数据条目
 @return 返回一个组装好的全能查询对象
 */
+ (instancetype)queryDataContextWithTableName:(NSString *)tableName
                               queryFieldName:(NSArray *)queryFieldName
                                     whereSQL:(NSString *)whereSQL
                                      sortKey:(NSString *)sortKey
                                       isDesc:(BOOL)isDesc
                                   queryLimit:(DBQueryLimitRang)queryLimit;


@end
