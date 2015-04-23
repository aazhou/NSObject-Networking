//
//  NEMutableArray.m
//  FishSaying
//
//  Created by aazhou on 1/30/12.
//  Copyright (c) 2012 FishSaying. All rights reserved.
//

#import "DataModelArray.h"
#import "NSObject+JSON.h"

@implementation DataModelArray

@synthesize itemType    = m_itemType;

+ (id)arrayWithItemType:(Class)itemType {
    DataModelArray *array = [[DataModelArray alloc] init];
    
    array.itemType = itemType;
    
    return array;
}

- (id)init
{
    self = [super init];
    if (self) {
        m_dataStore = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)fillWithJSONObejct:(NSArray *)jsonObject {
    Class itemType = self.itemType;
    
    for (id jsonItem in jsonObject) {
        if ([jsonItem isKindOfClass:[NSDictionary class]]) {
            NSObject *item = [[itemType alloc] init];
            
            [item fillWithJSONObejct:jsonItem];
            
            [self addObject:item];
        }
        else {
            [self addObject:jsonItem];
        }
    }
}

#pragma mark - NSArray methods

- (NSUInteger)count {
    return [m_dataStore count];
}

- (id)objectAtIndex:(NSUInteger)index {
    return [m_dataStore objectAtIndex:index];
}

#pragma mark - NSMutableArray methods

- (void)insertObject:(id)anObject atIndex:(NSUInteger)index {
    [m_dataStore insertObject:anObject atIndex:index];
}

- (void)removeObjectAtIndex:(NSUInteger)index {
    [m_dataStore removeObjectAtIndex:index];
}

- (void)addObject:(id)anObject {
    [m_dataStore addObject:anObject];
}

- (void)removeLastObject {
    [m_dataStore removeLastObject];
}

- (void)replaceObjectAtIndex:(NSUInteger)index withObject:(id)anObject {
    [m_dataStore replaceObjectAtIndex:index withObject:anObject];
}

@end
