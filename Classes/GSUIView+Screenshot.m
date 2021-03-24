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
//  GSUIView+Screenshot.m
//  gsutils
//
//  Created by Shane Breatnach on 10/05/2011.
//

#import "GSUIView+Screenshot.h"
#import <QuartzCore/QuartzCore.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES1/gl.h>

// PI / 180
#define CC_DEGREES_TO_RADIANS(__ANGLE__) ((__ANGLE__) * 0.01745329252f)

@implementation UIView (GSScreenshot)

- (UIImage*)screenshot
{
    return [self screenshotWithRect:self.bounds];
}

- (UIImage*)screenshotWithRect:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage*)glScreenshot
{
    return [self glScreenshotWithRect:self.bounds];
}

- (UIImage*)glScreenshotWithRect:(CGRect)rect
{
	// Create buffer for pixels
	GLuint bufferLength = rect.size.width * rect.size.height * 4;
	GLubyte* buffer = (GLubyte*)malloc(bufferLength);
    
	// Read Pixels from OpenGL
	glReadPixels(rect.origin.x, rect.origin.y,
                 rect.size.width, rect.size.height,
                 GL_RGBA, GL_UNSIGNED_BYTE, buffer);
	// Make data provider with data.
	CGDataProviderRef provider = CGDataProviderCreateWithData(NULL, buffer,
                                                              bufferLength,
                                                              NULL);
    
	// Configure 8888 RGB image
	int bitsPerComponent = 8;
	int bitsPerPixel = 32;
	int bytesPerRow = 4 * rect.size.width;
	CGColorSpaceRef colorSpaceRef = CGColorSpaceCreateDeviceRGB();
	CGBitmapInfo bitmapInfo = kCGBitmapByteOrderDefault;
	CGColorRenderingIntent renderingIntent = kCGRenderingIntentDefault;
	CGImageRef iref = CGImageCreate(rect.size.width, rect.size.height,
                                    bitsPerComponent, bitsPerPixel, bytesPerRow,
                                    colorSpaceRef, bitmapInfo, provider, NULL,
                                    NO, renderingIntent);
    
    // create the context where the bitmap created above will be drawn
    // using relevant rotations and translations
	uint32_t* pixels = (uint32_t*)malloc(bufferLength);
	CGContextRef context = CGBitmapContextCreate(pixels, rect.size.width,
                                                 rect.size.height, 8,
                                                 bytesPerRow,
                                                 colorSpaceRef, 
                                                 kCGImageAlphaPremultipliedLast
                                                 | kCGBitmapByteOrder32Big);
    
    // NB the pixels being read from the OpenGL view are y-inverted compared to
    // the CGImage coordinate system, hence the slightly counter-intuitive
    // transforms defined below.
#ifdef __IPHONE_OS_VERSION_MAX_ALLOWED
    switch( [[UIDevice currentDevice] orientation] )
    {
        case UIDeviceOrientationPortraitUpsideDown:
            // raw image already upside down, so do nothing
            break;
        case UIDeviceOrientationLandscapeLeft:
            CGContextRotateCTM(context, CC_DEGREES_TO_RADIANS(-90));
            CGContextTranslateCTM(context, -rect.size.height, 0);
            break;
        case UIDeviceOrientationLandscapeRight:
            CGContextRotateCTM(context, CC_DEGREES_TO_RADIANS(90));
            CGContextTranslateCTM(context,
                                  rect.size.height-rect.size.width,
                                  -rect.size.height);
            break;
        default:
            // standard Portrait orientation, draw right way up
            CGContextTranslateCTM(context, 0, rect.size.height);
            CGContextScaleCTM(context, 1.0f, -1.0f);
            break;
    }
#else
    // draw right way up
    CGContextTranslateCTM(context, 0, rect.size.height);
    CGContextScaleCTM(context, 1.0f, -1.0f);
#endif
    CGContextDrawImage(context, rect, iref);
    // take translated image in context and create new image based off context
	CGImageRef imageRef = CGBitmapContextCreateImage(context);
	UIImage *outputImage = [[[UIImage alloc] initWithCGImage:imageRef]
                            autorelease];
    
	// Deallocate all C structs
    CGImageRelease(imageRef);
    CGContextRelease(context);
    free(pixels);
	CGDataProviderRelease(provider);
	CGImageRelease(iref);
	CGColorSpaceRelease(colorSpaceRef);
	free(buffer);
    
	return outputImage;
}

@end
