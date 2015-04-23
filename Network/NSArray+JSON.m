//
//  NSArray+JSON.m
//  FishSaying
//
//  Created by aazhou on 1/30/12.
//  Copyright (c) 2012 FishSaying. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSArray+JSON.h"
#import "NSObject+JSON.h"

@implementation NSArray (JSON)

- (NSString *)_toJSONString {
    NSArray *jsonObject = [self _toJSONObject];
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:&error];
    NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    return jsonString;
}

- (NSArray *)_toJSONObject {
    NSMutableArray *jsonArray = [NSMutableArray array];
    
    for (id item in self) {
        id value = nil;
        if ([item isKindOfClass:[NSString class]]) {
            value = item;
        } else if ([item isKindOfClass:[NSNumber class]]) {
            value = item;
        } else if ([item isKindOfClass:[NSNull class]]) {
            value = item;
        } else if ([item isKindOfClass:[NSArray class]]) {
            value = [(NSArray *)item _toJSONObject];
        } else {
            value = [item toJSONObject];
        }

        [jsonArray addObject:value];
    }
    
    return jsonArray;
}

@end
