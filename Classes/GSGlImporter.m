//
//  GSGlImporter.m
//  gsutils
//
//  Created by Shane Breatnach on 19/08/2011.
//  Copyright 2011 Whizz Computing Inc. All rights reserved.
//

#import "GSGlImporter.h"
#import "GSFileReader.h"
#import "GSGlObject.h"
#import "GSLogging.h"


@interface GSGlImporter ()

+ (void)readWavefrontObject:(GSGlObject*)object reader:(GSFileReader*)reader;

@end

@implementation GSGlImporter

+ (GSGlObject*)objectFromResource:(NSString *)resource
{
    return [self objectFromPath:
            [[NSBundle mainBundle] pathForResource:resource ofType:@"obj"]];
}

+ (GSGlObject*)objectFromPath:(NSString *)path
{
    GSGlObject *glObj = [GSGlObject object];
    GSFileReader *reader = [[GSFileReader alloc] initWithPath:path];
    if( glObj != nil && reader != nil )
    {
        // TODO: do file type detection for different object formats
        [self readWavefrontObject:glObj reader:reader];
    }
    [reader release];
    return glObj;
}

+ (void)readWavefrontObject:(GSGlObject*)object reader:(GSFileReader*)reader
{
    
}

@end
