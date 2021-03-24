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
//  GSServerController.m
//  gsutils
//
//  Created by Shane Breatnach on 01/02/2011.
//

#import "GSServerController.h"
#import "GSHTTPRequest.h"
#import "GSHTTPResponse.h"
#import "GSHTTPOperation.h"
#import "GTMNSObject+KeyValueObserving.h"
#import "GSFileCache.h"

static GSServerController *sharedInstance = nil;

@implementation GSServerController

// MARK Singleton Methods

+ (GSServerController*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
            sharedInstance = [[GSServerController alloc] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)init {
    self = [super init];
    if( self != nil )
    {
        _responseCache = [[GSFileCache alloc] init];
        _operationMap = [[NSMutableDictionary alloc] init];
        _operationQueue = [[NSOperationQueue alloc] init];
        NSHTTPCookieStorage *cookieStorage = 
        [NSHTTPCookieStorage sharedHTTPCookieStorage];
        [cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
    }
    return self;
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (oneway void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

// MARK -
// MARK Instance Methods

- (void)isResponseFinished: (GTMKeyValueChangeNotification*) notification
{
    NSDictionary *changeDict = [notification change];
    BOOL isFinished = 
    [(NSNumber*) [changeDict objectForKey:NSKeyValueChangeNewKey] boolValue];
    if( isFinished )
    {
        GSHTTPOperation *finishedOperation =
        (GSHTTPOperation*) [notification userInfo];
        NSNumber *operationKey = [NSNumber numberWithLong:
                                  [finishedOperation hash]];
        NSArray *delegateAction = [_operationMap objectForKey:operationKey];
        NSObject *target = [delegateAction objectAtIndex:0];
        SEL delegateSelector = NSSelectorFromString( [delegateAction
                                                      objectAtIndex:1] );
        if( [target respondsToSelector:delegateSelector] )
        {
            [target performSelector:delegateSelector 
                         withObject:finishedOperation.response];
        }
        //void (*callback)(id, SEL, TPHTTPResponse*);
        //callback = (void (*)(id, SEL, TPHTTPResponse*))
        //[target methodForSelector:delegateSelector];
        //callback( target, delegateSelector, finishedOperation.response );
        [_operationMap removeObjectForKey:operationKey];
        [finishedOperation gtm_removeObserver:self
                                   forKeyPath:@"isFinished"
                                     selector:@selector(isResponseFinished:)];
    }
}

- (void)sendAsyncRequest: (GSHTTPRequest*) request
              withTarget: (NSObject*) target
           andActionName: (NSString*) action
{
    GSHTTPOperation *serverOperation = [[GSHTTPOperation alloc]
                                        initWithRequest: request];
    serverOperation.responseCache = _responseCache;
    NSMutableArray *delegateAction = [[[NSMutableArray alloc]
                                       initWithCapacity:2] autorelease];
    [delegateAction addObject:target];
    [delegateAction addObject:action];
    [_operationMap setObject:delegateAction
                      forKey:[NSNumber numberWithLong:[serverOperation hash]]];
    [serverOperation gtm_addObserver: self
                          forKeyPath: @"isFinished"
                            selector: @selector(isResponseFinished:)
                            userInfo: serverOperation
                             options: NSKeyValueObservingOptionNew];
    // TODO: does this require operationQueue to be atomic?
    [_operationQueue addOperation: serverOperation];
    [serverOperation release];
}

@end
