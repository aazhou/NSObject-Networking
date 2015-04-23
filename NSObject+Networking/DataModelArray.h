//
//  NEMutableArray.h
//  FishSaying
//
//  Created by aazhou on 1/30/12.
//  Copyright (c) 2012 FishSaying. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DataModelArray : NSMutableArray {
    NSMutableArray  *m_dataStore;
    Class           m_itemType;
}

@property(nonatomic,assign) Class   itemType;

+ (id)arrayWithItemType:(Class)itemType;

- (void)fillWithJSONObejct:(NSArray *)jsonObject;

@end
