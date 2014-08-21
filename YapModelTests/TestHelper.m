//
//  TestHelper.m
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import <Kiwi/Kiwi.h>
#import "TestHelper.h"
#import "Person.h"
#import "Company.h"

@interface YapDatabaseExtension(Private)
- (BOOL)supportsDatabase:(YapDatabase *)database withRegisteredExtensions:(NSDictionary *)registeredExtensions;
@end

void(^SetupDatabaseIndex)(YapDatabase*) = ^(YapDatabase* database){
    YapDatabaseSecondaryIndexSetup *setup = [ [YapDatabaseSecondaryIndexSetup alloc] init];
    [setup addColumn:@"age" withType:YapDatabaseSecondaryIndexTypeInteger];
    
    YapDatabaseSecondaryIndexBlockType blockType = YapDatabaseSecondaryIndexBlockTypeWithObject;
    YapDatabaseSecondaryIndexWithObjectBlock block = ^(NSMutableDictionary *dict, NSString *collection, NSString *key, id object){
        if ([object isKindOfClass:[Person class]]) {
            Person *person = (Person *)object;
            [dict setObject:person.age forKey:@"age"];
        }
    };
    YapDatabaseSecondaryIndex* index = [[YapDatabaseSecondaryIndex alloc] initWithSetup:setup block:block blockType:blockType];
    
    // for some reason the method return NO in test
    [index stub:@selector(supportsDatabase:withRegisteredExtensions:) andReturn:@YES];
    BOOL registered = [database registerExtension:index withName:@"index"];
    if (!registered) {
        NSLog(@"failed register extension: %@", index);
    }
};

YapDatabase*(^CreateDatabase)(void) = ^{
    NSString* databaseName = [NSString stringWithFormat:@"testing-%d.sqlite", arc4random()];
    NSURL* documentDirectory = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                                       inDomains:NSUserDomainMask] lastObject];
    NSString *databaseDir = [[documentDirectory path] stringByAppendingPathComponent:databaseName];
    return [[YapDatabase alloc] initWithPath:databaseDir];
};

void(^CleanupDatabase)(YapDatabase*) = ^(YapDatabase* database){
    NSString* path = database.databasePath;
    NSError* error;
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* directory = [path stringByDeletingLastPathComponent];
    NSString* filenamePrefix = [[path lastPathComponent] stringByDeletingPathExtension];
    NSArray *contents = [fileManager contentsOfDirectoryAtPath:directory
                                                         error:&error];

    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"self CONTAINS %@", filenamePrefix];
    for (NSString *filename in [contents filteredArrayUsingPredicate:predicate]) {
        NSLog(@"filename = %@", filename);
        [fileManager removeItemAtPath:[directory stringByAppendingPathComponent:filename]
                                error:&error];
    }
};


@implementation TestHelper
@end
