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
//  GSPathFindingGraph.h
//  gsutils
//
//  Created by Shane Breatnach on 18/11/2011.
//  Copyright (c) 2011-2012 GlicSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GSPathNode;

/**
 * Defines a graph that can search a set of graph nodes for the (nearly) optimal
 * path.
 */
@interface GSPathFindingGraph : NSObject
{
    NSMutableArray *_traversedNodes;
    NSMutableArray *_openNodes;
    NSMutableArray *_closedNodes;
    GSPathNode *_startNode;
    GSPathNode *_endNode;
    NSMutableArray *_path;
    BOOL _foundPath;
    BOOL _searchFinished;
}

@property (nonatomic, assign, readonly) BOOL foundPath;
@property (nonatomic, assign, readonly) BOOL searchFinished;
@property (nonatomic, retain) GSPathNode *startNode;
@property (nonatomic, retain) GSPathNode *endNode;
/**
 * The full path to the end node, ordered by end node first, start node last.
 * Empty if path not found yet.
 */
@property (nonatomic, retain, readonly) NSArray *path;

/**
 * Blocking call that fully calculates the optimal path from the set start node
 * to the set end node. Returns path with end node first and start node last.
 * If no path is found, nil is returned. Generates temporary graph for
 * calculation.
 */
+ (NSArray*)pathFromStartNode:(GSPathNode*)startNode
                    toEndNode:(GSPathNode*)endNode;
/**
 * Blocking call that fully calculates the optimal path from the set start node
 * to the set end node. Returns path with end node first and start node last.
 * If no path is found, nil is returned. Returns weak reference to path that
 * is re-used when graph path is re-calculated.
 */
- (NSArray*)pathFromStartNode:(GSPathNode*)startNode
                    toEndNode:(GSPathNode*)endNode;

+ (id)graph;

- (void)updateOpenNodes;
- (void)allocatePathWithEndNode:(GSPathNode*)node;

@end
