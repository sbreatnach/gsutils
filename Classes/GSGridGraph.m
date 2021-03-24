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
//  GSGridGraph.m
//  gsutils
//
//  Created by Shane Breatnach on 25/11/2011.
//  Copyright (c) 2011-2012 GlicSoft. All rights reserved.
//

#import "GSGridGraph.h"
#import "GSFile.h"
#import "GSFileReader.h"
#import "GSGridPathNode.h"
#import "GSLogging.h"

@interface GSGridGraph ()

- (NSArray*)nodesAtRect:(CGRect)aRect;

@end

@implementation GSGridGraph

@dynamic rowLength;
@synthesize nodes = _nodes;

- (void)dealloc
{
    [_linePath release];
    [_nodes release];
    [super dealloc];
}

// designated initaliser for graph
- (id)init
{
    self = [super init];
    if( self != nil )
    {
        _nodes = [[NSMutableArray alloc] init];
        _linePath = [[NSMutableArray alloc] init];
    }
    return self;
}

- (id)initWithFile:(GSFile *)file
{
    self = [self init];
    if( self != nil )
    {
        // file defines a grid with nodes connected in up to 8 directions
        GSFileReader *reader = [GSFileReader readerWithPath:file.path];
        reader.encoding = NSASCIIStringEncoding;
        NSUInteger rowIndex = 0;
        NSUInteger rowLength = 0;
        while( !reader.eof )
        {
            // each line is a line of the grid. every line must be the same
            // length
            NSString *line = [reader readLine];
            rowLength = [line length];
            for( NSUInteger i = 0; i < rowLength; i ++ )
            {
                // each char represents a node in the line
                unsigned char c = [line characterAtIndex:i];
                GSGridPathNode *node = [GSGridPathNode nodeWithXPos:rowIndex
                                                               yPos:i];
                
                // make connections with other nodes as defined by map file.
                // since every connection is 2-way, no need to make bottom
                // or right connections, since it will be defined by top and
                // left connections of future nodes.
                // NB: no verification that each node definition matches
                // connections with other node definitions
                BOOL lastInRow = (i == (rowLength-1));
                BOOL firstInRow = (i == 0);
                NSUInteger prevNodeRowIndex = [_nodes count]-i-rowLength;
                if( rowIndex > 0 )
                {
                    if( !firstInRow && (c & GSGridNode_TopLeft) != 0 )
                    {
                        [node addConnection:[_nodes objectAtIndex:
                                             prevNodeRowIndex+i-1]];
                        [node addNeighbor:[_nodes objectAtIndex:
                                           prevNodeRowIndex+i-1]];
                    }
                    if( (c & GSGridNode_Top) != 0 )
                    {
                        [node addConnection:[_nodes objectAtIndex:
                                             prevNodeRowIndex+i]];
                        [node addNeighbor:[_nodes objectAtIndex:
                                           prevNodeRowIndex+i]];
                    }
                    if( !lastInRow && (c & GSGridNode_TopRight) != 0 )
                    {
                        [node addConnection:[_nodes objectAtIndex:
                                             prevNodeRowIndex+i+1]];
                        [node addNeighbor:[_nodes objectAtIndex:
                                           prevNodeRowIndex+i+1]];
                    }
                }
                if( !firstInRow && (c & GSGridNode_Left) != 0 )
                {
                    [node addConnection:[_nodes objectAtIndex:
                                         [_nodes count]-1]];
                    [node addNeighbor:[_nodes objectAtIndex:
                                       [_nodes count]-1]];
                }
                
                [_nodes addObject:node];
            }
            rowIndex ++;
        }
    }
    return self;
}

- (id)initWithTotalSize:(CGSize)totalSize nodeSize:(CGSize)nodeSize
{
    self = [self init];
    if( self != nil )
    {
        _totalSize = totalSize;
        _nodeSize = nodeSize;
        NSUInteger totalWidth = _totalSize.width;
        NSUInteger totalHeight = _totalSize.height;
        NSUInteger subWidth = _nodeSize.width;
        NSUInteger subHeight = _nodeSize.height;
        NSUInteger rowIndex = 0;
        NSUInteger rowLength = self.rowLength;
        NSUInteger columnIndex = 0;
        for( NSUInteger yPos = 0; yPos < totalHeight; yPos += subHeight )
        {
            columnIndex = 0;
            for( NSUInteger xPos = 0; xPos < totalWidth; xPos += subWidth )
            {
                CGRect aRect = CGRectMake(xPos, yPos, subWidth, subHeight);
                GSGridPathNode *node = [GSGridPathNode nodeWithRect:aRect];
                BOOL lastInRow = (xPos+subWidth >= totalWidth);
                BOOL firstInRow = (columnIndex == 0);
                NSUInteger prevNodeRowIndex = ([_nodes count]-
                                               columnIndex-rowLength);
                // generate all possible connections; nodes on borders are the
                // limits of the graph
                if( rowIndex > 0 )
                {
                    if( !firstInRow )
                    {
                        [node addConnection:[_nodes objectAtIndex:
                                             prevNodeRowIndex+columnIndex-1]];
                        [node addNeighbor:[_nodes objectAtIndex:
                                           prevNodeRowIndex+columnIndex-1]];
                    }
                    [node addConnection:[_nodes objectAtIndex:
                                         prevNodeRowIndex+columnIndex]];
                    [node addNeighbor:[_nodes objectAtIndex:
                                       prevNodeRowIndex+columnIndex]];
                    if( !lastInRow )
                    {
                        [node addConnection:[_nodes objectAtIndex:
                                             prevNodeRowIndex+columnIndex+1]];
                        [node addNeighbor:[_nodes objectAtIndex:
                                           prevNodeRowIndex+columnIndex+1]];
                    }
                }
                if( !firstInRow )
                {
                    [node addConnection:[_nodes objectAtIndex:[_nodes count]-1]];
                    [node addNeighbor:[_nodes objectAtIndex:[_nodes count]-1]];
                }
                [_nodes addObject:node];
                columnIndex ++;
            }
            rowIndex ++;
        }
    }
    return self;
}

+ (id)graphWithFile:(GSFile *)file
{
    return [[[self alloc] initWithFile:file] autorelease];
}

+ (id)graphWithTotalSize:(CGSize)aSize nodeSize:(CGSize)subSize
{
    return [[[self alloc] initWithTotalSize:aSize nodeSize:subSize] autorelease];
}

- (NSUInteger)rowLength
{
    return _totalSize.width / _nodeSize.width;
}

- (NSArray*)linePathFromStartPoint:(CGPoint)startPoint
                        toEndPoint:(CGPoint)endPoint
{
    GSGridPathNode *startNode = [self nodeAtPoint:startPoint];
    GSGridPathNode *endNode = [self nodeAtPoint:endPoint];
    NSArray *path = [self pathFromStartNode:startNode toEndNode:endNode];
    [_linePath removeAllObjects];
    for( GSGridPathNode *node in path )
    {
        [_linePath addObject:node.pointValue];
    }
    return _linePath;
}

- (void)addObstacleAtRect:(CGRect)aRect
{
    NSArray *nodes = [self nodesAtRect:aRect];
    // if adding an obstacle, simply remove all connections for all the nodes
    // intersecting the rect
    for( GSPathNode *node in nodes )
    {
        [node removeAllConnections];
    }
}

- (void)removeObstacleAtRect:(CGRect)aRect
{
    NSArray *nodes = [self nodesAtRect:aRect];
    // want to make the nodes intersecting reconnect where applicable
    for( GSPathNode *node in nodes )
    {
        // run 2 passes - one to connect to found nodes and another to connect
        // to node neighbours.
        // the 2-pass approach is necessary here as the neighbour might not
        // be in the found node list and may have no connections, in which
        // case it should NOT be reconnected as it has an obstable that has
        // NOT been removed. We don't want the obstacle removal in this area 
        // becoming infectious and removing other obstacles wantonly.
        // But, we want reconnections to occur with this new set of nodes
        // so force at least one reconnection with each found node so the
        // second pass works. This avoids the edge case where the nodes are
        // isolated and have no neighbours with connections.
        
        // connect to other found nodes if they are neighbours - establish
        // a baseline of the nodes being re-connected
        for( GSPathNode *otherNode in nodes )
        {
            if( node != otherNode &&
                [node.neighbors containsObject:otherNode] )
            {
                [node addConnection:otherNode];
            }
        }
        // connect to neighbours for the node if they have connections
        for( GSPathNode *neighbor in node.neighbors )
        {
            if( [neighbor.connections count] > 0 )
            {
                [node addConnection:neighbor];
            }
        }
    }
}

- (void)clearObstacles
{
    // reconnect all neighbour nodes
    for( GSPathNode *node in self.nodes )
    {
        for( GSPathNode *neighbor in node.neighbors )
        {
            [node addConnection:neighbor];
        }
    }
}

- (GSGridPathNode*)nodeAtRect:(CGRect)aRect
{
    CGPoint point = CGPointMake(aRect.origin.x+aRect.size.width/2,
                                aRect.origin.y+aRect.size.height/2);
    return [self nodeAtPoint:point];
}

- (GSGridPathNode*)nodeAtPoint:(CGPoint)aPoint
{
    NSUInteger columnIndex = (aPoint.x / _nodeSize.width);
    NSUInteger rowIndex = (aPoint.y / _nodeSize.height);
    NSUInteger nodeIndex = (self.rowLength*rowIndex) + columnIndex;
    GSGridPathNode *node = nil;
    if( self.rowLength > columnIndex && [_nodes count] > nodeIndex )
    {
        node = [_nodes objectAtIndex:nodeIndex];
    }
    else
    {
        DLog( @"Node at (%d,%d) doesn't exist in grid.", rowIndex, columnIndex );
    }
    return node;
}

- (NSArray*)nodesAtRect:(CGRect)aRect
{
    NSMutableArray *foundNodes = [NSMutableArray array];
    // determine general area of obstacle
    NSUInteger startColumnIndex = ((aRect.origin.x + _nodeSize.width/2) / 
                                   _nodeSize.width);
    NSUInteger startRowIndex = ((aRect.origin.y + _nodeSize.height/2) / 
                                _nodeSize.height);
    NSUInteger stopColumnIndex = ((aRect.origin.x + aRect.size.width -
                                   _nodeSize.width/2) / 
                                  _nodeSize.width);
    NSUInteger stopRowIndex = ((aRect.origin.y + aRect.size.height - 
                                _nodeSize.height/2) / 
                               _nodeSize.height);
    // check all nodes that are in the general vicinity of the rect
    for( NSUInteger rowIndex = startRowIndex;
         rowIndex <= stopRowIndex; rowIndex ++ )
    {
        for( NSUInteger columnIndex = startColumnIndex;
             columnIndex <= stopColumnIndex; columnIndex ++ )
        {
            NSUInteger nodeIndex = (self.rowLength*rowIndex) + columnIndex;
            if( self.rowLength < columnIndex || [_nodes count] < nodeIndex )
            {
                DLog( @"Node at (%d,%d) doesn't exist in grid.", rowIndex, columnIndex );
                continue;
            }
            // check against found node and all surrounding nodes, adding to
            // the list those that intersect
            // ensure that checked nodes aren't added more than once to found
            // node list
            GSGridPathNode *node = [_nodes objectAtIndex:nodeIndex];
            for( GSGridPathNode *connection in node.connections )
            {
                if( ![foundNodes containsObject:connection] &&
                    CGRectIntersectsRect(aRect, connection.rect) )
                {
                    [foundNodes addObject:connection];
                }
            }
            if( ![foundNodes containsObject:node] && 
                CGRectIntersectsRect(aRect, node.rect) )
            {
                [foundNodes addObject:node];
            }
        }
    }
    return foundNodes;
}

@end
