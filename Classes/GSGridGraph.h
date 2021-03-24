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
//  GSGridGraph.h
//  gsutils
//
//  Created by Shane Breatnach on 25/11/2011.
//  Copyright (c) 2011-2012 GlicSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSPathFindingGraph.h"

/**
 * Enumeration of directions defined for the nodes of the grid. These are the
 * bitmask values set as part of the -initWithFile: constructor.
 */
enum {
    GSGridNode_TopLeft = 1 << 0,
    GSGridNode_Top = 1 << 1,
    GSGridNode_TopRight = 1 << 2,
    GSGridNode_Left = 1 << 3,
    GSGridNode_Right = 1 << 4,
    GSGridNode_BottomLeft = 1 << 5,
    GSGridNode_Bottom = 1 << 6,
    GSGridNode_BottomRight = 1 << 7,
} GSGridNodeMask;

@class GSFile;
@class GSGridPathNode;

/**
 * Specialisation of the path finding graph that is built for fixed-size grids
 * of nodes. Each node has 8 directions: top-left, top, top-right, left,
 * right, bottom-left, bottom, bottom-right
 */
@interface GSGridGraph : GSPathFindingGraph
{
    NSMutableArray *_nodes;
    NSMutableArray *_linePath;
    CGSize _totalSize;
    CGSize _nodeSize;
}

/**
 * The list of grid path nodes generated from the graph source.
 */
@property (nonatomic, retain) NSArray *nodes;
@property (nonatomic, assign, readonly) NSUInteger rowLength;

+ (id)graphWithFile:(GSFile*)file;
/**
 * Initialises a pre-generated grid graph with all node data in the given
 * file. File must consist of rows of bytes (8-bit chars) that represent nodes.
 * Each byte is a bitmask that specifies 8 directions from the node.
 *
 * For the purposes of other messages to the class, every node is considered
 * to have a width and height of 1.
 */
- (id)initWithFile:(GSFile*)file;

+ (id)graphWithTotalSize:(CGSize)aSize nodeSize:(CGSize)subSize;
/**
 * Initialises a blank grid graph which consists of the total width and height
 * supplied, made up of sub rectangles with the given width and height.
 *
 * If the subSize does not fit exactly within the bounds of aSize, the number of
 * nodes per row and the number of rows will be rounded up.
 */
- (id)initWithTotalSize:(CGSize)totalSize nodeSize:(CGSize)nodeSize;

/**
 * Caclulates and returns the array of NSValue (containing CGPoint) that make
 * up the line path from the given start and end points.
 */
- (NSArray*)linePathFromStartPoint:(CGPoint)startPoint
                        toEndPoint:(CGPoint)endPoint;

/**
 * Updates the set of nodes with the obstacle located at the given rect. Sets
 * any nodes that intersect as impassable and updates all neighbouring nodes
 * accordingly.
 */
- (void)addObstacleAtRect:(CGRect)aRect;
/**
 * Updates the set of nodes removing the obstacle located at the given rect.
 * Sets any nodes that intersect as passable and updates all neighbouring nodes
 * accordingly.
 */
- (void)removeObstacleAtRect:(CGRect)aRect;
/**
 * Removes all obstacles on the grid. Returns the grid to a blank slate.
 */
- (void)clearObstacles;

- (GSGridPathNode*)nodeAtPoint:(CGPoint)aPoint;
- (GSGridPathNode*)nodeAtRect:(CGRect)aRect;

@end
