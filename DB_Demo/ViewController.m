//
//  ViewController.m
//  DB_Demo
//
//  Created by 支舍社 on 2017/4/24.
//  Copyright © 2017年 支舍社. All rights reserved.
//

#import "ViewController.h"
#import "UserModel.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    UserModel *model1 = [UserModel new];
    model1.name = @"aaa";
    model1.passwd = @"1111";
    model1.age = 1;
    
    UserModel *model2 = [UserModel new];
    model2.name = @"bbbb";
    model2.passwd = @"22222";
    model2.age = 2;
    
    UserModel *model3 = [UserModel new];
    model3.name = @"cccc";
    model3.passwd = @"3333";
    model3.age = 3;
    
    NSArray *modelArray = @[model1,model2,model3];
    BOOL result =  [UserModel saveWithTable:TABLE_DB_USER_INFO filterfeildName:@"name" ModelArray:modelArray];
    NSLog(@"aasfasg");
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    DB_DBOperationContext *context = [DB_DBOperationContext new];
    context.tableName = TABLE_DB_USER_INFO;
    context.modelClas = [UserModel class];
    context.opertionType = TableOpertaionTypeSelect;
    
    NSArray *array = [UserModel queryModelWithDBOpertaionContext:context];
    NSLog(@"aa");
}
@end
