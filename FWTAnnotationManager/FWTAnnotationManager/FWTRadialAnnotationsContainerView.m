//
//  FWTRadialAnnotationsContainerView.m
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 09/11/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>

#import "FWTRadialAnnotationsContainerView.h"
#import "FWTAnnotationView.h"
#import "FWTRadialMaskLayer.h"

#define FWT_RACV_BACKGROUND_COLOR           [[UIColor blackColor] colorWithAlphaComponent:.5f]
#define FWT_RACV_RADIAL_GRADIENT_RADIUS     100.0f

@interface FWTRadialAnnotationDescriptor : NSObject
@property (nonatomic, retain) FWTAnnotationView *view;
@property (nonatomic, retain) FWTRadialMaskLayer *layer;
@property (nonatomic, assign) CGRect frame;
@property (nonatomic, assign) BOOL needsRenderInContext;
@end

@implementation FWTRadialAnnotationDescriptor
- (void)dealloc
{
    self.view = nil;
    self.layer = nil;
    [super dealloc];
}
@end

NSString *const keyPathFrame = @"frame";

@interface FWTRadialAnnotationsContainerView ()
@property (nonatomic, retain) UIImage *radialMaskImage;
@property (nonatomic, retain) UIImage *accessoryImage;
@property (nonatomic, assign) CGFloat radialGradientRadius;

@property (nonatomic, retain) UIColor *realBackgroundColor;
@property (nonatomic, retain) NSMutableDictionary *model;
@end

@implementation FWTRadialAnnotationsContainerView

- (void)dealloc
{
    self.model = nil;
    self.realBackgroundColor = nil;
    self.accessoryImage = nil;
    self.radialMaskImage = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.contentMode = UIViewContentModeRedraw;
        
        // default settings
        self.backgroundColor = FWT_RACV_BACKGROUND_COLOR;
        self.radialMaskImage = [[self class] _defaultRadialMaskImage];
        self.accessoryImage  = [[self class] _defaultAccessoryImage];
        self.radialGradientRadius = FWT_RACV_RADIAL_GRADIENT_RADIUS;
    }
    return self;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:[UIColor clearColor]];
    self.realBackgroundColor = backgroundColor;
}

- (void)drawRect:(CGRect)rect
{
    //
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    // first iteration fill the background and clear the clip paths
    CGContextSetFillColorWithColor(ctx, self.realBackgroundColor.CGColor);
    CGContextFillRect(ctx, rect);
    void(^appendSubpath)(UIBezierPath *, CGRect) = ^(UIBezierPath *path, CGRect rect) {
        [path moveToPoint:rect.origin];
        [path addLineToPoint:CGPointMake(CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect))];
        [path addLineToPoint:CGPointMake(CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect) + CGRectGetHeight(rect))];
        [path addLineToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + CGRectGetHeight(rect))];
        [path addLineToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))];
    };

    __block UIBezierPath *bezierPath = nil;
    [self.model enumerateKeysAndObjectsUsingBlock:^(id key, FWTRadialAnnotationDescriptor *radialAnnotation, BOOL *stop) {
        if (!bezierPath) bezierPath = [[UIBezierPath bezierPath] retain];
        appendSubpath(bezierPath, radialAnnotation.frame);
    }];
    
    if (bezierPath)
    {
        [bezierPath closePath];
        CGContextAddPath(ctx, bezierPath.CGPath);
        [bezierPath release];
        CGContextClip(ctx);
        CGContextClearRect(ctx, rect);
    }
    
    // time to render layers into the context
    __block CGFloat dx = .0f;
    __block CGFloat dy = .0f;
    [self.model enumerateKeysAndObjectsUsingBlock:^(id key, FWTRadialAnnotationDescriptor *radialAnnotation, BOOL *stop) {
        if (radialAnnotation.needsRenderInContext)
        {
            // translate back
            if (dx != .0f || dy != .0f) CGContextTranslateCTM(ctx, -dx, -dy);
            
            //
            dx = radialAnnotation.frame.origin.x;
            dy = radialAnnotation.frame.origin.y;
            CGContextTranslateCTM(ctx, dx, dy);
            [radialAnnotation.layer renderInContext:ctx];
        }
    }];
}

#pragma mark - Overrides
- (void)addAnnotation:(FWTAnnotation *)annotation withView:(FWTAnnotationView *)annotationView
{
    CGFloat presentDelay = annotationView.animationHelper.presentDelay;
    if (presentDelay > .25) presentDelay -= .25f;   //  our animations will take 1/4 of second
    [self performSelector:@selector(_addAnnotationView:) withObject:annotationView afterDelay:presentDelay];
}

- (void)removeAnnotation:(FWTAnnotation *)annotation withView:(FWTAnnotationView *)annotationView
{
    // remove from kvo
    [annotationView removeObserver:self forKeyPath:keyPathFrame];
    
    // update the entry
    NSString *annotationKey = [self _keyForAnnotationView:annotationView];
    FWTRadialAnnotationDescriptor *entry = [self.model objectForKey:annotationKey];
    entry.needsRenderInContext = NO;
    
    // add to view hierarchy (be sure the frame is right)
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    entry.layer.frame = entry.frame;
    [CATransaction commit];
    [self.layer insertSublayer:entry.layer below:entry.view.layer];
    
    // refresh
    [self setNeedsDisplay];
    
    // animate
    __block typeof(self) myself = self;
    void(^completionBlock)() = [[^() {
        [myself.model removeObjectForKey:annotationKey];    // remove entry
        [entry.layer removeFromSuperlayer];                 // remove layer from hierarchy
        [self setNeedsDisplay];                             // refresh
    } copy] autorelease];
    [entry.layer performSelector:@selector(dismissAnimation:) withObject:completionBlock afterDelay:.0f];
}

- (void)cancel
{
    //
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    
    //
    [self.model enumerateKeysAndObjectsUsingBlock:^(id key, FWTRadialAnnotationDescriptor *entry, BOOL *stop) {
        [entry.view removeObserver:self forKeyPath:keyPathFrame];
    }];
    
    //
    [self.model removeAllObjects];
    
    //
    [self setNeedsDisplay];
}

#pragma mark - Getters
- (NSMutableDictionary *)model
{
    if (!self->_model) self->_model = [[NSMutableDictionary alloc] init];
    return self->_model;
}

#pragma mark - Private
- (void)_addAnnotationView:(FWTAnnotationView *)annotationView
{
    CGRect rectForAnnotation = [self _rectForAnnotationView:annotationView];
    
    // create layer
    FWTRadialMaskLayer *theLayer = [FWTRadialMaskLayer layer];
    theLayer.fillColor = self.realBackgroundColor.CGColor;
    theLayer.maskImageRef = self.radialMaskImage.CGImage;
    theLayer.accessoryImageRef = self.accessoryImage.CGImage;
    theLayer.frame = rectForAnnotation;

    // add to view hierarchy
    [self.layer insertSublayer:theLayer below:annotationView.layer];
    
    // create entry and add it to the model
    FWTRadialAnnotationDescriptor *entry = [[[FWTRadialAnnotationDescriptor alloc] init] autorelease];
    entry.view = annotationView;
    entry.layer = theLayer;
    entry.frame = rectForAnnotation;
    [self.model setObject:entry forKey:[self _keyForAnnotationView:annotationView]];
    
    // add for kvo
    [annotationView addObserver:self forKeyPath:keyPathFrame options:NSKeyValueObservingOptionNew context:NULL];
    
    // refresh
    [self setNeedsDisplay];
    
    // animate
    __block typeof(self) myself = self;
    void(^completionBlock)() = [[^() {
        [entry.layer removeFromSuperlayer]; // remove from view hierarchy
        entry.needsRenderInContext = YES;   // update entry
        [myself setNeedsDisplay];           // refresh
    } copy] autorelease];
    [entry.layer performSelector:@selector(presentAnimation:) withObject:completionBlock afterDelay:.0f];
}

- (CGRect)_rectForAnnotationView:(FWTAnnotationView *)annotationView
{
    CGRect arrowRect = [annotationView arrowRect];
    CGRect radialRect = CGRectMake(.0f, .0f, self.radialGradientRadius*2, self.radialGradientRadius*2);
    radialRect.origin.x = CGRectGetMidX(arrowRect)-radialRect.size.width*.5f;
    radialRect.origin.y = CGRectGetMidY(arrowRect)-radialRect.size.height*.5f;
    
    if (annotationView.arrow.direction & FWTPopoverArrowDirectionUp)
    {
        radialRect = CGRectOffset(radialRect, annotationView.arrow.cornerOffset, -annotationView.arrow.size.height*.5f);
    }
    else if (annotationView.arrow.direction & FWTPopoverArrowDirectionDown)
    {
        radialRect = CGRectOffset(radialRect, annotationView.arrow.cornerOffset, annotationView.arrow.size.height*.5f);
    }
    else if (annotationView.arrow.direction & FWTPopoverArrowDirectionLeft)
    {
        radialRect = CGRectOffset(radialRect, -annotationView.arrow.size.height*.5f, annotationView.arrow.cornerOffset);
    }
    else if (annotationView.arrow.direction & FWTPopoverArrowDirectionRight)
    {
        radialRect = CGRectOffset(radialRect, annotationView.arrow.size.height*.5f, annotationView.arrow.cornerOffset);
    }
    else if (annotationView.arrow.direction & FWTPopoverArrowDirectionNone)
    {
        radialRect = CGRectZero;
    }
    
    return radialRect;
}

- (NSString *)_keyForAnnotationView:(FWTAnnotationView *)annotationView
{
    return [NSString stringWithFormat:@"%u", [annotationView hash]];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:keyPathFrame])
    {
        // update the frame
        FWTRadialAnnotationDescriptor *entry = [self.model objectForKey:[self _keyForAnnotationView:object]];
        entry.frame = [self _rectForAnnotationView:object];
    }
}

#pragma mark -
+ (UIImage *)_defaultAccessoryImage
{
    static UIImage *_accessoryImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize size = CGSizeMake(50.0f, 50.0f);
        CGRect ctxRect = CGRectMake(.0f, .0f, size.width, size.height);
        UIGraphicsBeginImageContextWithOptions(size, NO, .0f);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGRect availableRect = CGRectInset(ctxRect, 4, 4);
        [[UIColor whiteColor] setStroke];
        [[[UIColor whiteColor] colorWithAlphaComponent:.3f] setFill];
        
        UIBezierPath *bp = [UIBezierPath bezierPathWithOvalInRect:availableRect];
        bp.lineWidth = 3.0f;
        [bp fill];
        
        CGContextSetShadowWithColor(ctx, CGSizeZero, 2.0f, [UIColor blackColor].CGColor);
        [bp stroke];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        _accessoryImage = [image retain];
    });
    
    return _accessoryImage;
}

+ (UIImage *)_defaultRadialMaskImage
{
    static UIImage *_radialMaskImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        CGFloat side = FWT_RACV_RADIAL_GRADIENT_RADIUS;
        CGFloat startRadius = 16.0f;
        CGFloat endRadius   = 48.0f;
        
        CGSize ctxSize = CGSizeMake(side, side);
        CGRect ctxRect = CGRectMake(.0f, .0f, ctxSize.width, ctxSize.height);
        CGPoint start, end;
        start = end = CGPointMake(CGRectGetMidX(ctxRect), CGRectGetMidY(ctxRect));
        
        UIGraphicsBeginImageContextWithOptions(ctxSize, YES, .0f);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
        CGContextFillRect(ctx, ctxRect);
        
        CGFloat colors[] =
        {
             .00f,  1.00f,  // solid black
            1.00f,   .40f,  // transparent white to get a smoother interpolation
        };
        
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();
        CGGradientRef grayScaleGradient = CGGradientCreateWithColorComponents(colorSpace, colors, NULL, 2);
        CGColorSpaceRelease(colorSpace);
        CGContextDrawRadialGradient(ctx, grayScaleGradient, start, startRadius, end, endRadius, kCGGradientDrawsBeforeStartLocation);
        CGGradientRelease(grayScaleGradient);
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        _radialMaskImage = [image retain];
    });
    
    return _radialMaskImage;
}

@end
