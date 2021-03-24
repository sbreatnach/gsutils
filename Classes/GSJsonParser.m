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
//  GSJsonParser.m
//  gsutils
//
//  Created by Shane Breatnach on 30/03/2011.
//

#import "GSJsonParser.h"
#import "GSConstants.h"
#import "GSJsonSerializable.h"

@interface GSJsonParser ()

/**
 Recursively converts the given parsed JSON data object, inserting where
 possible the GSJsonSerializable objects.
 */
- (id)convertObject: (id)object;

@end

@implementation GSJsonParser


- (id)objectWithData:(NSData *)data
{
    id object = [super objectWithData:data];
    id newObject = [self convertObject:object];
    return newObject;
}

- (id)convertObject:(id)object
{
    id newObject = nil;
    if( [object isKindOfClass:[NSDictionary class]] )
    {
        // depth-first parsing of all dictionaries, so that the values
        // of the dictionary holds any possible component classes.
        NSMutableDictionary *dictionary = [[NSMutableDictionary alloc] init];
        for( NSString *key in [object keyEnumerator] )
        {
            [dictionary setObject:[self convertObject:[object objectForKey:key]]
                           forKey:key];
        }
        // does this dict represent a class?
        id className = [dictionary objectForKey:GS_DK_Class];
        if( className != nil && [className isKindOfClass:[NSString class]] )
        {
            // assumed to be an object that implements GSJsonSerializable AND
            // is registered with the Objective-C runtime when this message
            // is invoked.
            newObject = [[[NSClassFromString(className) alloc] init]
                         autorelease];
            [newObject loadJsonData:dictionary];
            [dictionary release];
        }
        else
        {
            newObject = [dictionary autorelease];
        }
    }
    else if( [object isKindOfClass:[NSArray class]] )
    {
        // create new array with (possibly) converted values
        newObject = [NSMutableArray array];
        for( id subObject in object )
        {
            [newObject addObject:[self convertObject:subObject]];
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
