//
//  CYSqliteCache.m
//  CYCache
//
//  Created by 成焱 on 2019/9/18.
//

#import "CYSqliteCache.h"
#import "CYCacheDefine.h"
#import "CYDataBase.h"
#import "FMDB.h"

static NSString * const kCYCache_SQL_Column_Key = @"key";
static NSString * const kCYCache_SQL_Column_Value = @"value";

static NSString * const kCYCache_SQL_Check  = @"SELECT COUNT(*) AS 'count' FROM sqlite_master WHERE type='table' AND name='Table_Key_Value'";
static NSString * const kCYCache_SQL_Create = @"CREATE TABLE Table_Key_Value ('key' VARCHAR(255) PRIMARY KEY NOT NULL, 'value' BLOB)";
static NSString * const kCYCache_SQL_Insert = @"INSERT INTO Table_Key_Value(key, value) VALUES(?, ?)";
static NSString * const kCYCache_SQL_Update = @"UPDATE Table_Key_Value SET value=? WHERE key=?";
static NSString * const kCYCache_SQL_Delete = @"DELETE FROM Table_Key_Value WHERE key=?";
static NSString * const kCYCache_SQL_Select = @"SELECT * FROM Table_Key_Value WHERE key=?";
static NSString * const kCYCache_SQL_Select_All = @"SELECT * FROM TABLE_KEY_VALUE";


@interface CYSqliteCache ()

@property (nonatomic, assign, readwrite) CYCacheType type;
@property (nonatomic, strong) CYDataBase *dataBase;
@end

@implementation CYSqliteCache
@synthesize name;

+ (BOOL) cacheisExistWithName:(NSString *)name
{
    if (!name || [name isEqualToString:@""]) {
        return NO;
    }
    NSString *path = [CY_DEFAULT_CACHE_DIRECTORY stringByAppendingPathComponent:name];
    BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:path];
    return isExist;
}



- (instancetype) init
{
    self = [super init];
    if (self) {
        self.dataBase = [[CYDataBase alloc] init];
        self.type = CYCacheType_Sqlite;
        [self.dataBase open];
        
        [self.dataBase excuteUpdateBlock:^(FMDatabase *db, BOOL *rollBack) {
            FMResultSet * rs = [db executeQuery:kCYCache_SQL_Check];
            if ([rs next]) {
                int count = [rs intForColumn:@"count"];
                if (count == 0) {
                    BOOL isSuccess = [db executeUpdate:kCYCache_SQL_Create];
                    NSLog(@" isSuccess = %@lastError = %@",@(isSuccess), db.lastError);
                }
            }
            [rs close];
            rs = nil;
        }];
    }
    return self;
}


+ (instancetype) defaultCache
{
    static CYSqliteCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[CYSqliteCache alloc] init];
    });
    return cache;
}

- (void)dealloc
{
    [self.dataBase close];
}


- (BOOL) setObject:(id)object forKey:(NSString *)key
{
    if (![self.dataBase isOpen]) {
        return NO;
    }
    if (![NSJSONSerialization isValidJSONObject:object]) {
        return NO;
    }
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:object options:NSJSONWritingPrettyPrinted error:&error];
    
    __block BOOL retVal = NO;
    
    if (!error && jsonData) {
        [self.dataBase excuteUpdateBlock:^(FMDatabase *db, BOOL *rollBack) {
            FMResultSet *rs = [db executeQuery:kCYCache_SQL_Select,key];
            if (rs && rs.next) {
                retVal = [db executeUpdate:kCYCache_SQL_Update,jsonData,key];
            }
            else{
                retVal = [db executeUpdate:kCYCache_SQL_Insert,key,jsonData];
            }
            [rs close];
            rs = nil;
        }];
    }
    
    return retVal;
}

- (BOOL) removeObjectWithKey:(NSString *)key
{
    __block BOOL retVal = NO;
    [self.dataBase excuteUpdateBlock:^(FMDatabase *db, BOOL *rollBack) {
        retVal = [db executeUpdate:kCYCache_SQL_Delete,key];
    }];
    return retVal;
}

- (id) objectForKey:(NSString *)key
{
    __block id obj = nil;
    [self.dataBase excuteQueryBlock:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:kCYCache_SQL_Select,key];
        while ([rs next]) {
            NSString *content = [rs stringForColumn:@"value"];
            NSData *jsonData = [content dataUsingEncoding:NSUTF8StringEncoding];
            obj = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
            
        }
        [rs close];
        rs = nil;
    }];
    return obj;
}

- (NSDictionary *) allObjects
{
    NSMutableDictionary *objs = [NSMutableDictionary dictionary];
    [self.dataBase excuteQueryBlock:^(FMDatabase *db) {
        FMResultSet *rs = [db executeQuery:kCYCache_SQL_Select_All];
        while ([rs next]) {
            NSString *key = [rs stringForColumn:@"key"];
            NSString *content = [rs stringForColumn:@"value"];
            NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
            id retVal = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:nil];
            [objs setObject:retVal forKey:key];
        }
        [rs close];
        rs = nil;
    }];
    return objs;
}


@end
