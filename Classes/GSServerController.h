/*
 Copyright (c) 2011-2012 GlicSoft
 All rights reserved.
 
 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions are met:
 * Redistributions of source code must retain the above copyright
 notice, this list of conditions and the following disclaimer.
 * Redistributions in binary form must reproduce the above copyright
 notice, this list of conditions and the following disclaimer in the
 documentation and/or other materials provided with the distribution.
 * Neither the name of GlicSoft nor the
 names of its contributors may be used to endorse or promote products
 derived from this software without specific prior written permission.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
 ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
 WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 DISCLAIMED. IN NO EVENT SHALL GLICSOFT BE LIABLE FOR ANY
 DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
 (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
 LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
 SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
//
//  GSServerController.h
//  gsutils
//
//  Created by Shane Breatnach on 01/02/2011.
//

#import <Foundation/Foundation.h>

@class GSFileCache;
@class GSHTTPRequest;
@class GTMKeyValueChangeNotification;

/**
 Offers singleton interface for making HTTP requests and linking callbacks
 for the response data.
 */
@interface GSServerController : NSObject
{
    GSFileCache *_responseCache;
    NSOperationQueue *_operationQueue;
    NSMutableDictionary *_operationMap;
}

/**
 Singleton shared instance for centralising all access to the server.
 */
+ (GSServerController*)sharedInstance;
/**
 Checks that the given notification registered by the controller is a response
 finished notification.
 */
- (void)isResponseFinished: (GTMKeyValueChangeNotification*) notification;
/**
 Sends the given HTTP request to the server with a given target and action as
 callback on completion. Callback signature must be 
 -(void)parseResponse:(GSHTTPResponse*). The name version of this is
 @"parseResponse:"
 */
- (void)sendAsyncRequest: (GSHTTPRequest*) request
              withTarget: (NSObject*) target
           andActionName: (NSString*) action;

@end
