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
//  GSHTTPResponse.h
//  gsutils
//
//  Created by Shane Breatnach on 04/02/2011.
//

#import <Foundation/Foundation.h>

/**
 Contains all the response data as read from a HTTP request. Includes methods
 for parsing raw data into more user-friendly formats.
 */
@interface GSHTTPResponse : NSObject
{
    NSUInteger _statusCode;
    NSInteger _contentLength;
    NSData *_content;
    NSDictionary *_HEADERS;
    NSString *_fileName;
    NSURL *_request;
}


/**
 The original request URL that has created this response.
 */
@property (nonatomic, retain) NSURL *request;
/**
 Status code for the response. 200 means success, 302 means redirection, etc.
 */
@property (nonatomic, assign) NSUInteger statusCode;
/**
 Expected length of the content. -1 if no specific length was specified in the
 response.
 */
@property (nonatomic, assign) NSInteger contentLength;
/**
 The raw HTTP response data.
 */
@property (nonatomic, retain) NSData *content;
/**
 The raw headers of the response.
 */
@property (nonatomic, retain) NSDictionary *HEADERS;
/**
 If the content disposition header was set, contains the file name from the
 given data. Returns nil if no such header was set in the raw response.
 */
@property (nonatomic, retain, readonly) NSString *fileName;
/**
 Attempts to parse the response as JSON data. Returns the Objective-C
 representation of the JSON data e.g. dictionaries, arrays, etc. If the content
 is not valid JSON, nil is returned.
 */
- (id)jsonContent;
/**
 Returns the raw data response as a formatted string.
 */
- (NSString*)stringContent;

@end
