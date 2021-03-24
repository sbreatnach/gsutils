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
//  GSJsonWriter.m
//  gsutils
//
//  Created by Shane Breatnach on 30/03/2011.
//

#import "GSJsonWriter.h"
#import "GSConstants.h"
#import "GSJsonSerializable.h"

@interface GSJsonWriter ()

- (id)convertObject: (id)object;

@end

@implementation GSJsonWriter

- (NSData*)dataWithObject:(id)value
{
    id newValue = [self convertObject:value];
    return [super dataWithObject:newValue];
}

- (id)convertObject:(id)object
{
    id newObject = nil;
    if( [object conformsToProtocol:@protocol(GSJsonSerializable)] )
    {
        newObject = [object jsonData];
    }
    else if( [object isKindOfClass:[NSArray class]] )
    {
        // create new array with (possibly) converted values
        newObject = [NSMutableArray arrayWithCapacity:[object count]];
        for( id subObject in object )
        {
            [newObject addObject:[self convertObject:subObject]];
        }
    }
    else if( [object isKindOfClass:[NSDictionary class]] )
    {
        // create new dictionary with (possibly) converted values
        newObject = [NSMutableDictionary dictionaryWithCapacity:[object count]];
        for( id key in [object keyEnumerator] )
        {
            id newKey = [self convertObject:key];
            id newValue = [self convertObject:[object objectForKey:key]];
            [newObject setObject:newValue forKey:newKey];
        }
    }
    else
    {
        // existing, unchanged object is assumed to be controlled via
        // autorelease
        newObject = object;
    }
    return newObject;
}

@end
