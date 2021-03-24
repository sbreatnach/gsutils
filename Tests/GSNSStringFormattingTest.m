//
//  GSNSStringFormattingTest.m
//  gsutils
//
//  Created by Shane Breatnach on 23/08/2011.
//  Copyright (c) 2011-2012 GlicSoft. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "GSNSString+FormattingUtils.h"


@interface GSNSStringFormattingTest : GHTestCase { }
@end

@implementation GSNSStringFormattingTest

- (void)testUnitStringFormatting
{
    double number = 10.0;
    GHAssertEqualStrings([NSString unitStringFromBytes:number flags:GSNSStringBinaryUnits], @"10 B", nil);
    
    number = 1024.0;
    GHAssertEqualStrings([NSString unitStringFromBytes:number flags:GSNSStringBinaryUnits], @"1 kB", nil);
    
    number = 1048576.0;
    GHAssertEqualStrings([NSString unitStringFromBytes:number flags:GSNSStringBinaryUnits], @"1 MB", nil);
    
    number = 1000.0;
    GHAssertEqualStrings([NSString unitStringFromBytes:number flags:GSNSStringDecimalUnits], @"1 kB", nil);
    
    number = 1000000.0;
    GHAssertEqualStrings([NSString unitStringFromBytes:number flags:GSNSStringDecimalUnits], @"1 MB", nil);
}

@end
