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
//  GSPathFindingGraph.m
//  gsutils
//
//  Created by Shane Breatnach on 18/11/2011.
//  Copyright (c) 2011-2012 GlicSoft. All rights reserved.
//

#import "GSPathFindingGraph.h"
#import "GSPathNode.h"
#import "GSLogging.h"

@interface GSPathFindingGraph ()

/**
 * Resets the state of the graph to blank for new run of algorithm.
 */
- (void)reset;
/**
 * Checks the given node to see if it's the best node for going to the primary
 * node supplied. If it is, the goal and heuristic for the node is updated
 * as per algorithm and graph is rebalanced.
 */
- (void)checkNode:(GSPathNode*)node primary:(GSPathNode*)primary;
/**
 * The given updated node is the next node on the list for the algorithm so
 * the goals of all linked nodes must be updated to work with new node goal.
 * Traverses the graph for nodes that are affected by the new goal and modifies
 * the goal for each node accordingly.
 */
- (void)rebalanceGraph:(GSPathNode*)updatedNode;

@end

@implementation GSPathFindingGraph

@dynamic startNode;
@dynamic endNode;
@synthesize path = _path;
@synthesize foundPath = _foundPath;
@synthesize searchFinished = _searchFinished;

- (void)dealloc
{
    [_startNode release];
    [_endNode release];
    [_openNodes release];
    [_closedNodes release];
    [_path release];
    [_traversedNodes release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if( self != nil )
    {
        _openNodes = [[NSMutableArray alloc] init];
        _closedNodes = [[NSMutableArray alloc] init];
        _path = [[NSMutableArray alloc] init];
        _traversedNodes = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (id)graph
{
    return [[[self alloc] init] autorelease];
}

+ (NSArray*)pathFromStartNode:(GSPathNode *)startNode
                    toEndNode:(GSPathNode *)endNode
{
    GSPathFindingGraph *graph = [GSPathFindingGraph graph];
    return [graph pathFromStartNode:startNode toEndNode:endNode];
}

- (NSArray*)pathFromStartNode:(GSPathNode*)startNode
                    toEndNode:(GSPathNode*)endNode
{
    self.startNode = startNode;
    self.endNode = endNode;
    while( !self.searchFinished )
    {
        [self updateOpenNodes];
    }
    NSArray *path = nil;
    if( self.foundPath )
    {
        path = self.path;
    }
    return path;
}

- (GSPathNode*)endNode
{
    return _endNode;
}

- (void)setEndNode:(GSPathNode *)endNode
{
    if( endNode != _endNode )
    {
        [_endNode release];
        _endNode = [endNode retain];
        [self reset];
    }
}

- (GSPathNode*)startNode
{
    return _startNode;
}

- (void)setStartNode:(GSPathNode *)startNode
{
    if( startNode != _startNode )
    {
        [_startNode release];
        _startNode = [startNode retain];
        [self reset];
    }
}

- (void)updateOpenNodes
{
    if( _foundPath || [_openNodes count] == 0 )
    {
        _searchFinished = YES;
        return;
    }
    GSPathNode *bestNode = [_openNodes objectAtIndex:0];
    [_openNodes removeObjectAtIndex:0];
    [_closedNodes addObject:bestNode];
    _foundPath = [bestNode isEqual:_endNode];
    if( _foundPath )
    {
        [self allocatePathWithEndNode:bestNode];
    }
    else
    {
        // update the open and closed node list by checking all connections
        // of the current best node
        for( GSPathNode *nextNode in bestNode.connections )
        {
            [self checkNode:nextNode primary:bestNode];
        }
        // sort the open list by node fitness so that the
        // best node is first in the list for next run through
        [_openNodes sortUsingSelector:@selector(compareNodeFitness:)];
    }
}

- (void)allocatePathWithEndNode:(GSPathNode *)node
{
    [_path removeAllObjects];
    GSPathNode *curNode = node;
    while( ![curNode isEqual:_startNode] )
    {
        [_path addObject:curNode];
        curNode = curNode.primaryConnection;
    }
    [_path addObject:curNode];
}

- (void)checkNode:(GSPathNode *)node primary:(GSPathNode *)primary
{
    NSUInteger curGoal = [node goalForPrimaryNode:primary];
    NSUInteger curHeuristic = [node heuristicForEndNode:_endNode];
    if( [_closedNodes containsObject:node] )
    {
        if( (curGoal+curHeuristic) < node.fitness )
        {
            node.goal = curGoal;
            node.heuristic = curHeuristic;
            node.primaryConnection = primary;
            [self rebalanceGraph:node];
        }
    }
    else
    {
        if( (curGoal+curHeuristic) < node.fitness )
        {
            node.goal = curGoal;
            node.heuristic = curHeuristic;
            node.primaryConnection = primary;
        }
        if( ![_openNodes containsObject:node] )
        {
            [_openNodes addObject:node];
        }
    }
}

- (void)rebalanceGraph:(GSPathNode *)updatedNode
{
    [_traversedNodes removeAllObjects];
    [_traversedNodes addObjectsFromArray:_openNodes];
    [_traversedNodes addObjectsFromArray:_closedNodes];
    for( GSPathNode *curNode in _traversedNodes )
    {
        for( GSPathNode *connection in curNode.connections )
        {
            NSUInteger curGoal = [connection goalForPrimaryNode:curNode];
            if( curGoal < connection.goal )
            {
                connection.goal = curGoal;
                connection.primaryConnection = curNode;
            }
        }
    }
}

- (void)reset
{
    _searchFinished = NO;
    _foundPath = NO;
    for( GSPathNode *node in _openNodes )
    {
        node.primaryConnection = nil;
    }
    for( GSPathNode *node in _closedNodes )
    {
        node.primaryConnection = nil;
    }
    [_openNodes removeAllObjects];
    [_path removeAllObjects];
    [_closedNodes removeAllObjects];
    if( _startNode != nil )
    {
        _startNode.heuristic = [_startNode heuristicForEndNode:_endNode];
        _startNode.goal = 0;
        [_openNodes addObject:_startNode];
    }
}

@end
