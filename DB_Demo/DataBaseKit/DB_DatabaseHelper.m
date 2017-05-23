//
//  DB_DatabaseHelper.m
//  DB_MyBaby
//
//  Created by 支舍社 on 2017/3/7.
//  Copyright © 2017年 Bohuai Chen. All rights reserved.
//

#import "DB_DatabaseHelper.h"
#import "DB_DBOperationContext.h"
#import "DB_TableSQL.h"
#import "NSObject+Property.h"

#ifndef weakify
#if DEBUG
#if __has_feature(objc_arc)
#define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
#endif
#else
#if __has_feature(objc_arc)
#define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
#else
#define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
#endif
#endif
#endif

#ifndef strongify
#if DEBUG
#if __has_feature(objc_arc)
#define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
#endif
#else
#if __has_feature(objc_arc)
#define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
#else
#define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
#endif
#endif
#endif

static const float DBVERSION = 3.1f;
static  NSString *DB_VERSION_KEY = @"ser_version";
static  NSString *DB_Name = @"testDB";

@interface DB_DatabaseHelper ()
@property (nonatomic, strong) NSString *DBName;
@property (nonatomic, copy) NSString   *DBPath;
@property (nonatomic, strong) FMDatabaseQueue *databaseQueue;
@property (nonatomic, strong)dispatch_queue_t sqliteOpertationQueue;

- (void)createTableIfNeed;

@end

@implementation DB_DatabaseHelper
#pragma mark - -------------- DB method
+ (instancetype)sharedHelper {
    static DB_DatabaseHelper *_instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[DB_DatabaseHelper alloc] initDBWithDBName:DB_Name];
    });
    return _instance;
}

#pragma mark - 数据库管理
- (instancetype)initDBWithDBName:(NSString *)DBName {
    if (self = [super init]) {
//        DB_Assert(DBName);
        self.DBName = DB_Name;
        [self DBPath];
        [self databaseQueue];
        [self switchOnForeignKey];
        [self createTableIfNeed];
        [self updateDBVersion:DBVERSION];

    }
    return self;
}

+ (instancetype)helperWithDBName:(NSString *)DBName {
    return [[self alloc] initDBWithDBName:DBName];
}

#pragma mark 更新数据库版本
- (void)updateDBVersion:(float)newVersion {
    NSString *updateVersionSQL = [NSString stringWithFormat:@"PRAGMA %@ = %ld",DB_VERSION_KEY, (long)newVersion];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        BOOL isSuccess = [db executeUpdate:updateVersionSQL];
        if (isSuccess) {
            
        }else {
            
        }
    }];
}

#pragma mark 查询数据库版本
- (NSNumber *)DBVersion {
    NSString *queryVersionSQL = [NSString stringWithFormat:@"PRAGMA %@",DB_VERSION_KEY];
    __block int nVersion = 0;
    [_databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *result = [db executeQuery:queryVersionSQL];
        
        while ([result next]) {
            nVersion = [result intForColumn:DB_VERSION_KEY];
        }
        [result close];
    }];
    return @(nVersion);
}

#pragma mark 关闭数据库
- (void)closeDB{
    if ([self.databaseQueue openFlags] == 1) {
        DBLog(@"数据库已打开，或打开失败。请求关闭数据库失败。");
        return;
    }
    [self.databaseQueue close];
    DBLog(@"关闭数据库成功。");
}

#pragma mark - -------------- lazy method
- (NSString *)DBPath {
    if (!_DBPath) {
        NSFileManager *fileManager = [NSFileManager defaultManager];
        NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *appCachPath = [NSString stringWithFormat:@"%@/fcihpy",docPath];
        if (![fileManager fileExistsAtPath:appCachPath isDirectory:nil]) {
            NSError *error = nil;
            [fileManager createDirectoryAtPath:appCachPath withIntermediateDirectories:NO attributes:nil error:&error];
            if (error) {
                DBLog(@"数据库文件夹建立失败");
            }
        }
        _DBPath = [appCachPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.sqlite",_DBName]];
    }
    DBLog(@"DB-Path: %@",_DBPath);
    return _DBPath;
}

- (dispatch_queue_t)sqliteOpertationQueue {
    if (!_sqliteOpertationQueue) {
        _sqliteOpertationQueue = dispatch_queue_create("com.DB_MB.sqliteQueue", DISPATCH_QUEUE_SERIAL);
    }
    return _sqliteOpertationQueue;
}

- (FMDatabaseQueue *)databaseQueue {
    @synchronized (self) {
        if (!_databaseQueue) {
            _databaseQueue = [FMDatabaseQueue databaseQueueWithPath:_DBPath];
        } 
    }
    
    return _databaseQueue;
}

#pragma mark - -------------- private method
- (NSArray<NSString *> *)getColumnFromTableName:(NSString *)tableName {
    NSString *columnSQL = [NSString stringWithFormat:@"PRAGMA table_info(%@)",tableName];
    if (!tableName) {
        return nil;
    }
    __block NSMutableArray *columnNameArray = [NSMutableArray array];
    __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *resultSet = [db executeQuery:columnSQL];
        while ([resultSet next]) {
            NSString *columnName = [resultSet stringForColumn:@"name"];
            [columnNameArray addObject:columnName];
        }
        dispatch_semaphore_signal(sem);
        [resultSet close];
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return columnNameArray;
}

- (void)switchOnForeignKey {
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        [db executeUpdate:@"PRAGMA foreign_keys=ON;"];
    }];
}

- (BOOL)deleteDataBase {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:self.DBPath]) {
        NSError *error = nil;
        return [fileManager removeItemAtPath:self.DBPath error:&error];
    }
    return YES;
}
@end

@implementation DB_DatabaseHelper (Table)

#pragma mark - -------------- createTable
- (void)createTableIfNeed {
    @autoreleasepool {
        [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
            NSString *userInfoTableSQL = [DB_TableSQL userInfoTableSQL];
            [db executeUpdate:userInfoTableSQL];
        }];
    }
}

#pragma mark - 数据表相关
- (void)handleDataWithDBOperationContext:(DB_DBOperationContext *)DBContext
                             resultBlock:(void (^) (BOOL isSuccess,
                                                    NSString *resultMsg))resultBlock {
    
    NSString *excuteSQL = nil;
    NSString *execuResultMsg = @"插入数据成功";
    NSString *tableName = DBContext.tableName;
    NSString *whereSQL = DBContext.whereSQL;
    __block NSString *filterSQL = [NSString string];
    //根据字典拼接筛选条件语句
    if (DBContext.filterDict && DBContext.filterDict.count > 0) {
        [DBContext.filterDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key,
                                                                  id  _Nonnull obj,
                                                                  BOOL * _Nonnull stop) {
            filterSQL = [NSString stringWithFormat:@"%@ = '%@'",key,obj];
        }];
    }
    if (DBContext.opertionType == TableOpertaionTypeSave) {
        if ([filterSQL isEqualToString:@""]) {
            [self insertDataWithDBOperationContext:DBContext];
        }else {
            //根据条件，从数据表中查询记录，有则执行更新操作，无则执行插入操作
            NSInteger count = [self countOfTableName:tableName
                                            whereSQL:filterSQL];
            if (count > 0) {
                if (resultBlock) {
                    if ([self updatDataWithDBOperationContext:DBContext]) {
                        resultBlock(YES,@"更新数据成功");
                    }else {
                        resultBlock(NO,@"更新数据失败");
                    }
                }
            }else {
                if (resultBlock) {
                    if ([self insertDataWithDBOperationContext:DBContext]) {
                        resultBlock(YES,@"插入数据成功");
                    }else {
                        resultBlock(NO,@"插入数据失败");
                    }
                }
            }
        }
    } else {
        switch (DBContext.opertionType) {
                
            case TableOpertaionTypeDelete:  //删除数据
            {//SQLEXAMPLE   WHERE field 条件
                if (!DB_IS_STR_NIL(filterSQL)) {
                    excuteSQL = [NSString stringWithFormat:
                                 @"DELETE FROM %@ WHERE %@",
                                 tableName, filterSQL];
                }else {
                    excuteSQL = [NSString stringWithFormat:
                                 @"DELETE FROM %@",
                                 tableName];
                }
                execuResultMsg = @"删除数据成功";
                
            }
                break;
                
            case TableOpertaionTypeAlter:  //更新字段
            {
                excuteSQL = [NSString stringWithFormat:
                             @"ALTER TABLE %@ ADD COLUMN %@",
                             tableName, DBContext.fieldName];
            }
                break;
            case TableOpertaionTypeUpdateDBVersion:
            {
                excuteSQL = whereSQL;
                execuResultMsg = @"数据库版本更新成功";
            }
                break;                
            default:
                break;
                
        }
        DB_dispatch_main_async_safe(^{
            if (!excuteSQL) {
                if (resultBlock) {
                    resultBlock(NO, @"缺少sql语句");
                }
            } else {
                [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                    DBLog(@"DBSql:%@",excuteSQL);
                    [db executeUpdate:excuteSQL];
                    if ([db hadError]) {
                        if (resultBlock) {
                            resultBlock(NO, [db lastErrorMessage]);
                        }
                    } else {
                        if (resultBlock) {
                            resultBlock(YES, execuResultMsg);
                        }
                    }
                }];
            }
        });
    }
}

- (BOOL)insertDataWithDBOperationContext:(DB_DBOperationContext *)DBContext {
    
    //清洗传进来的字典数据，只要与数据库字典匹配的
    NSDictionary *updateDict = [self purgeDataWithTableName:DBContext.tableName
                                                  modelDict:DBContext.updateDict];
    
    __block NSMutableString *keyString = [NSMutableString string];
    __block NSMutableString *valueString = [NSMutableString string];
    NSMutableArray *argArray = [NSMutableArray array];
    
    //获取数据库表中所有列名
    [updateDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key,
                                                    id  _Nonnull obj,
                                                    BOOL * _Nonnull stop) {
        if (![key isEqualToString:@"ID"]) {
            [keyString appendFormat:@",%@",key];
            [valueString appendFormat:@",?"];
            [argArray addObject:obj];
        }
    }];
    if (keyString && keyString.length > 0) {
        keyString = [[keyString substringFromIndex:1] mutableCopy];
    }
    if (valueString && valueString.length > 0) {
        valueString = [[valueString substringFromIndex:1] mutableCopy];
    }
    
    
    NSString *insertDataSQL = [NSString stringWithFormat:
                               @"INSERT INTO %@(%@) VALUES (%@)",
                               DBContext.tableName, keyString,valueString];
    
    //打印要执行sql语句
    DBLog(@"DBSql:%@",insertDataSQL);
    if (insertDataSQL) {
        __block BOOL isSuccess = NO;
        DB_dispatch_main_async_safe(^{
            [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                [db executeUpdate:insertDataSQL withArgumentsInArray:argArray];
                isSuccess = ![db hadError];
            }];
        });
        return isSuccess;
    } else {
        return NO;
    }
}

- (BOOL)updatDataWithDBOperationContext:(DB_DBOperationContext *)DBContext {
    //清洗传进来的字典数据，只要与数据库字典匹配的
    NSDictionary *updateDict = [self purgeDataWithTableName:DBContext.tableName
                                                  modelDict:DBContext.updateDict];
    
    NSArray *filterColumnArray = DBContext.filterDict.allKeys;
    
    NSMutableString *tempSQL = [NSMutableString string];
    [updateDict enumerateKeysAndObjectsUsingBlock:^(id  _Nonnull key,
                                                    id  _Nonnull data,
                                                    BOOL * _Nonnull stop) {
        
        [filterColumnArray enumerateObjectsUsingBlock:^(id  _Nonnull obj,
                                                        NSUInteger idx,
                                                        BOOL * _Nonnull stop) {
            if (![key isEqualToString:obj]) {
                [tempSQL appendFormat:@"%@ = '%@',",key,data];
            }
        }];
    }];
    __block NSString *filterSQL = [NSString string];
    [DBContext.filterDict enumerateKeysAndObjectsUsingBlock:^(NSString * _Nonnull key,
                                                              id  _Nonnull obj,
                                                              BOOL * _Nonnull stop) {
        filterSQL = [NSString stringWithFormat:@"%@ = '%@'",key,obj];
    }];
    
    NSMutableString *updateSQL = [NSMutableString stringWithFormat:
                                  @"UPDATE %@ SET %@ where %@",
                                  DBContext.tableName, [tempSQL substringToIndex:tempSQL.length - 1],filterSQL];
    if (updateSQL) {
        __block BOOL isSuccess = NO;
        DB_dispatch_main_async_safe(^{
            [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                [db executeUpdate:updateSQL];
                isSuccess = ![db hadError];
            }];
        });
        return isSuccess;
    } else {
        return NO;
    }
}

#pragma mark 清洗传进来的字典数据
- (NSDictionary *)purgeDataWithTableName:(NSString *)tableName
                               modelDict:(NSDictionary *)modelDict {
    
    __block NSMutableDictionary *updateDict = [NSMutableDictionary dictionary];
    [[self getColumnFromTableName:tableName] enumerateObjectsUsingBlock:^(NSString * _Nonnull obj,
                                                                          NSUInteger idx,
                                                                          BOOL * _Nonnull stop) {
        if (obj && ![obj isEqualToString:@"ID"]) {
            NSString *valueData = modelDict[obj];
            NSDictionary *dict = @{obj : valueData ? valueData:@" "};;
            [updateDict addEntriesFromDictionary:dict];
        }
    }];
    return updateDict;
}

#pragma mark - -------------- 查询
- (NSArray<NSDictionary *> *)queryDataWithDBOperationContext:(DB_DBOperationContext *)DBContext {
    if (!DBContext) {
        return nil;
    }
    //获取某张表的所有字段名
    __block NSArray *fieldNameArray = [self getColumnFromTableName:DBContext.tableName];
    __block  NSMutableArray *dataArray = [NSMutableArray array];
    __block NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    //获取类的属性信息
    NSDictionary *modelInfoDict = [DBContext.modelClas propertyInfoDict];
    __block dispatch_semaphore_t sem = dispatch_semaphore_create(0);
    [self queryDBWithContext:DBContext resultBlock:^(FMResultSet *result) {
        while ([result next]) {
            for (NSString *fildName in fieldNameArray) {
                NSString *propertyType = modelInfoDict[fildName];
                if ([propertyType isEqualToString:@"NSString"]) {
                    [result stringForColumn:fildName];
                    [dict addEntriesFromDictionary:@{fildName : [result stringForColumn:fildName]}];
                }else if ([propertyType isEqualToString:@"NSNumber"]) {
                    [result intForColumn:fildName];
                    [dict addEntriesFromDictionary:@{fildName : @([result intForColumn:fildName])}];
                }else if ([propertyType isEqualToString:@"NSInteger"]) {
                    [result intForColumn:fildName];
                    [dict addEntriesFromDictionary:@{fildName : @([result intForColumn:fildName])}];
                }
            }
            [dataArray addObject:dict];
            
        }
        dispatch_semaphore_signal(sem);
    }];
    dispatch_semaphore_wait(sem, DISPATCH_TIME_FOREVER);
    return dataArray;
}


- (void)queryDBWithContext:(DB_DBOperationContext *)DBContext
               resultBlock:(void (^) (FMResultSet *result))resultBlock {
    NSMutableString *selectSQL = [NSMutableString string];
    NSString *tableName = DBContext.tableName;
    NSString *queryFieldName = DBContext.fieldName;
    NSString *whereSQL = DBContext.whereSQL;
    NSString *sortKey = DBContext.sortKey;
    
    //1、判断表名是否为空
    if (!tableName) {
        NSAssert(tableName, @"表名不能为空");
        if (resultBlock) {
            resultBlock(nil);
        };
    }
    //2、判断要查询的字段
    if (queryFieldName) {
        [selectSQL appendFormat:@"SELECT %@ FROM %@",queryFieldName, tableName];
    } else {
        [selectSQL appendFormat:@"SELECT * FROM %@", tableName];
    }
    //3、构建wher条件
    if (whereSQL) {
        [selectSQL appendFormat:@" WHERE %@",whereSQL];
    } else if (DBContext.filterDict) {
        
    } else if (DBContext.queryCondationAndFilterDict) {
        
    } else if (DBContext.queryCondationOrFilterDict) {
        
    }
    //4、判断是否排序
    if (sortKey) {
        [selectSQL appendFormat:@" ORDER BY %@ %@",sortKey,DBContext.isDesc ? @"DESC":@"ASC"];
    }
    //5、判断输出限制
    if (DBContext.queryLimit.count) {
        [selectSQL appendFormat:@" LIMIT %lu OFFSET %lu",DBContext.queryLimit.count,DBContext.queryLimit.atIndex];
    }
    DBLog(@"--------->%@",selectSQL);
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        if (selectSQL) {
            //6、执行查询数据库操作
            [self.databaseQueue inDatabase:^(FMDatabase *db) {
                FMResultSet *rs = [db executeQuery:selectSQL];
                if (resultBlock) {
                    if ([db hadError]) {
                        resultBlock(nil);
                    }else {
                        resultBlock(rs);
                    }
                }
                [rs close];
            }];
        } else {
            if (resultBlock) {
                resultBlock(nil);
            }
        }
    });
}

#pragma mark 获取表中总数据长度
- (NSInteger)countOfTableName:(NSString *)tableName whereSQL:(nonnull NSString *)whereSQL{
    
    __block int count = 0;
    NSString *querySQL = [NSString stringWithFormat:@"SELECT COUNT(*) FROM %@ WHERE %@",tableName,whereSQL];
    [self.databaseQueue inDatabase:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:querySQL];
        while ([rs next]) {
            count = [rs intForColumnIndex:0];
        }
        [rs close];
    }];
    return count;
}

@end

