//
//  FWTPopoverHintView.m
//  FWTPopoverHintView
//
//  Created by Marco Meschini on 7/12/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "FWTAnnotationView.h"

@interface FWTAnnotationView ()
{
    UIImageView *_backgroundImageView;
}
@property (nonatomic, retain)  UIImageView *backgroundImageView;
@property (nonatomic, readwrite) FWTAnnotationArrowDirection arrowDirection;
@property (nonatomic, readwrite, retain) UIBezierPath *bezierPath;
@property (nonatomic, readwrite, retain) UIView *contentView;

//  Private
- (void)adjustEdgeInsets;
- (UIImage *)resizableBackgroundImageForSize:(CGSize)size;
- (CGFloat)arrowOffsetForDeltaX:(CGFloat)dX deltaY:(CGFloat)dY direction:(NSInteger)direction;
- (CGPoint)midPointForRect:(CGRect)rect popoverSize:(CGSize)popoverSize arrowDirection:(FWTAnnotationArrowDirection)arrowDirections;

@end

@implementation FWTAnnotationView
@synthesize backgroundImageView = _backgroundImageView;
@synthesize contentView = _contentView;

- (void)dealloc
{
    self.contentView = nil;
    self.bezierPathColorStroke = nil;
    self.bezierPathColorFill = nil;
    self.shadowColor = nil;
    self.bezierPath = nil;
    self.drawPathBlock = nil;
    self.prepareToAnimationsBlock = nil;
    self.presentAnimationsBlock = nil;
    self.dismissAnimationsBlock = nil;
    self.presentCompletionBlock = nil;
    self.dismissCompletionBlock = nil;
    self.backgroundImageView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame]))
    {        
        self.backgroundColor = [UIColor clearColor];
        
        self.desiredEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        self.edgeInsets = self.edgeInsets;
        
        self.contentSize = CGSizeZero;
        
        self.shadowBlur = 8.0f;
        self.shadowOffset = CGSizeMake(.0f, 2.0f);
        self.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.75f];
        
        self.cornerRadius = 6.0f;
        
        self.arrowDirection = FWTAnnotationArrowDirectionUp;
        self.arrowSize = CGSizeMake(10.0f, 10.0f);
        self.arrowOffset = .0f;
        self.arrowCornerOffset = .0f;
        
        self.bezierPathColorFill = [[UIColor blackColor] colorWithAlphaComponent:.5f];
        self.bezierPathColorStroke = [UIColor blackColor];
        self.bezierPathLineWidth = 1.0f;
        
        self.contentViewEdgeInsets = UIEdgeInsetsZero;
        
        self.adjustPositionInSuperviewEnabled = YES;
        
        self.prepareToAnimationsBlock = ^{ self.alpha = .0f; };
        self.presentAnimationsBlock = ^{ self.alpha = 1.0f; };
        self.presentCompletionBlock = NULL;
        self.dismissAnimationsBlock = ^{ self.alpha = .0f; };
        self.dismissCompletionBlock = NULL;
        
        self.animationDuration = .2f;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    if (!self.backgroundImageView.superview)
        [self addSubview:self.backgroundImageView];
    
    self.backgroundImageView.frame = self.bounds;
    
    
    if (!self.contentView.superview)
        [self addSubview:self.contentView];
    
    CGRect avalaibleRect = UIEdgeInsetsInsetRect(self.bounds, self.edgeInsets);
    self.contentView.frame = UIEdgeInsetsInsetRect(avalaibleRect, self.contentViewEdgeInsets);
}

#pragma mark - Getters
- (UIImageView *)backgroundImageView
{
    if (!self->_backgroundImageView)
        self->_backgroundImageView = [[UIImageView alloc] init];
        
    return self->_backgroundImageView;
}

- (UIView *)contentView
{
    if (!self->_contentView)
        self->_contentView = [[UIView alloc] init];
    
//    self->_contentView.layer.borderWidth = 1.0f;
//    self->_contentView.layer.borderColor = [UIColor greenColor].CGColor;
    
    return self->_contentView;
}

#pragma mark - Private
- (void)adjustEdgeInsets
{
    UIEdgeInsets currentInsets = self.edgeInsets;
    CGFloat dY = self.arrowSize.height;
    
    if (self.arrowDirection & FWTAnnotationArrowDirectionUp)
        currentInsets.top += dY;
    else if (self.arrowDirection & FWTAnnotationArrowDirectionLeft)
        currentInsets.left += dY;
    else if (self.arrowDirection & FWTAnnotationArrowDirectionRight)
        currentInsets.right += dY;
    else if (self.arrowDirection & FWTAnnotationArrowDirectionDown)
        currentInsets.bottom += dY;
    
    self.edgeInsets = currentInsets;
}

- (UIImage *)resizableBackgroundImageForSize:(CGSize)size
{
    //
    UIEdgeInsets capInsets = UIEdgeInsetsZero;
    CGSize contextSize = size;
    if (self.arrowDirection & FWTAnnotationArrowDirectionUp || self.arrowDirection & FWTAnnotationArrowDirectionDown)
    {
        contextSize.height = (self.cornerRadius * 2) + self.edgeInsets.top + self.edgeInsets.bottom + 1.0f;
        capInsets = UIEdgeInsetsMake(self.edgeInsets.top + self.cornerRadius, .0f, self.edgeInsets.bottom + self.cornerRadius, .0f);
    }
    
    if (self.arrowDirection & FWTAnnotationArrowDirectionLeft || self.arrowDirection & FWTAnnotationArrowDirectionRight)
    {
        contextSize.width = (self.cornerRadius * 2) + self.edgeInsets.left + self.edgeInsets.right + 1.0f;
        capInsets = UIEdgeInsetsMake(.0f, self.edgeInsets.left + self.cornerRadius, .0f, self.edgeInsets.right + self.cornerRadius);
    }
    
    //
    CGSize ctxSize = contextSize;
    CGRect rect = CGRectMake(.0f, .0f, ctxSize.width, ctxSize.height);
    
    //
    UIEdgeInsets insets = self.edgeInsets;
    CGRect shapeBounds = UIEdgeInsetsInsetRect(rect, insets);
    
    //
    self.bezierPath = [self bezierPathForRect:shapeBounds];
    
    //
    UIImage *image = [self backgroundImageForSize:ctxSize];
    
    return [image resizableImageWithCapInsets:capInsets];
    
//    return image;
}

- (CGFloat)arrowOffsetForDeltaX:(CGFloat)dX deltaY:(CGFloat)dY direction:(NSInteger)direction
{
    //
    CGRect shapeBounds = UIEdgeInsetsInsetRect(self.bounds, self.edgeInsets);
    CGSize availableHalfRectSize = CGSizeMake((shapeBounds.size.width-2*self.cornerRadius)*.5f, (shapeBounds.size.height-2*self.cornerRadius)*.5f);
    CGFloat maxArrowOffset = .0f;
    
    CGFloat arrowOffset = .0f;
    if (self.arrowDirection & FWTAnnotationArrowDirectionUp || self.arrowDirection & FWTAnnotationArrowDirectionDown)
    {
        arrowOffset = direction*dX;
        maxArrowOffset = availableHalfRectSize.width - self.cornerRadius;
    }
    
    if (self.arrowDirection & FWTAnnotationArrowDirectionLeft || self.arrowDirection & FWTAnnotationArrowDirectionRight)
    {
        arrowOffset = direction*dY;
        maxArrowOffset = availableHalfRectSize.height - self.cornerRadius;
    }
    
    if (abs(arrowOffset) > maxArrowOffset)
        arrowOffset = (arrowOffset > 0) ? maxArrowOffset : -maxArrowOffset;
    
    return arrowOffset;
}

- (CGPoint)midPointForRect:(CGRect)rect popoverSize:(CGSize)popoverSize arrowDirection:(FWTAnnotationArrowDirection)arrowDirections
{
    CGPoint midPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    if (self.arrowDirection & FWTAnnotationArrowDirectionUp)
        midPoint.x -= (popoverSize.width * .5f + self.arrowCornerOffset);
    
    if (self.arrowDirection & FWTAnnotationArrowDirectionDown)
    {
        midPoint.x -= (popoverSize.width * .5f + self.arrowCornerOffset);
        midPoint.y -= popoverSize.height;
    }
    
    if (self.arrowDirection & FWTAnnotationArrowDirectionLeft)
        midPoint.y -= (popoverSize.height * .5f + self.arrowCornerOffset);
    
    if (self.arrowDirection & FWTAnnotationArrowDirectionRight)
    {
        midPoint.x -= popoverSize.width;
        midPoint.y -= (popoverSize.height * .5f + self.arrowCornerOffset);
    }
    
    if (self.arrowDirection & FWTAnnotationArrowDirectionNone)
    {
        midPoint.x -= popoverSize.width * .5f;
        midPoint.y -= popoverSize.height * .5f;
    }
    
    return midPoint;
}

- (void)adjustAndSetFrame:(CGRect)frame inSuperview:(UIView *)view
{
    CGFloat dX = .0f;
    CGFloat dY = .0f;
    NSInteger direction = 1;
    
    if (self.adjustPositionInSuperviewEnabled)
    {
        CGRect intersection = CGRectIntersection(view.bounds, frame);

        CGFloat frameWidth = frame.size.width;
        CGFloat frameHeight = frame.size.height;
        if (intersection.size.width != frameWidth)
        {
            dX = frameWidth-intersection.size.width;
            if (intersection.origin.x == 0)
            {
                frame = CGRectOffset(frame, dX, .0f);
                direction = -1;
            }
            else
                frame = CGRectOffset(frame, -dX, .0f);
        }
        if (intersection.size.height != frameHeight)
        {
            dY = frameHeight-intersection.size.height;
            if (intersection.origin.y == 0)
            {
                frame = CGRectOffset(frame, .0f, dY);
                direction = -1;
            }
            else
                frame = CGRectOffset(frame, .0f, -dY);
        }
    }
    
    //
    self.frame = CGRectIntegral(frame);
    
    //
    if (self.adjustPositionInSuperviewEnabled)
        self.arrowOffset = [self arrowOffsetForDeltaX:dX deltaY:dY direction:direction];
}

#pragma mark - Public
- (void)presentAnnotationFromRect:(CGRect)rect
                        inView:(UIView *)view
       permittedArrowDirection:(FWTAnnotationArrowDirection)arrowDirection
                      animated:(BOOL)animated
{
    //
    self.arrowDirection = arrowDirection;
    
    //
    self.edgeInsets = self.desiredEdgeInsets;
    [self adjustEdgeInsets];
    
    //
    CGPoint midPoint = [self midPointForRect:rect popoverSize:self.contentSize arrowDirection:self.arrowDirection];
    CGRect frame = CGRectZero;
    frame.origin = midPoint;
    frame.size = self.contentSize;
    
    //
    [self adjustAndSetFrame:frame inSuperview:view];
    
    //
    self.backgroundImageView.image = [self resizableBackgroundImageForSize:self.contentSize];
    
    //
    [self setNeedsLayout];
    
    //
    if (!animated)
        [view addSubview:self];
    else
    {
        //
        self.prepareToAnimationsBlock();
        
        //
        [view addSubview:self];
          
        //
        [UIView animateWithDuration:self.animationDuration
                              delay:.0f
                            options:UIViewAnimationOptionCurveEaseIn
                         animations:self.presentAnimationsBlock
                         completion:self.presentCompletionBlock];
    }
}

- (void)dismissPopoverAnimated:(BOOL)animated
{
    //
    [UIView animateWithDuration:self.animationDuration
                          delay:.0f
                        options:UIViewAnimationOptionCurveEaseIn
                     animations:self.dismissAnimationsBlock
                     completion:self.dismissCompletionBlock];
}

- (UIBezierPath *)bezierPathForRect:(CGRect)rect
{
    CGFloat radius = self.cornerRadius;
    
    //
    //      b           c
    //  a                   d
    //
    //  h                   e
    //      g           f
    //
    CGPoint a = CGPointMake(rect.origin.x, rect.origin.y + radius);
    CGPoint b = CGPointMake(a.x + radius, a.y - radius);
    CGPoint c = CGPointMake(a.x + rect.size.width - radius, rect.origin.y);
    CGPoint d = CGPointMake(c.x + radius, c.y + radius);
    CGPoint e = CGPointMake(a.x + rect.size.width, rect.origin.y + rect.size.height - radius);
    CGPoint f = CGPointMake(e.x - radius, e.y + radius);
    CGPoint g = CGPointMake(a.x + radius, rect.origin.y + rect.size.height);
    CGPoint h = CGPointMake(g.x - radius, g.y - radius);
    
    //
    CGSize arrowSize = self.arrowSize;
    CGFloat halfArrowWidth = arrowSize.width*.5f;
    CGSize availableHalfRectSize = CGSizeMake((rect.size.width-2*radius)*.5f, (rect.size.height-2*radius)*.5f);
    
    //
    UIBezierPath *bp = [UIBezierPath bezierPath];
    [bp moveToPoint:a];
    [bp addQuadCurveToPoint:b controlPoint:CGPointMake(a.x, a.y - radius)];
    if (self.arrowDirection & FWTAnnotationArrowDirectionUp)
    {
        CGPoint a0 = CGPointMake(b.x + (availableHalfRectSize.width - halfArrowWidth) + self.arrowOffset, b.y);
        CGPoint a1 = CGPointMake(b.x + availableHalfRectSize.width + self.arrowOffset + self.arrowCornerOffset, b.y - arrowSize.height);
        CGPoint a2 = CGPointMake(b.x + (availableHalfRectSize.width + halfArrowWidth) + self.arrowOffset, b.y);
        
        [bp addLineToPoint:a0];
        [bp addLineToPoint:a1];
        [bp addLineToPoint:a2];
    }
    
    [bp addLineToPoint:c];
    [bp addQuadCurveToPoint:d controlPoint:CGPointMake(c.x + radius, c.y)];
    if (self.arrowDirection & FWTAnnotationArrowDirectionRight)
    {
        CGPoint a0 = CGPointMake(d.x, d.y + (availableHalfRectSize.height - halfArrowWidth) + self.arrowOffset);
        CGPoint a1 = CGPointMake(d.x + arrowSize.height, d.y + availableHalfRectSize.height + self.arrowOffset + self.arrowCornerOffset);
        CGPoint a2 = CGPointMake(d.x, d.y + (availableHalfRectSize.height + halfArrowWidth) + self.arrowOffset);
        
        [bp addLineToPoint:a0];
        [bp addLineToPoint:a1];
        [bp addLineToPoint:a2];
    }
    
    [bp addLineToPoint:e];
    [bp addQuadCurveToPoint:f controlPoint:CGPointMake(e.x, e.y + radius)];
    if (self.arrowDirection & FWTAnnotationArrowDirectionDown)
    {
        CGPoint a0 = CGPointMake(f.x - (availableHalfRectSize.width - halfArrowWidth) + self.arrowOffset, f.y);
        CGPoint a1 = CGPointMake(f.x - (availableHalfRectSize.width) + self.arrowOffset + self.arrowCornerOffset, f.y + arrowSize.height);
        CGPoint a2 = CGPointMake(f.x - (availableHalfRectSize.width + halfArrowWidth) + self.arrowOffset, f.y);
        
        [bp addLineToPoint:a0];
        [bp addLineToPoint:a1];
        [bp addLineToPoint:a2];
    }
    
    [bp addLineToPoint:g];
    [bp addQuadCurveToPoint:h controlPoint:CGPointMake(g.x - radius, g.y)];
    if (self.arrowDirection & FWTAnnotationArrowDirectionLeft)
    {
        CGPoint a0 = CGPointMake(h.x, h.y - (availableHalfRectSize.height - halfArrowWidth) + self.arrowOffset);
        CGPoint a1 = CGPointMake(h.x - arrowSize.height, h.y - availableHalfRectSize.height + self.arrowOffset + self.arrowCornerOffset);
        CGPoint a2 = CGPointMake(h.x, h.y - (availableHalfRectSize.height + halfArrowWidth) + self.arrowOffset);
        
        [bp addLineToPoint:a0];
        [bp addLineToPoint:a1];
        [bp addLineToPoint:a2];
    }
    
    [bp closePath];
    
    return bp;
}

- (UIImage *)backgroundImageForSize:(CGSize)size
{
    //
    UIGraphicsBeginImageContextWithOptions(size, NO, .0f);
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    //  join with a rounded end
    CGContextSetLineJoin(ctx, kCGLineJoinRound);
    
    //  fill with a solid to get good shadow - then clear inside
    CGContextSaveGState(ctx);
    CGContextSetFillColorWithColor(ctx, [UIColor blackColor].CGColor);
    CGContextSetShadowWithColor(ctx, self.shadowOffset, self.shadowBlur, self.shadowColor.CGColor);
    CGContextAddPath(ctx, self.bezierPath.CGPath);
    CGContextDrawPath(ctx, kCGPathFill);
    CGContextRestoreGState(ctx);
    CGContextSaveGState(ctx);
    [self.bezierPath addClip];
    [[UIColor clearColor] setFill];
    UIRectFill(CGContextGetClipBoundingBox(ctx));
    CGContextRestoreGState(ctx);
    
    //  fill with the right color now
    CGContextSetFillColorWithColor(ctx, self.bezierPathColorFill.CGColor);
    CGContextAddPath(ctx, self.bezierPath.CGPath);
    CGContextDrawPath(ctx, kCGPathFill);
    
    //
    if (self.drawPathBlock)
        self.drawPathBlock(ctx, self);
    
    //  stroke the border
    CGContextSetStrokeColorWithColor(ctx, self.bezierPathColorStroke.CGColor);
    CGContextSetLineWidth(ctx, self.bezierPathLineWidth);
    CGContextAddPath(ctx, self.bezierPath.CGPath);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    //
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}


@end
