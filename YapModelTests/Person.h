//
//  Person.h
//  YapModel
//
//  Created by Francis Chong on 2/15/14.
//  Copyright (c) 2014 Ignition Soft. All rights reserved.
//

#import "YapModelObject.h"

@interface Person : YapModelObject

@property (nonatomic, copy) NSString* name;
@property (nonatomic, assign) NSUInteger age;
@property (nonatomic, assign) BOOL member;

@end
