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
//  GSGraphNode.h
//  gsutils
//
//  Created by Shane Breatnach on 23/03/2011.
//

#import <Foundation/Foundation.h>


/**
 Represents the node of a directed graph. May have multiple parent or
 child nodes. Every node may have an object that it contains.
 
 Every link between each node is two-way i.e. a parent node has a link with
 the child and the child has a link to the parent.
 */
@interface GSGraphNode : NSObject
{
    NSMutableArray *_parents;
    NSMutableArray *_children;
    id _object;
}

/**
 The current parent nodes for this node.
 */
@property (nonatomic, retain, readonly) NSArray *parents;
/**
 The current child nodes for this node.
 */
@property (nonatomic, retain, readonly) NSArray *children;
/**
 The containing object for the node.
 */
@property (nonatomic, retain) id object;

/**
 Creates an instance of a node with no containing object set.
 */
+ (id)node;
/**
 Creates a node with the given object contained within.
 */
+ (id)nodeWithObject: (id)object;
/**
 Adds the given node as a parent of this node. Adds this node as a child of the
 given node.
 */
- (void)addParent: (GSGraphNode*)parent;
/**
 Removes all parents for this node. Removes the child links for this node
 in all parents.
 */
- (void)removeAllParents;
/**
 Removes all parents for this node. If cleanup is YES, the child links for this
 node are removed in all parents also.
 */
- (void)removeAllParentsWithCleanup:(BOOL)cleanup;
/**
 Removes the node as a parent of this node. Removes the child link for this node
 in the given node.
 */
- (void)removeParent: (GSGraphNode*)parent;
/**
 Adds the given node as a child for this node. Adds this node as a parent for
 the given node.
 */
- (void)addChild: (GSGraphNode*)child;
/**
 Removes all child nodes for this node. Removes the parent link for the child
 nodes.
 */
- (void)removeAllChildren;
/**
 Removes all child nodes for this node. If cleanup is YES, removes the parent
 link for all child nodes also.
 */
- (void)removeAllChildrenWithCleanup:(BOOL)cleanup;
/**
 Removes the given node as a child. Removes the parent link for this node in
 the given node.
 */
- (void)removeChild: (GSGraphNode*)child;

@end
