//
//  CYArchieveCache.m
//  CYCache
//
//  Created by 成焱 on 2019/9/18.
//

#import "CYArchieveCache.h"
#import "CYCacheProtocol.h"

#define CYKeyChainName @"CYCacheKeyChain"
@interface CYArchieveCache ()
@property (nonatomic, strong) NSMutableDictionary *data;
@property (nonatomic, assign, readwrite) CYCacheType type;
@end
@implementation CYArchieveCache
@synthesize name;
+ (BOOL) cacheisExistWithName:(NSString *)name
{
    NSMutableDictionary *keychainQuery = [self keyChainDictionaryWithName:name];
    NSMutableDictionary *ret = nil;
    CFDataRef keyData = NULL;
    if (SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData) == noErr) {
        @try {
            ret = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge NSData *)keyData];
        } @catch (NSException *exception) {
            ret = nil;
        }
    }
    if (keyData) {
        CFRelease(keyData);
    }
    return ret != nil;
    
}

+ (NSMutableDictionary *)keyChainDictionaryWithName:(NSString *)name
{
    NSMutableDictionary *keychainQuery = [NSMutableDictionary dictionaryWithObjectsAndKeys:(__bridge id)kSecClassGenericPassword,(__bridge id)kSecClass,
                                          name,(__bridge id)kSecAttrService,
                                          name,(__bridge id)kSecAttrAccount,
                                          (__bridge id)kSecAttrAccessibleAfterFirstUnlock,
                                          (__bridge id)kSecAttrAccessible,
                                          nil];

    return keychainQuery;
}

+ (instancetype) defaultCache
{
    static CYArchieveCache *cache = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        cache = [[CYArchieveCache alloc] init];
    });
    return cache;
}

- (id) init
{
    self = [super init];
    if (self) {
        self.name = CYKeyChainName;
        self.type = CYCacheType_Archieve;
        NSMutableDictionary *keychainQuery = [[self class] keyChainDictionaryWithName:self.name];
        [keychainQuery setObject:(id)kCFBooleanTrue forKey:(__bridge id)kSecReturnData];
        [keychainQuery setObject:(__bridge id)kSecMatchLimitOne forKey:(__bridge id)kSecMatchLimit];
        NSMutableDictionary *data;
        CFDataRef keyData = NULL;
        
        OSStatus result = SecItemCopyMatching((__bridge CFDictionaryRef)keychainQuery, (CFTypeRef *)&keyData);
        if (result == noErr) {
            @try {
                data = [NSKeyedUnarchiver unarchiveObjectWithData:(__bridge id)keyData];
            } @catch (NSException *exception) {
                data = nil;
            }
        }
        
        if (keyData) {
            CFRelease(keyData);
        }
        
        if (!data) {
            data = [NSMutableDictionary dictionary];
            NSMutableDictionary *keychainForAdd = [[self class] keyChainDictionaryWithName:self.name];
            SecItemDelete((CFDictionaryRef )keychainQuery);
            [keychainForAdd setObject:[NSKeyedArchiver archivedDataWithRootObject:data] forKey:(__bridge id)kSecValueData];
            OSStatus result = SecItemAdd((__bridge CFDictionaryRef)keychainForAdd, NULL);
            if (result != noErr) {
                return nil;
            }
        }
        
        self.data = data;
    }
    return self;
}

- (BOOL) setObject:(id)object forKey:(NSString *)key
{
    [self.data setValue:object forKey:key];
    NSMutableDictionary *keyChainQuery = [[self class] keyChainDictionaryWithName:self.name];
    SecItemDelete((__bridge CFDictionaryRef)keyChainQuery);
    [keyChainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:self.data] forKey:(__bridge id)kSecValueData];
    OSStatus result = SecItemAdd((__bridge CFDictionaryRef)keyChainQuery, NULL);
    return (result == noErr);
}

- (BOOL) removeObjectWithKey:(NSString *)key
{
    [self.data removeObjectForKey:key];
    NSMutableDictionary *keyChainQuery = [[self class] keyChainDictionaryWithName:self.name];
    SecItemDelete((__bridge CFDictionaryRef)keyChainQuery);
    [keyChainQuery setObject:[NSKeyedArchiver archivedDataWithRootObject:self.data] forKey:(__bridge id)kSecValueData];
    OSStatus result = SecItemAdd((__bridge CFDictionaryRef)keyChainQuery, NULL);
    return (result == noErr);

}

- (id) objectForKey:(NSString *)key
{
    return [self.data valueForKey:key];
}

- (NSDictionary *) allObjects
{
    return [NSDictionary dictionaryWithDictionary:self.data];
}

@end
