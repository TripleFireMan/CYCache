//
//  CYCacheProtocol.h
//  CYCache
//
//  Created by 成焱 on 2019/9/18.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSInteger, CYCacheType){
    CYCacheType_UserDefault = 0,
    CYCacheType_Plist,
    CYCacheType_Archieve,
    CYCacheType_Sqlite,
};

@protocol CYCacheProtocol <NSObject>

@property (nonatomic, strong) NSString *name;

/// 是否存在对应名称的cache对象
+ (BOOL)cacheisExistWithName:(NSString *)name;
+ (instancetype)defaultCache;

- (BOOL)setObject:(id)object forKey:(NSString *)key;
- (BOOL)removeObjectWithKey:(NSString *)key;
- (id)objectForKey:(NSString *)key;
- (NSDictionary *)allObjects;
@end

NS_ASSUME_NONNULL_END
