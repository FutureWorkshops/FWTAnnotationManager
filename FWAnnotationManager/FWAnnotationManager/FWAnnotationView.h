//
//  FWPopoverHintView.h
//  FWPopoverHintView
//
//  Created by Marco Meschini on 7/12/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    FWAnnotationArrowDirectionNone = 1UL << 0,
    FWAnnotationArrowDirectionUp = 1UL << 1,
    FWAnnotationArrowDirectionDown = 1UL << 2,
    FWAnnotationArrowDirectionLeft = 1UL << 3,
    FWAnnotationArrowDirectionRight = 1UL << 4,
//    FWAnnotationArrowDirectionAny = FWAnnotationArrowDirectionUp | FWAnnotationArrowDirectionDown | FWAnnotationArrowDirectionLeft | FWAnnotationArrowDirectionRight,
//    FWAnnotationArrowDirectionUnknown = NSUIntegerMax,
};
typedef NSUInteger FWPopoverArrowDirection;

@class FWAnnotationView;
typedef void (^FWAnnotationViewDrawBezierPathBlock)(CGContextRef, FWAnnotationView *);
typedef void (^FWAnnotationViewPrepareToAnimationsBlock)(void);
typedef void (^FWAnnotationViewAnimationsBlock)(void);
typedef void (^FWAnnotationViewCompletionBlock)(BOOL finished);

@interface FWAnnotationView : UIView
{
    UIEdgeInsets _edgeInsets, _desiredEdgeInsets;
    
    CGSize _contentSize;
    
    CGFloat _shadowBlur;
    CGSize _shadowOffset;
    UIColor *_shadowColor;
    
    CGFloat _cornerRadius;
    
    FWPopoverArrowDirection _arrowDirection;
    CGSize _arrowSize;
    CGFloat _arrowOffset;
    CGFloat _arrowCornerOffset;
    
    UIBezierPath *_bezierPath;
    UIColor *_bezierPathColorFill, *_bezierPathColorStroke;
    CGFloat _bezierPathLineWidth;
    
    FWAnnotationViewDrawBezierPathBlock _drawPathBlock;
    FWAnnotationViewPrepareToAnimationsBlock _prepareToAnimationsBlock;
    FWAnnotationViewAnimationsBlock _presentAnimationsBlock, _dismissAnimationsBlock;
    FWAnnotationViewCompletionBlock _presentCompletionBlock, _dismissCompletionBlock;
    
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

@property (nonatomic, readonly) FWPopoverArrowDirection arrowDirection;
@property (nonatomic, assign) CGSize arrowSize;
@property (nonatomic, assign) CGFloat arrowOffset;
@property (nonatomic, assign) CGFloat arrowCornerOffset;

@property (nonatomic, readonly, retain) UIBezierPath *bezierPath;
@property (nonatomic, retain) UIColor *bezierPathColorFill, *bezierPathColorStroke;
@property (nonatomic, assign) CGFloat bezierPathLineWidth;

@property (nonatomic, copy) FWAnnotationViewDrawBezierPathBlock drawPathBlock;
@property (nonatomic, copy) FWAnnotationViewPrepareToAnimationsBlock prepareToAnimationsBlock;
@property (nonatomic, copy) FWAnnotationViewAnimationsBlock presentAnimationsBlock, dismissAnimationsBlock;
@property (nonatomic, copy) FWAnnotationViewCompletionBlock presentCompletionBlock, dismissCompletionBlock;

@property (nonatomic, assign) CGFloat animationDuration;

@property (nonatomic, readonly, retain) UIView *contentView;
@property (nonatomic, assign) UIEdgeInsets contentViewEdgeInsets;

@property (nonatomic, assign) BOOL adjustPositionInSuperviewEnabled;

//
- (void)presentPopoverFromRect:(CGRect)rect
                        inView:(UIView *)view
       permittedArrowDirection:(FWPopoverArrowDirection)arrowDirection
                      animated:(BOOL)animated;

//- (void)presentPopoverFromBarButtonItem:(UIBarButtonItem *)item
//               permittedArrowDirections:(FWPopoverArrowDirection)arrowDirections
//                               animated:(BOOL)animated;

- (void)dismissPopoverAnimated:(BOOL)animated;


//
- (UIBezierPath *)bezierPathForRect:(CGRect)rect;

//
- (UIImage *)backgroundImageForSize:(CGSize)size;

@end
