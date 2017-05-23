//
//  DB_DBOperationContext.m
//  DB_MyBaby
//
//  Created by 支舍社 on 2017/3/21.
//  Copyright © 2017年 Bohuai Chen. All rights reserved.
//

#import "DB_DBOperationContext.h"

@implementation DB_DBOperationContext

+ (instancetype)queryDataContextWithTableName:(NSString *)tableName
                                     whereSQL:(NSString *)whereSQL {
    
    return [self queryDataContextWithTableName:tableName
                                queryFieldName:nil
                                      whereSQL:whereSQL
                                       sortKey:nil
                                        isDesc:NO
                                    queryLimit:DBQueryLimitMakeRang(0, 0)];
}

- (instancetype)initWithTableName:(NSString *)tableName
                   queryFieldName:(NSString *)queryFieldName
                         whereSQL:(NSString *)whereSQL
                          sortKey:(NSString *)sortKey
                           isDesc:(BOOL)isDesc
                       queryLimit:(DBQueryLimitRang)queryLimit
                     opertionType:(TableOpertaionType)opertionType
                       updateDict:(NSDictionary *)updateDict {
    if (self = [super init]) {
        _tableName = tableName;
        _fieldName = queryFieldName;
        _whereSQL = whereSQL;
        _queryLimit = queryLimit;
        _isDesc = isDesc;
        _sortKey = sortKey;
        _opertionType = opertionType;
        _updateDict = updateDict;
    }
    return self;
}
@end
