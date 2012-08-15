//
//  FWTPopoverHintView.h
//  FWTPopoverHintView
//
//  Created by Marco Meschini on 7/12/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    FWTAnnotationArrowDirectionNone = 1UL << 0,
    FWTAnnotationArrowDirectionUp = 1UL << 1,
    FWTAnnotationArrowDirectionDown = 1UL << 2,
    FWTAnnotationArrowDirectionLeft = 1UL << 3,
    FWTAnnotationArrowDirectionRight = 1UL << 4,
//    FWTAnnotationArrowDirectionAny = FWTAnnotationArrowDirectionUp | FWTAnnotationArrowDirectionDown | FWTAnnotationArrowDirectionLeft | FWTAnnotationArrowDirectionRight,
//    FWTAnnotationArrowDirectionUnknown = NSUIntegerMax,
};
typedef NSUInteger FWTAnnotationArrowDirection;

@class FWTAnnotationView;
typedef void (^FWTAnnotationViewDrawBezierPathBlock)(CGContextRef, FWTAnnotationView *);
typedef void (^FWTAnnotationViewPrepareToAnimationsBlock)(void);
typedef void (^FWTAnnotationViewAnimationsBlock)(void);
typedef void (^FWTAnnotationViewCompletionBlock)(BOOL finished);

@interface FWTAnnotationView : UIView
{
    UIEdgeInsets _edgeInsets, _desiredEdgeInsets;
    
    CGSize _contentSize;
    
    CGFloat _shadowBlur;
    CGSize _shadowOffset;
    UIColor *_shadowColor;
    
    CGFloat _cornerRadius;
    
    FWTAnnotationArrowDirection _arrowDirection;
    CGSize _arrowSize;
    CGFloat _arrowOffset;
    CGFloat _arrowCornerOffset;
    
    UIBezierPath *_bezierPath;
    UIColor *_bezierPathColorFill, *_bezierPathColorStroke;
    CGFloat _bezierPathLineWidth;
    
    FWTAnnotationViewDrawBezierPathBlock _drawPathBlock;
    FWTAnnotationViewPrepareToAnimationsBlock _prepareToAnimationsBlock;
    FWTAnnotationViewAnimationsBlock _presentAnimationsBlock, _dismissAnimationsBlock;
    FWTAnnotationViewCompletionBlock _presentCompletionBlock, _dismissCompletionBlock;
    
    CGFloat _animationDuration;
    
    UIView *_contentView;
    UIEdgeInsets _contentViewEdgeInsets;
    
    BOOL _adjustPositionInSuperviewEnabled;
}

@property (nonatomic, assign) UIEdgeInsets edgeInsets, desiredEdgeInsets;

@property (nonatomic, assign) CGSize contentSize;

@property (nonatomic, assign) CGFloat shadowBlur;
@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, retain) UIColor *shadowColor;

@property (nonatomic, assign) CGFloat cornerRadius;

@property (nonatomic, readonly) FWTAnnotationArrowDirection arrowDirection;
@property (nonatomic, assign) CGSize arrowSize;
@property (nonatomic, assign) CGFloat arrowOffset;
@property (nonatomic, assign) CGFloat arrowCornerOffset;

@property (nonatomic, readonly, retain) UIBezierPath *bezierPath;
@property (nonatomic, retain) UIColor *bezierPathColorFill, *bezierPathColorStroke;
@property (nonatomic, assign) CGFloat bezierPathLineWidth;

@property (nonatomic, copy) FWTAnnotationViewDrawBezierPathBlock drawPathBlock;
@property (nonatomic, copy) FWTAnnotationViewPrepareToAnimationsBlock prepareToAnimationsBlock;
@property (nonatomic, copy) FWTAnnotationViewAnimationsBlock presentAnimationsBlock, dismissAnimationsBlock;
@property (nonatomic, copy) FWTAnnotationViewCompletionBlock presentCompletionBlock, dismissCompletionBlock;

@property (nonatomic, assign) CGFloat animationDuration;

@property (nonatomic, readonly, retain) UIView *contentView;
@property (nonatomic, assign) UIEdgeInsets contentViewEdgeInsets;

@property (nonatomic, assign) BOOL adjustPositionInSuperviewEnabled;

//
- (void)presentAnnotationFromRect:(CGRect)rect
                           inView:(UIView *)view
          permittedArrowDirection:(FWTAnnotationArrowDirection)arrowDirection
                         animated:(BOOL)animated;

//
- (void)dismissPopoverAnimated:(BOOL)animated;

//
- (UIBezierPath *)bezierPathForRect:(CGRect)rect;

//
- (UIImage *)backgroundImageForSize:(CGSize)size;

@end
