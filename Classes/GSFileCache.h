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
//  GSHTTPCache.h
//  gsutils
//
//  Created by Shane Breatnach on 21/01/2012.
//  Copyright (c) 2012 GlicSoft. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GSFile.h"

extern NSString * const GSFileCacheSettingsLocationKey;
extern NSString * const GSFileCacheSettingsDirectoryKey;
extern NSString * const GSFileCacheSettingsRenewOptionKey;
extern NSString * const GSFileCacheSettingsClearKey;
extern NSString * const GSFileCacheSettingsClearOptionKey;
extern NSString * const GSFileCacheSettingsClearLimitKey;
extern NSString * const GSFileCacheSettingsClearTimeoutKey;

typedef enum {
    GSFileCacheRenewOptionNever,
    GSFileCacheRenewOptionOnAccess,
} GSFileCacheRenewOption;

typedef enum {
    GSFileCacheRenewClearOptionFileExpired = 1,
    GSFileCacheRenewClearOptionDiskLimitExceeded = 2,
} GSFileCacheClearOption;

@interface GSFileCache : NSObject
{
    NSMutableDictionary *_cache;
    NSDictionary *_settings;
    GSFile *_cacheFile;
    NSTimer *_clearTimer;
}

- (id)initWithSettings:(NSDictionary*)settings cache:(GSFile*)cache;
- (id)init;

+ (NSMutableDictionary*)defaultSettings;

/**
 * Stores the given binary data in the cache as a unique, randomly-named file,
 * keyed by the given value. Note this does not retain the fileData object.
 */
- (void)setData:(NSData*)fileData forKey:(NSString*)key;
/**
 * Returns the file keyed by the given value.
 */
- (GSFile*)fileForKey:(NSString*)key;
/**
 * Returns the binary data for the file keyed by the given value.
 */
- (NSData*)dataForKey:(NSString*)key;
/**
 Returns the path directory where all cache files are stored.
 */
- (NSString*)cacheDirectory;

@end
