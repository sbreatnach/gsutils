//
//  GSGlObject.h
//  gsutils
//
//  Created by Shane Breatnach on 19/08/2011.
//  Copyright 2011 Whizz Computing Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface GSGlObject : NSObject
{
    NSMutableArray *_vertices;
    NSMutableArray *_faces;
    NSMutableArray *_textures;
    NSMutableArray *_groups;
    NSMutableArray *_materials;
}

@property (nonatomic, retain) NSMutableArray *vertices;
@property (nonatomic, retain) NSMutableArray *faces;
@property (nonatomic, retain) NSMutableArray *textures;
@property (nonatomic, retain) NSMutableArray *materials;
@property (nonatomic, retain) NSMutableArray *groups;

+ (id)object;

@end
