//
//  FWTRadialMaskLayer.m
//  FWTAnnotationManager
//
//  Created by Marco Meschini on 11/11/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import "FWTRadialMaskLayer.h"

@interface FWTRadialMaskLayer ()
@property (nonatomic, retain) UIBezierPath *boundsBezierPath;
@property (nonatomic, retain) CALayer *accessoryLayer;
@property (nonatomic, assign) CGFloat maskRadius;
@end

@implementation FWTRadialMaskLayer
@dynamic maskRadius;

- (void)dealloc
{
    self.accessoryLayer = nil;
    self.maskImageRef = nil;
    self.boundsBezierPath = nil;
    self.fillColor = nil;
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
        self.needsDisplayOnBoundsChange = YES;
        //        self.contentsScale = [UIScreen mainScreen].scale;
        //        self.borderWidth = 1.0f;
        //        self.borderColor = [UIColor redColor].CGColor;
    }
    return self;
}

- (id)initWithLayer:(id)layer
{
    if ((self = [super initWithLayer:layer]))
    {
        self.fillColor = [(FWTRadialMaskLayer *)layer fillColor];
        self.boundsBezierPath = [(FWTRadialMaskLayer *)layer boundsBezierPath];
        self.maskImageRef = [(FWTRadialMaskLayer *)layer maskImageRef];
    
        CGImageRef theAccessoryImageRef = [(FWTRadialMaskLayer *)layer accessoryImageRef];
        if (theAccessoryImageRef)
        {
            self.accessoryImageRef = theAccessoryImageRef;
            self.accessoryLayer = [(FWTRadialMaskLayer *)layer accessoryLayer];
        }
        
    }
    return self;
}

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self _updateBoundsBezierPath];
}

- (void)setBounds:(CGRect)bounds
{
    [super setBounds:bounds];
    [self _updateBoundsBezierPath];
}

- (void)drawInContext:(CGContextRef)ctx
{
    CGRect rect = CGContextGetClipBoundingBox(ctx);
    CGContextSetFillColorWithColor(ctx, self.fillColor);
    
    //
    CGFloat side = rect.size.width*.5f;
    CGFloat test = side*(1-self.maskRadius);
    CGRect myRect = CGRectInset(rect, test, test);
    myRect = CGRectIntegral(myRect);
    
    //
    UIBezierPath *bp = [UIBezierPath bezierPathWithRect:myRect];
    [bp appendPath:self.boundsBezierPath];
    CGContextAddPath(ctx, bp.CGPath);
    CGContextEOFillPath(ctx);
    
    //
    CGContextClipToMask(ctx, myRect, self.maskImageRef);
    CGContextFillRect(ctx, rect);
}

- (void)layoutSublayers
{
    [super layoutSublayers];
    
    if (self.accessoryImageRef)
    {
        if (!self.accessoryLayer.superlayer) [self addSublayer:self.accessoryLayer];
        self.accessoryLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    }
}

#pragma mark - Getters
- (CALayer *)accessoryLayer
{
    if (!self->_accessoryLayer) self->_accessoryLayer = [[CALayer alloc] init];
    return self->_accessoryLayer;
}

#pragma mark - Private
- (void)_updateBoundsBezierPath
{
    if (!self.boundsBezierPath || !CGSizeEqualToSize(self.bounds.size, self.boundsBezierPath.bounds.size))
        self.boundsBezierPath = [UIBezierPath bezierPathWithRect:self.bounds];
}

- (void)_animateMaskRadius:(CGFloat)toValue accessoryBounds:(CGRect)destBounds completion:(void (^)(void))completionBlock
{
    [CATransaction begin];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
    [CATransaction setCompletionBlock:completionBlock];
    
    // animate the radial mask
    CABasicAnimation *animation_a = [CABasicAnimation animationWithKeyPath:@"maskRadius"];
    animation_a.toValue = [NSNumber numberWithFloat:toValue];
    self.maskRadius = toValue;
    [self addAnimation:animation_a forKey:@"maskRadius"];
    
    // animate the accessory layer - optional
    if (self.accessoryImageRef)
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"bounds"];
        animation.toValue = [NSValue valueWithCGRect:destBounds];
        self.accessoryLayer.bounds = destBounds;
        [self.accessoryLayer addAnimation:animation forKey:@"animateBounds"];
    }
    
    [CATransaction commit];
}

#pragma mark - Public
- (void)setAccessoryImageRef:(CGImageRef)accessoryImageRef
{
    if (self->_accessoryImageRef != accessoryImageRef)
    {
        CGImageRelease(self->_accessoryImageRef);
        self->_accessoryImageRef = nil;
        
        if (accessoryImageRef)
        {
            self->_accessoryImageRef = CGImageRetain(accessoryImageRef);
            self.accessoryLayer.contents = (id)self->_accessoryImageRef;
        }
        else
        {
            if (self->_accessoryLayer)
            {
                [self.accessoryLayer removeFromSuperlayer];
                self.accessoryLayer = nil;
            }
        }
    }
}

- (void)presentAnimation:(void (^)(void))completionBlock
{
    CGRect destRect = CGRectZero;
    if (self.accessoryImageRef)
    {
        CGFloat scale = [UIScreen mainScreen].scale;
        CGImageRef imageRef = (CGImageRef)self.accessoryLayer.contents;
        CGSize imageSize = CGSizeMake(CGImageGetWidth(imageRef)*1/scale, CGImageGetHeight(imageRef)*1/scale);
        destRect = CGRectMake(.0f, .0f, imageSize.width, imageSize.height);
    }
    
    [self _animateMaskRadius:1.0f accessoryBounds:destRect completion:completionBlock];
}

- (void)dismissAnimation:(void (^)(void))completionBlock
{
    [self _animateMaskRadius:.0f accessoryBounds:CGRectZero completion:completionBlock];
}

#pragma mark - Custom animatable property
// This is the core of what does animation for us. It
// tells CoreAnimation that it needs to redisplay on
// each new value of progress, including tweened ones.
+ (BOOL)needsDisplayForKey:(NSString *)key
{
    return [key isEqualToString:@"maskRadius"] || [super needsDisplayForKey:key];
}

@end
