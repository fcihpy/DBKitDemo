//
//  NSObject+Property.m
//  DB_Demo
//
//  Created by 支舍社 on 2017/4/24.
//  Copyright © 2017年 支舍社. All rights reserved.
//

#import "NSObject+Property.h"
#import <objc/runtime.h>

#pragma mark 根据属性名获取属性类型
static NSString *property_getTypeName(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T') {  //对象
            size_t len = strlen(attribute);
            NSString *propertyType = nil;
            if (len > 2) {
                
                attribute[len -1] = '\0';
                const char *propertyTypeChar = (const char *)[[NSData dataWithBytes:(attribute + 3) length:len -2] bytes];
                propertyType =  [NSString stringWithUTF8String:propertyTypeChar];
            } else {
                propertyType = [NSString stringWithCString: property_getAttributes(property) encoding:NSUTF8StringEncoding];
                if ([propertyType hasPrefix:@"TB"]) {
                    propertyType = @"BOOL";
                } else if ([propertyType hasPrefix:@"Tq"]) {
                    propertyType = @"NSInteger";
                } else if ([propertyType hasPrefix:@"TQ"]) {
                    propertyType = @"NSUInteger";
                }else if ([propertyType hasPrefix:@"Tf"]) {
                    propertyType = @"flot";
                }else if ([propertyType hasPrefix:@"Tl"]) {
                    propertyType = @"long";
                }else if ([propertyType hasPrefix:@"Td"]) {
                    propertyType = @"double";
                }else if ([propertyType hasPrefix:@"Ti"]) {
                    propertyType = @"int";
                }
            }
            return propertyType;
        }
    }
    return @"";
}

@implementation NSObject (Property)

+ (NSDictionary *)propertyInfoDict {
    NSMutableDictionary *infoDict = [NSMutableDictionary dictionary];
    unsigned int outcCount, i ;
    objc_property_t *properties = class_copyPropertyList([self class], &outcCount);
    for (i = 0 ; i < outcCount; i ++) {
        objc_property_t property = properties[i];
        
        //获取属性名propoert
        const char *tempName = property_getName(property);
        NSString *propertyName = [NSString stringWithCString:tempName encoding:NSUTF8StringEncoding];
        
        //获取属性类型等参数
        NSString *propertyType = property_getTypeName(property);
        NSDictionary *dict = @{propertyName: propertyType};
        [infoDict addEntriesFromDictionary:dict];
    }
    free(properties);
    return infoDict;
}

@end

