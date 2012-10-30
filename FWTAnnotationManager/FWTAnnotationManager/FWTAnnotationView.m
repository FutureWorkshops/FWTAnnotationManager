//
//  FWTPopoverHintView.m
//  FWTPopoverHintView
//
//  Created by Marco Meschini on 7/12/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "FWTAnnotationView.h"
#import <QuartzCore/QuartzCore.h>

@interface FWTAnnotationView ()
{
    UIImageView *_backgroundImageView;
}
@property (nonatomic, retain)  UIImageView *backgroundImageView;
@property (nonatomic, readwrite) FWTAnnotationArrowDirection arrowDirection;
@property (nonatomic, readwrite, retain) UIBezierPath *bezierPath;
@property (nonatomic, readwrite, retain) UIView *contentView;
@property (nonatomic, readwrite, retain) FWTAnnotationBackgroundImageHelper *backgroundImageHelper;
@property (nonatomic, readwrite, retain) FWTAnnotationArrow *arrow;

//  Private
- (void)adjustEdgeInsets;
//- (UIImage *)resizableBackgroundImageForSize:(CGSize)size;
- (CGFloat)arrowOffsetForDeltaX:(CGFloat)dX deltaY:(CGFloat)dY direction:(NSInteger)direction;
- (CGPoint)midPointForRect:(CGRect)rect popoverSize:(CGSize)popoverSize arrowDirection:(FWTAnnotationArrowDirection)arrowDirections;

@end

@implementation FWTAnnotationView
@synthesize backgroundImageView = _backgroundImageView;
@synthesize contentView = _contentView;
@synthesize backgroundImageHelper = _backgroundImageHelper;
@synthesize arrow = _arrow;

- (void)dealloc
{
    self.arrow = nil;
    self.backgroundImageHelper = nil;
    self.contentView = nil;
//    self.bezierPathColorStroke = nil;
//    self.bezierPathColorFill = nil;
//    self.shadowColor = nil;
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

        //
        self.arrowDirection = FWTAnnotationArrowDirectionUp;
        
        //
        self.adjustPositionInSuperviewEnabled = YES;
        
        
        self.prepareToAnimationsBlock = ^{ self.alpha = .0f; };
        self.presentAnimationsBlock = ^{ self.alpha = 1.0f; };
        self.presentCompletionBlock = NULL;
        self.dismissAnimationsBlock = ^{ self.alpha = .0f; };
        self.dismissCompletionBlock = NULL;
        
        self.animationDuration = .2f;
        
//        self.layer.borderWidth = 1.0f;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //
    if (!self.backgroundImageView.superview)
        [self addSubview:self.backgroundImageView];

    self.backgroundImageView.frame = self.bounds;
    
    //
    if (!self.contentView.superview)
        [self addSubview:self.contentView];
    
    CGRect avalaibleRect = UIEdgeInsetsInsetRect(self.bounds, self.edgeInsets);
    self.contentView.frame = avalaibleRect;
}

#pragma mark - Getters
- (UIImageView *)backgroundImageView
{
    if (!self->_backgroundImageView)
        self->_backgroundImageView = [[UIImageView alloc] init];
    
    self->_backgroundImageView.layer.borderWidth = 1.0f;
    self->_backgroundImageView.layer.borderColor = [UIColor redColor].CGColor;
    
    return self->_backgroundImageView;
}

- (UIView *)contentView
{
    if (!self->_contentView)
        self->_contentView = [[UIView alloc] init];
    
    self->_contentView.layer.borderWidth = 1.0f;
    self->_contentView.layer.borderColor = [UIColor greenColor].CGColor;
    
    return self->_contentView;
}

- (FWTAnnotationBackgroundImageHelper *)backgroundImageHelper
{
    if (!self->_backgroundImageHelper)
        self->_backgroundImageHelper = [[FWTAnnotationBackgroundImageHelper alloc] initWithAnnotationView:self];
    
    return self->_backgroundImageHelper;
}

- (FWTAnnotationArrow *)arrow
{
    if (!self->_arrow)
        self->_arrow = [[FWTAnnotationArrow alloc] init];
    
    return self->_arrow;
}

#pragma mark - Private
- (void)adjustEdgeInsets
{
    UIEdgeInsets currentInsets = self.edgeInsets;
    CGFloat dY = self.arrow.arrowSize.height;
    
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

- (CGFloat)arrowOffsetForDeltaX:(CGFloat)dX deltaY:(CGFloat)dY direction:(NSInteger)direction
{
    //
    CGRect shapeBounds = UIEdgeInsetsInsetRect(self.bounds, self.edgeInsets);
    CGFloat cornerRadius = self.backgroundImageHelper.cornerRadius;
    CGSize availableHalfRectSize = CGSizeMake((shapeBounds.size.width-2*cornerRadius)*.5f, (shapeBounds.size.height-2*cornerRadius)*.5f);
    CGFloat maxArrowOffset = .0f;
    
    CGFloat arrowOffset = .0f;
    if (self.arrowDirection & FWTAnnotationArrowDirectionUp || self.arrowDirection & FWTAnnotationArrowDirectionDown)
    {
        arrowOffset = direction*dX;
        maxArrowOffset = availableHalfRectSize.width - cornerRadius;
    }
    
    if (self.arrowDirection & FWTAnnotationArrowDirectionLeft || self.arrowDirection & FWTAnnotationArrowDirectionRight)
    {
        arrowOffset = direction*dY;
        maxArrowOffset = availableHalfRectSize.height - cornerRadius;
    }
    
    if (abs(arrowOffset) > maxArrowOffset)
        arrowOffset = (arrowOffset > 0) ? maxArrowOffset : -maxArrowOffset;
    
    return arrowOffset;
}

- (CGPoint)midPointForRect:(CGRect)rect popoverSize:(CGSize)popoverSize arrowDirection:(FWTAnnotationArrowDirection)arrowDirections
{
    CGPoint midPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    if (self.arrowDirection & FWTAnnotationArrowDirectionUp)
        midPoint.x -= (popoverSize.width * .5f + self.arrow.arrowCornerOffset);
    
    if (self.arrowDirection & FWTAnnotationArrowDirectionDown)
    {
        midPoint.x -= (popoverSize.width * .5f + self.arrow.arrowCornerOffset);
        midPoint.y -= popoverSize.height;
    }
    
    if (self.arrowDirection & FWTAnnotationArrowDirectionLeft)
        midPoint.y -= (popoverSize.height * .5f + self.arrow.arrowCornerOffset);
    
    if (self.arrowDirection & FWTAnnotationArrowDirectionRight)
    {
        midPoint.x -= popoverSize.width;
        midPoint.y -= (popoverSize.height * .5f + self.arrow.arrowCornerOffset);
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
        self.arrow.arrowOffset = [self arrowOffsetForDeltaX:dX deltaY:dY direction:direction];
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
    [self adjustAndSetFrame:frame inSuperview:view];
    
    //
    self.backgroundImageView.image = [self.backgroundImageHelper resizableBackgroundImageForSize:self.contentSize];
    
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
                            options:UIViewAnimationCurveEaseIn
                         animations:self.presentAnimationsBlock
                         completion:self.presentCompletionBlock];
    }
}

- (void)dismissPopoverAnimated:(BOOL)animated
{
    //
    [UIView animateWithDuration:self.animationDuration
                          delay:.0f
                        options:UIViewAnimationCurveEaseIn
                     animations:self.dismissAnimationsBlock
                     completion:self.dismissCompletionBlock];
}

@end
