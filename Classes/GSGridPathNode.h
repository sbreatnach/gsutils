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
//  GSGridPathNode.h
//  gsutils
//
//  Created by Shane Breatnach on 25/11/2011.
//  Copyright (c) 2011-2012 GlicSoft. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GSPathNode.h"

/**
 * Defines a node on a grid graph. Each node is defined as a rect of the grid
 * with a centre point.
 */
@interface GSGridPathNode : GSPathNode
{
    NSValue *_rectValue;
    NSValue *_pointValue;
}

/**
 * x value of grid node center point.
 */
@property (nonatomic, assign, readonly) NSUInteger xPos;
/**
 * y value of grid node center point.
 */
@property (nonatomic, assign, readonly) NSUInteger yPos;
/**
 * Rect of grid node.
 */
@property (nonatomic, assign, readonly) CGRect rect;
/**
 * Centre point of grid node.
 */
@property (nonatomic, assign, readonly) CGPoint point;
/**
 * NSValue container for centre point of grid node.
 */
@property (nonatomic, assign, readonly) NSValue *pointValue;
/**
 * NSValue container for rect of grid node.
 */
@property (nonatomic, assign, readonly) NSValue *rectValue;

+ (id)nodeWithXPos:(NSUInteger)xPos yPos:(NSUInteger)yPos;
- (id)initWithXPos:(NSUInteger)xPos yPos:(NSUInteger)yPos;
+ (id)nodeWithRect:(CGRect)aRect;
- (id)initWithRect:(CGRect)aRect;

@end
