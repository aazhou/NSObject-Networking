//
//  ServiceResult.h
//  CoreFamework
//
//  Created by aazhouzhou on 13-6-17.
//  Copyright (c) 2013年 FishSaying. All rights reserved.
//

#import <CoreFoundation/CoreFoundation.h>

typedef enum {
    ErrorTypeSystem,
    ErrorTypeBusiness
} ErrorType;

@interface ServiceError : NSObject

@property(nonatomic,assign) ErrorType   type;
@property(nonatomic,assign) NSInteger   code;
@property(nonatomic,strong) NSString    *message;

+ (instancetype)errorWithNSError:(NSError *)error;

@end

@interface ServiceResult : NSObject

@property (nonatomic, strong) id data;
@property (nonatomic, strong) ServiceError *error;

+ (ServiceResult*)resultWithJSON:(id)jsonObject forDataType:(Class)dataType;
+ (ServiceResult*)resultWithErrorType:(ErrorType)type errorMessage:(NSString*)errorMessage statusCode:(NSInteger)statusCode;

@end
