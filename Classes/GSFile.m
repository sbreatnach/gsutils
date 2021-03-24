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
//  GSFile.m
//  gsutils
//
//  Created by Shane Breatnach on 03/02/2011.
//

#import "GSFile.h"
#import "GSFileManager.h"
#import "GSLogging.h"


@interface GSFile ()

- (void)clearCache;

@end

@implementation GSFile

@synthesize mimeType = _mimeType;
@dynamic location;
@dynamic fileName;
@dynamic fileNameWithoutExtension;
@dynamic data;
@dynamic path;

- (void)dealloc
{
    [self clearCache];
    [_fileName release];
    [_mimeType release];
    [super dealloc];
}

+ (id)file
{
    return [[[self alloc] init] autorelease];
}

+ (id)fileFromPath:(NSString *)path
{
    GSFile *file = [GSFile file];
    file.location = ([path isAbsolutePath] ?
                     GSFileLocationAbsolute : GSFileLocationBundle);
    file.fileName = path;
    file.mimeType = @"application/octet-stream";
    return file;
}

- (NSData*)data
{
    if( _data == nil )
    {
        _data = [[NSData dataWithContentsOfFile:self.path] retain];
    }
    return _data;
}

- (NSString*)path
{
    if( _path == nil )
    {
        GSFileManager *manager = [GSFileManager sharedInstance];
        switch (self.location)
        {
            case GSFileLocationDocuments:
                _path = [[manager documentPath:self.fileName] retain];
                break;
            case GSFileLocationLibrary:
                _path = [[manager libraryPath:self.fileName] retain];
                break;
            case GSFileLocationTemporary:
                _path = [[manager temporaryPath:self.fileName] retain];
                break;
            case GSFileLocationBundle:
                _path = [[manager resourcePath:self.fileName] retain];
                break;
                
            default:
                _path = [self.fileName retain];
                break;
        }
    }
    return _path;
}

- (NSString*)fileName
{
    return _fileName;
}

- (NSString*)fileNameWithoutExtension
{
    if( _fileNameWithoutExtension == nil )
    {
        _fileNameWithoutExtension = [[[_fileName lastPathComponent]
                                      stringByDeletingPathExtension] retain];
    }
    return _fileNameWithoutExtension;
}

- (void)setFileName:(NSString *)fileName
{
    if( _fileName == nil || fileName == nil ||
        (_fileName != fileName && ![_fileName isEqualToString:fileName]) )
    {
        [_fileName release];
        _fileName = [fileName retain];
        // unload any cached data for the file
        [self clearCache];
    }
}

- (GSFileLocation)location
{
    return _location;
}

- (void)setLocation:(GSFileLocation)location
{
    _location = location;
    // unload any cached data for the file
    [self clearCache];
}

- (BOOL)exists
{
    return [[GSFileManager sharedInstance] pathExists:self.path];
}

- (id)plistObject
{
    NSData *plistData = [NSData dataWithContentsOfFile:self.path];
    NSString *error;
    NSPropertyListFormat format;
    id plist;
    
    plist = [NSPropertyListSerialization propertyListFromData:plistData
                                             mutabilityOption:NSPropertyListImmutable
                                                       format:&format
                                             errorDescription:&error];
    if(!plist)
    {
        DLog(@"Failed to parse plist: %@", error);
        [error release];
    }
    return plist;
}

- (void)clearCache
{
    [_fileNameWithoutExtension release];
    _fileNameWithoutExtension = nil;
    [_data release];
    _data = nil;
    [_path release];
    _path = nil;
}

@end
