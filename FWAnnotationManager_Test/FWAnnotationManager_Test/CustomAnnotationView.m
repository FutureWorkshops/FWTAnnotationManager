//
//  CustomAnnotationView.m
//  FWAnnotationManager_Test
//
//  Created by Marco Meschini on 01/11/2012.
//  Copyright (c) 2012 Marco Meschini. All rights reserved.
//

#import "CustomAnnotationView.h"

@interface FWTPopoverView ()
@property (nonatomic, retain)  UIImageView *backgroundImageView;
@end

@interface CustomAnnotationView ()
@property (nonatomic, retain) UIImageView *ringImageView;
@end

@implementation CustomAnnotationView

- (void)dealloc
{
    self.ringImageView = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        //
        self.contentSize = CGSizeMake(160.0f, 40.0f);
        
        //
        self.arrow.cornerOffset = 10.0f;
        
        //
        self.textLabel.textAlignment = UITextAlignmentCenter;
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.textLabel.numberOfLines = 0;
        self.textLabel.font = [UIFont systemFontOfSize:12.0f];
        self.textLabel.textColor = [UIColor colorWithWhite:.91f alpha:1.0f];
        self.textLabel.shadowOffset = CGSizeMake(.0f, -.7f);
        self.textLabel.shadowColor = [[UIColor blackColor] colorWithAlphaComponent:.5f];
        
        //
        self.backgroundHelper.cornerRadius = 9.0f;
        self.backgroundHelper.drawPathBlock = ^(CGContextRef ctx, FWTPopoverBackgroundHelper *backgroundHelper){
            
            //  clip to current path
            CGContextSaveGState(ctx);
            CGContextAddPath(ctx, backgroundHelper.path);
            CGContextClip(ctx);
            
            //  stroke a thick inner border
            CGRect innerShapeBounds = CGRectInset(backgroundHelper.pathFrame, 2.0f, 2.0f);
            UIBezierPath *innerBezierPath = [backgroundHelper bezierPathForRect:innerShapeBounds];
            CGContextSetStrokeColorWithColor(ctx, [[UIColor whiteColor] colorWithAlphaComponent:.5f].CGColor);
            CGContextSetLineWidth(ctx, 5.0f);
            CGContextSetLineJoin(ctx, kCGLineJoinRound);
            CGContextSetBlendMode(ctx, kCGBlendModeColorDodge);
            CGContextAddPath(ctx, innerBezierPath.CGPath);
            CGContextDrawPath(ctx, kCGPathStroke);
            CGContextRestoreGState(ctx);
        };
        
        //
        self.animationHelper.dismissDuration = .3f;
    }
    
    return self;
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//
//    if (!self.ringImageView.superview)
//        [self insertSubview:self.ringImageView belowSubview:self.backgroundImageView];
//    
//    
//    CGRect arrowRect = [self arrowRect];
//    arrowRect = [self convertRect:arrowRect fromView:self.superview];
//    
//    if (self.arrow.direction & FWTPopoverArrowDirectionUp)
//    {
//        arrowRect = CGRectOffset(arrowRect, self.arrow.cornerOffset, -self.arrow.size.height*.5f);
//    }
//    else if (self.arrow.direction & FWTPopoverArrowDirectionDown)
//    {
//        arrowRect = CGRectOffset(arrowRect, self.arrow.cornerOffset, self.arrow.size.height*.5f);
//    }
//    else if (self.arrow.direction & FWTPopoverArrowDirectionLeft)
//    {
//        arrowRect = CGRectOffset(arrowRect, -self.arrow.size.width*.5f, self.arrow.cornerOffset);
//    }
//    else if (self.arrow.direction & FWTPopoverArrowDirectionRight)
//    {
//        arrowRect = CGRectOffset(arrowRect, self.arrow.size.width*.5f, self.arrow.cornerOffset);
//    }
//    else if (self.arrow.direction & FWTPopoverArrowDirectionNone)
//    {
//        arrowRect = CGRectZero;
//    }
//
//    CGRect ringRect = arrowRect;
//    ringRect.size = CGSizeMake(50.0f, 50.0f);
//    ringRect.origin.x -= (ringRect.size.width - arrowRect.size.width)*.5f;
//    ringRect.origin.y -= (ringRect.size.height - arrowRect.size.height)*.5f;
////    self.ringImageView.layer.cornerRadius = ringRect.size.width*.5f;
//    
//    self.ringImageView.frame = ringRect;
//}
//
//- (UIImageView *)ringImageView
//{
//    if (!self->_ringImageView) self->_ringImageView = [[UIImageView alloc] initWithImage:[[self class] ringImage]];    
//    return self->_ringImageView;
//}

- (void)setupAnimationHelperWithSuperview:(UIView *)theSuperview
{
    __block typeof(self) myself = self;
    self.animationHelper.prepareBlock = ^{
        myself.frame = CGRectOffset(myself.frame, .0f, -theSuperview.frame.size.height);
    };
    
    self.animationHelper.presentAnimationsBlock = ^{
        myself.frame = CGRectOffset(myself.frame, .0f, theSuperview.frame.size.height);// + 5.0f);
    };
    
//    self.animationHelper.presentCompletionBlock = ^(BOOL finished){
//        [UIView animateWithDuration:.1f animations:^{
//            myself.frame = CGRectOffset(myself.frame, .0f, -5.0f);
//        }];
//    };
    
    self.animationHelper.dismissAnimationsBlock = ^{
        myself.transform = ((arc4random()%1000) > 500) ? CGAffineTransformMakeRotation(M_PI*.5f):CGAffineTransformMakeRotation(-M_PI*.5f);
        myself.frame = CGRectOffset(myself.frame, .0f, theSuperview.frame.size.height);
    };
}

+ (UIImage *)ringImage
{
    static UIImage *_ringImage = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGSize ctxSize = CGSizeMake(50.0f, 50.0f);
        CGRect ctxRect = CGRectMake(.0f, .0f, ctxSize.width, ctxSize.height);
        UIGraphicsBeginImageContextWithOptions(ctxSize, NO, .0f);
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGRect availableRect = CGRectInset(ctxRect, 4, 4);
        [[UIColor whiteColor] setStroke];
        [[[UIColor whiteColor] colorWithAlphaComponent:.2f] setFill];
        
        
        UIBezierPath *bp = [UIBezierPath bezierPathWithOvalInRect:availableRect];
        bp.lineWidth = 3.0f;
        [bp fill];
        
        CGContextSetShadowWithColor(ctx, CGSizeZero, 2.0f, [UIColor blackColor].CGColor);
        [bp stroke];
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        _ringImage = [image retain];
    });
    
    return _ringImage;
}

@end
