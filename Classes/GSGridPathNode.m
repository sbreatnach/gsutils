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
//  GSGridPathNode.m
//  gsutils
//
//  Created by Shane Breatnach on 25/11/2011.
//  Copyright (c) 2011-2012 GlicSoft. All rights reserved.
//

#import "GSGridPathNode.h"

@implementation GSGridPathNode

@synthesize pointValue = _pointValue;
@synthesize rectValue = _rectValue;
@dynamic xPos;
@dynamic yPos;
@dynamic rect;
@dynamic point;

- (void)dealloc
{
    [_rectValue release];
    [_pointValue release];
    [super dealloc];
}

- (id)initWithXPos:(NSUInteger)xPos yPos:(NSUInteger)yPos
{
    self = [super init];
    if( self != nil )
    {
        _rectValue = [[NSValue valueWithCGRect:CGRectMake(xPos, yPos, 1, 1)]
                      retain];
        _pointValue = [[NSValue valueWithCGPoint:CGPointMake(xPos, yPos)]
                       retain];
    }
    return self;
}

- (id)initWithRect:(CGRect)aRect
{
    self = [super init];
    if( self != nil )
    {
        _rectValue = [[NSValue valueWithCGRect:aRect] retain];
        CGPoint centerPoint = CGPointMake(aRect.origin.x+aRect.size.width/2,
                                          aRect.origin.y+aRect.size.height/2);
        _pointValue = [[NSValue valueWithCGPoint:centerPoint] retain];
    }
    return self;
}

+ (id)nodeWithXPos:(NSUInteger)xPos yPos:(NSUInteger)yPos
{
    return [[[self alloc] initWithXPos:xPos yPos:yPos] autorelease];
}

+ (id)nodeWithRect:(CGRect)aRect
{
    return [[[self alloc] initWithRect:aRect] autorelease];
}

- (NSUInteger)xPos
{
    return _rectValue.CGRectValue.origin.x;
}

- (NSUInteger)yPos
{
    return _rectValue.CGRectValue.origin.y;
}

- (CGRect)rect
{
    return _rectValue.CGRectValue;
}

- (CGPoint)point
{
    return _pointValue.CGPointValue;
}

- (NSUInteger)heuristicForEndNode:(GSPathNode *)endNode
{
    // supplied end node must be grid path node
    GSGridPathNode *gridEndNode = (GSGridPathNode*)endNode;
    // grid heuristic is the Manhattan Distance => |endX - srcX| + |endY - srcY|
    return (abs(gridEndNode.xPos-self.xPos) + abs(gridEndNode.yPos-self.yPos));
}

@end
