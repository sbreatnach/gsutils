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
//  GSHTTPResponse.m
//  gsutils
//
//  Created by Shane Breatnach on 04/02/2011.
//

#import "GSHTTPResponse.h"
#import "GSJsonParser.h"
#import "GSNSString+FormattingUtils.h"

@implementation GSHTTPResponse

@synthesize statusCode = _statusCode;
@synthesize contentLength = _contentLength;
@synthesize content = _content;
@synthesize HEADERS = _HEADERS;
@synthesize request = _request;

@dynamic fileName;
- (NSString*)fileName
{
    if( _fileName != nil )
    {
        return _fileName;
    }
    NSString *fileNameHeader = [self.HEADERS
                                objectForKey:@"Content-Disposition"];
    if( fileNameHeader != nil )
    {
        NSCharacterSet *whitespaceSet = [[NSCharacterSet
                                          whitespaceAndNewlineCharacterSet]
                                         retain];
        // ideally, all tests listed in http://greenbytes.de/tech/tc2231/
        // pass without issue. Perhaps outside the scope of this code :)
        // TODO: what about ; used in filename?
        NSArray *dispositionParts = [[fileNameHeader
                                      componentsSeparatedByString:@";"] retain];
        for( NSUInteger i = 0; i < [dispositionParts count]; i ++ )
        {
            // first part always disposition type, ignore
            // TODO: handle type correctly (inline/attachment)
            if( i == 0 )
            {
                continue;
            }
            NSString *dispositionPart = [[[dispositionParts objectAtIndex:i]
                                          stringByTrimmingCharactersInSet:
                                          whitespaceSet] retain];
            // TODO: what about = used in filename?
            NSArray *keyValue = [[dispositionPart
                                  componentsSeparatedByString:@"="] retain];
            if( [[keyValue objectAtIndex:0] isEqual:@"filename"] )
            {
                // TODO: handle RFC 2047 encoding
                _fileName = [[keyValue objectAtIndex:1] copy];
            }
            [keyValue release];
            [dispositionPart release];
        }
        [dispositionParts release];
        [whitespaceSet release];
    }
    else
    {
        // if no file name header, generate random name (Firefox-like)
        _fileName = [[NSString randomStringOfLength:16] retain];
    }
    return _fileName;
}

- (void)dealloc
{
    [_content release];
    [_HEADERS release];
    [_fileName release];
    [_request release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if( self != nil )
    {
        _contentLength = -1;
    }
    return self;
}

- (id)jsonContent
{
    id jsonData = nil;
    if( self.content != nil )
    {
        GSJsonParser *parser = [[GSJsonParser alloc] init];
        jsonData = [parser objectWithData: self.content];
        [parser release];
    }
    return jsonData;
}

- (NSString*)stringContent
{
    NSString *stringData = @"";
    if( self.content != nil )
    {
        stringData = [[[NSString alloc]
                       initWithData:self.content
                       encoding:NSUTF8StringEncoding] autorelease];
    }
    return stringData;
}

@end
