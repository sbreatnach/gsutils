//
//  GSPathFindingGraphTest.m
//  gsutils
//
//  Created by Shane Breatnach on 18/11/2011.
//  Copyright (c) 2011-2012 GlicSoft. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "GSPathFindingGraph.h"
#import "GSPathNode.h"
#import "GSGridPathNode.h"
#import "GSGridGraph.h"
#import "GSFile.h"
#import "GSLogging.h"


@interface GSPathFindingGraphTest : GHTestCase { }
- (void)prettyPrintPath:(NSArray*)path;
@end

@implementation GSPathFindingGraphTest

// All code under test must be linked into the Unit Test bundle
- (void)testBasicGraph
{
    // create simple 3-node graph that connects from one to the next in a chain.
    // only one path and only one solution
    GSPathNode *node1 = [GSPathNode node];
    GSPathNode *node2 = [GSPathNode node];
    GSPathNode *node3 = [GSPathNode node];
    [node1 addConnection:node2];
    [node2 addConnection:node3];
    NSArray *path = [GSPathFindingGraph pathFromStartNode:node1 toEndNode:node3];
    GHAssertTrue([path count] == 3, @"Path must be of length 3.");
    GHAssertEquals([path objectAtIndex:0], node1,
                   @"First node must be start node");
    GHAssertEquals([path objectAtIndex:1], node2,
                   @"Middle node neither start nor end node");
    GHAssertEquals([path objectAtIndex:2], node3,
                   @"First node must be start node");
};

- (void)testExtendedBasicGraph
{
    // create simple n-node graph that represents a square grid of nodes
    static NSUInteger rowSize = 4;
    NSMutableArray *nodes = [NSMutableArray arrayWithCapacity:rowSize*rowSize];
    for( NSUInteger i = 0; i < rowSize*rowSize; i ++ )
    {
        GSPathNode *node = [GSPathNode node];
        if( i / rowSize == 0 )
        {
            // first row, don't make connections except left-right
            if( i > 0 )
            {
                [node addConnection:[nodes objectAtIndex:i-1]];
            }
        }
        else
        {
            // second+ row, up with row above and left-right
            [node addConnection:[nodes objectAtIndex:i-rowSize]];
            [node addConnection:[nodes objectAtIndex:i-(rowSize-1)]];
            if( i % rowSize > 0 )
            {
                [node addConnection:[nodes objectAtIndex:i-(rowSize+1)]];
                [node addConnection:[nodes objectAtIndex:i-1]];
            }
        }
        [nodes addObject:node];
    }
    NSArray *path = [GSPathFindingGraph pathFromStartNode:[nodes objectAtIndex:0]
                                                toEndNode:[nodes lastObject]];
    GHAssertTrue([path count] == 4, @"Path must be of length 4.");
    GHAssertEquals([path objectAtIndex:0], [nodes objectAtIndex:0],
                   @"First node must be start node");
    GHAssertEquals([path objectAtIndex:1], [nodes objectAtIndex:5],
                   @"Next node down and to the right of start node");
    GHAssertEquals([path objectAtIndex:2], [nodes objectAtIndex:10],
                   @"Next node down and to the right of last node");
    GHAssertEquals([path objectAtIndex:3], [nodes lastObject],
                   @"First node must be start node");
};

- (void)testBasicGridGraph
{
    // generate nodes from graph file
    GSFile *file = [GSFile fileFromPath:@"grid_16x16.gph"];
    GSGridGraph *graph = [GSGridGraph graphWithFile:file];
    NSArray *nodes = graph.nodes;
    GHAssertTrue([nodes count] == 16*16, @"Grid must be 16x16 in size.");
    
    NSArray *path = [GSGridGraph pathFromStartNode:[nodes objectAtIndex:0]
                                         toEndNode:[nodes lastObject]];
    GHAssertTrue([path count] == 16, @"Path must be of length 16.");
    GHAssertEquals([path objectAtIndex:0], [nodes objectAtIndex:0],
                   @"First node must be start node");
    for( NSUInteger i = 1; i < 15; i ++ )
    {
        GHAssertEquals([path objectAtIndex:i], [nodes objectAtIndex:i*16+i],
                       @"Next node down and to the right of previous node");
    }
    GHAssertEquals([path objectAtIndex:15], [nodes lastObject],
                   @"Last node must be end node");
}

- (void)testComplexGridGraph
{
    // generate nodes from graph file
    GSFile *file = [GSFile fileFromPath:@"grid_complex.gph"];
    GSGridGraph *graph = [GSGridGraph graphWithFile:file];
    NSArray *nodes = graph.nodes;
    GHAssertTrue([nodes count] == 7*5, @"Grid must be 7x5 in size.");
    
    NSArray *path = [GSGridGraph pathFromStartNode:[nodes objectAtIndex:2]
                                         toEndNode:[nodes objectAtIndex:7+5]];
    GHAssertTrue([path count] == 8, @"Path must be of length 8.");
    GHAssertEquals([path objectAtIndex:0], [nodes objectAtIndex:2],
                   @"First node must be start node");
    GHAssertEquals([path objectAtIndex:1], [nodes objectAtIndex:7+1],
                   @"Next node down and to the left");
    GHAssertEquals([path objectAtIndex:2], [nodes objectAtIndex:(7*2)+2],
                   @"Next node down and to the right");
    GHAssertEquals([path objectAtIndex:3], [nodes objectAtIndex:(7*2)+3],
                   @"Next node to the right");
    GHAssertEquals([path objectAtIndex:4], [nodes objectAtIndex:(7*3)+4],
                   @"Next node down and to the right");
    GHAssertEquals([path objectAtIndex:5], [nodes objectAtIndex:(7*3)+5],
                   @"Next node to the right");
    GHAssertEquals([path objectAtIndex:6], [nodes objectAtIndex:(7*2)+6],
                   @"Next node up and to the right");
    GHAssertEquals([path objectAtIndex:7], [nodes objectAtIndex:7+5],
                   @"Last node must be end node");
}

- (void)testLargeComplexGridGraph
{
    // generate nodes from sizes
    GSGridGraph *graph = [GSGridGraph graphWithTotalSize:CGSizeMake(5000, 10000)
                                            nodeSize:CGSizeMake(125, 125)];
    NSArray *nodes = graph.nodes;
    GHAssertTrue([nodes count] == 40*80, @"Grid must be 40x80 in size.");
    
    // add obstacles to the grid
    [graph addObstacleAtRect:CGRectMake(500, 1000, 125, 500)];
    [graph addObstacleAtRect:CGRectMake(4200, 1200, 125, 500)];
    [graph addObstacleAtRect:CGRectMake(2500, 5000, 2500, 125)];
    [graph addObstacleAtRect:CGRectMake(250, 7500, 500, 125)];
    [graph addObstacleAtRect:CGRectMake(3750, 5250, 125, 4500)];
    
    // check that adding an obstacle actually worked
    // nodes where obstacle should be will have no connections
    GHAssertTrue([[[nodes objectAtIndex:(8*40)+4] connections] count] == 0,
                 @"Part of first obstacle missing.");
    GHAssertTrue([[[nodes objectAtIndex:(9*40)+4] connections] count] == 0,
                 @"Part of first obstacle missing.");
    GHAssertTrue([[[nodes objectAtIndex:(10*40)+4] connections] count] == 0,
                 @"Part of first obstacle missing.");
    GHAssertTrue([[[nodes objectAtIndex:(11*40)+4] connections] count] == 0,
                 @"Part of first obstacle missing.");
    // neighbours of obstacle will have no connections to it
    GHAssertTrue([[[nodes objectAtIndex:(7*40)+3] connections] count] == 7,
                 @"Neighbors of first obstacle has connection to obstacle.");
    GHAssertTrue([[[nodes objectAtIndex:(8*40)+3] connections] count] == 6,
                 @"Neighbors of first obstacle has connection to obstacle.");
    GHAssertTrue([[[nodes objectAtIndex:(9*40)+3] connections] count] == 5,
                 @"Neighbors of first obstacle has connection to obstacle.");
    GHAssertTrue([[[nodes objectAtIndex:(10*40)+3] connections] count] == 5,
                 @"Neighbors of first obstacle has connection to obstacle.");
    GHAssertTrue([[[nodes objectAtIndex:(11*40)+3] connections] count] == 6,
                 @"Neighbors of first obstacle has connection to obstacle.");
    GHAssertTrue([[[nodes objectAtIndex:(12*40)+3] connections] count] == 7,
                 @"Neighbors of first obstacle has connection to obstacle.");
    GHAssertTrue([[[nodes objectAtIndex:(12*40)+4] connections] count] == 7,
                 @"Neighbors of first obstacle has connection to obstacle.");
    GHAssertTrue([[[nodes objectAtIndex:(12*40)+5] connections] count] == 7,
                 @"Neighbors of first obstacle has connection to obstacle.");
    GHAssertTrue([[[nodes objectAtIndex:(11*40)+5] connections] count] == 6,
                 @"Neighbors of first obstacle has connection to obstacle.");
    GHAssertTrue([[[nodes objectAtIndex:(10*40)+5] connections] count] == 5,
                 @"Neighbors of first obstacle has connection to obstacle.");
    GHAssertTrue([[[nodes objectAtIndex:(9*40)+5] connections] count] == 5,
                 @"Neighbors of first obstacle has connection to obstacle.");
    GHAssertTrue([[[nodes objectAtIndex:(8*40)+5] connections] count] == 6,
                 @"Neighbors of first obstacle has connection to obstacle.");
    GHAssertTrue([[[nodes objectAtIndex:(7*40)+5] connections] count] == 7,
                 @"Neighbors of first obstacle has connection to obstacle.");
    GHAssertTrue([[[nodes objectAtIndex:(7*40)+4] connections] count] == 7,
                 @"Neighbors of first obstacle has connection to obstacle.");
    
    NSArray *path = [GSGridGraph pathFromStartNode:[nodes objectAtIndex:(8*40)+2]
                                         toEndNode:[nodes objectAtIndex:(64*40)+32]];
    //[self prettyPrintPath:path];
    GHAssertTrue([path count] == 85, @"Incorrect path size.");
}

- (void)prettyPrintPath:(NSArray*)path;
{
    for( GSGridPathNode *node in path )
    {
        ALog(@"Next node: %@", NSStringFromCGRect(node.rect) );
    }
}

@end
