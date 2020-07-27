//
//  SqliteTool.m
//  myimage
//
//  Created by liuqingyuan on 2018/12/13.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

#import "SqliteTool.h"
#import "FMDatabaseQueue.h"
#import "FMDatabaseAdditions.h"
#import "NSString+Extension.h"

@interface SqliteTool ()

@property(nonatomic, strong) FMDatabaseQueue *queue;

@end

@implementation SqliteTool

static SqliteTool *_instance = nil;
static id sharedSingleton = nil;

+ (id)allocWithZone:(struct _NSZone *)zone {
    if (_instance == nil) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            sharedSingleton = [super allocWithZone:zone];
        });
    }
    return sharedSingleton;
}

- (id)init {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedSingleton = [super init];
    });
    return sharedSingleton;
}

+ (instancetype)sharedInstance {
    return [[self alloc] init];
}

+ (id)copyWithZone:(struct _NSZone *)zone {
    return sharedSingleton;
}

+ (id)mutableCopyWithZone:(struct _NSZone *)zone {
    return sharedSingleton;
}

- (void)createDBWithName:(NSString *)name
                   exist:(void (^)(void))exist
                 success:(void (^)(void))success
                 failure:(void (^)(void))failure {
    [FileTool createDocumentWithname:@"database"];
    NSString *documentPath = [FileTool getDocumentPath];
    NSString *path = [NSString stringWithFormat:@"%@/database/%@", documentPath, name];
    int result = [FileTool createFileWithPath:path];
    if (result == 1) {
        NSLog(@"数据库已存在");
        exist();
    } else if (result == 2) {
        //文件创建成功
        NSLog(@"文件创建成功");
        success();
    } else {
        NSLog(@"文件创建失败");
        // 文件创建失败
        failure();
    }
}

-(BOOL)insertTable:(NSString *)tableName element:(NSString *)element value:(NSString *)value  where:(NSString * _Nullable)where {
    FMDatabase *db = [self openDB];
    if ([NSString MyStringIsNULL:where]) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", tableName, element, value];
        NSLog(@"insert:%@", sql);
        return [db executeUpdate:sql];
    }else{
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) SELECT %@ FROM %@ WHRE NOT EXISTS (%@)",tableName,element,value,tableName,where];
        NSLog(@"insert and where not exist:%@",sql);
        return [db executeUpdate:sql];
    }
}

- (NSMutableArray *)selectDataFromTable:(NSString *)tableName
                                  where:(NSString *)where
                                  field:(NSString *)value
                                  Class:(Class)modelClass {
    FMDatabase *db = [self openDB];
    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@", value, tableName, where];
    NSLog(@"查询语句%@", sql);
    FMResultSet *result = [db executeQuery:sql];
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:@[]];
    while ([result next]) {
        @try {
            id object = [[modelClass class] new];
            unsigned int outCount;
            Ivar *ivars = class_copyIvarList(modelClass, &outCount);
            for (NSUInteger i = 0; i < outCount; i++) {
                Ivar ivar = ivars[i];
                NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
                if ([[key substringToIndex:1] isEqualToString:@"_"]) {
                    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                }

                id value = [result objectForColumn:key];
                if ([value isKindOfClass:[NSString class]]) {
                    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
                    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if ([result isKindOfClass:[NSDictionary class]] || [result isKindOfClass:[NSMutableDictionary class]] || [result isKindOfClass:[NSArray class]] || [result isKindOfClass:[NSMutableArray class]]) {
                        [object setValue:result forKey:key];
                    } else {
                        [object setValue:value forKey:key];
                    }
                } else {
                    [object setValue:value forKey:key];
                }
            }
            // 添加
            [array addObject:object];
        } @catch (NSException *exception) {
            NSLog(@"name:%@,reson:%@",exception.name,exception.reason);
        } @finally {
        }
    }
    [db close];
    return array;
}

- (NSMutableArray *)selectDataFromTable:(NSString *)tableName
                                  where:(NSString *)where
                                  field:(NSString *)value
                                  Class:(Class)modelClass
                                  limit:(int)limit
                               pageSize:(int)pageSize{
    FMDatabase *db = [self openDB];
    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ limit %d,%d", value, tableName, where,limit,pageSize];
    NSLog(@"查询语句%@", sql);
    FMResultSet *result = [db executeQuery:sql];
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:@[]];
    while ([result next]) {
        @try {
            id object = [[modelClass class] new];
            unsigned int outCount;
            Ivar *ivars = class_copyIvarList(modelClass, &outCount);
            for (NSUInteger i = 0; i < outCount; i++) {
                Ivar ivar = ivars[i];
                NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
                if ([[key substringToIndex:1] isEqualToString:@"_"]) {
                    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                }

                id value = [result objectForColumn:key];
                if ([value isKindOfClass:[NSString class]]) {
                    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
                    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if ([result isKindOfClass:[NSDictionary class]] || [result isKindOfClass:[NSMutableDictionary class]] || [result isKindOfClass:[NSArray class]] || [result isKindOfClass:[NSMutableArray class]]) {
                        [object setValue:result forKey:key];
                    } else {
                        [object setValue:value forKey:key];
                    }
                } else {
                    [object setValue:value forKey:key];
                }
            }
            // 添加
            [array addObject:object];
        } @catch (NSException *exception) {
            NSLog(@"name:%@,reson:%@",exception.name,exception.reason);
        } @finally {
        }
    }
    [db close];
    return array;
}

-(Class)findDataFromTable:(NSString *)tableName
                    where:(NSString *)where
                    field:(NSString *)value
                    Class:(Class)modelClass {
    FMDatabase *db = [self openDB];
    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@", value, tableName, where];
    NSLog(@"查询语句%@", sql);
    FMResultSet *result = [db executeQuery:sql];
    id object = [[modelClass class] new];
    while ([result next]) {
        @try {
            unsigned int outCount;
            Ivar *ivars = class_copyIvarList(modelClass, &outCount);
            for (NSUInteger i = 0; i < outCount; i++) {
                Ivar ivar = ivars[i];
                NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
                if ([[key substringToIndex:1] isEqualToString:@"_"]) {
                    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                }

                id value = [result objectForColumn:key];
                if ([value isKindOfClass:[NSString class]]) {
                    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
                    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if ([result isKindOfClass:[NSDictionary class]] || [result isKindOfClass:[NSMutableDictionary class]] || [result isKindOfClass:[NSArray class]] || [result isKindOfClass:[NSMutableArray class]]) {
                        [object setValue:result forKey:key];
                    } else {
                        [object setValue:value forKey:key];
                    }
                } else {
                    [object setValue:value forKey:key];
                }
            }
        } @catch (NSException *exception) {
            NSLog(@"name:%@,reson:%@",exception.name,exception.reason);
        } @finally {
        }
    }
    [db close];
    return object;
}

-(NSMutableArray *)selectDataFromTable:(NSString *)tableName
                                  join:(NSString *)join
                                    on:(NSString *)on
                                 where:(NSString *)where
                                 field:(NSString *)value
                                 class:(Class)modelClass{
    FMDatabase *db = [self openDB];
    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ %@ ON %@ WHERE %@", value, tableName, join, on, where];
    NSLog(@"查询语句%@", sql);
    FMResultSet *result = [db executeQuery:sql];
    NSMutableArray *array = [[NSMutableArray alloc] initWithArray:@[]];
    while ([result next]) {
        @try {
            id object = [[modelClass class] new];
            unsigned int outCount;
            Ivar *ivars = class_copyIvarList(modelClass, &outCount);
            for (NSUInteger i = 0; i < outCount; i++) {
                Ivar ivar = ivars[i];
                NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];
                if ([[key substringToIndex:1] isEqualToString:@"_"]) {
                    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                }

                id value = [result objectForColumn:key];
                if ([value isKindOfClass:[NSString class]]) {
                    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
                    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if ([result isKindOfClass:[NSDictionary class]] || [result isKindOfClass:[NSMutableDictionary class]] || [result isKindOfClass:[NSArray class]] || [result isKindOfClass:[NSMutableArray class]]) {
                        [object setValue:result forKey:key];
                    } else {
                        [object setValue:value forKey:key];
                    }
                } else {
                    [object setValue:value forKey:key];
                }
            }
            // 添加
            [array addObject:object];
        } @catch (NSException *exception) {
            NSLog(@"name:%@,reson:%@",exception.name,exception.reason);
        } @finally {
        }
    }
    [db close];
    return array;
}


- (void)createTableWithSql:(NSString *)sql {
    FMDatabase *db = [self openDB];
    if ([db executeUpdate:sql]) {
        NSLog(@"数据表创建成功");
    } else {
        NSLog(@"数据表创建失败");
    }
    [db close];
}

// 打开数据库
- (FMDatabase *)openDB {
    NSString *filePath = [FileTool getDatabasePathWithDBName:@"imgDatabase.db"];
    FMDatabase *db = [FMDatabase databaseWithPath:filePath];
    [db open];
    if (![db open]) {
        NSLog(@"db open fail");
        return nil;
    } else {
        return db;
    }
}

- (BOOL)updateTable:(NSString *)tablename
              where:(NSString *)where
              value:(NSString *)value {
    FMDatabase *db = [self openDB];
    NSString *sql = [NSString stringWithFormat:@"update %@ set %@ where %@", tablename, value, where];
    NSLog(@"%@", sql);
    BOOL result = [db executeUpdate:sql];
    [db close];
    return result;
}

- (int)getCountWithTable:(NSString *)table WithWhere:(NSString *)where {
    FMDatabase *db = [self openDB];
    NSString *sql = [NSString stringWithFormat:@"select count(*) from %@ where %@", table, where];
    NSLog(@"%@", sql);
    int count = [db intForQuery:sql];
    [db close];
    return count;
}

/**
 删除数据
 
 @param tablename 数据库名称
 @param where 数据库删除条件
 @return 是否成功
 */
- (BOOL)deleteDataFromTable:(NSString *)tablename where:(NSString *)where {
    FMDatabase *db = [self openDB];
    NSString *sql = [NSString stringWithFormat:@"delete from %@ where %@", tablename, where];
    NSLog(@"sql=%@", sql);
    BOOL result = [db executeUpdate:sql];
    [db close];
    return result;
}

- (BOOL)updateDatabase {
    // 在表中增加新字段
//    FMDatabase *db = [self openDB];
//    if (![db columnExists:@"img_id" inTableWithName:@"image"]){
//        NSString *alertStr = [NSString stringWithFormat:@"ALTER TABLE %@ ADD %@ INTEGER",@"image",@"img_id"];
//        BOOL worked = [db executeUpdate:alertStr];
//        return worked;
//    } else{
//        return false;
//    }
    return YES;
}

// 删除站点
-(BOOL)deleteWebsiteWithID:(NSString *)ID{
    FMDatabase *db = [self openDB];
    // 联表删除
    NSString *sql = [NSString stringWithFormat:@"%@",ID];
    BOOL result = [db executeUpdate:sql];
    [db close];
    return result;
}

@end
