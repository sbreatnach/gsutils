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
//  GSMultiValueDictionary.h
//  gsutils
//
//  Created by Shane Breatnach on 02/02/2011.
//

#import <Foundation/Foundation.h>


/**
 Defines a dictionary which stores multiple, unordered
 values per key. Useful for replicating HTTP request/responses which
 support multiple values for a single key.
 */
@interface GSMultiValueDictionary : NSMutableDictionary
{
    NSMutableArray *keys;
    NSMutableArray *values;
}

/**
 Initialises the dictionary with an initial set capacity.
 */
- (id)initWithCapacity: (NSUInteger)numItems;
/**
 Adds an object for this key. If there are no existing objects for the key,
 the object list is created. This object is stored as the first object for the
 key.
 */
- (void)addObject: (id)object forKey: (id)key;
/**
 Adds a series of objects for this key. If there are no existing objects for
 the key, the object list is created. The objects are stored LIFO (Last in -
 First Out) in the list for the key.
 */
- (void)addObjects: (NSArray*)objects forKey: (id)key;
/**
 Sets the first object for this key. If there are no existing objects for the
 key, the object list is created. If there is an existing object for the key
 it is replaced.
 */
- (void)setObject: (id)object forKey: (id)key;
/**
 Removes the first object for this key. If there are no more values for the key,
 the key/value match is removed from the dictionary.
 */
- (void)removeObjectForKey: (id)key;
/**
 Returns the number of keys in the dictionary. There may be multiple values
 per key so this doesn't return the precise number of entries.
 */
- (NSUInteger)count;
/**
 Returns an enumerator for the keys of the dictionary. No ordering is assumed.
 */
- (NSEnumerator *)keyEnumerator;
/**
 Returns the first object found for this key. If no object is found, nil is
 returned.
 */
- (id)objectForKey: (id)aKey;
/**
 Returns all the values for the given key in an array. If no values are found,
 nil is returned.
 */
- (NSArray*)arrayForKey: (id)key;

@end
