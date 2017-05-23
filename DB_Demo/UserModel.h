//
//  UserModel.h
//  DB_Demo
//
//  Created by 支舍社 on 2017/4/24.
//  Copyright © 2017年 支舍社. All rights reserved.
//

#import "BaseModel.h"

@interface UserModel : BaseModel

@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *passwd;
@property (nonatomic, assign) NSInteger age;

@end
