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
//  GSDirectedGraph.h
//  gsutils
//
//  Created by Shane Breatnach on 23/03/2011.
//

#import <Foundation/Foundation.h>


@class GSGraphNode;

/**
 Defines an interface for creating, modifying and traversing a directed
 graph ( http://en.wikipedia.org/wiki/Directed_graph ).
 
 Every edge is transitive e.g. if node C is a child of node B, and node B is
 a child of node A, node C is considered a child of node A. Hence, if node B
 is deleted, the graph is automatically balanced so that node C will remain
 being a child of node A.
 
 Each node of the graph may have multiple parent nodes and multiple
 child nodes. Cycles are allowed.
 */
@interface GSDirectedGraph : NSObject
{
    NSMutableArray *_rootNodes;
    NSMutableArray *_flatNodes;
}

/**
 Returns an empty graph.
 */
+ (id)graph;
/**
 Adds the supplied node as a root of the graph, if the node is a valid root node
 i.e. contains no parent nodes. Returns the node added. nil may be returned if
 the node supplied is nil or has a parent.
 */
- (GSGraphNode*)addRootNode: (GSGraphNode*)node;
/**
 Creates and adds a node, storing the given object, as a root of the graph.
 Returns the node added. nil may be returned if nil was supplied for the object
 or a parent node wasn't added.
 */
- (GSGraphNode*)addRoot: (id)object;
/**
 Traverses and returns the node for the given object. nil is returned if the
 given object is nil or the object is not found.
 */
- (GSGraphNode*)nodeForObject: (id)object;
/**
 Removes the given node from the graph. Traverses the graph and removes the node
 from the graph, updating parent and child links. Balances the graph so
 transitive property of graph applies.
 */
- (void)removeNode: (GSGraphNode*)node;
/**
 Removes the given node from the graph and it's branch of children. A child
 node is removed only if, after removing the parent node, there are no more
 parent nodes left for the child.
 */
- (void)removeBranchOfNode: (GSGraphNode*)node;
/**
 Clears the graph of all nodes. Traverses the graph using the root nodes and
 deletes all nodes.
 */
- (void)clear;
/**
 Returns the flat representation of the root nodes and their children.
 The nodes are traversed and inserted into the resulting array in depth-first
 fashion. Any nodes that are in a cycle are added once only.
 */
- (NSArray*)flat;
/**
 Returns the total number of nodes in the graph.
 */
- (NSUInteger)count;

@end
