# CYCache
一个缓存管理的工具类，支持Plist、Sqilte、Archieve


## 1.数据库存储

```objc
[[CYSqliteCache defaultCache] setObject:@{@"name":@"成焱"} forKey:@"user"];
id obj = [[CYSqliteCache defaultCache] objectForKey:@"user"];
NSLog(@"obj = %@",obj);
```

## 2.钥匙串存储
```objc
[[CYArchieveCache defaultCache] setObject:@"18612545535" forKey:@"account"];
[[CYArchieveCache defaultCache] setObject:@"123" forKey:@"password"];
id account =  [[CYArchieveCache defaultCache] objectForKey:@"account"];
id password = [[CYArchieveCache defaultCache] objectForKey:@"password"];
NSLog(@"account : %@, password : %@", account, password);
```

## 3.Plist存储
```objc
[[CYPlistCache defaultCache] setObject:@"花猫" forKey:@"cat"];
[[CYPlistCache defaultCache] setObject:@"白猫" forKey:@"whiteCat"];
id cat = [[CYPlistCache defaultCache] objectForKey:@"cat"];
id whiteCat = [[CYPlistCache defaultCache] objectForKey:@"whiteCat"];
NSLog(@"cat = %@, whiteCat = %@",cat, whiteCat);
```
