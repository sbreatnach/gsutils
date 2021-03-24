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
//  GSURLTest.m
//  gsutils
//
//  Created by Shane Breatnach on 26/04/2011.
//

#import <GHUnitIOS/GHUnit.h>
#import "GSNSURL+URLUtilities.h"
#import "GSMultiValueDictionary.h"

@interface GSNSURLTest : GHTestCase { }
@end

@implementation GSNSURLTest

// all code under test must be linked into the Unit Test bundle

- (void)testBasicQueryDictionary
{
    NSURL *url = [NSURL URLWithString:@"http://www.google.ie/?q=test"];
    NSDictionary *query = [url queryDictionary];
    GHAssertTrue([query count] == 1, nil);
    GHAssertNotNil([query objectForKey:@"q"], nil);
    GHAssertEqualStrings([query objectForKey:@"q"], @"test", nil);
}

- (void)testComplexQueryDictionary
{
    NSURL *url = [NSURL URLWithString:
                  @"http://www.google.ie/?q=test&q=another%20test&lang=en&val="
                  "&val2=f%C3%A9ar&"];
    GSMultiValueDictionary *query = [url queryDictionary];
    GHAssertTrue([query count] == 4, nil);
    GHAssertNotNil([query objectForKey:@"q"], nil);
    GHAssertTrue([[query arrayForKey:@"q"] count] == 2, nil);
    GHAssertTrue([[query arrayForKey:@"q"] containsObject:@"test"], nil);
    GHAssertTrue([[query arrayForKey:@"q"] containsObject:@"another test"], nil);
    GHAssertEqualStrings([query objectForKey:@"val2"], @"féar", nil);
}

@end
