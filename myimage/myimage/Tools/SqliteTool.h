//
//  SqliteTool.h
//  myimage
//
//  Created by liuqingyuan on 2018/12/13.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//   数据库操作类

#import <Foundation/Foundation.h>
#import <objc/runtime.h>
NS_ASSUME_NONNULL_BEGIN

@interface SqliteTool : NSObject

+ (SqliteTool *) sharedInstance;
+ (id)copyWithZone:(struct _NSZone *)zone;
+ (id)mutableCopyWithZone:(struct _NSZone *)zone;

// 创建数据库
-(void)createDBWithName:(NSString *)name exist:(void(^)(void))exist success:(void(^)(void))success failure:(void(^)(void))failure;
// 创建数据库表
-(void)createTableWithSql:(NSString *)sql;
// 插入数据，附带数据是否存在查询条件
-(BOOL)insertTable:(NSString *)tableName element:(NSString *)element value:(NSString *)value  where:(NSString * _Nullable)where;
// 删除数据
-(BOOL)deleteDataFromTable:(NSString *)tablename where:(NSString *)where;
// 删除站点
-(BOOL)deleteWebsiteWithID:(NSString *)ID;

// 读取数据
-(NSMutableArray *)selectDataFromTable:(NSString *)tableName where:(NSString *)where field:(NSString *)value Class:(Class)modelClass;
-(NSMutableArray *)selectDataFromTable:(NSString *)tableName where:(NSString *)where field:(NSString *)value Class:(Class)modelClass limit:(int)limit pageSize:(int)pageSize;
-(Class)findDataFromTable:(NSString *)tableName where:(NSString *)where field:(NSString *)value Class:(Class)modelClass;
// 联表查询
//  只能返回单一model类型
-(NSMutableArray *)selectDataFromTable:(NSString *)tableName join:(NSString *)join on:(NSString *)on where:(NSString *)where field:(NSString *)value class:(Class)modelClass;

// 更新数据
-(BOOL)updateTable:(NSString *)tablename where:(NSString *)where value:(NSString *)value;

-(BOOL)updateDatabase;

@end

NS_ASSUME_NONNULL_END
