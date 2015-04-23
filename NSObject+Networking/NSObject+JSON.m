//
//  NSObject+JSON.m
//  INCDFramework
//
//  Created by aazhou on 2/3/12.
//  Copyright (c) 2012 FishSaying. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NSObject+JSON.h"
#import <objc/runtime.h>
#import "DataModelArray.h"
#import "NSArray+JSON.h"

@implementation NSObject (JSON)

static const NSString *S_VALUE_TYPES = @"cislqCISLQfdB";

+ (id)dataModelWithJSONString:(NSString *)jsonString {
    NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    id dataModel = [self dataModelWithJSONObject:jsonObject];
    
    return dataModel;
}

+ (id)dataModelWithJSONObject:(id)jsonObject {
    id dataModel = nil;
    
    Class itemType = [self class];
    
    if ([jsonObject isKindOfClass:[NSArray class]]) {
        DataModelArray *modelArray = [DataModelArray arrayWithItemType:itemType];
        
        [modelArray fillWithJSONObejct:jsonObject];
        
        dataModel = modelArray;
    } else if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSObject *modelItem = [[itemType alloc] init];
        
        [modelItem fillWithJSONObejct:jsonObject];
        
        dataModel = modelItem;
    }
    
    return dataModel;
}

- (void)fillWithJSONObejct:(NSDictionary *)jsonObject {
    Class class = [self class];
    NSArray *keys = [jsonObject allKeys];
    
    for (NSString *key in keys) {
        objc_property_t property = class_getProperty(class, [key UTF8String]);
        
        if (property != nil) {
            NSString *attribute = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
            
            // 忽略属性是ReadOnly
            NSString *attrs = [NSString stringWithCString:property_getAttributes(property) encoding:NSUTF8StringEncoding];
            if ([attrs containsString:@",R"]) {
                continue;
            }
            
            NSRange range = NSMakeRange(1, [attribute rangeOfString:@","].location - 1);
            NSString *attrType = [attribute substringWithRange:range];
            
            id value = [jsonObject objectForKey:key];
            
            id newValue = nil;
            if ([attrType hasPrefix:@"@\""]) {
                attrType = [attrType substringWithRange:NSMakeRange(2, [attrType length] - 3)];
                
                Class class = NSClassFromString(attrType);
                
                if ([class isSubclassOfClass:[NSDecimalNumber class]]) {
                    if ([value isKindOfClass:[NSDecimalNumber class]]) {
                        newValue = value;
                    } else if ([value isKindOfClass:[NSNumber class]]) {
                        newValue = [NSDecimalNumber decimalNumberWithDecimal:[value decimalValue]];
                    }
                } else if ([class isSubclassOfClass:[NSNumber class]]) {
                    if ([value isKindOfClass:[NSNumber class]]) {
                        newValue = value;
                    }
                } else if ([class isSubclassOfClass:[NSString class]]) {
                    if ([value isKindOfClass:[NSString class]]) {
                        newValue = value;
                    }
                } else if ([class isSubclassOfClass:[NSDictionary class]]) {
                    if ([value isKindOfClass:[NSDictionary class]]) {
                        newValue = value;
                    }
                } else if ([class isSubclassOfClass:[NSArray class]]) {
                    newValue = [self valueForKey:key];
                    
                    if ([value isKindOfClass:[NSArray class]] && [newValue isKindOfClass:[DataModelArray class]]) {
                        [(DataModelArray *)newValue fillWithJSONObejct:value];
                    }
                } else {
                    if ([value isKindOfClass:[NSDictionary class]]) {
                        newValue = [[class alloc] init];
                        
                        [newValue fillWithJSONObejct:value];
                    }
                }
            } else if ([S_VALUE_TYPES rangeOfString:attrType].location != NSNotFound) {
                newValue = value;
            }
            [self setValue:newValue forKey:key];
        }
    }
}

- (NSString *)toJSONString {
    NSString *jsonString = nil;
    if ([self isKindOfClass:[NSArray class]]) {
        jsonString = [(NSArray*)self _toJSONString];
    }
    else if ([self isKindOfClass:[NSDictionary class]]) {
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self options:NSJSONWritingPrettyPrinted error:nil];
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        
    }
    else {
        NSDictionary *jsonObject = [self toJSONObject];
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:jsonObject options:NSJSONWritingPrettyPrinted error:nil];
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    
    return jsonString;
}

- (NSDictionary *)toJSONObject {
    NSMutableDictionary *jsonDictionary = [NSMutableDictionary dictionary];
    
    uint count;
    
    Class class = [self class];
    
    while (class != [NSObject class]) {
        objc_property_t *properties = class_copyPropertyList(class, &count);
        
        for (int i = 0; i < count; i++) {
            NSString *key = [NSString stringWithCString:property_getName(properties[i]) encoding:NSUTF8StringEncoding];
            
            // 忽略属性是ReadOnly
            NSString *attrs = [NSString stringWithCString:property_getAttributes(properties[i]) encoding:NSUTF8StringEncoding];
            if ([attrs containsString:@",R"]) {
                continue;
            }
            
            id value = [self valueForKey:key];
            id newValue = nil;

            // 忽略不需要进行序列化的类型
            if ([value isKindOfClass:[UIImage class]] ||
                [value isKindOfClass:[UIViewController class]] ||
                [value isKindOfClass:[UIView class]] ||
                [value isKindOfClass:[UIResponder class]]) {
                continue;
            }
            
            if ([value isKindOfClass:[NSString class]]) {
                newValue = value;
            } else if ([value isKindOfClass:[NSNumber class]]) {
                newValue = value;
            } else if ([value isKindOfClass:[NSNull class]]) {
                newValue = value;
            } else if ([value isKindOfClass:[NSDictionary class]]) {
                newValue = value;
            } else if ([value isKindOfClass:[NSArray class]]) {
                newValue = [(NSArray *)value _toJSONObject];
            }
            else {
                newValue = [value toJSONObject];
            }
            
            if (newValue != nil) {
                [jsonDictionary setObject:newValue forKey:key];
            }
        }
        
        free(properties);
        class = class_getSuperclass(class);
    }
    
    return jsonDictionary;
}

@end
