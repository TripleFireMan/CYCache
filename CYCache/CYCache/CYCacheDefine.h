//
//  CYCacheDefine.h
//  CYCache
//
//  Created by 成焱 on 2019/9/18.
//

#ifndef CYCacheDefine_h
#define CYCacheDefine_h

#define CY_DOCUMENT_DIRECTORY [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject]
#define CY_CACHE_DIRECTORY [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject]
#define CY_LIBRARY_DIRECTORY [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject]
#define CY_TEM_DIRECTORY NSTemporaryDirectory()
#define CY_DEFAULT_CACHE_DIRECTORY  [CY_LIBRARY_DIRECTORY stringByAppendingPathComponent:@"com.chengyan.CYCache"]
#define CY_PLIST_CACHE      [CYPlistCache defaultCache]
#define CY_SQLITE_CACHE     [CYSqliteCache defaultCache]
#define CY_ARCHIEVE_CACHE   [CYArchieveCache defaultCache]
#endif /* CYCacheDefine_h */
