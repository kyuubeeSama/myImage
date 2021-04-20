//
//  SqliteTool.m
//  myimage
//
//  Created by liuqingyuan on 2018/12/13.
//  Copyright © 2018 liuqingyuan. All rights reserved.
//

#import <FMDB/FMDatabase.h>
#import <FMDB/FMDatabaseAdditions.h>
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

- (void)createDbTableAndColumn {
    //        website
    [self createTableWithSql:@"CREATE TABLE IF NOT EXISTS `website`  "
                             "(website_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,"
                             "name VARCHAR(200) NOT NULL,"
                             "value INT NOT NULl,"
                             "url VARCHAR(200) NOT NULL,"
                             "is_delete INT NOT NULL DEFAULT(1))"];
    //        category
    [self createTableWithSql:@"CREATE TABLE IF NOT EXISTS `category` "
                             "(category_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,"
                             "website_id INT NOT NULL,"
                             "name VARCHAR(200) NOT NULL,"
                             "value VARCHAR(50) NOT NULL,"
                             "is_delete INT NOT NULL DEFAULT(1))"];
    //        此处使用项目时间还是使用前id
    [self createTableWithSql:@"CREATE TABLE IF NOT EXISTS `article` "
                             "(article_id INTEGER NOT NULL PRIMARY KEY AUTOINCREMENT,"
                             "website_id INT NOT NULL,"
                             "name VARCHAR(200) NOT NULL,"
                             "category_id INT NOT NULL,"
                             "detail_url VARCHAR(200) NOT NULL UNIQUE,"
                             "has_done INT NOT NULL DEFAULT(1),"
                             "is_delete INT NOT NULL DEFAULT(1),"
                             "aid INT DEFAULT(0),"
                             "img_url VARCHAR(200) NOT NULL)"];
    //        image
    [self createTableWithSql:@"CREATE TABLE IF NOT EXISTS `image` "
                             "(image_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                             "image_url VARCHAR(200) NOT NULL,"
                             "website_id INT NOT NULL,"
                             "article_id INT NOT NULL,"
                             "width FLOAT DEFAULT(0),"
                             "height FLOAT DEFAULT(0))"];
    //        collect
    [self createTableWithSql:@"CREATE TABLE IF NOT EXISTS `collect` "
                             "(collect_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                             "value INT NOT NULL,"
                             "type INT NOT NULL)"];
    //        history  历史记录
    [self createTableWithSql:@"CREATE TABLE IF NOT EXISTS 'history'"
                             "(history_id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL,"
                             "article_id INTEGER NOT NULL UNIQUE,"
                             "add_time INTEGER)"];
}

- (BOOL)insertTable:(NSString *)tableName
            element:(NSString *)element
              value:(NSString *)value
              where:(NSString *_Nullable)where {
    FMDatabase *db = [self openDB];
    if ([NSString MyStringIsNULL:where]) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES (%@)", tableName, element, value];
        NSLog(@"insert:%@", sql);
        return [db executeUpdate:sql];
    } else {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) SELECT %@ WHERE NOT EXISTS (%@)", tableName, element, value, where];
        NSLog(@"insert and where not exist:%@", sql);
        return [db executeUpdate:sql];
    }
}

- (BOOL)replaceTable:(NSString *)tableName
             element:(NSString *)element
               value:(NSString *)value {
    FMDatabase *db = [self openDB];
    NSString *sql = [NSString stringWithFormat:@"REPLACE INTO %@ (%@) VALUES (%@)", tableName, element, value];
    NSLog(@"replace:%@", sql);
    return [db executeUpdate:sql];
}

- (NSMutableArray *)selectDataFromTable:(NSString *)tableName
                                  where:(NSString *)where
                                  field:(NSString *)field
                                orderby:(NSString *)order
                                  Class:(Class)modelClass {
    FMDatabase *db = [self openDB];
    NSString *orderInfo = @"";
    if (order.length > 0) {
        orderInfo = [NSString stringWithFormat:@"order by %@", order];
    }
    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ %@", field, tableName, where, orderInfo];
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
            NSLog(@"name:%@,reson:%@", exception.name, exception.reason);
        } @finally {
        }
    }
    [db close];
    return array;
}

- (BOOL)findColumnExistFromTable:(NSString *)tableName column:(NSString *)column {
    FMDatabase *db = [self openDB];
//    select * from sqlite_master where name = 'article' and sql like '%aid%'
    return [db columnExists:column inTableWithName:tableName];
}

- (BOOL)addColumnFromTable:(NSString *)tableName columnAndValue:(NSString *)column {
    FMDatabase *db = [self openDB];
//    alter table article add aid INT default 0
    NSString *sql = [NSString stringWithFormat:@"alter table %@ add %@", tableName, column];
    BOOL result = [db executeUpdate:sql];
    [db close];
    return result;
}

- (NSMutableArray *)selectDataFromTable:(NSString *)tableName
                                  where:(NSString *)where
                                  field:(NSString *)field
                                  Class:(Class)modelClass
                                  limit:(NSInteger)limit
                               pageSize:(NSInteger)pageSize {
    FMDatabase *db = [self openDB];
    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@ limit %ld,%ld", field, tableName, where, (long) limit, (long) pageSize];
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
            NSLog(@"name:%@,reson:%@", exception.name, exception.reason);
        } @finally {
        }
    }
    [db close];
    return array;
}

- (Class)findDataFromTable:(NSString *)tableName
                     where:(NSString *)where
                     field:(NSString *)field
                     Class:(Class)modelClass {
    FMDatabase *db = [self openDB];
    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ WHERE %@", field, tableName, where];
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
            NSLog(@"name:%@,reson:%@", exception.name, exception.reason);
        } @finally {
        }
    }
    [db close];
    return object;
}

- (NSMutableArray *)selectDataFromTable:(NSString *)tableName
                                   join:(NSString *)join
                                     on:(NSString *)on
                                  where:(NSString *)where
                                  field:(NSString *)field
                                  limit:(NSInteger)limit
                               pageSize:(NSInteger)pageSize
                                  class:(Class)modelClass {
    FMDatabase *db = [self openDB];
    NSString *sql = [NSString stringWithFormat:@"SELECT %@ FROM %@ %@ ON %@ WHERE %@ limit %ld,%ld", field, tableName, join, on, where, limit, pageSize];
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
            NSLog(@"name:%@,reson:%@", exception.name, exception.reason);
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

- (NSInteger)getCountWithTable:(NSString *)table WithWhere:(NSString *)where {
    FMDatabase *db = [self openDB];
    NSString *sql = [NSString stringWithFormat:@"select count(*) from %@ where %@", table, where];
    NSLog(@"%@", sql);
    NSInteger count = [db intForQuery:sql];
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

@end
