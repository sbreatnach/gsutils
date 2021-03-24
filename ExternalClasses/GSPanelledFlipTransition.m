/* ===========================================================================
 
 Copyright (c) 2010 Edward Patel
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 
 =========================================================================== */

#import "GSPanelledFlipTransition.h"
#import <UIKit/UIKit.h>

@implementation GSPanelledFlipTransition

@synthesize texturePath = _texturePath;

- (void)dealloc
{
    [_texturePath release];
    [super dealloc];
}

- (void)setupTransition
{
    // Setup matrices
    glMatrixMode(GL_PROJECTION);
    glLoadIdentity();
    glFrustumf(-0.1, 0.1, -0.15, 0.15, 0.4, 100.0);
    glMatrixMode(GL_MODELVIEW);
    glLoadIdentity();
    glEnable(GL_CULL_FACE);
    rotationAngle = 0;

    UIImage *woodImage = [UIImage imageWithContentsOfFile:self.texturePath];
    texture = [GSGLTransitionView textureFromImage:woodImage];
}

// GL context is active and screen texture bound to be used
- (BOOL)drawTransitionFrameWithTextureFrom:(GLuint)textureFromView 
                                 textureTo:(GLuint)textureToView
{
    BOOL yAxisRotate = YES;
    /* TODO: support other orientations
    switch( [[UIDevice currentDevice] orientation] )
    {
        case UIDeviceOrientationLandscapeLeft:
        case UIDeviceOrientationLandscapeRight:
            yAxisRotate = NO;
            break;
            
        default:
            break;
    }
     */
    GLfloat vertices[] = {
        -1, -1.5,
         1, -1.5,
        -1,  1.5,
         1,  1.5,
    };
    
    GLfloat texcoords[] = {
        0, 1,
        1, 1,
        0, 0,
        1, 0,
    };
    
    GLfloat verticesSide[] = {
        1, -1.5,  -0.5,
		1,  1.5,  -0.5,
        1, -1.5,   0,
		1,  1.5,   0,
    };

    GLfloat texcoordsSide[] = {
        0.0, 0.0,
        0.0, 1.0,
        0.167, 0.0,
        0.167, 1.0,
    };
    
    glEnableClientState(GL_VERTEX_ARRAY);
    glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    // For a little ease-in-ease-out
    float rotationStep = -(-cos(rotationAngle)+1.0)/2.0;
	glColor4f(1, 1, 1, 1);
    
    glPushMatrix();
    
    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, texcoords);
    
    glBindTexture(GL_TEXTURE_2D, textureFromView);
    glTranslatef(0, 0, -4.25-sin(-rotationStep*M_PI));
    if( yAxisRotate )
    {
        glRotatef(rotationStep*180, 0, 1, 0);
    }
    else
    {
        glRotatef(rotationStep*180, 1, 0, 0);
    }
    glTranslatef(0, 0, 0.25);
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4); // Draw front
    
	glVertexPointer(3, GL_FLOAT, 0, verticesSide);
    glTexCoordPointer(2, GL_FLOAT, 0, texcoordsSide);
    
    glBindTexture(GL_TEXTURE_2D, texture);
	glDrawArrays(GL_TRIANGLE_STRIP, 0, 4); // Draw side

    glVertexPointer(2, GL_FLOAT, 0, vertices);
    glTexCoordPointer(2, GL_FLOAT, 0, texcoords);

	glBindTexture(GL_TEXTURE_2D, textureToView);
    glTranslatef(0, 0, -0.5);
    if( yAxisRotate )
    {
        glRotatef(180, 0, 1, 0);
    }
    else
    {
        glRotatef(180, 1, 0, 0);
    }
    glDrawArrays(GL_TRIANGLE_STRIP, 0, 4); // Draw back
    
    glPopMatrix();

    // determines rotation delta size; 80 frames to rotate
    rotationAngle += M_PI/80.0;
    
    return rotationAngle < M_PI;
}

- (void)transitionEnded
{
    glDeleteTextures(1, &texture);
}

@end
