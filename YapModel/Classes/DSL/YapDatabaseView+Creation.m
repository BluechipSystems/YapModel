//
//  YapDatabaseView+Shorthand.m
//  YapModel
//
//  Created by Francis Chong on 21/8/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapDatabaseView+Creation.h"

#define YapDatabaseViewCreate(collection, groupBy, sortBy, version)

@implementation YapDatabaseView (Creation)

+(instancetype) viewWithCollection:(NSString*)collection groupByKeys:(NSArray*)groupByKeys sortByKeys:(NSArray*)sortByKeys versionTag:(NSString*)versionTag
{
    return [[self alloc] initWithCollection:collection groupByKeys:groupByKeys sortByKeys:sortByKeys versionTag:versionTag];
}

+(instancetype) viewWithCollection:(NSString*)collection
                       groupByKeys:(NSArray*)groupByKeys
                        sortByKeys:(NSArray*)sortByKeys
{
    NSString* groupByTag = groupByKeys ? [groupByKeys componentsJoinedByString:@"-"] : @"all";
    NSString* sortByTag = sortByKeys ? [sortByKeys componentsJoinedByString:@"-"] : @"none";
    NSString* versionTag = [[groupByTag stringByAppendingString:@"-"] stringByAppendingString:sortByTag];
    return [[self alloc] initWithCollection:collection groupByKeys:groupByKeys sortByKeys:sortByKeys versionTag:versionTag];
}

#pragma mark - Private

-(instancetype) initWithCollection:(NSString*)collection groupByKeys:(NSArray*)groupByKeys sortByKeys:(NSArray*)sortByKeys versionTag:(NSString*)versionTag
{
    
    YapDatabaseViewBlockType groupingBlockType;
    YapDatabaseViewGroupingBlock groupingBlock;
    YapDatabaseViewBlockType sortingBlockType;
    YapDatabaseViewSortingBlock sortingBlock;
    YapDatabaseViewOptions* options;
    
    if (groupByKeys && groupByKeys.count > 0) {
        groupingBlockType = YapDatabaseViewBlockTypeWithObject;
        groupingBlock = ^NSString*(NSString *collection, NSString *key, id object){
            NSMutableArray* groupByValues = [NSMutableArray array];
            [groupByKeys enumerateObjectsUsingBlock:^(NSString* groupBySelector, NSUInteger idx, BOOL *stop) {
                id group = [object valueForKey:groupBySelector];
                if ([group isMemberOfClass:[NSString class]]) {
                    [groupByValues addObject:group];
                } else {
                    [groupByValues addObject:[group description]];
                }
            }];
            return [groupByValues componentsJoinedByString:@"-"];
        };
    } else {
        groupingBlockType = YapDatabaseViewBlockTypeWithKey;
        groupingBlock = ^NSString*(NSString *key, id object){
            return @"all";
        };
    }
    
    if (sortByKeys && sortByKeys.count > 0) {
        sortingBlockType = YapDatabaseViewBlockTypeWithObject;
        sortingBlock = ^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1, id object1,
                                           NSString *collection2, NSString *key2, id object2) {
            __block NSComparisonResult result = NSOrderedSame;
            [sortByKeys enumerateObjectsUsingBlock:^(NSString* sortBySelector, NSUInteger idx, BOOL *stop) {
                NSComparisonResult _result = [[object1 valueForKey:sortBySelector] compare:[object2 valueForKey:sortBySelector]];
                if (_result != NSOrderedSame) {
                    result = _result;
                    *stop = YES;
                }
            }];
            return result;
        };
    } else {
        sortingBlockType = YapDatabaseViewBlockTypeWithKey;
        sortingBlock = ^NSComparisonResult(NSString *group, NSString *collection1, NSString *key1,
                                           NSString *collection2, NSString *key2) {
            return NSOrderedSame;
        };
    }

    options = [[YapDatabaseViewOptions alloc] init];
    options.allowedCollections = [[YapWhitelistBlacklist alloc] initWithWhitelist:[NSSet setWithArray:@[collection]]];
    
    return [[YapDatabaseView alloc] initWithGroupingBlock:groupingBlock
                                        groupingBlockType:groupingBlockType
                                             sortingBlock:sortingBlock
                                         sortingBlockType:sortingBlockType
                                               versionTag:versionTag
                                                  options:options];
}

@end
