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
//  Tests.m
//  Tests
//
//  Created by Shane Breatnach on 26/04/2011.
//

#import <GHUnitIOS/GHUnit.h>
#import "GSNSMutableDictionary+Utilities.h"

@interface GSNSMutableDictionaryTest : GHTestCase { }
@end

@implementation GSNSMutableDictionaryTest

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testSimpleMerge
{
    NSMutableDictionary *dict1 = [NSMutableDictionary dictionary];
    NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
    [dict2 setObject:@"val" forKey:@"key"];
    [NSMutableDictionary mergeDictionary:dict1 withDictionary:dict2];
    GHAssertEqualStrings([dict1 objectForKey:@"key"], @"val", nil);
}

- (void)testComplexMerge
{
    NSMutableDictionary *dict1 = [NSMutableDictionary dictionary];
    // base dict which will be merged/overridden
    [dict1 setObject:[NSMutableArray arrayWithObjects:@"obj1", @"obj2", nil]
              forKey:@"arr"];
    [dict1 setObject:[NSMutableDictionary dictionaryWithObjectsAndKeys:
                      @"obj3", @"key1", @"obj4", @"key2", nil]
              forKey:@"dict"];
    [dict1 setObject:@"val1" forKey:@"override"];
    [dict1 setObject:@"val3" forKey:@"nonoverride1"];
    
    // source dict which may override
    NSMutableDictionary *dict2 = [NSMutableDictionary dictionary];
    [dict2 setObject:[NSArray arrayWithObjects:@"obj5", @"obj6", nil]
              forKey:@"arr"];
    [dict2 setObject:[NSDictionary dictionaryWithObjectsAndKeys:
                      @"obj7", @"key3", @"obj8", @"key2", nil]
              forKey:@"dict"];
    [dict2 setObject:@"val2" forKey:@"override"];
    [dict2 setObject:@"val4" forKey:@"nonoverride2"];
    
    [NSMutableDictionary mergeDictionary:dict1 withDictionary:dict2];
    
    // array extended by merging key
    GHAssertTrue([[dict1 objectForKey:@"arr"] count] == 4, nil);
    GHAssertTrue([[dict1 objectForKey:@"arr"] containsObject:@"obj1"], nil);
    GHAssertTrue([[dict1 objectForKey:@"arr"] containsObject:@"obj2"], nil);
    GHAssertTrue([[dict1 objectForKey:@"arr"] containsObject:@"obj5"], nil);
    GHAssertTrue([[dict1 objectForKey:@"arr"] containsObject:@"obj6"], nil);
    // dict is overridden with matching keys, added otherwise
    GHAssertTrue([[dict1 objectForKey:@"dict"] count] == 3, nil);
    GHAssertEqualStrings([[dict1 objectForKey:@"dict"] objectForKey:@"key1"], @"obj3",nil);
    GHAssertEqualStrings([[dict1 objectForKey:@"dict"] objectForKey:@"key2"], @"obj8",nil);
    GHAssertEqualStrings([[dict1 objectForKey:@"dict"] objectForKey:@"key3"], @"obj7",nil);
    // equal keys are overridden
    GHAssertEqualStrings([dict1 objectForKey:@"override"], @"val2",nil);
    // non-equal left as is
    GHAssertEqualStrings([dict1 objectForKey:@"nonoverride1"], @"val3",nil);
    GHAssertEqualStrings([dict1 objectForKey:@"nonoverride2"], @"val4",nil);
}

@end
