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
//  GSUIColor+Utilities.m
//  gsutils
//
//  Created by Shane Breatnach on 17/06/2011.
//

#import "GSUIColor+Utilities.h"


@implementation UIColor (GSColorUtilities)

@dynamic rgbaValues;
- (NSArray*)rgbaValues
{
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:4];
    const CGFloat *components = CGColorGetComponents([self CGColor]);
    [values addObject:[NSNumber numberWithFloat:components[0]]];
    [values addObject:[NSNumber numberWithFloat:components[1]]];
    [values addObject:[NSNumber numberWithFloat:components[2]]];
    [values addObject:[NSNumber numberWithFloat:components[3]]];
    return values;
}

+ (UIColor*)colorWithRGBA:(NSArray *)rgbaValues
{
    return [UIColor colorWithRed:[[rgbaValues objectAtIndex:0] floatValue]
                           green:[[rgbaValues objectAtIndex:1] floatValue]
                            blue:[[rgbaValues objectAtIndex:2] floatValue]
                           alpha:[[rgbaValues objectAtIndex:3] floatValue]];
}

+ (UIColor*)colorWithByteRed:(NSUInteger)red
                       green:(NSUInteger)green
                        blue:(NSUInteger)blue
                       alpha:(CGFloat)alpha
{
    return [UIColor colorWithRed:((CGFloat)red)/255.0
                           green:((CGFloat)green)/255.0
                            blue:((CGFloat)red)/255.0
                           alpha:alpha];
}

@end
