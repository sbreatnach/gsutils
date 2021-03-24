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
//  GSNSString+FormattingUtils.m
//  gsutils
//
//  Created by Shane Breatnach on 11/08/2011.
//  Copyright (c) 2011-2012 GlicSoft. All rights reserved.
//

#import "GSNSString+FormattingUtils.h"


@implementation NSString (GSFormattingUtils)

// Taken from http://stackoverflow.com/questions/572614/objc-cocoa-class-for-converting-size-to-human-readable-string
// and modified to be slightly less clever
+ (NSString*)unitStringFromBytes:(double)bytes flags:(uint8_t)flags
{
    static const char units[] = { '\0', 'k', 'M', 'G', 'T', 'P', 'E', 'Z', 'Y' };
    static int maxUnits = sizeof units - 1;
    
    int multiplier = (flags & GSNSStringDecimalUnits) ? 1000 : 1024;
    int exponent = 0;
    
    while (bytes >= multiplier && exponent < maxUnits)
    {
        bytes /= multiplier;
        exponent++;
    }
    NSNumberFormatter* formatter = [[NSNumberFormatter alloc] init];
    [formatter setMaximumFractionDigits:2];
    if (flags & GSNSStringLocalizedFormat)
    {
        [formatter setNumberStyle: NSNumberFormatterDecimalStyle];
    }
    // Beware of reusing this format string. -[NSString stringWithFormat]
    // ignores \0, *printf does not.
    NSString *formattedValue = [NSString stringWithFormat:@"%@ %cB",
                                [formatter stringFromNumber:
                                 [NSNumber numberWithDouble: bytes]],
                                units[exponent]];
    [formatter release];
    return formattedValue;
}

+ (NSString*)randomString
{
    NSUInteger length = (8 + (arc4random()%8));
    return [self randomStringOfLength:length];
}

+ (NSString*)randomStringOfLength:(NSUInteger)length
{
    return [self randomStringOfLength:length
                           characters:@"abcdefghijklmnopqrstuvwxyz"];
}

+ (NSString*)randomStringOfLength:(NSUInteger)length
                       characters:(NSString *)characters
{
    NSMutableString *randomString = [NSMutableString stringWithCapacity:length];
    for( NSUInteger index = 0; index < length; index ++ )
    {
        [randomString appendString:
         [characters substringWithRange:
          [characters rangeOfComposedCharacterSequenceAtIndex:
           arc4random()%[characters length]]]];
    }
    return randomString;
}

@end
