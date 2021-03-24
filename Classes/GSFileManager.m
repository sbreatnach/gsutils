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
//  GSFileManager.m
//  gsutils
//
//  Created by Shane Breatnach on 21/02/2011.
//

#import "GSFileManager.h"
#import "GSFileCache.h"
#import "GSNSString+FormattingUtils.h"

@interface GSFileManager ()

- (GSFileCache*)cache;

@end

static GSFileManager *sharedInstance = nil;
static NSUInteger kCacheDiskSpaceLimit = 1024*1024*20;

@implementation GSFileManager

// MARK Singleton Methods

+ (GSFileManager*)sharedInstance
{
    @synchronized(self)
    {
        if (sharedInstance == nil)
            sharedInstance = [[GSFileManager alloc] init];
    }
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedInstance == nil) {
            sharedInstance = [super allocWithZone:zone];
            return sharedInstance;  // assignment and return on first allocation
        }
    }
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone
{
    return self;
}

- (id)retain {
    return self;
}

- (NSUInteger)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (oneway void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

// MARK Inherited methods

- (id)init
{
    self = [super init];
    if( self != nil )
    {
        _emptyData = [[NSData data] retain];
        _fileManager = [[NSFileManager alloc] init];
        [_fileManager setDelegate:self];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory,
                                                             NSUserDomainMask,
                                                             YES);
        if( [paths count] > 0 )
        {
            // to ensure value is NSString (not NSPathStore), alloc new string.
            // avoids unrecognized selector when using categories on these
            // values
            _libraryPath = [[NSString alloc] initWithString:
                            [paths objectAtIndex:0]];
        }
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                    NSUserDomainMask,
                                                    YES);
        if( [paths count] > 0 )
        {
            _documentPath = [[NSString alloc] initWithString:
                             [paths objectAtIndex:0]];
        }
        _resourcePath = [[[NSBundle mainBundle] resourcePath] retain];
        _tempPath = [NSTemporaryDirectory() retain];
    }
    return self;
}

- (void)dealloc
{
    [_emptyData release];
    [_libraryPath release];
    [_resourcePath release];
    [_tempPath release];
    [_fileManager release];
    [super dealloc];
}

// MARK Instance Methods

- (BOOL)pathExists:(NSString *)path
{
    BOOL exists = NO;
    if( path != nil )
    {
        NSString *testPath = nil;
        if( ![path isAbsolutePath] )
        {
            // if the path is relative, assumed to be relative to bundle dir
            testPath = [[_resourcePath
                         stringByAppendingPathComponent:path] retain];
        }
        else
        {
            testPath = [path retain];
        }
        exists = [_fileManager fileExistsAtPath:testPath];
        [testPath release];
    }
    return exists;
}

- (NSUInteger)sizeOfPath:(NSString *)path
{
    NSUInteger size = 0;
    NSDictionary *attributes = [_fileManager attributesOfItemAtPath:path
                                                              error:nil];
    if( attributes != nil )
    {
        size = [attributes fileSize];
    }
    return size;
}

- (NSData*)pathData:(NSString *)path
{
    NSData *data = nil;
    if( [self pathExists:path] )
    {
        data = [NSData dataWithContentsOfFile:path];
    }
    return data;
}

- (NSString*)nameFromPath:(NSString *)path
{
    BOOL isDirectory = NO;
    BOOL pathExists = (path != nil && [_fileManager
                                       fileExistsAtPath:path
                                       isDirectory:&isDirectory]);
    NSString *name = nil;
    if( pathExists && !isDirectory )
    {
        name = [path lastPathComponent];
    }
    return name;
}

- (BOOL)hasLibraryFile:(NSString *)fileName
{
    NSString *fullPath = [[_libraryPath stringByAppendingPathComponent:fileName]
                          retain];
    BOOL fileExists = NO;
    if( fullPath != nil )
    {
        fileExists = [_fileManager fileExistsAtPath:fullPath];
    }
    [fullPath release];
    return fileExists;
}

- (NSData*)readLibraryFile:(NSString *)fileName
{
    NSData *readData = nil;
    NSString *fullPath = [[_libraryPath
                           stringByAppendingPathComponent:fileName] retain];
    if( fullPath != nil && [_fileManager fileExistsAtPath:fullPath] )
    {
        // TODO log any error that occurs here
        readData = [NSData dataWithContentsOfFile:fullPath];
    }
    [fullPath release];
    return readData;
}

- (NSData*)readResourceFile:(NSString *)fileName
{
    NSData *readData = nil;
    NSString *fullPath = [[_resourcePath
                           stringByAppendingPathComponent:fileName] retain];
    if( fullPath != nil && [_fileManager fileExistsAtPath:fullPath] )
    {
        // TODO log any error that occurs here
        readData = [NSData dataWithContentsOfFile:fullPath];
    }
    [fullPath release];
    return readData;
}

- (NSData*)readLibraryResourceFile: (NSString*)fileName
{
    NSData *fileData = nil;
    if( [[GSFileManager sharedInstance] hasLibraryFile:fileName] )
    {
        fileData = [[GSFileManager sharedInstance] readLibraryFile:fileName];
    }
    else
    {
        fileData = [[GSFileManager sharedInstance] readResourceFile:fileName];
    }
    return fileData;
}

- (NSString*)libraryResourceExistingPath:(NSString *)fileName
{
    NSString *path = nil;
    NSString *fullPath = [_libraryPath stringByAppendingPathComponent:fileName];
    if( fullPath != nil )
    {
        if( [_fileManager fileExistsAtPath:fullPath] )
        {
            path = fullPath;
        }
        else
        {
            path = [fullPath retain];
            [path release];
            path = nil;
        }
    }
    if( path == nil )
    {
        fullPath = [_resourcePath stringByAppendingPathComponent:fileName];
        if( fullPath != nil )
        {
            if( [_fileManager fileExistsAtPath:fullPath] )
            {
                path = fullPath;
            }
            else
            {
                path = [fullPath retain];
                [path release];
                path = nil;
            }
        }
    }
    return path;
}

- (NSString*)resourcePath:(NSString *)fileName
{
    // must allocate new string to avoid returning NSPathStore
    return [NSString stringWithString:
            [[self pathOfLocation:GSFileLocationBundle]
             stringByAppendingPathComponent:fileName]];
}

- (NSString*)libraryPath:(NSString *)fileName
{
    return [NSString stringWithString:
            [[self pathOfLocation:GSFileLocationLibrary]
             stringByAppendingPathComponent:fileName]];
}

- (NSString*)documentPath:(NSString *)fileName
{
    return [NSString stringWithString:
            [[self pathOfLocation:GSFileLocationDocuments]
             stringByAppendingPathComponent:fileName]];
}

- (NSString*)temporaryPath:(NSString *)fileName
{
    return [NSString stringWithString:
            [[self pathOfLocation:GSFileLocationTemporary]
             stringByAppendingPathComponent:fileName]];
}

- (NSString*)temporaryCachePath:(NSString *)fileName
{
    return [[[self cache] cacheDirectory] stringByAppendingPathComponent:fileName];
}

- (NSString*)uniqueFilename:(NSString*)fileName
                 atLocation:(GSFileLocation)location
{
    NSString *locationPath = [self pathOfLocation:location];
    return [self uniqueFilename:fileName atPath:locationPath];
}
    
- (NSString*)uniqueFilename:(NSString*)fileName
                     atPath:(NSString*)path
{
    NSMutableString *mutableFileName = [NSMutableString stringWithCapacity:
                                        [fileName length]];
    [mutableFileName appendString:fileName];
    NSMutableString *mutablePath = [NSMutableString string];
    [mutablePath setString:[path
                            stringByAppendingPathComponent:mutableFileName]];
    while( [_fileManager fileExistsAtPath:mutablePath] )
    {
        [mutableFileName insertString:@"_" atIndex:0];
        [mutablePath setString:[path stringByAppendingPathComponent:
                                mutableFileName]];
    }
    return mutableFileName;
}

- (GSFile*)temporaryFile
{
    GSFile *file = [GSFile file];
    file.fileName = [self uniqueFilename:[NSString randomString]
                              atLocation:GSFileLocationTemporary];
    file.location = GSFileLocationTemporary;
    return file;
}

- (GSFile*)temporaryCacheFile
{
    NSString *randomKey = [NSString randomString];
    [[self cache] setData:[NSData data] forKey:randomKey];
    return [[self cache] fileForKey:randomKey];
}

- (void)writeLibraryFile:(NSString *)fileName withData:(NSData *)data
{
    if( data == nil )
    {
        data = _emptyData;
    }
    NSString *fullPath = [[_libraryPath
                           stringByAppendingPathComponent:fileName] retain];
    if( fullPath != nil )
    {
        // TODO log any error that occurs here
        [_fileManager createFileAtPath:fullPath contents:data attributes:nil];
    }
    [fullPath release];
}

- (void)writeFilePath:(NSString *)filePath withData:(NSData *)data
{
    if( data == nil )
    {
        data = _emptyData;
    }
    if( filePath != nil )
    {
        // TODO log all errors that occur here
        // create any intermediate directories if they don't already exist
        NSString *dirPath = [filePath stringByDeletingLastPathComponent];
        if( [dirPath length] > 0 )
        {
            [_fileManager createDirectoryAtPath:dirPath
                    withIntermediateDirectories:YES
                                     attributes:nil
                                          error:nil];
        }
        // create file in dir with default attributes
        [_fileManager createFileAtPath:filePath contents:data attributes:nil];
    }
}

- (void)deleteFile:(GSFile *)file
{
    if( file != nil && file.exists )
    {
        // TODO: log errors
        [_fileManager removeItemAtPath:file.path error:nil];
    }
}

- (NSString*)pathOfLocation:(GSFileLocation)location
{
    NSString *path = nil;
    switch (location) {
        case GSFileLocationTemporary:
            path = _tempPath;
            break;
        case GSFileLocationLibrary:
            path = _libraryPath;
            break;
        case GSFileLocationBundle:
            path = _resourcePath;
            break;
        case GSFileLocationDocuments:
            path = _documentPath;
            break;
            
        default:
            break;
    }
    return path;
}


/////////////////////////
/////////////////////////
// MARK - Private methods

- (GSFileCache*)cache
{
    if( _cache == nil )
    {
        // initialise the cache in standard library location
        GSFile *defaultConfig = [GSFile file];
        defaultConfig.location = GSFileLocationLibrary;
        defaultConfig.fileName = @"gsfilemanagercache.json";
        // new cache directory, no cache expiry and disk space limit
        NSDictionary *clearSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                       [NSNumber numberWithInt:
                                        GSFileCacheRenewClearOptionDiskLimitExceeded],
                                       GSFileCacheSettingsClearOptionKey,
                                       [NSNumber numberWithInt:kCacheDiskSpaceLimit],
                                       GSFileCacheSettingsClearLimitKey, nil];
        NSDictionary *config = [NSDictionary dictionaryWithObjectsAndKeys:
                                @"gsfilemanagercache", GSFileCacheSettingsDirectoryKey,
                                clearSettings, GSFileCacheSettingsClearKey, nil];
        _cache = [[GSFileCache alloc] initWithSettings:config
                                                 cache:defaultConfig];
    }
    return _cache;
}

@end
