//
//  GSDirectedGraphTest.m
//  gsutils
//
//  Created by Shane Breatnach on 23/08/2011.
//  Copyright (c) 2011-2012 GlicSoft. All rights reserved.
//

#import <GHUnitIOS/GHUnit.h>
#import "GSDirectedGraph.h"
#import "GSGraphNode.h"


@interface GSDirectedGraphTest : GHTestCase { }
@end

@implementation GSDirectedGraphTest

- (void)testSimpleGraph
{
    GSDirectedGraph *graph = [GSDirectedGraph graph];
    GHAssertNotNil(graph, nil);
    
    GSGraphNode *node1 = [GSGraphNode nodeWithObject:@"obj1"];
    [graph addRootNode:node1];
    GHAssertTrue([graph count] == 1, nil);
    GHAssertTrue([[graph flat] containsObject:node1], nil);
    
    GSGraphNode *node2 = [graph addRoot:@"obj2"];
    GHAssertTrue([graph count] == 2, nil);
    GHAssertTrue([[graph flat] containsObject:node2], nil);
    
    GSGraphNode *node3 = [GSGraphNode nodeWithObject:@"obj3"];
    [graph removeNode:node1];
    [graph addRootNode:node3];
    GHAssertTrue([graph count] == 2, nil);
    GHAssertFalse([[graph flat] containsObject:node1], nil);
    GHAssertTrue([[graph flat] containsObject:node3], nil);
    
    GSGraphNode *node4 = [GSGraphNode nodeWithObject:@"obj4"];
    [node4 addParent:node2];
    GHAssertTrue([graph count] == 3, nil);
    GHAssertTrue([[graph flat] containsObject:node4], nil);
    
    [graph removeBranchOfNode:node2];
    GHAssertTrue([graph count] == 1, nil);
    GHAssertFalse([[graph flat] containsObject:node4], nil);
    
    [graph clear];
    GHAssertTrue([graph count] == 0, nil);
    GHAssertFalse([[graph flat] containsObject:node3], nil);
}

@end
