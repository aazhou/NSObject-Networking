//
//  NSObject+Networking.m
//  FishSaying
//
//  Created by aazhou on 13-7-17.
//  Copyright (c) 2013年 FishSaying. All rights reserved.
//

#import "NSObject+Networking.h"
#import <objc/runtime.h>
#import "AFNetworking.h"
#import "AFNetworkActivityLogger.h"
#import "AFNetworkActivityIndicatorManager.h"

static const char *kHTTPOperationManagerPropertyKey = "kHTTPOperationManagerPropertyKey";

@implementation NSObject (Networking)

//////////////////////////////////////////////////////////////////
#pragma mark - HTTP

- (void)getWithURL:(NSURL *)url dataType:(Class)dataType callback:(HTTPCompletionBlock)callback {
    __weak __typeof__(self) _blockSelf = self;
    
    AFHTTPRequestOperationManager *manager = [self sharedOperationManager];
    AFHTTPRequestOperation *operation = [manager GET:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [_blockSelf onRequestDidFinished:operation dataType:dataType callback:callback];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_blockSelf onRequestDidFailed:operation dataType:dataType callback:callback];
    }];
    [self onRequestStart:operation];
}

- (void)postWithURL:(NSURL *)url formData:(NSDictionary *)formData dataType:(Class)dataType callback:(HTTPCompletionBlock)callback {
    __weak __typeof__(self) _blockSelf = self;
    
    AFHTTPRequestOperationManager *manager = [self sharedOperationManager];
    AFHTTPRequestOperation *operation = [manager POST:[url absoluteString] parameters:formData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [_blockSelf onRequestDidFinished:operation dataType:dataType callback:callback];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_blockSelf onRequestDidFailed:operation dataType:dataType callback:callback];
    }];
    [self onRequestStart:operation];
}

- (void)putWithURL:(NSURL *)url formData:(NSDictionary *)formData dataType:(Class)dataType callback:(HTTPCompletionBlock)callback {
    __weak __typeof__(self) _blockSelf = self;
    
    AFHTTPRequestOperationManager *manager = [self sharedOperationManager];
    AFHTTPRequestOperation *operation = [manager PUT:[url absoluteString] parameters:formData success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [_blockSelf onRequestDidFinished:operation dataType:dataType callback:callback];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_blockSelf onRequestDidFailed:operation dataType:dataType callback:callback];
    }];
    [self onRequestStart:operation];
}

- (void)deleteWithURL:(NSURL *)url callback:(HTTPCompletionBlock)callback {
    __weak __typeof__(self) _blockSelf = self;
    
    AFHTTPRequestOperationManager *manager = [self sharedOperationManager];
    AFHTTPRequestOperation *operation = [manager DELETE:[url absoluteString] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [_blockSelf onRequestDidFinished:operation dataType:nil callback:callback];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [_blockSelf onRequestDidFailed:operation dataType:nil callback:callback];
    }];
    [self onRequestStart:operation];
}

- (NSDictionary *)defaultHTTPHeaderFields {
    return nil;
}

#pragma mark - SharedOperationManager

- (AFHTTPRequestOperationManager *)sharedOperationManager {
    if (!self.operationManager) {
        AFHTTPRequestOperationManager *manager = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:nil];
        AFSecurityPolicy *securityPolicy = [AFSecurityPolicy policyWithPinningMode:AFSSLPinningModeNone];
        securityPolicy.allowInvalidCertificates = YES;
        manager.securityPolicy = securityPolicy;
        NSDictionary *headers = [self defaultHTTPHeaderFields];
        if (headers) {
            for (NSString *key in headers.allKeys) {
                [manager.requestSerializer setValue:[headers objectForKey:key]
                                 forHTTPHeaderField:key];
            }
        }
        self.operationManager = manager;
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [[AFNetworkActivityIndicatorManager sharedManager] setEnabled:YES];
#if DEBUG
        [[AFNetworkActivityLogger sharedLogger] startLogging];
        [[AFNetworkActivityLogger sharedLogger] setLevel:AFLoggerLevelDebug];
#endif
        
    });
    return self.operationManager;
}

#pragma mark - 

- (void)onRequestStart:(AFHTTPRequestOperation *)operation {
    [self onRequestStartedWithRequestURL:operation.request.URL];
}

- (void)onRequestDidFinished:(AFHTTPRequestOperation *)operation dataType:(Class)dataType callback:(HTTPCompletionBlock)callback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        ServiceResult *result = nil;
        if (operation.responseObject) {
            result = [ServiceResult resultWithJSON:operation.responseObject forDataType:dataType];
        }
        else {
            result = [ServiceResult resultWithErrorType:ErrorTypeSystem
                                           errorMessage:operation.responseString
                                             statusCode:operation.response.statusCode];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self onRequestFinishedWithRequestURL:operation.request.URL];
            
            if (callback) {
                callback(result);
            }
        });
    });
}

- (void)onRequestDidFailed:(AFHTTPRequestOperation *)operation dataType:(Class)dataType callback:(HTTPCompletionBlock)callback {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(){
        ServiceResult *result = nil;
        if (operation.responseObject) {
            result = [ServiceResult resultWithJSON:operation.responseObject forDataType:dataType];
        }
        else if (operation.responseString) {
            NSData *data = [operation.responseString dataUsingEncoding:NSUTF8StringEncoding];
            id jsonObject = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            result = [ServiceResult resultWithJSON:jsonObject forDataType:dataType];
        }
        else {
            NSInteger code = operation.error.code;
            NSString *msg = [operation.error localizedDescription];
            result = [ServiceResult resultWithErrorType:ErrorTypeSystem
                                           errorMessage:msg
                                             statusCode:code];
        }
        
        dispatch_async(dispatch_get_main_queue(), ^(){
            [self onRequestFinishedWithRequestURL:operation.request.URL];
            
            if (callback) {
                callback(result);
            }
        });
    });
}

#pragma mark - Call Networking Protocol

- (void)onRequestStartedWithRequestURL:(NSURL *)requestURL {
    Class _selfClass = [self class];
    BOOL conforms = [_selfClass conformsToProtocol:@protocol(NetworkingProtocol)];
    if (conforms) {
        if ([self respondsToSelector:@selector(onNetworkingDidStarted:)]) {
            [self performSelector:@selector(onNetworkingDidStarted:) withObject:requestURL];
        }
    }
}

- (void)onRequestFinishedWithRequestURL:(NSURL *)requestURL {
    Class _selfClass = [self class];
    BOOL conforms = [_selfClass conformsToProtocol:@protocol(NetworkingProtocol)];
    if (conforms) {
        if ([self respondsToSelector:@selector(onNetworkingDidFinished:)]) {
            [self performSelector:@selector(onNetworkingDidFinished:) withObject:requestURL];
        }
    }
}

#pragma mark - HTTPRequest

- (void)cancelAllHTTPRequest {
    [self.operationManager.operationQueue cancelAllOperations];
}

#pragma mark - Operations Property

- (AFHTTPRequestOperationManager *)operationManager {
     return objc_getAssociatedObject(self, kHTTPOperationManagerPropertyKey);
}

- (void)setOperationManager:(AFHTTPRequestOperationManager *)operationManager {
    objc_setAssociatedObject(self, kHTTPOperationManagerPropertyKey, operationManager, OBJC_ASSOCIATION_RETAIN);
}

@end
