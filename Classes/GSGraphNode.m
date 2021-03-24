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
//  GSGraphNode.m
//  gsutils
//
//  Created by Shane Breatnach on 23/03/2011.
//

#import "GSGraphNode.h"


@implementation GSGraphNode

@synthesize parents = _parents;
@synthesize children = _children;
@synthesize object = _object;

+ (id)node
{
    return [[[self alloc] init] autorelease];
}

+ (id)nodeWithObject:(id)object
{
    GSGraphNode *node = [[[self alloc] init] autorelease];
    node.object = object;
    return node;
}

- (id)init
{
    self = [super init];
    if( self != nil )
    {
        _parents = [[NSMutableArray alloc] init];
        _children = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    [_object release];
    [_parents release];
    [_children release];
    [super dealloc];
}

- (void)addParent:(GSGraphNode *)parent
{
    if( ![_parents containsObject:parent] )
    {
        [_parents addObject:parent];
        [parent addChild:self];
    }
}

- (void)removeAllParents
{
    [self removeAllParentsWithCleanup:YES];
}

- (void)removeAllParentsWithCleanup:(BOOL)cleanup
{
    if( cleanup )
    {
        for( GSGraphNode *parent in _parents )
        {
            [parent removeChild:self];
        }
    }
    [_parents removeAllObjects];
}

- (void)removeParent:(GSGraphNode *)parent
{
    if( [_parents containsObject:parent] )
    {
        [_parents removeObject:parent];
        [parent removeChild:self];
    }
}

- (void)addChild:(GSGraphNode *)child
{
    if( ![_children containsObject:child] )
    {
        [_children addObject:child];
        [child addParent:self];
    }
}

- (void)removeAllChildren
{
    [self removeAllChildrenWithCleanup:YES];
}

- (void)removeAllChildrenWithCleanup:(BOOL)cleanup
{
    if( cleanup )
    {
        for( GSGraphNode *child in _children )
        {
            [child removeParent:self];
        }
    }
    [_children removeAllObjects];
}

- (void)removeChild:(GSGraphNode *)child
{
    if( [_children containsObject:child] )
    {
        [_children removeObject:child];
        [child removeParent:self];
    }
}

@end
