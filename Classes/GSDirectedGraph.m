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
//  GSDirectedGraph.m
//  gsutils
//
//  Created by Shane Breatnach on 23/03/2011.
//

#import "GSDirectedGraph.h"
#import "GSGraphNode.h"

@interface GSDirectedGraph ()

/**
 Recursively adds the children of the given node to the array supplied.
 */
- (void)addNode: (GSGraphNode*)node children: (NSMutableArray*)children;
/**
 Recursively searches the node graph for the node that contains the given
 object.
 */
- (GSGraphNode*)traverseNodes: (NSArray*)nodes forObject: (id)object;
/**
 Recursively deletes the parent node from a given node's parent list. If
 the node has no more parents, it too is removed. If a node has at least
 one parent remaining, the traversal stops for that branch.
 */
- (void)deleteParent: (GSGraphNode*)parent ofNode: (GSGraphNode*)node;

@end

@implementation GSDirectedGraph

- (void)dealloc
{
    [_flatNodes release];
    [_rootNodes release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if( self != nil )
    {
        _flatNodes = [[NSMutableArray alloc] init];
        _rootNodes = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (id)graph
{
    return [[[self alloc] init] autorelease];
}

- (GSGraphNode*)addRootNode:(GSGraphNode *)node
{
    GSGraphNode *addedNode = nil;
    if( node != nil && [node.parents count] == 0 &&
        ![_rootNodes containsObject:node] )
    {
        [_rootNodes addObject:node];
        addedNode = node;
    }
    return addedNode;
}

- (GSGraphNode*)addRoot:(id)object
{
    if( object == nil )
    {
        return nil;
    }
    GSGraphNode *parentNode = [GSGraphNode nodeWithObject:object];
    if( parentNode != nil )
    {
        [_rootNodes addObject:parentNode];
    }
    return parentNode;
}

- (GSGraphNode*)nodeForObject:(id)object
{
    GSGraphNode *foundNode = nil;
    if( object != nil )
    {
        foundNode = [self traverseNodes:_rootNodes forObject:object];
    }
    return foundNode;
}

- (void)removeNode:(GSGraphNode *)node
{
    if( node == nil )
    {
        return;
    }
    // remove this node if it's stored as a root node
    NSUInteger rootIndex = [_rootNodes indexOfObject:node];
    if( rootIndex != NSNotFound )
    {
        [_rootNodes removeObjectAtIndex:rootIndex];
    }
    // take a copy of the nodes as -remove*: messages directly affect nodes'
    // children and parents arrays.
    NSArray *parentNodes = [node.parents copy];
    NSArray *childNodes = [node.children copy];
    
    // remove this node as parent for it's children - join children of node
    // with parents of node
    for( GSGraphNode *childNode in childNodes )
    {
        [childNode removeParent:node];
        for( GSGraphNode *parentNode in parentNodes )
        {
            [childNode addParent:parentNode];
        }
        if( [childNode.parents count] == 0 && rootIndex != NSNotFound )
        {
            // if deleting a root node and child only has one parent, want to
            // place these child nodes into the slot the root node occupied.
            [_rootNodes insertObject:childNode atIndex:rootIndex];
            rootIndex ++;
        }
    }
    // remove this node as child for it's parents - join parents of node
    // with children of node
    for( GSGraphNode *parentNode in parentNodes )
    {
        [parentNode removeChild:node];
        for( GSGraphNode *childNode in childNodes )
        {
            [parentNode addChild:childNode];
        }
    }
    [node removeAllChildren];
    [node removeAllParents];
    
    [parentNodes release];
    [childNodes release];
    // remove from flat node representation
    [_flatNodes removeObject:node];
}

- (void)removeBranchOfNode:(GSGraphNode *)node
{
    if( node == nil )
    {
        return;
    }
    // remove this node if it's stored as a root node
    NSUInteger rootIndex = [_rootNodes indexOfObject:node];
    if( rootIndex != NSNotFound )
    {
        [_rootNodes removeObjectAtIndex:rootIndex];
    }
    // delink node from possible parents and remove any children that have
    // it as a lone parent
    [node removeAllParents];
    for( GSGraphNode *curNode in node.children )
    {
        [self deleteParent:node ofNode:curNode];
    }
}

- (void)clear
{
    [self flat];
    for( GSGraphNode *curNode in _flatNodes )
    {
        [curNode removeAllParentsWithCleanup:NO];
        [curNode removeAllChildrenWithCleanup:NO];
    }
    [_flatNodes removeAllObjects];
    [_rootNodes removeAllObjects];
}

- (NSArray*)flat
{
    [_flatNodes removeAllObjects];
    for( GSGraphNode *parent in _rootNodes )
    {
        [_flatNodes addObject:parent];
        [self addNode:parent children:_flatNodes];
    }
    return _flatNodes;
}

- (NSUInteger)count
{
    return [[self flat] count];
}


// MARK Recursive Graph Traversals

- (void)addNode:(GSGraphNode *)node children:(NSMutableArray *)children
{
    [children addObjectsFromArray:node.children];
    for( GSGraphNode *child in node.children )
    {
        // check that the child hasn't already been added, as there may be
        // cycles in the graph.
        if( ![children containsObject:child] )
        {
            [self addNode:child children:children];
        }
    }
}

- (void)deleteParent: (GSGraphNode*)parent ofNode: (GSGraphNode*)node
{
    [node removeParent:parent];
    if( [node.parents count] == 0 )
    {
        for( GSGraphNode *curNode in node.children )
        {
            [self deleteParent:node ofNode:curNode];
        }
        [node removeAllChildren];
    }
}

- (GSGraphNode*)traverseNodes:(NSArray *)nodes forObject:(id)object
{
    GSGraphNode *foundNode = nil;
    for( GSGraphNode *curNode in nodes )
    {
        if( [curNode.object isEqual:object] )
        {
            foundNode = curNode;
        }
        else
        {
            foundNode = [self traverseNodes:curNode.children forObject:object];
        }
        if( foundNode != nil )
        {
            break;
        }
    }
    return foundNode;
}

@end
