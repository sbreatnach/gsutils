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
//  gsfunctions.h
//  gsutils
//
//  Created by Shane Breatnach on 05/11/2011.
//  Copyright (c) 2011-2012 GlicSoft. All rights reserved.
//

#ifndef __GSFUNCTIONS_H__
#define __GSFUNCTIONS_H__

#include <UIKit/UIKit.h>

/**
 * Returns a unique identifier for the application currently being run.
 * Drop-in replacement for deprecated -uniqueIdentifier message of UIDevice.
 * NB: this uses standard NSUserDefaults to store app ID for lifetime of
 * app install, don't reset unless you want it to recreate itself.
 */
extern NSString* GSUniqueAppIdentifier();
/**
 * Simple function that returns the value bounded by the upper and lower
 * values.
 */
extern float fbound( float value, float lower, float upper );
/**
 * Returns a new CGColorRef with the given ARGB integer value and
 * CGColorSpaceRef. The argb value should be 32-bits and be in the format
 * 0xAARRGGBB
 */
extern CGColorRef CGColorCreateWithARGB( CGColorSpaceRef colorspace,
                                        NSUInteger argb );
/**
 * Initialises the rect at the given pointer with the data from the given
 * array. The array must have 4 NSNumber float values and contain, in order:
 * index 0: x coord
 * index 1: y coord
 * index 2: width
 * index 3: height
 */
extern void CGRectMakeWithArrayRepresentation( NSArray* array,
                                              CGRect* rect );
/**
 * Initialises the rect at the given pointer with the data from the given
 * array. The array must have 4 NSNumber float values and contain, in order:
 * index 0: x coord
 * index 1: y coord
 * index 2: width
 * index 3: height
 */
extern NSValue* CGRectValueMakeWithArrayRepresentation( NSArray* array );

#endif
