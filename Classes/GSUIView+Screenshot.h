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
//  GSUIView+Screenshot.h
//  gsutils
//
//  Created by Shane Breatnach on 10/05/2011.
//

#import <UIKit/UIKit.h>


@interface UIView (GSScreenshot)

/**
 Captures a screenshot of the current OpenGL buffer in the view, if any.
 
 NB: for iOS 6+, must be called before [context presentRenderbuffer:GL_RENDERBUFFER];
 or the view's CAEAGLLayer drawableProperties must have the property
 kEAGLDrawablePropertyRetainedBacking set to YES, otherwise empty screenshots
 will result.
 */
- (UIImage*)glScreenshot;
/**
 Captures a screenshot of the current OpenGL buffer in the view for the
 specified area.
 */
- (UIImage*)glScreenshotWithRect: (CGRect)rect;
/**
 Captures a screenshot of the current state of the view.
 */
- (UIImage*)screenshot;
/**
 Captures a screenshot of the current state of the view in the specified area.
 */
- (UIImage*)screenshotWithRect: (CGRect)rect;

@end
