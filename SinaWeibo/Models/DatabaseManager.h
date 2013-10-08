//
//  DatabaseManager.h
//  SinaWeibo
//
//  Created by cxjwin on 13-8-30.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <FMDB/FMDatabase.h>

@interface DatabaseManager : NSObject

@property (strong, nonatomic) FMDatabase *database;
@property (readonly, nonatomic) NSString *databaseName;
@property (readonly, nonatomic) NSArray *tableNames;

+ (DatabaseManager *)defaultManager;

- (int)checkAndCreateTables;

@end
