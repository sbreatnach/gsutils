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
//  GSFile.h
//  gsutils
//
//  Created by Shane Breatnach on 03/02/2011.
//

#import <Foundation/Foundation.h>

typedef enum {
    GSFileLocationBundle = 0, // resource bundle location - DEFAULT
    GSFileLocationTemporary, // temporary dir (may be cleaned up by system)
    GSFileLocationDocuments, // documents dir, may be enabled as user viewable
    GSFileLocationLibrary, // library file location
    GSFileLocationAbsolute, // no specific location, defined fully in fileName
} GSFileLocation;

/**
 Simple abstraction of a file. Defines additional information on the file for
 use in network communications.
 
 NB: on iPhone, the application directory location changes every update (on the
 device only) so storing the full path to a file within the application
 directory is a BAD IDEA. Hence, the concept of locations + fileNames. A
 location defines a generic system directory where the file is located. The
 path is generated dynamically from the combination of location and file name.
 */
@interface GSFile : NSObject
{
    NSData *_data;
    NSString *_path;
    NSString *_fileNameWithoutExtension;
    NSString *_fileName;
    NSString *_mimeType;
    GSFileLocation _location;
}
/**
 Convenience property to get the file's name without any extension.
 */
@property (nonatomic, retain, readonly) NSString *fileNameWithoutExtension;
/**
 The file name for this file. May optionally define the full path to the file.
 Unloads any cached file data if set.
 */
@property (nonatomic, retain) NSString *fileName;
/**
 The system location of the file. Defines a generic location e.g. temporary
 file location, documents location, etc. If defined as absolute location,
 the fileName property must define the absolute path. Unloads any cached file
 data if set.
 */
@property (nonatomic, assign) GSFileLocation location;
/**
 The full absolute path to the file. Generated from combination of filename
 and system location. NB: this is not cached, so changing location will change
 path automatically.
 */
@property (nonatomic, retain, readonly) NSString *path;
/**
 The raw binary data for the file. Cached in memory on read.
 */
@property (nonatomic, retain, readonly) NSData *data;
/**
 The MIME type of the file. Convenience property for transferring via HTTP and
 other systems that need MIME definitions.
 */
@property (nonatomic, retain) NSString *mimeType;

/**
 Returns an instance of a GSFile.
 */
+ (id)file;
/**
 Returns an instance of GSFile populated with the data of the given file path.
 If the given path is relative, file assumed to be in resource bundle location.
 Returns nil if no such file exists.
 */
+ (id)fileFromPath: (NSString*)path;
/**
 Returns true if the file exists at the path defined; false otherwise.
 */
- (BOOL)exists;
/**
 * Returns property list object from the file path. Returns nil if  plist file
 * in invalid format.
 */
- (id)plistObject;

@end
