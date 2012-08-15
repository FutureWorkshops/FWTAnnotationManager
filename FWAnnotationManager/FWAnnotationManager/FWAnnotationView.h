//
//  FWPopoverHintView.h
//  FWPopoverHintView
//
//  Created by Marco Meschini on 7/12/12.
//  Copyright (c) 2012 Futureworkshops. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    FWPopoverArrowDirectionNone = 1UL << 0,
    FWPopoverArrowDirectionUp = 1UL << 1,
    FWPopoverArrowDirectionDown = 1UL << 2,
    FWPopoverArrowDirectionLeft = 1UL << 3,
    FWPopoverArrowDirectionRight = 1UL << 4,
//    FWPopoverArrowDirectionAny = FWPopoverArrowDirectionUp | FWPopoverArrowDirectionDown | FWPopoverArrowDirectionLeft | FWPopoverArrowDirectionRight,
//    FWPopoverArrowDirectionUnknown = NSUIntegerMax,
};
typedef NSUInteger FWPopoverArrowDirection;

@class FWAnnotationView;
typedef void (^FWPopoverViewDrawBezierPathBlock)(CGContextRef, FWAnnotationView *);
typedef void (^FWPopoverViewPrepareToAnimationsBlock)(void);
typedef void (^FWPopoverViewAnimationsBlock)(void);
typedef void (^FWPopoverViewCompletionBlock)(BOOL finished);

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
    
    FWPopoverViewDrawBezierPathBlock _drawPathBlock;
    FWPopoverViewPrepareToAnimationsBlock _prepareToAnimationsBlock;
    FWPopoverViewAnimationsBlock _presentAnimationsBlock, _dismissAnimationsBlock;
    FWPopoverViewCompletionBlock _presentCompletionBlock, _dismissCompletionBlock;
    
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

@property (nonatomic, copy) FWPopoverViewDrawBezierPathBlock drawPathBlock;
@property (nonatomic, copy) FWPopoverViewPrepareToAnimationsBlock prepareToAnimationsBlock;
@property (nonatomic, copy) FWPopoverViewAnimationsBlock presentAnimationsBlock, dismissAnimationsBlock;
@property (nonatomic, copy) FWPopoverViewCompletionBlock presentCompletionBlock, dismissCompletionBlock;

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
