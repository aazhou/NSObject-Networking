//
//  NSObject+Networking.h
//  FishSaying
//
//  Created by aazhou on 13-7-17.
//  Copyright (c) 2013年 FishSaying. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceResult.h"
#import "NetworkingProtocol.h"

@class AFHTTPRequestOperationManager;

typedef void(^HTTPCompletionBlock)(ServiceResult *result);

@interface NSObject (Networking)

@property (nonatomic, strong) AFHTTPRequestOperationManager *operationManager;

- (void)getWithURL:(NSURL *)url
          dataType:(Class)dataType
          callback:(HTTPCompletionBlock)callback;

- (void)postWithURL:(NSURL *)url
           formData:(NSDictionary *)formData
           dataType:(Class)dataType
           callback:(HTTPCompletionBlock)callback;

- (void)putWithURL:(NSURL *)url
          formData:(NSDictionary *)formData
          dataType:(Class)dataType
          callback:(HTTPCompletionBlock)callback;

- (void)deleteWithURL:(NSURL *)url
             callback:(HTTPCompletionBlock)callback;

- (void)cancelAllHTTPRequest;

- (NSDictionary *)defaultHTTPHeaderFields;

@end
