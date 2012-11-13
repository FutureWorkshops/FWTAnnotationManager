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
#import "FWTPopoverView.h"
#import "FWTRadialMaskLayer.h"

static char overlayHelperKey;

@interface FWTRadialAnnotationEntry : NSObject
@property (nonatomic, retain) UIView *view;
@property (nonatomic, retain) CALayer *accessoryLayer;
@property (nonatomic, retain) UIView *accessoryView;
@end

@implementation FWTRadialAnnotationEntry

- (void)dealloc
{
    self.view = nil;
    self.accessoryLayer = nil;
    self.accessoryView = nil;
    [super dealloc];
}

@end

@interface FWTRadialAnnotationsContainerView ()
@property (nonatomic, retain) NSMutableArray *targetSubviews;
@end

@implementation FWTRadialAnnotationsContainerView

- (void)dealloc
{
    self.targetSubviews = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {
        self.contentMode = UIViewContentModeRedraw;
        
        self.layer.borderColor = [UIColor redColor].CGColor;
        self.layer.borderWidth = 2.0f;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    UIColor *color = [[UIColor blackColor] colorWithAlphaComponent:.7f];
    CGContextSetFillColorWithColor(ctx, color.CGColor);
    CGContextFillRect(ctx, rect);
    
    void(^appendSubpath)(UIBezierPath *, CGRect) = ^(UIBezierPath *path, CGRect rect) {
        [path moveToPoint:rect.origin];
        [path addLineToPoint:CGPointMake(CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect))];
        [path addLineToPoint:CGPointMake(CGRectGetMinX(rect) + CGRectGetWidth(rect), CGRectGetMinY(rect) + CGRectGetHeight(rect))];
        [path addLineToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect) + CGRectGetHeight(rect))];
        [path addLineToPoint:CGPointMake(CGRectGetMinX(rect), CGRectGetMinY(rect))];
    };
    
    __block UIBezierPath *bezierPath = nil;
    [self.targetSubviews enumerateObjectsUsingBlock:^(UIView *subview, NSUInteger idx, BOOL *stop) {
        
//        FWTPopoverView *view = (FWTPopoverView *)entry.view;
        if (!bezierPath) bezierPath = [[UIBezierPath bezierPath] retain];
        appendSubpath(bezierPath, subview.frame);
    }];
    
    if (bezierPath)
    {
        [bezierPath closePath];
        CGContextAddPath(ctx, bezierPath.CGPath);
        [bezierPath release];
        
        //
        CGContextClip(ctx);
        CGContextClearRect(ctx, rect);
    }
}

- (void)didAddSubview:(UIView *)subview
{
    if ([subview isKindOfClass:[FWTPopoverView class]])
    {
        FWTPopoverView *cast = (FWTPopoverView *)subview;
        CGFloat presentDelay = cast.animationHelper.presentDelay;
        [self performSelector:@selector(_addTargetSubview:) withObject:subview afterDelay:presentDelay];
    }
}

- (void)willRemoveSubview:(UIView *)subview
{
    if ([subview isKindOfClass:[FWTPopoverView class]])
    {
        CALayer *layer = objc_getAssociatedObject(subview, &overlayHelperKey);
        [layer removeFromSuperlayer];
        
        [subview removeObserver:self forKeyPath:@"frame"];
        
        [self.targetSubviews removeObject:subview];
        [self setNeedsDisplay];
    }
}

#pragma mark - Getters
- (NSMutableArray *)targetSubviews
{
    if (!self->_targetSubviews) self->_targetSubviews = [[NSMutableArray alloc] init];
    return self->_targetSubviews;
}

#pragma mark - Private
- (void)_addTargetSubview:(UIView *)subview
{
    [self.targetSubviews addObject:subview];
    
//    [CATransaction begin];
//    [CATransaction setDisableActions:YES];
    CALayer *l = [CALayer layer];
    l.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.25f].CGColor;
    l.borderWidth = 1.0f;
    l.frame = subview.frame;
    [self.layer insertSublayer:l above:subview.layer];
    
//    UIView *accessoryView = [[[UIView alloc] init] autorelease];
//    accessoryView.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:.25f];
//    accessoryView.layer.borderWidth = 1.0f;
    
    [subview addObserver:self forKeyPath:@"frame" options:NSKeyValueObservingOptionNew context:NULL];
    
//    FWTRadialAnnotationEntry *entry = [[[FWTRadialAnnotationEntry alloc] init] autorelease];
//    entry.view = subview;
//    entry.accessoryView = accessoryView;
//    entry.accessoryLayer = l;
//    [self.targetSubviews addObject:entry];
    
//    [CATransaction commit];

//    FWTRadialMaskLayer *l = [FWTRadialMaskLayer layer];
//    l.fillColor = [[UIColor blackColor] colorWithAlphaComponent:.7f];
//    l.maskImage = [UIImage imageNamed:@"gradient_mask.png"];
//    l.frame = subview.frame;//CGRectMake(10, 10, 150, 150);
//    l.borderColor = [UIColor redColor].CGColor;
//    l.borderWidth = 1.0f;
//    [l setNeedsDisplay];
//    [self.layer insertSublayer:l above:subview.layer];
//    [l setValue:1.0f animated:YES];
    
    objc_setAssociatedObject(subview, &overlayHelperKey, l, OBJC_ASSOCIATION_ASSIGN);
    
    [self setNeedsDisplay];
//    [self setNeedsLayout];
}

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"frame"])
    {
        UIView *subview = (UIView *)object;
        CALayer *layer = objc_getAssociatedObject(subview, &overlayHelperKey);
        layer.frame = subview.frame;
        NSLog(@"KVO: frame");
    }
}

@end
