//
//  ServiceResult.m
//  CoreFamework
//
//  Created by aazhouzhou on 13-6-17.
//  Copyright (c) 2013年 FishSaying. All rights reserved.
//

#import "ServiceResult.h"
#import "NSObject+JSON.h"

@implementation ServiceError

+ (instancetype)errorWithNSError:(NSError *)error {
    ServiceError *serverError = [[ServiceError alloc] init];
    serverError.code = error.code;
    serverError.message = [error localizedDescription];
    
    return serverError;
}

@end

@implementation ServiceResult

+ (ServiceResult*)resultWithJSON:(id)jsonObject forDataType:(Class)dataType {
    ServiceResult *result = nil;
    
    result = [[ServiceResult alloc] init];
    if ([jsonObject isKindOfClass:[NSDictionary class]]) {
        NSUInteger code = 0;
        NSString *message = nil;
        id<NSObject> resultObject = nil;
        
        if ([[jsonObject allKeys] containsObject:@"code"]) {
            code = [[jsonObject objectForKey:@"code"] intValue];
        }
        if ([[jsonObject allKeys] containsObject:@"message"]) {
            message = [jsonObject objectForKey:@"message"];
        }
        
        if ([[jsonObject allKeys] containsObject:@"result"]) {
            resultObject = [jsonObject objectForKey:@"result"];
        }
        
        if (code > 0) {
            ServiceError *error = [[ServiceError alloc] init];
            error.type = ErrorTypeBusiness;
            error.code = code;
            error.message = message;
            result.error = error;
        }
        else {
            if (resultObject) {
                if (dataType) {
                    result.data = [dataType dataModelWithJSONObject:resultObject];
                    
                }
                else {
                    result.data = resultObject;
                }
            }
            else {
                if (dataType) {
                    result.data = [dataType dataModelWithJSONObject:resultObject];
                }
                else {
                    result.data = resultObject;
                }
            }
        }
    }
    
    return result;
}

+ (ServiceResult *)resultWithErrorType:(ErrorType)type
                          errorMessage:(NSString *)errorMessage
                            statusCode:(NSInteger)statusCode {
    ServiceError *error = [[ServiceError alloc] init];
    error.type = type;
    error.code = statusCode;
    error.message = errorMessage;
    
    ServiceResult *result = [[ServiceResult alloc] init];
    result.data = nil;
    result.error = error;
    
    return result;
}

@end
