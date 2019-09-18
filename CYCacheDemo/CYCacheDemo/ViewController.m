//
//  ViewController.m
//  CYCacheDemo
//
//  Created by 成焱 on 2019/9/18.
//  Copyright © 2019 cheng.yan. All rights reserved.
//

#import "ViewController.h"
#import "CYCache.h"
@interface ViewController ()
@property (nonatomic, strong) CYSqliteCache *cache;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    

    
    // 数据库存储
    [[CYSqliteCache defaultCache] setObject:@{@"name":@"成焱"} forKey:@"user"];
    id obj = [[CYSqliteCache defaultCache] objectForKey:@"user"];
    NSLog(@"obj = %@",obj);
    
    
    // 钥匙串存储
    [[CYArchieveCache defaultCache] setObject:@"18612545535" forKey:@"account"];
    [[CYArchieveCache defaultCache] setObject:@"123" forKey:@"password"];
    id account =  [[CYArchieveCache defaultCache] objectForKey:@"account"];
    id password = [[CYArchieveCache defaultCache] objectForKey:@"password"];
    NSLog(@"account : %@, password : %@", account, password);
    // Plist存储
    [[CYPlistCache defaultCache] setObject:@"花猫" forKey:@"cat"];
    [[CYPlistCache defaultCache] setObject:@"白猫" forKey:@"whiteCat"];
    id cat = [[CYPlistCache defaultCache] objectForKey:@"cat"];
    id whiteCat = [[CYPlistCache defaultCache] objectForKey:@"whiteCat"];
    NSLog(@"cat = %@, whiteCat = %@",cat, whiteCat);
    
}


@end
