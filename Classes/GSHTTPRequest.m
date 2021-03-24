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
//  GSHTTPRequest.m
//  gsutils
//
//  Created by Shane Breatnach on 03/02/2011.
//

#import "GSHTTPRequest.h"
#import "GSHTTPResponse.h"
#import "GSMultiValueDictionary.h"
#import "GSFile.h"
#import "GSLogging.h"
#import "GSNSData+Base64.h"

// Boundary for upload form. TODO: make this dynamic and check that it doesn't
// exist in the data being written as part of the form.
static NSString *kStringBoundary = @"----------------------DEADBEEF01234567890";
// 128KB pre-allocated body size to support simple uploads
static NSUInteger kDefaultPostBodyLength = 128 * 1024;

@interface GSHTTPRequest ()
/**
 Generates the raw POST body data if uploading a file, which follows a unique
 format to pass any binary data.
 */
- (NSData*)generateFileUploadBody;
/**
 Returns the url-encoded string query string as constructed from the given
 multi-value dictionary.
 */
- (NSString*)generateQueryString: (GSMultiValueDictionary*)dictionary;
@end

@implementation GSHTTPRequest

@synthesize path = _path;
@synthesize method = _method;
@synthesize encoding = _encoding;
@synthesize GET = _GET;
@synthesize POST = _POST;
@synthesize HEADERS = _HEADERS;
@synthesize FILES = _FILES;
@synthesize isSecure = _isSecure;
@synthesize cacheEnabled = _cacheEnabled;
@synthesize response = _response;
@synthesize validateSecureConnections = _validateSecureConnections;
@dynamic cacheKey;
@dynamic host;
@dynamic contentType;
@dynamic httpBody;

- (void)dealloc
{
    [_response release];
    [_path release];
    [_method release];
    [_httpBody release];
    [_tempBuffer release];
    [_GET release];
    [_POST release];
    [_FILES release];
    [_HEADERS release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if( self != nil )
    {
        _GET = [[GSMultiValueDictionary alloc] init];
        _POST = [[GSMultiValueDictionary alloc] init];
        _HEADERS = [[NSMutableDictionary alloc] init];
        _FILES = [[GSMultiValueDictionary alloc] init];
        _tempBuffer = [[NSMutableString alloc] init];
        _response = [[GSHTTPResponse alloc] init];
        _method = @"GET";
        _validateSecureConnections = YES;
        // TODO: use content-transfer-encoding header 
        _encoding = NSUTF8StringEncoding;
        // set the accepted language list for all requests based on the current
        // preferred languages list.
        NSArray *preferredLanguages = [NSLocale preferredLanguages];
        NSString *acceptedLanguages =
        [preferredLanguages componentsJoinedByString:@", "];
        [_HEADERS setObject:acceptedLanguages forKey:@"Accept-Language"];
    }
    return self;
}

+ (id)request
{
    return [[[self alloc] init] autorelease];
}

- (NSString*)cacheKey
{
    return [NSString stringWithFormat:@"%@-%@", self.host, self.path, nil];
}

- (NSString*)host
{
    return [self.HEADERS objectForKey:@"Host"];
}

- (void)setHost:(NSString *)aHost
{
    NSString *curHost = [self.HEADERS objectForKey:@"Host"];
    if( curHost == nil )
    {
        [self.HEADERS setObject:aHost forKey:@"Host"];
    }
}

- (NSString*)contentType
{
    if (_contentType == nil &&
        ([_method isEqualToString:@"POST"] ||
         [_method isEqualToString:@"PUT"]) )
    {
        if( [self.FILES count] > 0 )
        {
            self.contentType = [NSString
                                stringWithFormat:
                                @"multipart/form-data; boundary=%@",
                                kStringBoundary, nil];
        }
        else
        {
            self.contentType = @"application/x-www-form-urlencoded";
        }

    }
    return _contentType;
}

- (void)setContentType: (NSString*) aContentType
{
    if( aContentType != _contentType )
    {
        [_contentType release];
        _contentType = [aContentType retain];
    }
}

- (NSData*)httpBody
{
    NSData *aHttpBody = nil;
    if( _httpBody )
    {
        aHttpBody = _httpBody;
    }
    else if( [_method isEqualToString:@"POST"] ||
             [_method isEqualToString:@"PUT"] )
    {
        if( [self.FILES count] > 0 )
        {
            aHttpBody = [self generateFileUploadBody];
        }
        else
        {
            aHttpBody = [[self generateQueryString:self.POST]
                         dataUsingEncoding:NSUTF8StringEncoding];
        }

    }
    return aHttpBody;
}

- (void)setHttpBody:(NSData *) aHttpBody
{
    if( aHttpBody != _httpBody )
    {
        [_httpBody release];
        _httpBody = [aHttpBody retain];
    }
}

- (NSString*)generateQueryString: (GSMultiValueDictionary*)dictionary
{
    NSMutableString *queryString = [[[NSMutableString alloc] init] autorelease];
    // note that this code will leave a & trailing on the query string
    // a minor issue to avoid complicating code and/or increasing mem usage.
    for( NSString *key in [dictionary keyEnumerator] )
    {
        NSArray *values = [dictionary arrayForKey: key];
        for( id value in values )
        {
            [queryString appendString:
             [key stringByAddingPercentEscapesUsingEncoding: self.encoding]];
            [queryString appendString: @"="];
            NSString *valueString = value;
            if( [value respondsToSelector:@selector(stringValue)] )
            {
                valueString = [value stringValue];
            }
            [queryString appendString:
             [valueString stringByAddingPercentEscapesUsingEncoding:
              self.encoding]];
            [queryString appendString: @"&"];
        }
    }
    return queryString;
}

- (NSData*)generateFileUploadBody
{
    NSMutableData* body = [[[NSMutableData alloc] 
                            initWithCapacity:kDefaultPostBodyLength]
                           autorelease];
    // every element of the form has a boundary to signify begin/end of
    // each element. NB: additional -- before defined string boundary.
    NSData* boundaryData = [[NSString stringWithFormat:
                             @"\r\n--%@\r\n", kStringBoundary, nil]
                            dataUsingEncoding:self.encoding];
    
    // set the non-file key/values. They follow the same format as the
    // files, bar the content-type and content-length
    for( NSString *key in [self.POST keyEnumerator] )
    {
        NSArray *values = [self.POST arrayForKey:key];
        for( id value in [values objectEnumerator] )
        {
            [body appendData:boundaryData];
            [body appendData:
             [[NSString stringWithFormat:
               @"Content-Disposition: form-data; name=\"%@\"\r\n\r\n", key, nil] 
              dataUsingEncoding:self.encoding]];
            NSString *valueString = value;
            if( [value respondsToSelector:@selector(stringValue)] )
            {
                valueString = [value stringValue];
            }
            [body appendData:[valueString dataUsingEncoding:self.encoding]];
        }
    }
    
    // file data for the upload form - additional keys Content-Length and
    // Content-Type
    for( NSString *key in [self.FILES keyEnumerator] )
    {
        GSFile *file = (GSFile*) [self.FILES objectForKey: key];
        NSData* data = file.data;
        
        [body appendData:boundaryData];
        [body appendData:[[NSString stringWithFormat:
                           @"Content-Disposition: form-data; name=\"%@\"; "
                           "filename=\"%@\"\r\n",
                           key, file.fileName, nil]
                          dataUsingEncoding:self.encoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Length: %d\r\n",
                           data.length, nil]
                          dataUsingEncoding:self.encoding]];
        [body appendData:[[NSString stringWithFormat:@"Content-Type: %@\r\n\r\n",
                           file.mimeType, nil]
                          dataUsingEncoding:self.encoding]];
        [body appendData:data];
    }
    
    // final boundary of body data
    // note the additional -- to notify the parser that's it
    [body appendData:[[NSString stringWithFormat:@"\r\n--%@--\r\n",
                       kStringBoundary, nil]
                      dataUsingEncoding:self.encoding]];

    return body;
}

- (NSURLRequest*)allocNSURLRequest
{
    // at the very least, must have a host set. If not, fail.
    if( self.host == nil )
    {
        return nil;
    }
    // construct full URL from the components of the request.
    [_tempBuffer setString:@""];
    [_tempBuffer appendString: (self.isSecure ? @"https" : @"http" )];
    [_tempBuffer appendString: @"://"];
    [_tempBuffer appendString: self.host];
    if( self.path != nil )
    {
        [_tempBuffer appendString: self.path];
    }
    else
    {
        [_tempBuffer appendString: @"/"];
    }

    NSString *getQueryString = [[self generateQueryString:self.GET] retain];
    if( [getQueryString length] > 0 )
    {
        [_tempBuffer appendString: @"?"];
        [_tempBuffer appendString:getQueryString];
    }
    [getQueryString release];
    
    // create the NSURLRequest obj needed.
    NSURL *url = [[NSURL alloc] initWithString: _tempBuffer];
    if( url == nil )
    {
        return nil;
    }
    NSMutableURLRequest* urlRequest = [[NSMutableURLRequest alloc]
                                       initWithURL: url];
    if( urlRequest != nil )
    {
        [urlRequest setHTTPMethod:self.method];
        // store the body and set the accompanying content length header
        NSData* body = self.httpBody;
        if( body != nil )
        {
            [self.HEADERS setObject:[NSString stringWithFormat:@"%d",
                                     [body length]]
                             forKey:@"Content-Length"];
            [urlRequest setHTTPBody:body];
            [self.HEADERS setObject:self.contentType forKey:@"Content-Type"];
        }
        // set remaining headers and store in request
        [urlRequest setAllHTTPHeaderFields: self.HEADERS];
        //[URLRequest setHTTPShouldHandleCookies:request.shouldHandleCookies];
    }
    [url release];
    // if no body has been set and it's a method which expects a body,
    // fail
    if( [urlRequest HTTPBody] == nil &&
       ([[urlRequest HTTPMethod] isEqual: @"POST"] ||
        [[urlRequest HTTPMethod] isEqual: @"PUT"]) )
    {
        [urlRequest release];
        urlRequest = nil;
    }
    return urlRequest;
}

@end
