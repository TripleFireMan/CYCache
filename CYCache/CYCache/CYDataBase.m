//
//  CYDataBase.m
//  CYCache
//
//  Created by 成焱 on 2019/9/18.
//

#import "CYDataBase.h"
#import "CYCacheDefine.h"
#import "FMDB.h"

@interface CYDataBase ()
/// 数据库名称
@property (nonatomic, strong) NSString *dbName;
/// 数据库路径，默认是Library/com.chengyan.CYCache
@property (nonatomic, strong) NSString *directory;
/// 是否是打开的
@property (nonatomic, assign) BOOL isOpen;
/// 数据库操作队列
@property (nonatomic, strong) FMDatabaseQueue *dbQueue;
@end
@implementation CYDataBase
- (instancetype) init
{
    NSString *directory = [CY_LIBRARY_DIRECTORY stringByAppendingPathComponent:@"com.chengyan.CYCache"];
    return [self initWithDirectory:directory dbName:@"CYCache.db"];
    
}

- (instancetype) initWithDirectory:(NSString *)directory
{
    return [self initWithDirectory:directory dbName:@"CYCache.db"];
}

- (instancetype) initWithDirectory:(NSString *)directory dbName:(NSString *)name
{
    self = [super init];
    if (self) {
        self.directory = directory;
        self.dbName = name;
        BOOL isDir = YES;
        BOOL isExist = [[NSFileManager defaultManager] fileExistsAtPath:directory isDirectory:&isDir];
        if (!isExist) {
            BOOL success = [[NSFileManager defaultManager] createDirectoryAtPath:directory withIntermediateDirectories:YES attributes:nil error:nil];
            NSAssert(success, @"文件夹创建失败");
            
        }
        self.dbQueue = nil;
        self.isOpen = NO;
    }
    return self;
}

- (void) open
{
    if (self.dbQueue) {
        [self.dbQueue close];
    }
    NSString *dbQueuePath = [self.directory stringByAppendingPathComponent:self.dbName];
    self.dbQueue = [FMDatabaseQueue databaseQueueWithPath:dbQueuePath];
    if (self.dbQueue) {
        self.isOpen = YES;
    }
    else{
        self.isOpen = NO;
    }
}

- (void)dealloc
{
    [self close];
}

- (void)close
{
    [self.dbQueue close];
    self.dbQueue = nil;
    self.isOpen = NO;
}

- (void) excuteUpdateBlock:(void (^)(FMDatabase *, BOOL *))block
{
    if (self.dbQueue) {
        [self.dbQueue inTransaction:^(FMDatabase * _Nonnull db, BOOL * _Nonnull rollback) {
            block?block(db,rollback):nil;
        }];
    }
}

- (void) excuteQueryBlock:(void (^)(FMDatabase *))block
{
    if (self.dbQueue) {
        [self.dbQueue inDatabase:^(FMDatabase * _Nonnull db) {
            block?block(db):nil;
        }];
    }
}
@end
