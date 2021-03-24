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
//  gsfunctions.c
//  gsutils
//
//  Created by Shane Breatnach on 05/11/2011.
//  Copyright (c) 2011-2012 GlicSoft. All rights reserved.
//

#import "GSFunctions.h"

NSString* GSUniqueAppIdentifier()
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *appIdentifier = [defaults stringForKey:@"gs_unique_app_id"];
    if( appIdentifier == nil )
    {
        CFUUIDRef appIdRef = CFUUIDCreate(NULL);
        CFStringRef appIdStringRef = CFUUIDCreateString(NULL, appIdRef);
        appIdentifier = [NSString stringWithString:(NSString*)appIdStringRef];
        CFRelease(appIdRef);
        CFRelease(appIdStringRef);
        [defaults setObject:appIdentifier forKey:@"gs_unique_app_id"];
    }
    return appIdentifier;
}

float fbound( float value, float lower, float upper )
{
    if( value < lower )
    {
        value = lower;
    }
    else if( value > upper )
    {
        value = upper;
    }
    return value;
}

CGColorRef CGColorCreateWithARGB( CGColorSpaceRef colorspace,
                                  NSUInteger argb )
{
    // extract separate CGFloat values from argb integer
    CGFloat a = ((float)((argb >> 24) & 0xff))/0xff;
    CGFloat r = ((float)((argb >> 16) & 0xff))/0xff;
    CGFloat g = ((float)((argb >> 8) & 0xff))/0xff;
    CGFloat b = ((float)(argb & 0xff))/0xff;
    // create CGColor as standard
    CGFloat components[] = {r, g, b, a};
    CGColorRef color = CGColorCreate(colorspace, components);
    return color;
}

void CGRectMakeWithArrayRepresentation( NSArray* array,
                                        CGRect* rect )
{
    if( [array count] > 3 )
    {
        (*rect).origin.x = [[array objectAtIndex:0] floatValue];
        (*rect).origin.y = [[array objectAtIndex:1] floatValue];
        (*rect).size.width = [[array objectAtIndex:2] floatValue];
        (*rect).size.height = [[array objectAtIndex:3] floatValue];
    }
}

NSValue* CGRectValueMakeWithArrayRepresentation( NSArray* array )
{
    CGRect rect;
    CGRectMakeWithArrayRepresentation(array, &rect);
    return [NSValue valueWithCGRect:rect];
}
