/* ===========================================================================
 
 Copyright (c) 2010-2011 Edward Patel
 
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

#import <OpenGLES/ES1/glext.h>

#import "GSGLTransitionView.h"

@interface GSGLTransitionView ()

@end

@implementation GSGLTransitionView

@synthesize transitionDelegate = _transitionDelegate;
@synthesize stateDelegate = _stateDelegate;
@synthesize animating;
@dynamic transitionFrameInterval;

- (void) dealloc
{
    if (defaultFramebuffer)
    {
        glDeleteFramebuffersOES(1, &defaultFramebuffer);
        defaultFramebuffer = 0;
    }
    
    if (colorRenderbuffer)
    {
        glDeleteRenderbuffersOES(1, &colorRenderbuffer);
        colorRenderbuffer = 0;
    }
    
    if (depthRenderbuffer) 
    {
        glDeleteRenderbuffersOES(1, &depthRenderbuffer);
        depthRenderbuffer = 0;
    }
    
    if ([EAGLContext currentContext] == context)
    {
        [EAGLContext setCurrentContext:nil];
    }
    
    [context release];
    context = nil;
    
    [super dealloc];
}

+ (Class) layerClass
{
    return [CAEAGLLayer class];
}

+ (GLuint)textureFromImage:(UIImage *)image
{
    // use texture size in power of 2 as OpenGL prefers this.
    int maxSize = (image.size.width > image.size.height ?
                   image.size.width : image.size.height);
    int textureSize = 2;
    // TODO: must be a shortcut, this is caveman stuff :(
    while( textureSize < maxSize )
    {
        textureSize *= 2;
    }
    
    GLuint texture = 0;
    // Allocate some memory for the texture
    GLubyte *textureData = (GLubyte*)calloc( textureSize*4, textureSize );
    
    // Create a drawing context to draw image into texture memory
    CGContextRef textureContext =
    CGBitmapContextCreate(textureData, textureSize, textureSize, 8, 
                          textureSize*4, CGImageGetColorSpace(image.CGImage),
                          kCGImageAlphaPremultipliedLast);
    CGContextDrawImage(textureContext, 
                       CGRectMake(0, textureSize-image.size.height,
                                  image.size.width, image.size.height), 
                       image.CGImage);
    CGContextRelease(textureContext);
    // ...done creating the texture data
    
    // create and bind GL texture to current GL context
    glGenTextures(1, &texture);
    glBindTexture(GL_TEXTURE_2D, texture);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, textureSize, textureSize, 0,
                 GL_RGBA, GL_UNSIGNED_BYTE, textureData);
    
    // free texture data which is by now copied into the GL context
    free(textureData);
    
    return texture;
}

- (id)initWithFrame:(CGRect)frame
              image:(UIImage*)image
          delegate:(id<GSGLTransitionViewDelegate>)delegate;
{
    if ((self = [super initWithFrame:frame]))
    {
        size = self.bounds.size;
        _transitionDelegate = delegate;
        [self setClearColorRed:0.0
                         green:0.0
                          blue:0.0
                         alpha:0.0];
        
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        self.userInteractionEnabled = NO;
        eaglLayer.opaque = NO;
        eaglLayer.drawableProperties = [NSDictionary
                                        dictionaryWithObjectsAndKeys:
                                        [NSNumber numberWithBool:NO],
                                        kEAGLDrawablePropertyRetainedBacking, 
                                        kEAGLColorFormatRGBA8,
                                        kEAGLDrawablePropertyColorFormat, nil];
        
        // Create the OpenGL rendering context for the view
        context = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
        if (!context || ![EAGLContext setCurrentContext:context])
        {
            [self release];
            return nil;
        }
        
        // create GL texture for given image
        textureFromView = [GSGLTransitionView textureFromImage:image];
        
        // create buffers for GL rendering
        glGenFramebuffersOES(1, &defaultFramebuffer);
        glGenRenderbuffersOES(1, &colorRenderbuffer);
        glGenRenderbuffersOES(1, &depthRenderbuffer);
        glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, 
                                     GL_COLOR_ATTACHMENT0_OES, 
                                     GL_RENDERBUFFER_OES, 
                                     colorRenderbuffer);        
        glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
        glFramebufferRenderbufferOES(GL_FRAMEBUFFER_OES, 
                                     GL_DEPTH_ATTACHMENT_OES, 
                                     GL_RENDERBUFFER_OES, 
                                     depthRenderbuffer);

        // viewport for GL is size of view (obv)
        glViewport(0, 0, self.frame.size.width, self.frame.size.height);
        
        glEnable(GL_DEPTH_TEST);
        
        // set scaling for all textures, based on view size
        maxTextureSize = 512;
        if( size.width > 512 || size.height > 512 )
        {
            maxTextureSize = 1024;
        }
        glMatrixMode(GL_TEXTURE);
        glLoadIdentity();
        // Convert to screen part of the maxTextureSize*maxTextureSize texture
        glScalef(size.width/(float)maxTextureSize,
                 size.height/(float)maxTextureSize, 1.0);
        glMatrixMode(GL_MODELVIEW);
        
        // setup delegate now when GL context is active
        [_transitionDelegate setupTransition];
        
        animating = FALSE;
        displayLinkSupported = FALSE;
        transitionFrameInterval = 1;
        displayLink = nil;
        animationTimer = nil;
        
        // A system version of 3.1 or greater is required to use CADisplayLink.
        // The NSTimer class is used as fallback when it isn't available.
        NSString *reqSysVer = @"3.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if( [currSysVer compare:reqSysVer options:NSNumericSearch] !=
            NSOrderedAscending )
        {
            displayLinkSupported = TRUE;
        }
    }
    
    return self;
}

- (void) prepareDestinationWithImage:(UIImage*)image
{
    textureToView = [GSGLTransitionView textureFromImage:image];
}

- (NSInteger) transitionFrameInterval
{
    return transitionFrameInterval;
}

- (void)stopTransition
{
    if (animating)
    {
        if (displayLinkSupported)
        {
            [displayLink invalidate];
            displayLink = nil;
        }
        else
        {
            [animationTimer invalidate];
            animationTimer = nil;
        }
        
        animating = FALSE;
    }
}

- (void) setTransitionFrameInterval:(NSInteger)frameInterval
{
    if (frameInterval >= 1)
    {
        transitionFrameInterval = frameInterval;
        
        if (animating)
        {
            [self stopTransition];
            [self startTransition];
        }
    }
}

- (void) startTransition
{
    if (!animating)
    {
        if (displayLinkSupported)
        {           
            displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawView:)];
            [displayLink setFrameInterval:transitionFrameInterval];
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
        {
            animationTimer = [NSTimer
                              scheduledTimerWithTimeInterval:
                              (NSTimeInterval)((1.0 / 60.0) * 
                                               transitionFrameInterval)
                              target:self selector:@selector(drawView:)
                              userInfo:nil repeats:TRUE];
        }
        
        animating = TRUE;
        
        if( _stateDelegate != nil &&
           [_stateDelegate respondsToSelector:@selector(transitionStarted)] )
        {
            [_stateDelegate transitionStarted];
        }
    }
}

- (BOOL) render
{
    [EAGLContext setCurrentContext:context];
    
    glBindFramebufferOES(GL_FRAMEBUFFER_OES, defaultFramebuffer);
    
    glClearColor(clearColor[0], 
                 clearColor[1], 
                 clearColor[2], 
                 clearColor[3]);
    glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
    
    glEnable(GL_TEXTURE_2D);
    BOOL drawOK = [_transitionDelegate
                   drawTransitionFrameWithTextureFrom:textureFromView
                   textureTo:textureToView];
    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context presentRenderbuffer:GL_RENDERBUFFER_OES];
    
    return drawOK;
}

- (BOOL) resizeFromLayer:(CAEAGLLayer *)layer
{   
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, colorRenderbuffer);
    [context renderbufferStorage:GL_RENDERBUFFER_OES fromDrawable:layer];
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES,
                                    GL_RENDERBUFFER_WIDTH_OES, &backingWidth);
    glGetRenderbufferParameterivOES(GL_RENDERBUFFER_OES,
                                    GL_RENDERBUFFER_HEIGHT_OES, &backingHeight);    
    glBindRenderbufferOES(GL_RENDERBUFFER_OES, depthRenderbuffer);
    glRenderbufferStorageOES(GL_RENDERBUFFER_OES, 
                             GL_DEPTH_COMPONENT16_OES, 
                             backingWidth, 
                             backingHeight);
    
    if( glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES) !=
        GL_FRAMEBUFFER_COMPLETE_OES )
    {
        NSLog(@"Failed to make complete framebuffer object %x",
              glCheckFramebufferStatusOES(GL_FRAMEBUFFER_OES));
        return NO;
    }
    
    return YES;
}

- (void) drawView:(id)sender
{
    if ([self render] == NO)
    {
        [self stopTransition];
        if( _transitionDelegate && 
            [_transitionDelegate
             respondsToSelector:@selector(transitionEnded)] )
        {
            [_transitionDelegate transitionEnded];
        }
        [self removeFromSuperview];
        if( _stateDelegate != nil &&
           [_stateDelegate respondsToSelector:@selector(transitionEnded)] )
        {
            [_stateDelegate transitionEnded];
        }
    }
}

- (void) layoutSubviews
{
    [self resizeFromLayer:(CAEAGLLayer*)self.layer];
    [self drawView:nil];
}

- (void) setClearColorRed:(GLfloat)red 
                    green:(GLfloat)green
                     blue:(GLfloat)blue
                    alpha:(GLfloat)alpha
{
    clearColor[0] = red;
    clearColor[1] = green;
    clearColor[2] = blue;
    clearColor[3] = alpha;
    if (alpha > 0.9)
    {
        CAEAGLLayer *eaglLayer = (CAEAGLLayer *)self.layer;
        eaglLayer.opaque = YES;
    }
}

@end

