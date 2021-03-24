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
//  GSHTTPCache.m
//  gsutils
//
//  Created by Shane Breatnach on 21/01/2012.
//  Copyright (c) 2012 GlicSoft. All rights reserved.
//

#import "GSFileCache.h"
#import "GSFileManager.h"
#import "GSJsonParser.h"
#import "GSJsonWriter.h"
#import "GSNSMutableDictionary+Utilities.h"
#import "GSNSString+FormattingUtils.h"
#import "GSLogging.h"

NSString * const GSFileCacheSettingsLocationKey = @"Location";
NSString * const GSFileCacheSettingsDirectoryKey = @"Cache Directory";
NSString * const GSFileCacheSettingsRenewOptionKey = @"Renew Option";
NSString * const GSFileCacheSettingsClearKey = @"Clear Settings";
NSString * const GSFileCacheSettingsClearOptionKey = @"Options";
NSString * const GSFileCacheSettingsClearLimitKey = @"Disk Limit";
NSString * const GSFileCacheSettingsClearTimeoutKey = @"Timeout";

@interface GSFileCache ()

- (GSFileCacheRenewOption)renewOption;
- (void)clear:(NSTimer*)aTimer;
- (GSFile*)fileForCacheData:(NSDictionary*)cacheData;
- (void)setCacheDataWithKey:(NSString*)key filename:(NSString*)filename;

@end

@implementation GSFileCache

- (void)dealloc
{
    [_clearTimer invalidate];
    [_settings release];
    [_cache release];
    [_cacheFile release];
    [super dealloc];
}

- (id)initWithSettings:(NSDictionary*)settings cache:(GSFile *)cache
{
    self = [super init];
    if( self != nil )
    {
        NSMutableDictionary *defaultSettings = [GSFileCache defaultSettings];
        [defaultSettings addEntriesFromDictionary:settings];
        _settings = [defaultSettings retain];
        _cacheFile = [cache retain];
        if( _cacheFile.location == GSFileLocationBundle )
        {
            ALog(@"ERROR: Cache map file must be set in writable location.");
        }
        if( _cacheFile.exists )
        {
            GSJsonParser *parser = [[[GSJsonParser alloc] init] autorelease];
            _cache = [[parser objectWithData:_cacheFile.data] retain];
        }
        else
        {
            _cache = [[NSMutableDictionary alloc] init];
        }
        
        // regularly clear out the cache
        [self clear:nil];
        _clearTimer = [NSTimer scheduledTimerWithTimeInterval:60.0
                                                       target:self
                                                     selector:@selector(clear:)
                                                     userInfo:nil repeats:YES];
    }
    return self;
}

- (id)init
{
    // default settings, merged with app settings from Info plist
    NSDictionary *plistSettings = [[[NSBundle mainBundle] infoDictionary]
                                   objectForKey:@"GSFileCache Configuration"];
    
    // default file located in Library dir
    GSFile *defaultConfig = [GSFile file];
    defaultConfig.location = GSFileLocationLibrary;
    defaultConfig.fileName = @"gsfilecache.json";
    
    return [self initWithSettings:plistSettings cache:defaultConfig];
}


////////////////
////////////////
// MARK - Public methods

+ (NSMutableDictionary*)defaultSettings
{
    NSMutableDictionary *defaultSettings = [NSMutableDictionary dictionary];
    [defaultSettings setObject:[NSNumber numberWithInt:GSFileLocationLibrary]
                        forKey:GSFileCacheSettingsLocationKey];
    [defaultSettings setObject:@"gsfilecache"
                        forKey:GSFileCacheSettingsDirectoryKey];
    [defaultSettings setObject:[NSNumber numberWithInt:GSFileCacheRenewOptionNever]
                        forKey:GSFileCacheSettingsRenewOptionKey];
    NSDictionary *clearSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                                   [NSNumber numberWithFloat:86400.0],
                                   GSFileCacheSettingsClearTimeoutKey,
                                   [NSNumber numberWithInt:
                                    GSFileCacheRenewClearOptionFileExpired], 
                                   GSFileCacheSettingsClearOptionKey, nil];
    [defaultSettings setObject:clearSettings
                        forKey:GSFileCacheSettingsClearKey];
    return defaultSettings;
}

- (void)setData:(NSData *)fileData forKey:(NSString *)key
{
    NSString *cacheFilename = [NSString randomStringOfLength:10];
    NSString *basePath = [self cacheDirectory];
    NSString *fileName = [[GSFileManager sharedInstance]
                          uniqueFilename:cacheFilename atPath:basePath];
    [[GSFileManager sharedInstance]
     writeFilePath:[basePath stringByAppendingPathComponent:fileName]
     withData:fileData];
    [self setCacheDataWithKey:key filename:fileName];
}

- (GSFile*)fileForKey:(NSString *)key
{
    NSDictionary *cacheData = nil;
    @synchronized( _cache )
    {
        cacheData = [_cache objectForKey:key];
    }
    GSFile *file = nil;
    if( cacheData != nil )
    {
        file = [self fileForCacheData:cacheData];
        if( [self renewOption] == GSFileCacheRenewOptionOnAccess )
        {
            // update expiry timestamp for this file on successful access
            // if specified by settings
            [self setCacheDataWithKey:key
                             filename:[cacheData objectForKey:@"filename"]];
        }
    }
    return file;
}

- (NSData*)dataForKey:(NSString *)key
{
    GSFile *file = [self fileForKey:key];
    return file.data;
}

- (NSString*)cacheDirectory
{
    // location path + cache sub-directory = absolute path to cache dir
    return [[[GSFileManager sharedInstance] pathOfLocation:
             [[_settings objectForKey:GSFileCacheSettingsLocationKey] intValue]]
            stringByAppendingPathComponent:
            [_settings objectForKey:GSFileCacheSettingsDirectoryKey]];
}


///////////////////
///////////////////
// MARK - Private methods

- (void)setCacheDataWithKey:(NSString*)key filename:(NSString *)filename
{
    // create new dict representing cache data for filename
    NSMutableDictionary *cacheData = [NSMutableDictionary dictionaryWithObject:filename
                                                                        forKey:@"filename"];
    
    NSDictionary *clearSettings = [_settings objectForKey:
                                   GSFileCacheSettingsClearKey];
    // set expiry timestamp if valid timeout is set
    NSTimeInterval timeout = [[clearSettings objectForKey:
                               GSFileCacheSettingsClearTimeoutKey] floatValue];
    if( timeout > 0.0 )
    {
        NSTimeInterval expiryTimestamp = [[NSDate dateWithTimeIntervalSinceNow:timeout]
                                          timeIntervalSince1970];
        [cacheData setObject:[NSNumber numberWithFloat:expiryTimestamp]
                      forKey:@"expiry_timestamp"];
    }
    
    // update cache in mem and store on disk
    GSJsonWriter *writer = [[GSJsonWriter alloc] init];
    NSData *cacheFileData = nil;
    @synchronized( _cache )
    {
        [_cache setObject:cacheData forKey:key];
        cacheFileData = [[writer dataWithObject:_cache] retain];
    }
    @synchronized( _cacheFile )
    {
        [[GSFileManager sharedInstance] writeFilePath:_cacheFile.path
                                             withData:cacheFileData];
    }
    [cacheFileData release];
    [writer release];
}

- (GSFileCacheRenewOption)renewOption
{
    return [[_settings objectForKey:GSFileCacheSettingsRenewOptionKey] intValue];
}

- (GSFile*)fileForCacheData:(NSDictionary *)cacheData
{
    GSFile *file = [GSFile file];
    file.location = [[_settings objectForKey:GSFileCacheSettingsLocationKey]
                     intValue];
    file.fileName = [[_settings objectForKey:GSFileCacheSettingsDirectoryKey]
                     stringByAppendingPathComponent:
                     [cacheData objectForKey:@"filename"]];
    return file;
}


///////////////////
///////////////////
// MARK - NSTimers

- (void)clear:(NSTimer *)aTimer
{
    // parse options for clearing the cache from the current settings
    NSDictionary *clearSettings = [_settings objectForKey:
                                   GSFileCacheSettingsClearKey];
    GSFileCacheClearOption options = [[clearSettings objectForKey:
                                       GSFileCacheSettingsClearOptionKey] intValue];
    
    // should the files be deleted if disk space usage of cache directory exceeds
    // a certain total?
    BOOL diskLimitExceeded = NO;
    NSUInteger diskLimit = 0;
    NSUInteger freedDiskSpace = 0;
    NSUInteger currentDiskSpace = 0;
    if( (options & GSFileCacheRenewClearOptionDiskLimitExceeded) != 0 )
    {
        diskLimit = [[clearSettings objectForKey:
                      GSFileCacheSettingsClearLimitKey] unsignedIntValue];
        currentDiskSpace = [[GSFileManager sharedInstance] sizeOfPath:
                            [self cacheDirectory]];
        diskLimitExceeded = (currentDiskSpace > diskLimit);
        DLog(@"Clearing cache based on disk space limit of %d.", diskLimit);
    }
    
    // is the clear to be done using file's expiry timestamps?
    BOOL deleteOnExpiry = ((options & GSFileCacheRenewClearOptionFileExpired) != 0);
    NSTimeInterval curTimestamp = 0.0;
    if( deleteOnExpiry )
    {
        curTimestamp = [[NSDate date] timeIntervalSince1970];
        DLog(@"Clearing cached based on file expiry timestamp.");
    }
    
    // traverse cache data, removing any files based on clear options
    NSMutableArray *expiredKeys = [NSMutableArray array];
    @synchronized( _cache )
    {
        for( NSString *key in [_cache keyEnumerator] )
        {
            NSDictionary *data = [_cache objectForKey:key];
            GSFile *file = [self fileForCacheData:data];
            NSTimeInterval expiryTimestamp = 0.0;
            if( deleteOnExpiry )
            {
                expiryTimestamp = [[data objectForKey:@"expiry_timestamp"]
                                   floatValue];
            }
            if( (deleteOnExpiry && (expiryTimestamp < curTimestamp)) ||
                 // TODO: pick based on another criteria if limit exceeded?
                 // TODO: delete oldest file first
                 diskLimitExceeded )
            {
                if( diskLimitExceeded )
                {
                    // if tracking disk space usage, stop deleting files if gone
                    // under limit specified in settings
                    freedDiskSpace += [[GSFileManager sharedInstance]
                                       sizeOfPath:file.path];
                    diskLimitExceeded = (currentDiskSpace-freedDiskSpace > diskLimit);
                }
                [expiredKeys addObject:key];
                DLog(@"Deleting file %@ from cache.", file.path);
                [[GSFileManager sharedInstance] deleteFile:file];
            }
        }
        [_cache removeObjectsForKeys:expiredKeys];
    }
}

@end
