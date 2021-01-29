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

// 替换数据，有则替换，没有就插入
-(BOOL)replaceTable:(NSString *)tableName element:(NSString *)element value:(NSString *)value;

// 删除数据
-(BOOL)deleteDataFromTable:(NSString *)tablename where:(NSString *)where;
// 删除站点
-(BOOL)deleteWebsiteWithID:(NSString *)ID;

// 读取数据

/// 查询数据(全查询)
/// @param tableName 表名
/// @param where 查询条件
/// @param field 查询字段
/// @param modelClass 返回对象
-(NSMutableArray *)selectDataFromTable:(NSString *)tableName where:(NSString *)where field:(NSString *)field Class:(Class)modelClass;

/// 查询数据（带页码）
/// @param tableName 表名
/// @param where 查询条件
/// @param field 查询字段
/// @param modelClass 返回对象
/// @param limit 起始位置
/// @param pageSize 单页个数
-(NSMutableArray *)selectDataFromTable:(NSString *)tableName where:(NSString *)where field:(NSString *)field Class:(Class)modelClass limit:(NSInteger)limit pageSize:(NSInteger)pageSize;

/// 单数据查询
/// @param tableName 表名
/// @param where 查询条件
/// @param field 查询字段
/// @param modelClass 返回对象
-(Class)findDataFromTable:(NSString *)tableName where:(NSString *)where field:(NSString *)field Class:(Class)modelClass;

-(NSMutableArray *)selectDataFromTable:(NSString *)tableName join:(NSString *)join on:(NSString *)on where:(NSString *)where field:(NSString *)field class:(Class)modelClass;

// 更新数据
-(BOOL)updateTable:(NSString *)tablename where:(NSString *)where value:(NSString *)value;

-(BOOL)updateDatabase;

@end

NS_ASSUME_NONNULL_END
