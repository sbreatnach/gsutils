//
//  GSGlImporter.h
//  gsutils
//
//  Created by Shane Breatnach on 19/08/2011.
//  Copyright 2011 Whizz Computing Inc. All rights reserved.
//

#import <Foundation/Foundation.h>


@class GSGlObject;

@interface GSGlImporter : NSObject
{
    
}

+ (GSGlObject*)objectFromResource:(NSString*)resource;
+ (GSGlObject*)objectFromPath:(NSString*)path;

@end
