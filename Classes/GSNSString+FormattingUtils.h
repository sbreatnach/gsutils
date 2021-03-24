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
//  GSNSString+FormattingUtils.h
//  gsutils
//
//  Created by Shane Breatnach on 11/08/2011.
//  Copyright (c) 2011-2012 GlicSoft. All rights reserved.
//

#import <Foundation/Foundation.h>


enum GSNSStringUnitFlags {
    GSNSStringBinaryUnits     = 1 << 0,
    GSNSStringDecimalUnits    = 1 << 1,
    GSNSStringLocalizedFormat = 1 << 2
};

@interface NSString (GSFormattingUtils)

/**
 * Converts the given byte value into a formatted human-readable version of
 * the byte value. For example 1024 -> 1kB, etc. flags is a bitmask that can
 * specify the following:
 * GSNSStringBinaryUnits - round down the value to the nearest power of two
 * GSNSStringDecimalUnits - round down the value to the nearest power of 10.
 * Note that this is required by Apple's HIG.
 * GSNSStringLocalizedFormat - use the default locale to format the rounded
 * value i.e. use decimal point or comma where necessary.
 */
+ (NSString*)unitStringFromBytes:(double)bytes flags:(uint8_t)flags;

/**
 * Returns a random string of random length (8-16 characters) composed of ASCII
 * characters a -> z.
 */
+ (NSString*)randomString;
/**
 * Returns a random string of the specified length composed of ASCII characters
 * a -> z.
 */
+ (NSString*)randomStringOfLength:(NSUInteger)length;
/**
 * Returns a random string of the specified length composed of characters from
 * the given characters. Characters assumed to be ASCII.
 */
+ (NSString*)randomStringOfLength:(NSUInteger)length
                       characters:(NSString*)characters;

@end
