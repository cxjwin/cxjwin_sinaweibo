//
//  DatabaseManager.m
//  SinaWeibo
//
//  Created by cxjwin on 13-8-30.
//  Copyright (c) 2013年 cxjwin. All rights reserved.
//

#import "DatabaseManager.h"

@interface DatabaseManager ()

@property (readwrite, strong, nonatomic) NSString *databaseName;
@property (readwrite, strong, nonatomic) NSArray *tableNames;

@end

@implementation DatabaseManager

+ (DatabaseManager *)defaultManager {
	static DatabaseManager *manager = nil;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
	    manager = [[self alloc] init];
	});
	return manager;
}

- (id)init {
	self = [super init];
	if (self) {
		NSString *databaseName = @"weibo.db";
		NSArray *documentPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDir = [documentPaths objectAtIndex:0];
		NSString *databasePath = [documentsDir stringByAppendingPathComponent:databaseName];
		self.databaseName = databaseName;
		self.database = [FMDatabase databaseWithPath:databasePath];
		self.tableNames = @[@"login_account", @"statuses_data"];
	}

	return self;
}

#pragma mark -
#pragma mark - database methods

- (int)checkAndCreateTables {
	int rc = SQLITE_OK;

	for (NSString *name in self.tableNames) {
		NSString *sql =
		    [NSString stringWithFormat:@"select * from sqlite_master where type='table' and name='%@';", name];
		FMResultSet *result = [self.database executeQuery:sql];
		if ([name isEqualToString:@"login_account"] && ![result next]) {
			[self createLoginAccountTable];
		}

		if ([name isEqualToString:@"statuses_data"] && ![result next]) {
			[self createStatusesDataTable];
		}
	}

	return rc;
}

- (int)createLoginAccountTable {
	WBLog(@"createLoginAccountTable");
	char *sql =
		"create table login_account"
	    " (user_id integer primary key,"
	    " access_token text not null,"
	    " expires_in integer,"
	    " login_time integer);";

	char *zErr;
	int rc = sqlite3_exec([self.database sqliteHandle], sql, NULL, NULL, &zErr);
	if (rc != SQLITE_OK) {
		if (zErr != NULL) {
			WBLog(@"create table login_account err : %s", sqlite3_errmsg([self.database sqliteHandle]));
			sqlite3_free(zErr);
		}
	}

	return rc;
}

- (int)createStatusesDataTable {
	WBLog(@"createStatusesDataTable");
	char *sql = "create table statuses_data (data blob not null);";

	char *zErr;
	int rc = sqlite3_exec([self.database sqliteHandle], sql, NULL, NULL, &zErr);
	if (rc != SQLITE_OK) {
		if (zErr != NULL) {
			WBLog(@"create table statuses_data err : %s", sqlite3_errmsg([self.database sqliteHandle]));
			sqlite3_free(zErr);
		}
	}

	return rc;
}

@end
