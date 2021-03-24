//
//  GSFileReader.m
//  gsutils
//
//  Created by Shane Breatnach on 19/08/2011.
//  Copyright (c) 2011-2012 GlicSoft. All rights reserved.
//

#import "GSFileReader.h"


@implementation GSFileReader

@synthesize encoding = _encoding;
@synthesize offset = _offset;
@synthesize eof = _eof;

- (void)dealloc
{
    [_file release];
    [_data release];
    [super dealloc];
}

- (id) initWithPath:(NSString *)path
{
    self = [super init];
    if( self != nil )
    {
        _file = [[NSFileHandle fileHandleForReadingAtPath:path] retain];
        _data = [[NSMutableData alloc] initWithLength:0];
        _encoding = NSUTF8StringEncoding;
        _chunkSize = 4096;
        _offset = 0;
        _eof = NO;
    }
    return self;
}

+ (id)readerWithPath:(NSString *)path
{
    return [[[self alloc] initWithPath:path] autorelease];
}

- (NSString*)readLine
{
    if( _eof )
    {
        return nil;
    }
    [_file seekToFileOffset:_offset];
    [_data setLength:0];
    NSUInteger curDataOffset = 0;
    NSUInteger dataOffset = 0;
    NSRange dataRange;
    BOOL reading = YES;
    // TODO: must account for multi-byte characters
    char chars[1];
    NSUInteger charWidth = sizeof(char);
    while( reading )
    {
        NSData *chunk = [_file readDataOfLength:_chunkSize];
        // reached end of file, stop reading
        if( [chunk length] == 0 )
        {
            _eof = YES;
            reading = NO;
            continue;
        }
        // extend read data with new chunk
        [_data appendData:chunk];
        // look for line ending in new chunk
        for( curDataOffset = dataOffset; curDataOffset < [_data length];
             curDataOffset += charWidth )
        {
            dataRange.location = curDataOffset;
            dataRange.length = charWidth;
            [_data getBytes:chars range:dataRange];
            // TODO: will fail on multi-byte files
            if( chars[0] == '\n' )
            {
                // found line ending, stop parsing now
                [_data setLength:curDataOffset];
                // skip the line end char
                dataOffset += 1;
                reading = NO;
                break;
            }
        }
        // update offset for next run of loop
        dataOffset += curDataOffset;
    }
    _offset += dataOffset;
    NSString *line = [[[NSString alloc] initWithData:_data encoding:_encoding]
                      autorelease];
    return line;
}

@end
