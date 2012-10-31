//
//  FWTPopoverHintView.m
//  FWTPopoverHintView
//
//  Created by Marco Meschini on 7/12/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import "FWTAnnotationView.h"
#import <QuartzCore/QuartzCore.h>

@interface FWTAnnotationArrow ()
@property (nonatomic, readwrite, assign) FWTAnnotationArrowDirection direction;
@end

@interface FWTAnnotationView ()

@property (nonatomic, retain)  UIImageView *backgroundImageView;
@property (nonatomic, readwrite, retain) UIView *contentView;
@property (nonatomic, assign) UIEdgeInsets suggestedEdgeInsets, edgeInsets;

//  Private
- (CGFloat)_arrowOffsetForDeltaX:(CGFloat)dX deltaY:(CGFloat)dY direction:(NSInteger)direction;
- (CGPoint)_midPointForRect:(CGRect)rect popoverSize:(CGSize)popoverSize arrowDirection:(FWTAnnotationArrowDirection)arrowDirections;
- (void)_adjustAndSetFrame:(CGRect)frame inSuperview:(UIView *)view;

@end

@implementation FWTAnnotationView
@synthesize backgroundImageView = _backgroundImageView;
@synthesize contentView = _contentView;
@synthesize arrow = _arrow;
@synthesize backgroundHelper = _backgroundHelper;

- (void)dealloc
{
    self.arrow = nil;
    self.backgroundHelper = nil;
    self.contentView = nil;
    
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
        //
        self.suggestedEdgeInsets = UIEdgeInsetsMake(10.0f, 10.0f, 10.0f, 10.0f);
        self.contentSize = CGSizeZero;
        self.adjustPositionInSuperviewEnabled = YES;
        
        //
        self.prepareToAnimationsBlock = ^{ self.alpha = .0f; };
        self.presentAnimationsBlock = ^{ self.alpha = 1.0f; };
        self.presentCompletionBlock = NULL;
        self.dismissAnimationsBlock = ^{ self.alpha = .0f; };
        self.dismissCompletionBlock = NULL;
        self.animationDuration = .2f;
        
        self.contentView.layer.borderWidth = 1.0f;
        self.contentView.layer.borderColor = [UIColor redColor].CGColor;
        
        self.backgroundImageView.layer.borderWidth = 2.0f;
        
        
        self.layer.borderWidth = 1.0f;
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //
    if (!self.backgroundImageView.superview)
        [self addSubview:self.backgroundImageView];

//    self.backgroundImageView.frame = CGRectMake(.0f, .0f, self.backgroundImageView.image.size.width, self.backgroundImageView.image.size.height);//self.bounds;
    self.backgroundImageView.frame = self.bounds;
    
    //
    if (!self.contentView.superview)
        [self addSubview:self.contentView];
    
    self.contentView.frame = UIEdgeInsetsInsetRect(self.bounds, self.edgeInsets);
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
    
    return self->_contentView;
}

- (FWTAnnotationBackgroundHelper *)backgroundHelper
{
    if (!self->_backgroundHelper)
        self->_backgroundHelper = [[FWTAnnotationBackgroundHelper alloc] initWithAnnotationView:self];
    
    return self->_backgroundHelper;
}

- (FWTAnnotationArrow *)arrow
{
    if (!self->_arrow)
        self->_arrow = [[FWTAnnotationArrow alloc] init];
    
    return self->_arrow;
}

#pragma mark - Private
- (CGFloat)_arrowOffsetForDeltaX:(CGFloat)dX deltaY:(CGFloat)dY direction:(NSInteger)direction
{
    //
    CGRect shapeBounds = UIEdgeInsetsInsetRect(self.bounds, self.edgeInsets);
    CGFloat cornerRadius = self.backgroundHelper.cornerRadius;
    CGSize availableHalfRectSize = CGSizeMake((shapeBounds.size.width-2*cornerRadius)*.5f, (shapeBounds.size.height-2*cornerRadius)*.5f);
    CGFloat maxArrowOffset = .0f;
    
    CGFloat arrowOffset = .0f;
    if (self.arrow.direction & FWTAnnotationArrowDirectionUp || self.arrow.direction & FWTAnnotationArrowDirectionDown)
    {
        arrowOffset = direction*dX;
        maxArrowOffset = availableHalfRectSize.width - cornerRadius;
    }
    
    if (self.arrow.direction & FWTAnnotationArrowDirectionLeft || self.arrow.direction & FWTAnnotationArrowDirectionRight)
    {
        arrowOffset = direction*dY;
        maxArrowOffset = availableHalfRectSize.height - cornerRadius;
    }
    
    if (abs(arrowOffset) > maxArrowOffset)
        arrowOffset = (arrowOffset > 0) ? maxArrowOffset : -maxArrowOffset;
    
    return arrowOffset;
}

- (CGPoint)_midPointForRect:(CGRect)rect popoverSize:(CGSize)popoverSize arrowDirection:(FWTAnnotationArrowDirection)arrowDirections
{
    CGPoint midPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    if (self.arrow.direction & FWTAnnotationArrowDirectionUp)
        midPoint.x -= (popoverSize.width * .5f + self.arrow.cornerOffset);
    
    if (self.arrow.direction & FWTAnnotationArrowDirectionDown)
    {
        midPoint.x -= (popoverSize.width * .5f + self.arrow.cornerOffset);
        midPoint.y -= popoverSize.height;
    }
    
    if (self.arrow.direction & FWTAnnotationArrowDirectionLeft)
        midPoint.y -= (popoverSize.height * .5f + self.arrow.cornerOffset);
    
    if (self.arrow.direction & FWTAnnotationArrowDirectionRight)
    {
        midPoint.x -= popoverSize.width;
        midPoint.y -= (popoverSize.height * .5f + self.arrow.cornerOffset);
    }
    
    if (self.arrow.direction & FWTAnnotationArrowDirectionNone)
    {
        midPoint.x -= popoverSize.width * .5f;
        midPoint.y -= popoverSize.height * .5f;
    }
    
    return midPoint;
}

- (void)_adjustAndSetFrame:(CGRect)frame inSuperview:(UIView *)view
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
        self.arrow.offset = [self _arrowOffsetForDeltaX:dX deltaY:dY direction:direction];
}

#pragma mark - Public
- (void)presentAnnotationFromRect:(CGRect)rect
                           inView:(UIView *)view
          permittedArrowDirection:(FWTAnnotationArrowDirection)arrowDirection
                         animated:(BOOL)animated
{
    //
    self.arrow.direction = arrowDirection;
    
    //
    self.edgeInsets = [self.arrow adjustedEdgeInsetsForEdgeInsets:self.suggestedEdgeInsets];
    
    //
    CGPoint midPoint = [self _midPointForRect:rect popoverSize:self.contentSize arrowDirection:self.arrow.direction];
    CGRect frame = CGRectZero;
    frame.origin = midPoint;
    frame.size = self.contentSize;
    [self _adjustAndSetFrame:frame inSuperview:view];
    
    //
    self.backgroundImageView.image = [self.backgroundHelper resizableBackgroundImageForSize:self.contentSize edgeInsets:self.edgeInsets];
    
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
        if (animated)
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
    if (animated)
        [UIView animateWithDuration:self.animationDuration
                              delay:.0f
                            options:UIViewAnimationCurveEaseIn
                         animations:self.dismissAnimationsBlock
                         completion:self.dismissCompletionBlock];
    else
        [self removeFromSuperview];
}

@end
