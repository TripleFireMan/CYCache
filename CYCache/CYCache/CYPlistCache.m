//
//  CYPlistCache.m
//  CYCache
//
//  Created by 成焱 on 2019/9/18.
//

#import "CYPlistCache.h"
#import "CYCacheDefine.h"
@interface CYPlistCache ()
@property (nonatomic, assign) CYCacheType type;
@property (nonatomic, strong) NSMutableDictionary *data;
@end

@implementation CYPlistCache
@synthesize name;

+ (BOOL) cacheisExistWithName:(NSString *)name
{
    if (!name) {
        return NO;
    }
    
    NSString *filePath = [CY_DEFAULT_CACHE_DIRECTORY stringByAppendingPathComponent:name];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        return YES;
    }
    else{
        return NO;
    }
}

+ (instancetype) defaultCache
{
    static CYPlistCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[CYPlistCache alloc] init];
    });
    return cache;
}

- (id) init
{
    self = [super init];
    if (self) {
        self.name = @"CYCache.plist";
        self.type = CYCacheType_Plist;
        self.data = [NSMutableDictionary dictionary];
        NSString *filePath = [CY_DEFAULT_CACHE_DIRECTORY stringByAppendingPathComponent:self.name];
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            self.data = [NSMutableDictionary dictionaryWithContentsOfURL:[NSURL fileURLWithPath:filePath]];
        }
        else{
            [[NSFileManager defaultManager] createFileAtPath:filePath contents:nil attributes:nil];
            [self.data writeToFile:filePath atomically:YES];
        }
    }
    return self;
}

- (BOOL) setObject:(id)object forKey:(NSString *)key
{
    [self.data setObject:object forKey:key];
    return [self.data writeToFile:[CY_DEFAULT_CACHE_DIRECTORY stringByAppendingPathComponent:self.name] atomically:YES];
}

- (BOOL) removeObjectWithKey:(NSString *)key
{
    [self.data removeObjectForKey:key];
    return [self.data writeToFile:[CY_DEFAULT_CACHE_DIRECTORY stringByAppendingPathComponent:self.name] atomically:YES];
}

- (id) objectForKey:(NSString *)key
{
    return [self.data objectForKey:key];
}

- (NSDictionary *) allObjects
{
    return [NSDictionary dictionaryWithDictionary:self.data];
}
@end
