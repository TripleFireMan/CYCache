//
//  CYDataBase.h
//  CYCache
//
//  Created by 成焱 on 2019/9/18.
//

#import <Foundation/Foundation.h>
@class FMDatabase;
@interface CYDataBase : NSObject
/// 数据库名称
@property (nonatomic, strong, readonly) NSString *dbName;
/// 数据库路径，默认是Library/com.chengyan.CYCache
@property (nonatomic, strong, readonly) NSString *directory;
/// 是否是打开的
@property (nonatomic, assign, readonly) BOOL isOpen;
- (instancetype) init;
- (instancetype) initWithDirectory:(NSString *)directory;
- (instancetype) initWithDirectory:(NSString *)directory dbName:(NSString *)name NS_DESIGNATED_INITIALIZER;
- (void) open;
- (void) close;
- (void) excuteUpdateBlock:(void(^)(FMDatabase *db, BOOL *rollBack))block;
- (void) excuteQueryBlock:(void(^)(FMDatabase *db))block;
@end

