//
//  NSObject+JSON.h
//  INCDFramework
//
//  Created by aazhou on 2/3/12.
//  Copyright (c) 2012 FishSaying. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (JSON)

+ (id)dataModelWithJSONString:(NSString *)jsonString;
+ (id)dataModelWithJSONObject:(id)jsonObject;

- (void)fillWithJSONObejct:(NSDictionary *)jsonObject;

- (NSString *)toJSONString;
- (NSDictionary *)toJSONObject;

@end
