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
//  GSPathNode.h
//  gsutils
//
//  Created by Shane Breatnach on 18/11/2011.
//  Copyright (c) 2011-2012 GlicSoft. All rights reserved.
//

#import "GSGraphNode.h"

/**
 * Represents a node of a graph that can be searched for particular paths.
 * Supports A* path finding.
 *
 * Each node has a set of connections. Each connection is cyclic - if node A is
 * connected to node B, node B is also connected to node A.
 * In addition, to help determine the final path, each node has a primary
 * connection. This is the connection that has been calculated to be the
 * most optimal route for the final path.
 *
 * Optionally, neighbours may be specified for the nodes. Neighbour links can
 * be used to re-establish connections easily and other potential optimisations,
 * at the expense of increasing memory storage.
 */
@interface GSPathNode : GSGraphNode
{
    NSUInteger _goal;
    NSUInteger _heuristic;
    GSPathNode *_primaryConnection;
}

@property (nonatomic, assign, readonly) NSUInteger fitness;
@property (nonatomic, assign) NSUInteger goal;
@property (nonatomic, assign) NSUInteger heuristic;
@property (nonatomic, retain) GSPathNode *primaryConnection;
@property (nonatomic, retain, readonly) NSArray *connections;
@property (nonatomic, retain, readonly) NSArray *neighbors;

/**
 * Adds the given node as a neighbour of this node.
 */
- (void)addNeighbor:(GSPathNode*)node;
- (void)removeNeighbor:(GSPathNode*)node;
- (void)removeAllNeighbors;

/**
 * Adds the given node as a connection of this node.
 */
- (void)addConnection:(GSPathNode*)node;
- (void)removeConnection:(GSPathNode*)node;
- (void)removeAllConnections;

- (NSUInteger)goalForPrimaryNode:(GSPathNode*)primaryNode;
- (NSUInteger)heuristicForEndNode:(GSPathNode*)endNode;
- (NSComparisonResult)compareNodeFitness:(GSPathNode*)node;

- (BOOL)isBlocked;

@end
