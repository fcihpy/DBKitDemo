//
//  DB_DatabaseConstants.h
//  DB_MyBaby
//
//  Created by 支舍社 on 2017/3/16.
//  Copyright © 2017年 Bohuai Chen. All rights reserved.
//

#ifndef DB_DatabaseConstants_h
#define DB_DatabaseConstants_h
#endif
#import <Foundation/Foundation.h>
//！数据表操作类型
typedef NS_ENUM(NSInteger, TableOpertaionType) {
    TableOpertaionTypeNone,
    TableOpertaionTypeSelect,
    TableOpertaionTypeSave,
    TableOpertaionTypeDelete,
    TableOpertaionTypeDrop,
    TableOpertaionTypeAlter,            //更新、增加表字段
    TableOpertaionTypeUpdateDBVersion,
    TableOpertaionTypeSelectCount,      //获取表中记录和目
};
typedef struct DBQueryLimitRang {
    NSUInteger         atIndex;
    NSUInteger         count;
}DBQueryLimitRang;

NS_INLINE DBQueryLimitRang DBQueryLimitMakeRang (NSUInteger count, NSUInteger atIndex) {
    DBQueryLimitRang limit;
    limit.count = count;
    limit.atIndex = atIndex;
    return limit;
}



//USER_TABLE_FEILD
extern NSString *USERNAME;
extern NSString *PASSWD;
extern NSString *AGE;

//TABLE_FIELD_TYPE
extern NSString *TEXT;
extern NSString *INTEGER;
extern NSString *BLOB;

//TABLE_NAME
extern NSString *TABLE_DB_USER_INFO;

//INDEX_TABLE_NAME
extern NSString *TABLE_DB_USER_INFO_INDEX;


//判断字符是否为空
#define DB_IS_STR_NIL(objStr)                  (![objStr isKindOfClass:[NSString class]] || objStr == nil || [objStr length] <= 0 || [objStr isKindOfClass:[NSNull class]])
#define DB_IS_DICT_NIL(objDict)                (![objDict isKindOfClass:[NSDictionary class]] || objDict == nil || [objDict count] <= 0 || [objDict isKindOfClass:[NSNull class]])
#define DB_IS_ARRAY_NIL(objArray)              (![objArray isKindOfClass:[NSArray class]] || objArray == nil || [objArray count] <= 0 || [objArray isKindOfClass:[NSNull class]])
#define DB_IS_NUM_NIL(objNum)                  (![objNum isKindOfClass:[NSNumber class]] || objNum == nil || [objNum isKindOfClass:[NSNull class]])
#define DB_IS_DATA_NIL(objData)                (![objData isKindOfClass:[NSData class]] || objData == nil || [objData length] <= 0 || [objData isKindOfClass:[NSNull class]])
#define DB_IS_SET_NIL(objData)                 (![objData isKindOfClass:[NSSet class]] || objData == nil || [objData count] <= 0 || [objData isKindOfClass:[NSNull class]])

/*打印日志*/
#ifdef DEBUG
#   define DBLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__);
#else
#   define DBLog(...) (void)0
#endif

//要求在主线程操作
extern void DB_dispatch_main_async_safe(dispatch_block_t block);
