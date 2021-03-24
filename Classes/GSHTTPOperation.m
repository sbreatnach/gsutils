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
//  GSServerOperation.m
//  gsutils
//
//  Created by Shane Breatnach on 01/02/2011.
//

#import "GSHTTPOperation.h"
#import "GSHTTPRequest.h"
#import "GSHTTPResponse.h"
#import "GSFileCache.h"
#import "GSFile.h"
#import "GSLogging.h"

@interface GSHTTPOperation ()

- (void)finish;

@end

@implementation GSHTTPOperation

@synthesize response = _response;
@synthesize responseCache = _responseCache;

- (void) dealloc
{
    [_connection release];
    [_tempData release];
    [_request release];
    [_response release];
    [_responseCache release];
    [_cacheKey release];
    [super dealloc];
}

- (id) initWithRequest: (GSHTTPRequest*) aRequest
{
    self = [super init];
    if( self != nil )
    {
        _request = [aRequest allocNSURLRequest];
        _response = [aRequest.response retain];
        _response.request = _request.URL;
        _cacheEnabled = aRequest.cacheEnabled;
        _validateTrustedConnections = aRequest.validateSecureConnections;
        if( _cacheEnabled )
        {
            _cacheKey = [aRequest.cacheKey retain];
        }
        _tempData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)finish
{
    [_connection release];
    _connection = nil;
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    _executing = NO;
    _finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

// mark -
// mark NSURLConnection delegate messages

-(void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    DLog( @"Starting request %@", _request );
    _response.statusCode = 200;
    if( [response respondsToSelector:@selector(statusCode)] )
    {
        _response.statusCode = [((NSHTTPURLResponse *)response) statusCode];
        _response.HEADERS = [((NSHTTPURLResponse *)response) allHeaderFields];
    }
    // HTTP error response, fail now
    if( _response.statusCode >= 400 )
    {
        // stop connecting; no more delegate messages
        [connection cancel];
        NSDictionary *errorInfo= [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSString stringWithFormat:
                                   NSLocalizedString(@"Server returned "
                                                     "status code %d", nil),
                                   _response.statusCode],
                                  NSLocalizedDescriptionKey, nil];
        NSError *statusError = [NSError errorWithDomain:@"HTTPError"
                                                   code:_response.statusCode
                                               userInfo:errorInfo];
        [self connection:connection didFailWithError:statusError];
    }
    else
    {
        // normal connection, parse
        [_tempData setLength:0];
        _response.contentLength = [response expectedContentLength];
    }
}

- (BOOL)connection:(NSURLConnection *)connection
canAuthenticateAgainstProtectionSpace:(NSURLProtectionSpace *)protectionSpace
{
    return [protectionSpace.authenticationMethod isEqualToString:
            NSURLAuthenticationMethodServerTrust];
}

- (void)connection:(NSURLConnection *)connection
didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge
{
    if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust] && !_validateTrustedConnections)
    {
        [challenge.sender useCredential:[NSURLCredential credentialForTrust:
                                         challenge.protectionSpace.serverTrust]
             forAuthenticationChallenge:challenge];
    }
    [challenge.sender continueWithoutCredentialForAuthenticationChallenge:challenge];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    if( [self isCancelled] )
    {
        [connection cancel];
        NSDictionary *errorInfo= [NSDictionary dictionaryWithObjectsAndKeys:
                                  NSLocalizedString(@"Connection cancelled", nil),
                                  NSLocalizedDescriptionKey, nil];
        NSError *cancelError = [NSError errorWithDomain:@"HTTPError"
                                                   code:-1
                                               userInfo:errorInfo];
        [self connection:connection didFailWithError:cancelError];
    }
    else
    {
        [_tempData appendData:data];        
    }

}

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    DLog( @"Failed request %@", _request );
    DLog( @"Error: %@", [error localizedDescription] );
    _response.statusCode = [error code];
    // set content to be the localised error message
    [_tempData setLength:0];
    [_tempData appendData:
     [[error localizedDescription] dataUsingEncoding:NSUTF8StringEncoding]];
    _response.content = _tempData;
    [self finish];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    DLog( @"Successfully finished request %@", _request );
    _response.content = _tempData;
    if( _cacheEnabled )
    {
        [_responseCache setData:_tempData forKey:_cacheKey];
    }
    [self finish];
}

// mark -
// mark NSOperation methods

- (BOOL)isFinished
{
    return _finished;
}

- (BOOL)isConcurrent
{
    return YES;
}

- (BOOL)isExecuting
{
    return _executing;
}

- (void) start
{
    if (![NSThread isMainThread])
    {
        // invoking connection on main thread required for connection to be
        // processed
        [self performSelectorOnMainThread:@selector(start)
                               withObject:nil
                            waitUntilDone:NO];
        return;
    }
    
    if( [self isCancelled] )
    {
        [self willChangeValueForKey:@"isFinished"];
        _finished = YES;
        [self didChangeValueForKey:@"isFinished"];
    }
    else
    {
        [self willChangeValueForKey:@"isExecuting"];
        _executing = YES;
        [self didChangeValueForKey:@"isExecuting"];
        // check if request is for data in the cache
        GSFile *cachedFile = nil;
        if( _cacheEnabled )
        {
            cachedFile = [_responseCache fileForKey:_cacheKey];
        }
        if( cachedFile == nil )
        {
            if( _cacheEnabled )
            {
                DLog(@"Cache miss for HTTP request %@", [_request URL]);
            }
            _connection = [[NSURLConnection connectionWithRequest:_request
                                                         delegate:self] retain];
            if( _connection == nil )
            {
                [self finish];
            }
        }
        else
        {
            DLog(@"Cache hit for HTTP request %@", [_request URL]);
            _response.content = cachedFile.data;
            _response.statusCode = 302;
            [self finish];
        }
    }
}

@end
