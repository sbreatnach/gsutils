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
//  GSHTTPRequest.h
//  gsutils
//
//  Created by Shane Breatnach on 03/02/2011.
//

#import <Foundation/Foundation.h>

@class GSMultiValueDictionary;
@class GSHTTPResponse;

/**
 Simplified representation of a HTTP request that can be converted to a Cocoa-
 specific implementation.
 
 HEADERS contains the HTTP headers set for the request. Some headers are
 preset depending on the request method and body data.
 GET represents the query string values of the URL request.
 POST represents the key/value pairs of the URL post body. Only parsed if
 the method has been set to POST.
 FILES contains the key/file pairs of an upload form. Only parsed if method
 is POST. If there are values in FILES, the request is treated as an upload
 form, with the requisite changes to the request content type.
 
 All keys for GET, HEADERS and POST must be NSString instances. All values
 for HEADERS must be NSString instances. All values for GET and POST must be
 NSString instances or respond to the selector -stringValue. All values for
 FILES must be GSFile instances.
 
 Cookies are automatically stored and retained across requests.
 
 See http://www.faqs.org/rfcs/rfc1867.html for more detail regarding
 implementation.
 */
@interface GSHTTPRequest : NSObject
{
    BOOL _isSecure;
    BOOL _cacheEnabled;
    NSString *_path;
    NSString *_contentType;
    NSString *_method;
    NSData *_httpBody;
    NSMutableData *_postBody;
    NSMutableString *_tempBuffer;
    NSStringEncoding _encoding;
    GSMultiValueDictionary *_GET;
    GSMultiValueDictionary *_POST;
    NSMutableDictionary *_HEADERS;
    GSMultiValueDictionary *_FILES;
    GSHTTPResponse *_response;
    BOOL _validateSecureConnections;
}

/**
 The path on the server host to be requested. Defaults to /
 */
@property (nonatomic, retain) NSString *path;
/**
 Character encoding for all data in the request. Defaults to UTF-8.
 */
@property (nonatomic, assign) NSStringEncoding encoding;
/**
 The HTTP method for the request. Currently supported: GET, POST
 */
@property (nonatomic, retain) NSString *method;
/**
 The server host for the request. Required to be set for a successful request.
 */
@property (nonatomic, retain) NSString *host;
/**
 The query string key/value pairs for the request.
 */
@property (nonatomic, retain) GSMultiValueDictionary *GET;
/**
 The post body key/value pairs for the request.
 */
@property (nonatomic, retain) GSMultiValueDictionary *POST;
/**
 HTTP headers for the request.
 */
@property (nonatomic, retain, readonly) NSMutableDictionary *HEADERS;
/**
 The named files to be uploaded via this request.
 */
@property (nonatomic, retain) GSMultiValueDictionary *FILES;
/**
 Enable the cache for this request. By default, cache is disabled. If YES,
 a successful response will be stored locally on the global cache. Also, if
 the request is in the cache, the response will be loaded from the cache.
 */
@property (nonatomic, assign) BOOL cacheEnabled;
/**
 The key for using this request with the HTTP request cache.
 */
@property (nonatomic, retain, readonly) NSString *cacheKey;
/**
 Is the request secure? If YES, HTTPS will be attempted, otherwise plain HTTP.
 */
@property (nonatomic, assign) BOOL isSecure;
/**
 If YES, validates the certificates for secure connections. YES by default.
 */
@property (nonatomic, assign) BOOL validateSecureConnections;
/**
 The content type for the request. Automatically set based on other parameters.
 */
@property (nonatomic, retain) NSString *contentType;
/**
 The raw body to be sent. Only applicable if method is POST.
 */
@property (nonatomic, retain) NSData *httpBody;
/**
 The container for the response for this request.
 */
@property (nonatomic, retain) GSHTTPResponse *response;
/**
 Returns a blank request instance.
 */
+ (id)request;
/**
 Creates a copy of an NSURLRequest representative of the current state of the
 request.
 */
- (NSURLRequest*)allocNSURLRequest;

@end
