//
//  NetworkingProtocol.h
//  FishSaying
//
//  Created by aazhou on 13-8-6.
//  Copyright (c) 2013年 FishSaying. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ServiceResult.h"

typedef enum {
    HandleErrorTypePopup,
    HandleErrorTypePlane,
    HandleErrorTypeToast,
    HandleErrorTypeNone
}HandleErrorType;

@protocol NetworkingProtocol <NSObject>

@optional
- (void)onNetworkingDidStarted:(NSURL *)url;
- (void)onNetworkingDidFinished:(NSURL *)url;

@end