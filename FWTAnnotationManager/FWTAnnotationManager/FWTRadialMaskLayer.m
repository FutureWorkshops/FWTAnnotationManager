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
@end

@implementation FWTRadialMaskLayer
@dynamic value;

- (void)dealloc
{
    self.maskImage = nil;
    self.boundsBezierPath = nil;
    self.fillColor = nil;
    [super dealloc];
}

- (id)init
{
    if ((self = [super init]))
    {
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
        self.maskImage = [(FWTRadialMaskLayer *)layer maskImage];
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
    CGContextSetFillColorWithColor(ctx, self.fillColor.CGColor);
    
    //
    CGFloat side = rect.size.width*.5f;
    CGFloat test = side*(1-self.value);
    CGRect myRect = CGRectInset(rect, test, test);
    myRect = CGRectIntegral(myRect);
    
    //
    UIBezierPath *bp = [UIBezierPath bezierPathWithRect:myRect];
    [bp appendPath:self.boundsBezierPath];
    CGContextAddPath(ctx, bp.CGPath);
    CGContextEOFillPath(ctx);
    
    //
    CGContextClipToMask(ctx, myRect, self.maskImage.CGImage);
    CGContextFillRect(ctx, rect);
}

#pragma mark - Private
- (void)_updateBoundsBezierPath
{
    if (!self.boundsBezierPath || !CGSizeEqualToSize(self.bounds.size, self.boundsBezierPath.bounds.size))
    {
        NSLog(@"refresh path");
        self.boundsBezierPath = [UIBezierPath bezierPathWithRect:self.bounds];
    }
}

#pragma mark - Public
- (void)setValue:(CGFloat)value animated:(BOOL)animated
{
    if (animated)
    {
        CABasicAnimation *animation = (CABasicAnimation *)[[self class] defaultActionForKey:@"value"];
        animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault];
        //        animation.duration = .35f;
        animation.fromValue = [self.presentationLayer valueForKey:@"value"];
        animation.toValue = [NSNumber numberWithFloat:value];
        self.value = value;
        [self addAnimation:animation forKey:@"value"];
    }
    else
    {
        self.value = value;
    }
}

#pragma mark - Custom animatable property
// This is the core of what does animation for us. It
// tells CoreAnimation that it needs to redisplay on
// each new value of progress, including tweened ones.
+ (BOOL)needsDisplayForKey:(NSString *)key
{
    return [key isEqualToString:@"value"] || [super needsDisplayForKey:key];
}

+ (id<CAAction>)defaultActionForKey:(NSString *)event {
    if ([event isEqualToString:@"value"])
    {
        CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:event];
        return animation;
    }
    else
        return [super defaultActionForKey:event];
}
@end
