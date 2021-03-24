//
//  GSGlObject.m
//  gsutils
//
//  Created by Shane Breatnach on 19/08/2011.
//  Copyright 2011 Whizz Computing Inc. All rights reserved.
//

#import "GSGlObject.h"


@implementation GSGlObject

@synthesize vertices = _vertices;
@synthesize faces = _faces;
@synthesize groups = _groups;
@synthesize materials = _materials;
@synthesize textures = _textures;

- (void)dealloc
{
    [_vertices release];
    [_faces release];
    [_groups release];
    [_materials release];
    [_textures release];
    [super dealloc];
}

- (id)init
{
    self = [super init];
    if( self != nil )
    {
        _vertices = [[NSMutableArray alloc] init];
        _faces = [[NSMutableArray alloc] init];
        _groups = [[NSMutableArray alloc] init];
        _materials = [[NSMutableArray alloc] init];
        _textures = [[NSMutableArray alloc] init];
    }
    return self;
}

+ (id)object
{
    return [[[self alloc] init] autorelease];
}

@end
