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
//  GSPathNode.m
//  gsutils
//
//  Created by Shane Breatnach on 18/11/2011.
//  Copyright (c) 2011-2012 GlicSoft. All rights reserved.
//

#import "GSPathNode.h"

@implementation GSPathNode

@dynamic fitness;
@synthesize goal = _goal;
@synthesize heuristic = _heuristic;
@synthesize primaryConnection = _primaryConnection;
@dynamic connections;
@dynamic neighbors;

- (void)dealloc
{
    [_primaryConnection release];
    [super dealloc];
}

- (NSArray*)connections
{
    return _children;
}

- (NSArray*)neighbors
{
    return _parents;
}

- (NSUInteger)fitness
{
    NSUInteger curFitness = self.goal + self.heuristic;
    if( _primaryConnection == nil )
    {
        curFitness = NSUIntegerMax;
    }
    return curFitness;
}

- (NSComparisonResult)compareNodeFitness:(GSPathNode*)node
{
    return (self.fitness < node.fitness ? NSOrderedAscending :
            (self.fitness > node.fitness ? NSOrderedDescending : NSOrderedSame));
}

- (void)addConnection:(GSPathNode *)node
{
    if( ![_children containsObject:node] )
    {
        [_children addObject:node];
        [node addConnection:self];
    }
}

- (void)removeConnection:(GSPathNode *)node
{
    if( [_children containsObject:node] )
    {
        [_children removeObject:node];
        [node removeConnection:self];
    }
}

- (void)removeAllConnections
{
    if( [self.connections count] == 0 )
    {
        return;
    }
    NSArray *tempConnections = [self.connections copy];
    for( GSPathNode *node in tempConnections )
    {
        [node removeConnection:self];
    }
    [tempConnections release];
}

- (void)addNeighbor:(GSPathNode *)node
{
    if( ![_parents containsObject:node] )
    {
        [_parents addObject:node];
        [node addNeighbor:self];
    }
}

- (void)removeNeighbor:(GSPathNode *)node
{
    if( [_parents containsObject:node] )
    {
        [_parents removeObject:node];
        [node removeNeighbor:self];
    }
}

- (void)removeAllNeighbors
{
    if( [self.neighbors count] == 0 )
    {
        return;
    }
    NSArray *tempNeighbors = [self.neighbors copy];
    for( GSPathNode *node in tempNeighbors )
    {
        [node removeNeighbor:self];
    }
    [tempNeighbors release];
}

- (NSUInteger)goalForPrimaryNode:(GSPathNode *)primaryNode
{
    // default is the parent goal plus the cost of travelling to this node from
    // the parent node i.e. 1
    return primaryNode.goal + 1;
}

- (NSUInteger)heuristicForEndNode:(GSPathNode *)endNode
{
    // default is a uniform heuristic value, so every node is of equal
    // relevance. Sub-classes must implement this message to help the search
    // algorithm.
    return 1;
}

- (BOOL)isBlocked
{
    return [self.connections count] == 0;
}

@end
