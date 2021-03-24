//
//  GSFileReader.h
//  gsutils
//
//  Created by Shane Breatnach on 19/08/2011.
//  Copyright (c) 2011-2012 GlicSoft. All rights reserved.
//

#import <Foundation/Foundation.h>


/**
 * Offers a streaming interface for reading data from a file. Wraps the 
 * more low-level interface of NSFileHandle into a simpler approach.
 * NB: currently supports single byte encodings only.
 */
@interface GSFileReader : NSObject
{
    NSStringEncoding _encoding;
    NSMutableData *_data;
    NSFileHandle *_file;
    NSUInteger _chunkSize;
    NSUInteger _offset;
    BOOL _eof;
}

/**
 * The encoding for the string values.
 */
@property (nonatomic, assign) NSStringEncoding encoding;
/**
 * The current offset from where the next read line will occur. May be
 * set to skip ahead in the file if wanted.
 */
@property (nonatomic, assign) NSUInteger offset;
/**
 * YES if the end of file has been reached; NO otherwise.
 */
@property (nonatomic, assign) BOOL eof;

/**
 * Returns a reader for the given file path.
 */
+ (id)readerWithPath:(NSString*)path;
/**
 * Initialises a reader for the given file path.
 */
- (id)initWithPath:(NSString*)path;

/**
 * Reads a line from the file. Uses \n as line delimiter. Returns nil if
 * end of file has been reached.
 */
- (NSString*)readLine;

@end
