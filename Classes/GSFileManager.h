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
//  GSFileManager.h
//  gsutils
//
//  Created by Shane Breatnach on 21/02/2011.
//

#import <Foundation/Foundation.h>
#import "GSFile.h"

@class GSFileCache;

/**
 Abstraction of underlying platform file management. Offers a utility interface
 that allows for simple, common-case file management 
 */
@interface GSFileManager : NSObject
{
    NSData *_emptyData;
    NSString *_resourcePath;
    NSString *_documentPath;
    NSString *_libraryPath;
    NSString *_tempPath;
    NSFileManager *_fileManager;
    GSFileCache *_cache;
}

/**
 Singleton shared instance for accessing the file system.
 */
+ (GSFileManager*)sharedInstance;

/**
 Attempts to read from the resources area of the application the named file.
 Returns the raw binary data of the file if successful; nil otherwise.
 */
- (NSData*)readResourceFile: (NSString*)fileName;
/**
 Attempts to read from the library area of the application the named file.
 Returns the raw binary data of the file if successful; nil otherwise.
 */
- (NSData*)readLibraryFile: (NSString*)fileName;
/**
 Convenience function that attempts to read from the library area of the
 application first. If the file is not found, it attempts to read from
 the application resource area instead. nil is returned if neither contains
 the file.
 */
- (NSData*)readLibraryResourceFile: (NSString*)fileName;
/**
 Returns the full path to the file name supplied, if found in either the library
 or resource areas for the application. If not found, nil is returned.
 */
- (NSString*)libraryResourceExistingPath: (NSString*)fileName;
/**
 Returns the full path for the file name supplied in the resource directory.
 */
- (NSString*)resourcePath: (NSString*)fileName;
/**
 Returns the full path for the file name supplied in the library directory.
 */
- (NSString*)libraryPath: (NSString*)fileName;
/**
 Returns the full path for the file name supplied in the document directory.
 */
- (NSString*)documentPath: (NSString*)fileName;
/**
 Returns the full path for the file name supplied in the temporary directory.
 */
- (NSString*)temporaryPath: (NSString*)fileName;
/**
 Returns the full path for the file name supplied in the temporary cache directory.
 */
- (NSString*)temporaryCachePath: (NSString*)fileName;
/**
 Returns the base path to the file location given.
 */
- (NSString*)pathOfLocation:(GSFileLocation)location;
/**
 Returns the GSFile representation of a randomly-generated file name in the
 application temporary directory. Recommended for short-lived, volatile files.
 NB: not thread-safe.
 */
- (GSFile*)temporaryFile;
/**
 Returns the GSFile representation of a randomly-generated file name in the
 temporary cache. Recommended for long-lived, semi-volatile files.
 NB: not thread-safe.
 */
- (GSFile*)temporaryCacheFile;
/**
 Returns a unique file name based on the given name for the given location.
 NB: not thread-safe.
 */
- (NSString*)uniqueFilename:(NSString*)fileName
                 atLocation:(GSFileLocation)location;
/**
 Returns a unique file name based on the given name for the given absolute path.
 NB: not thread-safe.
 */
- (NSString*)uniqueFilename:(NSString*)fileName
                     atPath:(NSString*)path;
/**
 Attempts to write to the library area of the application the given raw binary
 data using the named file. Will overwrite any existing file if permissions
 allow.
 If data is nil, it is assumed to be an empty file.
 */
- (void)writeLibraryFile: (NSString*)fileName withData: (NSData*)data;
/**
 Attempts to write to the given file path the given raw binary data. Will
 overwrite any existing file if permissions allow. Attempts to create any
 directories defined in the path that do not exist.
 If data is nil, it is assumed to be an empty file.
 */
- (void)writeFilePath: (NSString*)filePath withData: (NSData*)data;
/**
 Attempts to delete the file specified from the file system. Does nothing if
 file is nil or file doesn't point to existing file in file system.
 */
- (void)deleteFile:(GSFile*)file;
/**
 Returns true if the named file exists in the library directory of the
 application; false otherwise.
 */
- (BOOL)hasLibraryFile: (NSString*)fileName;
/**
 Returns true if the path given exists in the file system.
 */
- (BOOL)pathExists: (NSString*)path;
/**
 Returns the disk space being used by the given directory or file in bytes.
 If path is a directory, size includes all sub-directories.
 */
- (NSUInteger)sizeOfPath:(NSString*)path;
/**
 Returns the raw data located at the given path. Returns nil if no such path
 exists.
 */
- (NSData*)pathData: (NSString*)path;
/**
 Returns the file name, if any, in the given path. Returns nil if path doesn't
 exist or path is to a directory.
 */
- (NSString*)nameFromPath: (NSString*)path;

@end
