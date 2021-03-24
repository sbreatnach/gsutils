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
//  GSMultiValueDictionary.m
//  gsutils
//
//  Created by Shane Breatnach on 02/02/2011.
//

#import "GSMultiValueDictionary.h"
#import "GSLogging.h"


@implementation GSMultiValueDictionary

- (void)dealloc
{
    [keys release];
    [values release];
    [super dealloc];
}

- (id)init
{
    return [self initWithCapacity: 10];
}

- (id)initWithCapacity: (NSUInteger)numItems
{
    self = [super init];
    if( self != nil )
    {
        keys = [[NSMutableArray alloc] initWithCapacity: numItems];
        values = [[NSMutableArray alloc] initWithCapacity: numItems];
    }
    return self;
}

- (void)setObject: (id)object forKey: (id)key;
{
    NSUInteger index = [keys indexOfObject: key];
    NSMutableArray *objects = nil;
    if( index != NSNotFound )
    {
        if( index >= [values count] )
        {
            DLog(@"Missing corresponding 'values' entry for key %@", key);
            [NSException raise: @"IndexOutOfBounds"
                        format: @"Missing corresponding 'values' entry!"];
        }
        objects = (NSMutableArray*) [values objectAtIndex: index];
        [objects replaceObjectAtIndex: 0 withObject: object];
    }
    else
    {
        objects = [[NSMutableArray alloc] initWithCapacity: 4];
        if( objects != nil )
        {
            [objects addObject: object];
            [keys addObject: key];
            [values addObject: objects];
        }
        [objects release];
    }
}

- (void)addObjects:(NSArray *)objects forKey:(id)key
{
    for( id object in objects )
    {
        [self addObject:object forKey:key];
    }
}

- (void)addObject: (id)object forKey: (id)key;
{
    NSUInteger index = [keys indexOfObject: key];
    NSMutableArray *objects = nil;
    if( index != NSNotFound )
    {
        if( index >= [values count] )
        {
            DLog(@"Missing corresponding 'values' entry for key %@", key);
            [NSException raise: @"IndexOutOfBounds"
                        format: @"Missing corresponding 'values' entry!"];
        }
        objects = (NSMutableArray*) [values objectAtIndex: index];
        [objects insertObject: object atIndex: 0];
    }
    else
    {
        objects = [[NSMutableArray alloc] initWithCapacity: 4];
        if( objects != nil )
        {
            [objects addObject: object];
            [keys addObject: key];
            [values addObject: objects];
        }
        [objects release];
    }
}

- (void)removeObjectForKey: (id)key;
{
    NSUInteger index = [keys indexOfObject: key];
    NSMutableArray *objects = nil;
    if( index != NSNotFound )
    {
        if( index >= [values count] )
        {
            DLog(@"Missing corresponding 'values' entry for key %@", key);
            [NSException raise: @"IndexOutOfBounds"
                        format: @"Missing corresponding 'values' entry!"];
        }
        objects = (NSMutableArray*) [values objectAtIndex: index];
    }
    [objects removeObjectAtIndex: 0];
}

- (NSUInteger)count
{
    return [keys count];
}

- (NSEnumerator *)keyEnumerator
{
    return [keys objectEnumerator];
}

- (id)objectForKey: (id)aKey
{
    NSArray *objects = [self arrayForKey: aKey];
    return [objects objectAtIndex: 0];
}

- (NSArray*)arrayForKey: (id)key
{
    NSUInteger index = [keys indexOfObject: key];
    NSMutableArray *objects = nil;
    if( index != NSNotFound )
    {
        if( index >= [values count] )
        {
            DLog(@"Missing corresponding 'values' entry for key %@", key);
            [NSException raise: @"IndexOutOfBounds"
                        format: @"Missing corresponding 'values' entry!"];
        }
        objects = (NSMutableArray*) [values objectAtIndex: index];
    }
    return objects;
}

@end
